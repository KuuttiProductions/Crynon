
import MetalKit

class Renderer: NSObject {
    
    static var screenWidth: Float!
    static var screenHeight: Float!
    static var aspectRatio: Float { return screenWidth/screenHeight }

    var forwardRenderPassDescriptor = MTLRenderPassDescriptor()
    
    override init() {
        super.init()
        Core.initialize(device: MTLCreateSystemDefaultDevice())
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
        AssetLibrary.textures.addTexture(colorTexture, key: "RenderTargetColor")
        
        depthTextureDescriptor.usage = [ .renderTarget ]
        let depthTexture = Core.device.makeTexture(descriptor: depthTextureDescriptor)
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
        guard let drawable = view.currentDrawable, let currentRenderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        //Update scene
        SceneManager.tick(1/Float(Preferences.preferredFPS))
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        let baseRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: forwardRenderPassDescriptor)
        baseRenderCommandEncoder?.label = "Base RenderCommandEncoder"
        MRM.setRenderCommandEncoder(baseRenderCommandEncoder)
        SceneManager.render(baseRenderCommandEncoder)
        baseRenderCommandEncoder?.endEncoding()
        
        let finalCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        finalCommandEncoder?.label = "Final RenderCommandEncoder"
        MRM.setRenderCommandEncoder(finalCommandEncoder)
        finalCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Final])
        finalCommandEncoder?.setFragmentTexture(AssetLibrary.textures["RenderTargetColor"], index: 0)
        finalCommandEncoder?.setFragmentSamplerState(GPLibrary.samplerStates[.Linear], index: 0)
        AssetLibrary.meshes[.Quad].draw(finalCommandEncoder)
        finalCommandEncoder?.endEncoding()
    
        MRM.resetAll()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
