
import MetalKit

class PhysicsManager {
    
    private var _physicsObjects: [RigidBody] = []
    private var gravity: simd_float3 = simd_float3(0, -1.0, 0)
    
    func addPhysicsObject(object: RigidBody) {
        _physicsObjects.append(object)
    }
    
    func step(deltaTime: Float) {
        for object in _physicsObjects {
            object.force += object.mass * gravity
            
            object.linearVelocity += object.force / object.mass * deltaTime
            object.addPos(object.linearVelocity * deltaTime)
            
            object.force = simd_float3(0, 0, 0)
        }
    }
    
    func render(renderCommandEncoder: MTLRenderCommandEncoder) {
        for object in _physicsObjects {
            object.modelConstant.modelMatrix = object.modelMatrix
            object.render(renderCommandEncoder)
        }
    }
}
