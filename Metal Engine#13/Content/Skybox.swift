
import MetalKit

class Skybox: Node {
    
    var texture: String = ""
    
    override init(_ name: String) {
        super.init(name)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        
    }
}
