
import MetalKit

class Renderer: NSObject {
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("Update")
    }
    
    func draw(in view: MTKView) {
        print("Draw")
    }
}
