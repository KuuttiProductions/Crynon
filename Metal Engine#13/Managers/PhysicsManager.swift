
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
            object.isColliding = false
            
            object.force += object.mass * gravity
            
            object.linearVelocity += object.force / object.mass * deltaTime
            if object.position.y < 0 {
                object.linearVelocity = simd_float3(0, -(1/deltaTime) * object.position.y, 0)
            }
            object.addPos(object.linearVelocity * deltaTime)
            
            object.force = simd_float3(0, 0, 0)
        }
        
        for i in 0..<_physicsObjects.count {
            for u in i+1..<_physicsObjects.count {
                let object1 = _physicsObjects[i]
                let object2 = _physicsObjects[u]
                
                if checkForAABBCollision(object1: object1, object2: object2) {
                    object2.linearVelocity = simd_float3()
                    object2.force = -gravity
                }
            }
        }
    }
    
    func checkForAABBCollision(object1: RigidBody, object2: RigidBody)-> Bool {
        if object1.aabbMin.y <= object2.aabbMax.y && object1.aabbMax.y >= object2.aabbMin.y {
            if object1.aabbMin.x <= object2.aabbMax.x && object1.aabbMax.x >= object2.aabbMin.x {
                if object1.aabbMin.z <= object2.aabbMax.z && object1.aabbMax.z >= object2.aabbMin.z {
                    object1.isColliding = true
                    object2.isColliding = true
                    return true
                }
            }
        }
        
        return false
    }
    
    func rayCast(origin: simd_float3, end: simd_float3)-> (result: hitResult?, didHit: Bool) {
        var hit: hitResult!
        var didHit: Bool = false
        
        for object in _physicsObjects {
            if object.aabbMax.y >= end.y && object.aabbMin.y <= end.y {
                if object.aabbMax.x >= end.x && object.aabbMin.x <= end.x {
                    if object.aabbMax.z >= end.z && object.aabbMin.z <= end.z {
                        didHit = true
                        hit = hitResult()
                    }
                }
            }
        }
        
        return (hit, didHit)
    }
    
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Rendering Physics Objects")
        for object in _physicsObjects {
            object.modelConstant.modelMatrix = object.modelMatrix
            object.render(renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }
    
    func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        renderCommandEncoder.pushDebugGroup("Casting Shadow on Physics Objects")
        for object in _physicsObjects {
            object.modelConstant.modelMatrix = object.modelMatrix
            object.castShadow(renderCommandEncoder)
        }
        renderCommandEncoder.popDebugGroup()
    }
}
