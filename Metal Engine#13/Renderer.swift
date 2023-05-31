
import MetalKit

class Renderer: NSObject {
 
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = Core.commandQueue.makeCommandBuffer()
        let renderCommandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderCommandEncoder?.endEncoding()
        
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
