
import MetalKit

class Renderer: NSObject {
    
    static var screenWidth: Float!
    static var screenHeight: Float!
    static var aspectRatio: Float { return screenWidth/screenHeight }

    var forwardRenderPassDescriptor = MTLRenderPassDescriptor()
    var shadowRenderPassDescriptor = MTLRenderPassDescriptor()
    
    override init() {
        super.init()
        createShadowRenderPassDescriptor()
        createJitterTexture()
    }
    
    func createJitterTexture() {
        let jitterTextureDescriptor = MTLTextureDescriptor()
        jitterTextureDescriptor.textureType = .type3D
        jitterTextureDescriptor.pixelFormat = .rg8Unorm
        jitterTextureDescriptor.width = 64
        jitterTextureDescriptor.height = 512
        jitterTextureDescriptor.depth = 1
        jitterTextureDescriptor.usage = [ .shaderWrite, .shaderRead ]
    
        let jitterTexture = Core.device.makeTexture(descriptor: jitterTextureDescriptor)
        jitterTexture?.label = "JitterTexture"
        AssetLibrary.textures.addTexture(jitterTexture, key: "JitterTexture")
    }
    
    func createShadowRenderPassDescriptor() {
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.depthFormat,
                                                                              width: 1024,
                                                                              height: 1024,
                                                                              mipmapped: false)
        depthTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        let depthTexture = Core.device.makeTexture(descriptor: depthTextureDescriptor)
        depthTexture?.label = "ShadowMap1"
        AssetLibrary.textures.addTexture(depthTexture, key: "ShadowMap1")
        
        shadowRenderPassDescriptor.depthAttachment.texture = AssetLibrary.textures["ShadowMap1"]
        shadowRenderPassDescriptor.depthAttachment.loadAction = .clear
        shadowRenderPassDescriptor.depthAttachment.storeAction = .store
    }
    
    func createForwardRenderPassDescriptor() {
        let colorTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.pixelFormat,
                                                                              width: Int(Renderer.screenWidth),
                                                                              height: Int(Renderer.screenHeight),
                                                                              mipmapped: false)
        let depthTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.depthFormat,
                                                                              width: Int(Renderer.screenWidth),
                                                                              height: Int(Renderer.screenHeight),
                                                                              mipmapped: false)
        colorTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        let colorTexture = Core.device.makeTexture(descriptor: colorTextureDescriptor)
        colorTexture?.label = "RenderTargetColor"
        AssetLibrary.textures.addTexture(colorTexture, key: "RenderTargetColor")
        
        depthTextureDescriptor.usage = [ .renderTarget ]
        let depthTexture = Core.device.makeTexture(descriptor: depthTextureDescriptor)
        depthTexture?.label = "RenderTargetDepth"
        AssetLibrary.textures.addTexture(depthTexture, key: "RenderTargetDepth")
        
        forwardRenderPassDescriptor.colorAttachments[0].texture = AssetLibrary.textures["RenderTargetColor"]
        forwardRenderPassDescriptor.colorAttachments[0].loadAction = .clear
        forwardRenderPassDescriptor.colorAttachments[0].clearColor = Preferences.clearColor
        forwardRenderPassDescriptor.depthAttachment.texture = AssetLibrary.textures["RenderTargetDepth"]
        forwardRenderPassDescriptor.depthAttachment.loadAction = .clear
    }
    
    func updateScreenSize(view: MTKView) {
        Renderer.screenWidth = Float((view.bounds.width))
        Renderer.screenHeight = Float((view.bounds.height))
        if Renderer.screenWidth > 0 && Renderer.screenHeight > 0 {
            createForwardRenderPassDescriptor()
        }
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        
        //Update scene
        SceneManager.tick(1/Float(Preferences.preferredFPS))
        
        SceneManager.physicsTick(1/Float(Preferences.preferredFPS))
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        
        computePass(commandBuffer: commandBuffer)
        
        shadowRenderPass(commandBuffer: commandBuffer)
        
        forwardRenderPass(commandBuffer: commandBuffer)
        
        finalRenderPass(commandBuffer: commandBuffer, view: view)
    
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    func shadowRenderPass(commandBuffer: MTLCommandBuffer!) {
        let shadowRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: shadowRenderPassDescriptor)
        shadowRenderCommandEncoder?.label = "Shadow RenderCommandEncoder"
        SceneManager.castShadow(shadowRenderCommandEncoder)
        shadowRenderCommandEncoder?.endEncoding()
    }
    
    func forwardRenderPass(commandBuffer: MTLCommandBuffer!) {
        let baseRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: forwardRenderPassDescriptor)
        baseRenderCommandEncoder?.label = "Base RenderCommandEncoder"
        SceneManager.render(baseRenderCommandEncoder)
        baseRenderCommandEncoder?.endEncoding()
    }
    
    func finalRenderPass(commandBuffer: MTLCommandBuffer!, view: MTKView) {
        let finalCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)
        finalCommandEncoder?.label = "Final RenderCommandEncoder"
        finalCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Final])
        finalCommandEncoder?.setFragmentTexture(AssetLibrary.textures["RenderTargetColor"], index: 0)
        finalCommandEncoder?.setFragmentSamplerState(GPLibrary.samplerStates[.Linear], index: 0)
        AssetLibrary.meshes[.Quad].draw(finalCommandEncoder)
        finalCommandEncoder?.endEncoding()
    }
    
    func computePass(commandBuffer: MTLCommandBuffer!) {
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        computeCommandEncoder?.label = "Main ComputeCommandEncoder"
        
        computeCommandEncoder?.setTexture(AssetLibrary.textures["JitterTexture"], index: 0)
        let texture = AssetLibrary.textures["JitterTexture"]!
        computeCommandEncoder?.setComputePipelineState(GPLibrary.computePipelineStates[.Jitter])
        let groupsPerGrid = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
        let threadsPerThreadGroup = MTLSize(width: GPLibrary.computePipelineStates[.Jitter].threadExecutionWidth, height: 1, depth: 1)
        computeCommandEncoder?.dispatchThreadgroups(groupsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        computeCommandEncoder?.endEncoding()
    }
}
