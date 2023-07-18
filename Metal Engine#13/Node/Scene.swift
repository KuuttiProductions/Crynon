
import MetalKit

class Scene: Node {
    
    var cameraManager = CameraManager()
    var lightManager = LightManager()
    var vertexSceneConstant = VertexSceneConstant()
    var fragmentSceneConstant = FragmentSceneConstant()
    
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
        vertexSceneConstant.viewMatrix = cameraManager._currentCamera.projectionMatrix * cameraManager._currentCamera.viewMatrix
        fragmentSceneConstant.cameraPosition = cameraManager._currentCamera.position
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.setVertexBytes(&vertexSceneConstant, length: VertexSceneConstant.stride, index: 2)
        renderCommandEncoder.setFragmentBytes(&fragmentSceneConstant, length: FragmentSceneConstant.stride, index: 2)
        lightManager.passLightData(renderCommandEncoder: renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
