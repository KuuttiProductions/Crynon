
import MetalKit

//Actual core
class Renderer: NSObject {
    
    var s: Mesh!
    
    override init() {
        Core.initialize(device: MTLCreateSystemDefaultDevice())
        s = Triangle_Mesh()
    }
}

//"Renderer"
extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        commandBuffer?.label = "Main CommandBuffer"
        let baseRenderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        baseRenderCommandEncoder?.label = "Base RenderCommandEncoder"
        baseRenderCommandEncoder?.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        s.draw(renderCommandEncoder: baseRenderCommandEncoder)
        baseRenderCommandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
