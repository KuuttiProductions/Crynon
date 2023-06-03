
import MetalKit

class Camera: Node {
    
    var cameraType: CameraType!
    
    var viewMatrix: matrix_float4x4 {
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.translate(position: -position)
        return viewMatrix
    }
}
