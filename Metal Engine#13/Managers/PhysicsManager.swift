
import MetalKit

class PhysicsManager {
    
    private var _physicsObjects: [RigidBody] = []
    private var _colliders: [Collider] = []
    private var gravity: simd_float3 = simd_float3(0, -9.81/3, 0)
    
    func addPhysicsObject(object: RigidBody) {
        _physicsObjects.append(object)
    }
    
    func step(deltaTime: Float) {
        for object in _physicsObjects {
            object.force += object.mass * gravity
            
            object.linearVelocity += object.force / object.mass * deltaTime
            if object.position.y < 0 {
                object.linearVelocity = simd_float3(0, -(1/deltaTime) * object.position.y, 0)
            }
            object.addPos(object.linearVelocity * deltaTime)
            
            object.force = simd_float3(0, 0, 0)
        }
    }
    
    func tick(deltaTime: Float) {
        for object in _physicsObjects {
            object.tick(deltaTime)
        }
    }
    
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Physics Objects")
        for object in _physicsObjects {
            object.modelConstant.modelMatrix = object.modelMatrix
            object.render(renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }
}
