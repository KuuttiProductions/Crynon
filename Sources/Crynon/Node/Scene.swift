
import MetalKit

open class Scene: Node {
    
    var cameraManager = CameraManager()
    var lightManager = LightManager()
    var physicsManager = PhysicsManager()
    private var vertexSceneConstant = VertexSceneConstant()
    private var viewMatrix: matrix_float4x4 = matrix_float4x4()
    private var fragmentSceneConstant = FragmentSceneConstant()
    
    public func addCamera(_ camera: Camera, _ setAsCurrent: Bool = true) {
        cameraManager.addCamera(camera, setAsCurrent)
        addChild(camera)
    }
    
    public func addLight(_ light: Light) {
        lightManager.addLight(light)
        addChild(light)
    }
    
    public func addPhysicsObject(_ object: RigidBody) {
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
        fragmentSceneConstant.fogDensity = Preferences.graphics.fogAmount
    }
    
    public override func getScene() -> Scene {
        return self
    }
    
    public override func removeChild(_ uuid: String) {
        super.removeChild(uuid)
        physicsManager.toBeRemoved.append(uuid)
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
        
        lightManager.passShadowLight(renderCommandEncoder: renderCommandEncoder)
        lightManager.passLightData(renderCommandEncoder: renderCommandEncoder)
        
        Renderer.projectionMatrix = vertexSceneConstant.projectionMatrix
        
        super.render(renderCommandEncoder)
    }
    
    func lightingPass(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.setFragmentBytes(&fragmentSceneConstant, length: FragmentSceneConstant.stride, index: 2)
        lightManager.passLightData(renderCommandEncoder: renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Shadow work on \(name!)")
        lightManager.passShadowLight(renderCommandEncoder: renderCommandEncoder)
        super.castShadow(renderCommandEncoder)
    }
}
