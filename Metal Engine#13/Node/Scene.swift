
import MetalKit

class Scene: Node {
    
    var cameraManager = CameraManager()
    var lightManager = LightManager()
    var sceneConstant = SceneConstant()
    
    func addCamera(_ camera: Camera, _ setAsCurrent: Bool = true) {
        cameraManager.addCamera(camera, setAsCurrent)
    }
    
    func addLight(_ light: Light) {
        lightManager.addLight(light)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        cameraManager.tick(deltaTime: deltaTime)
        lightManager.tick(deltaTime: deltaTime)
        sceneConstant.viewMatrix = cameraManager._currentCamera.projectionMatrix * cameraManager._currentCamera.viewMatrix
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.setVertexBytes(&sceneConstant, length: SceneConstant.stride, index: 2)
        lightManager.passLightData(renderCommandEncoder: renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
