
import MetalKit

class TestObject: GameObject {
    
    init() {
        super.init("TestObject")
        self.material.color = simd_float4(1.0, 0.3, 0.0, 1.0)
        self.mesh = .Object
    }
}
