
import MetalKit

class PhysicsManager {
    
    private var _physicsObjects: [RigidBody] = []
    private var _colliders: [Collider] = []
    private var gravity: simd_float3 = simd_float3(0, -9.81, 0)
    
    func addPhysicsObject(object: RigidBody) {
        _physicsObjects.append(object)
    }
    
    func step(deltaTime: Float) {
        for object in _physicsObjects {
            object.isColliding = false
            
            if object.isActive {
                object.forceAccumulator += object.mass * gravity
                
                object.linearVelocity += object.invMass * (object.forceAccumulator * deltaTime)
                object.angularVelocity += object.globalInvInertiaTensor * (object.torqueAccumulator * deltaTime)
                if object.position.y < -10 {
                    object.linearVelocity = simd_float3(0, -(1/deltaTime) * object.position.y, 0)
                }
                
                object.globalCenterOfMass += object.linearVelocity * deltaTime
                let axis: simd_float3 = normalize(object.angularVelocity).x.isNaN ? object.angularVelocity : normalize(object.angularVelocity)
                let angle: Float = length(object.angularVelocity) * deltaTime
                object.orientation = matrix_float3x3.rotation(axis: axis, angle: angle) * object.orientation
    
                //object.invOrientation = object.orientation.inverse
                object.updateOrientation()
                object.setRot(simd_float3.rotationFromMatrix(object.orientation))
                object.updatePositionFromGlobalCenterOfMass()
                
                object.forceAccumulator = simd_float3(0, 0, 0)
                object.torqueAccumulator = simd_float3(0, 0, 0)
                
                object.updateInvInertiaTensor()
            }
        }
        
        for i in 0..<_physicsObjects.count {
            for u in i+1..<_physicsObjects.count {
                let object1 = _physicsObjects[i]
                let object2 = _physicsObjects[u]
                
                if checkForAABBCollision(object1: object1, object2: object2) {
                    object2.linearVelocity = simd_float3()
                    object2.forceAccumulator = -gravity
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
    
    func rayCast(origin: simd_float3, end: simd_float3, distance: Float = Float.infinity)-> (result: rayCastResult?, didHit: Bool) {
        var hit: rayCastResult!
        var didHit: Bool = false
        
        let direction = normalize(end - origin)
        
        for object in _physicsObjects {
            let aabbMin = object.aabbMin
            let aabbMax = object.aabbMax
            
            let t1: Float = (aabbMin.x - origin.x) / direction.x
            let t2: Float = (aabbMax.x - origin.x) / direction.x
            let t3: Float = (aabbMin.y - origin.y) / direction.y
            let t4: Float = (aabbMax.y - origin.y) / direction.y
            let t5: Float = (aabbMin.z - origin.z) / direction.z
            let t6: Float = (aabbMax.z - origin.z) / direction.z
 
            let tMin: Float = max(max(min(t1, t2), min(t3, t4)), min(t5, t6))
            let tMax: Float = min(min(max(t1, t2), max(t3, t4)), max(t5, t6))
            
            if tMax < 0 || tMin > tMax {
                continue
            } else {
                if tMin <= distance {
                    didHit = true
                    hit = rayCastResult()
                    hit.distance = tMin
                    hit.node = object
                    hit.position = origin + direction * tMin
                    if t1 == tMin {
                        hit.normal = simd_float3(-1, 0, 0)
                    } else if t2 == tMin {
                        hit.normal = simd_float3(1, 0, 0)
                    } else if t3 == tMin {
                        hit.normal = simd_float3(0, -1, 0)
                    } else if t4 == tMin {
                        hit.normal = simd_float3(0, 1, 0)
                    } else if t5 == tMin {
                        hit.normal = simd_float3(0, 0, -1)
                    } else if t6 == tMin {
                        hit.normal = simd_float3(0, 0, 1)
                    }
                }
            }
        }
        
        return (hit, didHit)
    }
}
