
import MetalKit

class MetameshObject: GameObject {
    
    init() {
        super.init("Metamesh Object")
        self.material.shaderMaterial.color = simd_float4(1.0, 0.3, 0.0, 1.0)
        self.mesh = .Metamesh
    }
}
