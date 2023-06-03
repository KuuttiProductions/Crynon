
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
            print("yes")
        }
    }
    
    func tick(deltaTime: Float) {
        for camera in _cameras {
            camera.tick(deltaTime)
        }
    }
    
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        for camera in _cameras {
            camera.render(renderCommandEncoder)
        }
    }
}
