
import MetalKit

class DirectionalLight: Light {
    
    override var shadows: Bool { true }
    
    init() {
        super.init("DirectionalLight")
    }
    
    override var projectionMatrix: matrix_float4x4 {
        matrix_float4x4.orthographic(left: -20, right: 20, bottom: -20, top: 20, near: -20, far: 20)
    }
}
