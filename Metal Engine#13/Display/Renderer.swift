
import MetalKit

class Renderer: NSObject {
    
    static var screenWidth: Float!
    static var screenHeight: Float!
    static var aspectRatio: Float { return screenWidth/screenHeight }
    
    override init() {
        Core.initialize(device: MTLCreateSystemDefaultDevice())
    }
    
    func updateScreenSize(view: MTKView) {
        Renderer.screenWidth = Float((view.bounds.width))
        Renderer.screenHeight = Float((view.bounds.height))
    }
}

extension Renderer: MTKViewDelegate {
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateScreenSize(view: view)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        SceneManager.tick(1/60)
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        let baseRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        baseRenderCommandEncoder?.label = "Base RenderCommandEncoder"
        MRM.setRenderCommandEncoder(baseRenderCommandEncoder)
        SceneManager.render(baseRenderCommandEncoder)
        baseRenderCommandEncoder?.endEncoding()
    
        MRM.resetAll()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
