
import MetalKit

class Renderer: NSObject {
    override init() {
        Core.initialize(device: MTLCreateSystemDefaultDevice())
    }
}

extension Renderer: MTKViewDelegate {
    
    public static var _currentRenderCommandEncoder: MTLRenderCommandEncoder!
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        SceneManager.tick()
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        let baseRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        baseRenderCommandEncoder?.label = "Base RenderCommandEncoder"
        Renderer._currentRenderCommandEncoder = baseRenderCommandEncoder
        MRM.setRenderCommandEncoder(baseRenderCommandEncoder)
        SceneManager.render()
        baseRenderCommandEncoder?.endEncoding()
    
        MRM.resetAll()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
