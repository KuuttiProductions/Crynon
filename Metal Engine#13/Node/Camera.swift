
import MetalKit

class Camera: Node {
    
    var cameraType: CameraType!
    var fieldOfView: Float = 70
    var nearPlane: Float = 0.1
    var farPlane: Float = 1000
    
    override init(_ name: String) {
        super.init(name)
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
