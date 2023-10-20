
import MetalKit

class PhysicsManager {
    
    private var _physicsObjects: [RigidBody] = []
    private var _colliders: [Collider] = []
    private var gravity: simd_float3 = simd_float3(0, -9.81, 0)
    
    private var debug_gjkStepCount: Int = 1
    
    func addPhysicsObject(object: RigidBody) {
        _physicsObjects.append(object)
    }
    
    func step(deltaTime: Float) {
        for object in _physicsObjects {
            if object.isActive {
                object.isColliding = false
                object.forceAccumulator += object.mass * gravity
                
                object.linearVelocity += object.invMass * (object.forceAccumulator * deltaTime)
                object.angularVelocity += object.globalInvInertiaTensor * (object.torqueAccumulator * deltaTime)
                
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
                
                if checkForAABBCollision(object1: object1, object2: object2) {}
                
                let gjk = GJK(colliderA: object1.colliders[0], colliderB: object2.colliders[0])
                if gjk.overlap {
                    let manifold = generateContactData(colliderA: object1.colliders[0], colliderB: object2.colliders[0], simplex: gjk.simplex)
                    object1.isColliding = true
                    object2.isColliding = true
                    object2.addPos(manifold.contactNormal * manifold.depth * 0.5, teleport: false)
                    object1.addPos(manifold.contactNormal * manifold.depth * -0.5, teleport: false)
                    Debug.pointAndLine.point2 = manifold.contactNormal
                } else { object1.debug_simplex = [] }
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
                dir = normalize(cross(cross(vAb, vAo), vAb))
                return false
            case 3:
                let a: simd_float3 = simplex[2]
                let b: simd_float3 = simplex[1]
                let c: simd_float3 = simplex[0]
                let vAb = normalize(b - a)
                let vAc = normalize(c - a)
                let vAo = normalize(-a)
    
                var normal = normalize(cross(vAb, vAc))
                if dot(normal, vAo) < 0 { normal *= -1 }
                
                dir = normal
                return false
            case 4:
                let a: simd_float3 = simplex[3]
                let b: simd_float3 = simplex[2]
                let c: simd_float3 = simplex[1]
                let d: simd_float3 = simplex[0]
                
                let ab: simd_float3 = normalize(b - a)
                let ac: simd_float3 = normalize(c - a)
                let ad: simd_float3 = normalize(d - a)
                let vAo = normalize(-a)

                if dot(cross(ac, ab), vAo) > 0 {
                    dir = normalize(cross(ac, ab))
                    simplex.remove(at: 0)
                    return false
                } else if dot(cross(ab, ad), vAo) > 0 {
                    dir = normalize(cross(ab, ad))
                    simplex.remove(at: 1)
                    return false
                } else if dot(cross(ad, ac), vAo) > 0 {
                    dir = normalize(cross(ad, ac))
                    simplex.remove(at: 2)
                    return false
                }
                return true
            default:
                fatalError("Simplex in more than 3 dimensions!")
            }
        }
        
        let initialDirection = colliderB.body.globalCenterOfMass - colliderA.body.globalCenterOfMass
        let initialPoint = csoSupport(direction: initialDirection, colliderA: colliderA, colliderB: colliderB).support
        simplex.append(initialPoint)
        
        var dir = normalize(-simplex[0])
        
        for _ in 0...99 {
            let support = csoSupport(direction: dir, colliderA: colliderA, colliderB: colliderB).support
            if dot(normalize(support), dir) < 0 {
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
    
    func generateContactData(colliderA: Collider, colliderB: Collider, simplex: [simd_float3])-> CollisionData {
        var contactData = CollisionData()
        
        epa()
        generateTangents()
        
        func generateTangents() {
            let normal = contactData.contactNormal!
            if normal.x >= 0.57735 {
                contactData.contactTangentA = simd_float3(normal.y, -normal.x, 0.0)
            } else {
                contactData.contactTangentA = simd_float3(0.0, normal.z, -normal.y)
            }
            contactData.contactTangentA = normalize(contactData.contactTangentA)
            contactData.contactTangentB = cross(normal, contactData.contactTangentA)
        }
        
        func getFaceNormals(vertices: [simd_float3], triangles: [Int])-> (normals: [simd_float3], distances: [Float], minTriangle: Int) {
            var normals: [simd_float3] = []
            var distances: [Float] = []
            var minTriangle: Int = 0
            var minDistance: Float = .infinity
            
            for i in stride(from: 0, to: triangles.count, by: 3) {
                let a = vertices[triangles[i  ]]
                let b = vertices[triangles[i+1]]
                let c = vertices[triangles[i+2]]
                
                var normal: simd_float3 = normalize(cross(b-a, c-a))
                var distance = dot(a, normal)
                
                if dot(normal, a) < 0 {
                    normal *= -1
                    distance *= -1
                }
                
                normals.append(normal)
                distances.append(distance)
                
                if distance < minDistance {
                    minDistance = distance
                    minTriangle = i / 3
                }
            }
            return (normals, distances, minTriangle)
        }
        
        //If reverse of edge already exists, remove it. Else append new edge to list and return it.
        func addIfUniqueEdge(edges: [simd_int2], triangles: [Int], a: Int, b: Int)-> [simd_int2] {
            var edges = edges
             let reverse = simd_int2(Int32(triangles[b]), Int32(triangles[a]))
        
            if edges.contains(reverse) {
                edges.remove(at: edges.firstIndex(where: {$0 == reverse})!)
            } else {
                edges.append(simd_int2(Int32(triangles[a]), Int32(triangles[b])))
            }
            return edges
        }
        
        func epa() {
            var vertices: [simd_float3] = simplex
            
            let v30 = vertices[0] - vertices[3]
            let v31 = vertices[1] - vertices[3]
            let v32 = vertices[2] - vertices[3]
            let determinant = dot(v30, cross(v31, v32))
            if determinant > 0 { // 3, 2, 1, 0 -> 0, 1, 2, 3
                vertices.swapAt(3, 0)
                vertices.swapAt(2, 1)
            }
            
            var triangles: [Int] = [
                0, 1, 2,
                0, 3, 1,
                0, 2, 3,
                1, 3, 2
            ]
            
            let gfn = getFaceNormals(vertices: vertices, triangles: triangles)
            var normals = gfn.normals
            var distances = gfn.distances
            var minTriangle = gfn.minTriangle
            
            var minNormal: simd_float3!
            var minDistance: Float = Float.infinity
            
            var support: simd_float3!
            var supportA: simd_float3!
            var supportB: simd_float3!
            
            while(minDistance == Float.infinity) {
                minNormal = normals[minTriangle]
                minDistance = distances[minTriangle]
                
                //Find new support point in the direction of the closest triangles normal
                let csoSupport = csoSupport(direction: minNormal, colliderA: colliderA, colliderB: colliderB)
                support = csoSupport.support
                supportA = csoSupport.supportA
                supportB = csoSupport.supportB
                
                let d: Float = dot(support, minNormal)
                if d - minDistance > 0.00001 { // If new point is closer than the old one
                    minDistance = Float.infinity
                    
                    var uniqueEdges: [simd_int2] = []
                    var i = 0
                    while i < normals.count {
                        let f = i * 3
                        if dot(normals[i], (support - vertices[triangles[f]])) > 0 { // Check if triangle can be seen from support point
                            
                            uniqueEdges = addIfUniqueEdge(edges: uniqueEdges, triangles: triangles, a: f  , b: f+1)
                            uniqueEdges = addIfUniqueEdge(edges: uniqueEdges, triangles: triangles, a: f+1, b: f+2)
                            uniqueEdges = addIfUniqueEdge(edges: uniqueEdges, triangles: triangles, a: f+2, b: f)
                            
                            triangles.remove(at: f + 2)
                            triangles.remove(at: f + 1)
                            triangles.remove(at: f)
                            
                            normals.remove(at: i)
                            distances.remove(at: i)
                            
                            i -= 1
                        }
                        i += 1
                    }
            
                    var newTriangles: [Int] = []
                    for (_, edge) in uniqueEdges.enumerated() {
                        newTriangles.append(Int(edge.x))
                        newTriangles.append(Int(edge.y))
                        newTriangles.append(vertices.count)
                    }
                    
                    vertices.append(support)
                    
                    let ngfn = getFaceNormals(vertices: vertices, triangles: newTriangles)
                    var newMinTriangle = ngfn.minTriangle
                    
                    var oldMinDistance = Float.infinity
                    var oldMinTriangle = 0
                    for (i, d) in distances.enumerated() {
                        if d < oldMinDistance {
                            oldMinDistance = d
                            oldMinTriangle = i
                        }
                    }
                    
                    if oldMinDistance < ngfn.distances[newMinTriangle] {
                        newMinTriangle = oldMinTriangle
                    } else {
                        newMinTriangle = newMinTriangle + normals.count
                    }
                    
                    triangles.append(contentsOf: newTriangles)
                    normals.append(contentsOf: ngfn.normals)
                    distances.append(contentsOf: ngfn.distances)
                    minTriangle = newMinTriangle
                }
            }
            contactData.contactNormal = minNormal
            contactData.contactPointA = supportA
            contactData.contactPointB = supportB
            contactData.depth = minDistance
        }
        
        contactData.localContactPointA = colliderA.body.globalToLocal(point: contactData.contactPointA)
        contactData.localContactPointB = colliderB.body.globalToLocal(point: contactData.contactPointB)
        
        return contactData
    }
}
