
import MetalKit

class DirectionalLight: Light {
    
    override var shadows: Bool { true }
    
    init() {
        super.init("DirectionalLight")
        self.lightData.useDirection = true
    }
    
    override var projectionMatrix: matrix_float4x4 {
        matrix_float4x4.orthographic(left: -10, right: 10, bottom: -10, top: 10, near: -20, far: 10)
    }
    
    override var viewMatrix: matrix_float4x4 {
        matrix_float4x4.lookAt(position: simd_float3(0,0,0), target: self.direction)
    }
}
