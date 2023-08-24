
import MetalKit

class Renderer: NSObject {
    
    static var screenWidth: Float!
    static var screenHeight: Float!
    static var aspectRatio: Float { return screenWidth/screenHeight }
    static var currentBlendMode: BlendMode = .Opaque
    
    private var optimalTileSize: MTLSize = MTLSizeMake(32, 16, 1)

    var shadowRenderPassDescriptor = MTLRenderPassDescriptor()
    var deferredRenderPassDescriptor = MTLRenderPassDescriptor()
    
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
    
    func createGBuffer() {
        let bufferTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: Preferences.pixelFormat,
                                                                              width: Int(Renderer.screenWidth),
                                                                              height: Int(Renderer.screenHeight),
                                                                              mipmapped: false)
        bufferTextureDescriptor.usage = [ .renderTarget, .shaderRead ]
        bufferTextureDescriptor.storageMode = .memoryless
        
        let colorTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        colorTexture?.label = "GBufferColor"

        bufferTextureDescriptor.pixelFormat = Preferences.floatPixelFormat
        let positionTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        positionTexture?.label = "GBufferPosition"
        
        bufferTextureDescriptor.pixelFormat = Preferences.signedPixelFormat
        let normalShadowTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        normalShadowTexture?.label = "GBufferNormalShadow"
        
        bufferTextureDescriptor.pixelFormat = .r32Float
        let depthTexture = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        depthTexture?.label = "GBufferDepth"
        
        bufferTextureDescriptor.pixelFormat = Preferences.pixelFormat
        let metalRoughEmissionIOR = Core.device.makeTexture(descriptor: bufferTextureDescriptor)
        metalRoughEmissionIOR?.label = "GBufferMetalRoughEmissionIOR"
        
        deferredRenderPassDescriptor.colorAttachments[0].clearColor = Preferences.clearColor
        deferredRenderPassDescriptor.colorAttachments[1].clearColor = Preferences.clearColor
        
        deferredRenderPassDescriptor.colorAttachments[1].texture = colorTexture
        deferredRenderPassDescriptor.colorAttachments[2].texture = positionTexture
        deferredRenderPassDescriptor.colorAttachments[3].texture = normalShadowTexture
        deferredRenderPassDescriptor.colorAttachments[4].texture = depthTexture
        deferredRenderPassDescriptor.colorAttachments[5].texture = metalRoughEmissionIOR
        
        let loadAction = Preferences.useSkySphere == true ? MTLLoadAction.dontCare : MTLLoadAction.clear
        deferredRenderPassDescriptor.colorAttachments[0].loadAction = loadAction
        deferredRenderPassDescriptor.colorAttachments[1].loadAction = loadAction
        deferredRenderPassDescriptor.colorAttachments[2].loadAction = loadAction
        deferredRenderPassDescriptor.colorAttachments[3].loadAction = loadAction
        deferredRenderPassDescriptor.colorAttachments[4].loadAction = loadAction
        deferredRenderPassDescriptor.colorAttachments[5].loadAction = loadAction
        
        deferredRenderPassDescriptor.colorAttachments[0].storeAction = .store
        deferredRenderPassDescriptor.colorAttachments[1].storeAction = .dontCare
        deferredRenderPassDescriptor.colorAttachments[2].storeAction = .dontCare
        deferredRenderPassDescriptor.colorAttachments[3].storeAction = .dontCare
        deferredRenderPassDescriptor.colorAttachments[4].storeAction = .dontCare
        deferredRenderPassDescriptor.colorAttachments[5].storeAction = .dontCare
        
        //Sets the depth value to 1, so that default depth is infinity
        deferredRenderPassDescriptor.colorAttachments[4].clearColor = MTLClearColor(red: 1.0, green: 0, blue: 0, alpha: 0)
        
        //Sets the emissive value to 1, so that the sky won't be shaded.
        deferredRenderPassDescriptor.colorAttachments[5].clearColor = MTLClearColor(red: 0, green: 0, blue: 1, alpha: 0)
        
        deferredRenderPassDescriptor.tileWidth = optimalTileSize.width
        deferredRenderPassDescriptor.tileHeight = optimalTileSize.height
        deferredRenderPassDescriptor.imageblockSampleLength = GPLibrary.renderPipelineStates[.InitTransparency].imageblockSampleLength
    }
    
    func updateScreenSize(view: MTKView) {
        Renderer.screenWidth = Float((view.bounds.width))*2
        Renderer.screenHeight = Float((view.bounds.height))*2
        if Renderer.screenWidth > 0 && Renderer.screenHeight > 0 {
            createGBuffer()
        }
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let depthTexture = view.depthStencilTexture else { return }
        deferredRenderPassDescriptor.colorAttachments[0].texture = drawable.texture
        deferredRenderPassDescriptor.depthAttachment.texture = depthTexture

        //Update scene
        SceneManager.tick(1/Float(Preferences.preferredFPS))
        
        SceneManager.physicsTick(1/Float(Preferences.preferredFPS))
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        
        computePass(commandBuffer: commandBuffer)
        
        shadowRenderPass(commandBuffer: commandBuffer)
        
        deferredRenderPass(commandBuffer: commandBuffer)
        
        //finalRenderPass(commandBuffer: commandBuffer, view: view)
    
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }

    func shadowRenderPass(commandBuffer: MTLCommandBuffer!) {
        let shadowRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: shadowRenderPassDescriptor)
        shadowRenderCommandEncoder?.label = "Shadow RenderCommandEncoder"
        SceneManager.castShadow(shadowRenderCommandEncoder)
        shadowRenderCommandEncoder?.endEncoding()
    }
    
    func deferredRenderPass(commandBuffer: MTLCommandBuffer!) {
        let DeferredRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: deferredRenderPassDescriptor)
        DeferredRenderCommandEncoder?.label = "Deferred RenderCommandEncoder"
        
        DeferredRenderCommandEncoder?.pushDebugGroup("Initialize imageblock storage for transparency")
        DeferredRenderCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.InitTransparency])
        DeferredRenderCommandEncoder?.dispatchThreadsPerTile(optimalTileSize)
        DeferredRenderCommandEncoder?.popDebugGroup()

        DeferredRenderCommandEncoder?.pushDebugGroup("GBuffer fill")
        Renderer.currentBlendMode = .Opaque
        SceneManager.render(DeferredRenderCommandEncoder)
        Renderer.currentBlendMode = .Alpha
        SceneManager.render(DeferredRenderCommandEncoder)
        DeferredRenderCommandEncoder?.popDebugGroup()
        
        DeferredRenderCommandEncoder?.pushDebugGroup("Lighting")
        DeferredRenderCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Lighting])
        DeferredRenderCommandEncoder?.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteAlways])
        AssetLibrary.meshes[.Quad].draw(DeferredRenderCommandEncoder)
        DeferredRenderCommandEncoder?.popDebugGroup()
        
        DeferredRenderCommandEncoder?.pushDebugGroup("Blending Transparency")
        DeferredRenderCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.TransparentBlending])
        DeferredRenderCommandEncoder?.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteAlways])
        AssetLibrary.meshes[.Quad].draw(DeferredRenderCommandEncoder)
        DeferredRenderCommandEncoder?.popDebugGroup()
        
        DeferredRenderCommandEncoder?.endEncoding()
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
