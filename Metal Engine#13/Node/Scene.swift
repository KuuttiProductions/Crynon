
import MetalKit

class Scene: Node {
    
    var cameraManager = CameraManager()
    var sceneConstant = SceneConstant()
    
    func addCamera(_ camera: Camera, _ setAsCurrent: Bool = true) {
        cameraManager.addCamera(camera, setAsCurrent)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        cameraManager.tick(deltaTime: deltaTime)
        sceneConstant.viewMatrix = cameraManager._currentCamera.viewMatrix
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.setVertexBytes(&sceneConstant, length: SceneConstant.stride, index: 2)
        super.render(renderCommandEncoder)
    }
}
