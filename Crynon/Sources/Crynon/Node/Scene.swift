
import MetalKit

open class Scene: Node {
    
    var cameraManager = CameraManager()
    var lightManager = LightManager()
    var physicsManager = PhysicsManager()
    var vertexSceneConstant = VertexSceneConstant()
    var viewMatrix: matrix_float4x4 = matrix_float4x4()
    var fragmentSceneConstant = FragmentSceneConstant()
    
    open func addCamera(_ camera: Camera, _ setAsCurrent: Bool = true) {
        cameraManager.addCamera(camera, setAsCurrent)
        addChild(camera)
    }
    
    open func addLight(_ light: Light) {
        lightManager.addLight(light)
        addChild(light)
    }
    
    open func addPhysicsObject(_ object: RigidBody) {
        physicsManager.addPhysicsObject(object: object)
        addChild(object)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        if cameraManager._currentCamera != nil {
            vertexSceneConstant.viewMatrix = cameraManager._currentCamera.viewMatrix
            vertexSceneConstant.projectionMatrix = cameraManager._currentCamera.projectionMatrix
            fragmentSceneConstant.cameraPosition = cameraManager._currentCamera.position
            viewMatrix = cameraManager._currentCamera.viewMatrix
            viewMatrix[3][0] = 0
            viewMatrix[3][2] = 0
            viewMatrix[3][1] = 0
            viewMatrix = cameraManager._currentCamera.projectionMatrix * viewMatrix
        }
        fragmentSceneConstant.fogDensity = Preferences.fogAmount
    }
    
    override func getScene() -> Scene {
        return self
    }
    
    override func physicsTick(_ deltaTime: Float) {
        super.physicsTick(deltaTime)
        physicsManager.step(deltaTime: deltaTime)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering scene: \(name!)")
        renderCommandEncoder.setVertexBytes(&vertexSceneConstant, length: VertexSceneConstant.stride, index: 2)
        renderCommandEncoder.setFragmentBytes(&fragmentSceneConstant, length: FragmentSceneConstant.stride, index: 2)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures["ShadowMap1"], index: 0)
        renderCommandEncoder.setFragmentSamplerState(GPLibrary.samplerStates[.Linear], index: 0)
        renderCommandEncoder.setVertexBytes(&viewMatrix, length: float4x4.stride, index: 4)
        
        lightManager.passLightData(renderCommandEncoder: renderCommandEncoder)
        lightManager.passShadowLight(renderCommandEncoder: renderCommandEncoder)
        
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Shadow work on \(name!)")
        lightManager.passShadowLight(renderCommandEncoder: renderCommandEncoder)
        super.castShadow(renderCommandEncoder)
    }
}
