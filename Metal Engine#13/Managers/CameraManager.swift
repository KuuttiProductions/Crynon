
import MetalKit

enum CameraType {
    case FPS
}

class CameraManager {
    var _currentCamera: Camera!
    private var _cameras: [Camera] = []
    
    func addCamera(_ camera: Camera, _ setAsCurrent: Bool = true) {
        _cameras.append(camera)
        if setAsCurrent {
            _currentCamera = camera
        }
    }
}
