
import MetalKit

class Spotlight: Light {
    
    init() {
        super.init("Spotlight")
        self.lightData.cutoff = Float(50.deg2rad)
        self.lightData.cutoffInner = Float(45.deg2rad)
        self.self.direction = simd_float3(0, -1, 0)
    }
    
    override var viewMatrix: matrix_float4x4 {
        matrix_float4x4.lookAt(position: self.position, target: self.direction)
    }
}
