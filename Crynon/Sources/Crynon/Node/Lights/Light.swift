
import MetalKit

open class Light: Node {
    
    public var lightData: LightData = LightData()
    public var fieldOfView: Float = 80
    public var nearPlane: Float = 0.1
    public var farPlane: Float = 1000
    public var shadows: Bool { false }
    public var direction: simd_float3 = simd_float3(0,0,0)

    public override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        lightData.position = self.position
        lightData.direction = direction
    }
    
    var projectionMatrix: matrix_float4x4 {
        return matrix_float4x4.perspective(degreesFov: fieldOfView,
                                           aspectRatio: Renderer.aspectRatio,
                                           near: nearPlane,
                                           far: farPlane)
    }
    
    var viewMatrix: matrix_float4x4 {
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.rotate(direction: rotation.x, axis: .AxisX)
        viewMatrix.rotate(direction: rotation.y, axis: .AxisY)
        viewMatrix.rotate(direction: rotation.z, axis: .AxisZ)
        viewMatrix.translate(position: -position)
        return viewMatrix
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {}
}
