
import MetalKit

class Renderer: NSObject {
    
    var s: test!
    
    override init() {
        Core.initialize(device: MTLCreateSystemDefaultDevice())
        s = test()
    }
}

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
        baseRenderCommandEncoder?.setVertexBuffer(s.vertexBuffer, offset: 0, index: 0)
        baseRenderCommandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: s.vertices.count)
        baseRenderCommandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
