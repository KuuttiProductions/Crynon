
import MetalKit

class DirectionalLight: Light {
    
    override var shadows: Bool { true }
    
    init() {
        super.init("DirectionalLight")
    }
    
    override var projectionMatrix: matrix_float4x4 {
        matrix_float4x4.orthographic(left: -10, right: 10, bottom: -10, top: 10, near: -10, far: 10)
    }
}
