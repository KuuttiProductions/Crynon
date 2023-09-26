
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
                if object.position.y < 0 {
                    object.linearVelocity = simd_float3(0, -(1/deltaTime) * object.position.y, 0)
                }
                
                object.globalCenterOfMass += object.linearVelocity * deltaTime
                let axis: simd_float3 = normalize(object.angularVelocity).x.isNaN ? object.angularVelocity : normalize(object.angularVelocity)
                let angle: Float = length(object.angularVelocity) * deltaTime
                object.orientation = matrix_float3x3.rotation(axis: axis, angle: angle) * object.orientation
    
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
                
//                if checkForAABBCollision(object1: object1, object2: object2) {
//                    object1.isColliding = true
//                    object2.isColliding = true
//                }
                let gjk = GJK(colliderA: object1.colliders[0], colliderB: object2.colliders[0])
                if gjk.overlap {
                    object2.linearVelocity = simd_float3()
                    object2.forceAccumulator = -gravity
                    object1.isColliding = true
                    object2.isColliding = true
                }
            }
        }
    }
    
    func csoSupport(direction: simd_float3,
                    colliderA: Collider,
                    colliderB: Collider)-> (support: simd_float3,
                                            supportA: simd_float3,
                                            supportB: simd_float3) {
        let bodyA: RigidBody = colliderA.body
        let bodyB: RigidBody = colliderB.body
        
        let localDirA = bodyA.globalToLocalDir(dir: direction)
        let localDirB = bodyB.globalToLocalDir(dir: -direction)
        
        var supportA = colliderA.support(direction: localDirA)
        var supportB = colliderB.support(direction: localDirB)
        
        supportA = bodyA.localToGlobal(point: supportA)
        supportB = bodyB.localToGlobal(point: supportB)
        
        return (supportA - supportB, supportA, supportB)
    }
    
    func checkForAABBCollision(object1: RigidBody, object2: RigidBody)-> Bool {
        if object1.aabbMin.y <= object2.aabbMax.y && object1.aabbMax.y >= object2.aabbMin.y {
            if object1.aabbMin.x <= object2.aabbMax.x && object1.aabbMax.x >= object2.aabbMin.x {
                if object1.aabbMin.z <= object2.aabbMax.z && object1.aabbMax.z >= object2.aabbMin.z {
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

extension PhysicsManager {
    func GJK(colliderA: Collider, colliderB: Collider)-> (overlap: Bool, simplex: [simd_float3]) {
        var simplex: [simd_float3] = []
        var result: Bool = false
        
        func handleSimplex()-> Bool {
            switch simplex.count {
            case 2:
                let a: simd_float3 = simplex[1]
                let b: simd_float3 = simplex[0]
                let vAb = b - a
                let vAo = -a
                if distance(a, b) == distance(a, simd_float3(0, 0, 0)) + distance(b, simd_float3(0, 0, 0)) {
                    return true
                }
                dir = normalize(cross(cross(vAb, vAo), vAb))
                return false
            case 3:
                let a: simd_float3 = simplex[2]
                let b: simd_float3 = simplex[1]
                let c: simd_float3 = simplex[0]
                let vAb = b - a
                let vAc = c - a
                let vAo = -a
                let vAbPerp = normalize(cross(cross(vAc, vAb), vAb))
                let vAcPerp = normalize(cross(cross(vAb, vAc), vAc))
                
                var normal = cross(b-a, c-a)
                if dot(normal, vAo) < 0 { normal *= -1 }
                if dot(vAbPerp, vAo) > 0 {
                    dir = normal
                    return false
                } else if dot(vAcPerp, vAo) > 0 {
                    dir = normal
                    return false
                }
                return true
            case 4:
                let a: simd_float3 = simplex[3]
                let b: simd_float3 = simplex[2]
                let c: simd_float3 = simplex[1]
                let d: simd_float3 = simplex[0]
                
                let ab: simd_float3 = b - a
                let ac: simd_float3 = c - a
                let ad: simd_float3 = d - a
                let vAo = -a
                
                if dot(cross(ab, ac), vAo) > 0 {
                    var dir = cross(ab, ac)
                    simplex.remove(at: 0)
                    return false
                } else if dot(cross(ab, ad), vAo) > 0 {
                    dir = cross(ab, ad)
                    simplex.remove(at: 1)
                    return false
                } else if dot(cross(ad, ac), vAo) > 0 {
                    dir = cross(ad, ac)
                    simplex.remove(at: 2)
                    return false
                }
                return true
            default:
                fatalError("Simplex in more than 3 dimensions!")
            }
        }
        
        let initialDirection = normalize(colliderB.body.globalCenterOfMass - colliderA.body.globalCenterOfMass)
        let initialPoint = csoSupport(direction: initialDirection, colliderA: colliderA, colliderB: colliderB).support
        simplex.append(initialPoint)
        
        var dir = normalize(-simplex[0])
        
        for _ in 0...99 {
            let support = csoSupport(direction: dir, colliderA: colliderA, colliderB: colliderB).support
            if dot(support, dir) < 0 {
                break
            }
            simplex.append(support)

            if handleSimplex() {
                result = true
                break
            }
        }
        
        return (result, simplex)
    }
}
