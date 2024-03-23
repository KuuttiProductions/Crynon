
import MetalKit

open class DirectionalLight: Light {
    
    public override var shadows: Bool { true }
    
    public init() {
        super.init("DirectionalLight")
        self.lightData.useDirection = true
    }
    
    override var projectionMatrix: matrix_float4x4 {
        matrix_float4x4.orthographic(left: -70, right: 20, bottom: -20, top: 20, near: -40, far: 10)
    }
    
    override var viewMatrix: matrix_float4x4 {
        matrix_float4x4.lookAt(position: simd_float3(0,0,0), target: self.direction)
    }
}
