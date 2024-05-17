
import simd

struct ArbiterKey: Hashable {    
    var bodyA: String
    var bodyB: String
    
    init(bodyA: RigidBody, bodyB: RigidBody) {
        self.bodyA = bodyA.uuid
        self.bodyB = bodyB.uuid
    }
}

class Arbiter {
    var manifold: [Contact]! = []
    
    var bodyA: RigidBody
    var bodyB: RigidBody
    
    var friction: Float
    
    init(a: RigidBody, b: RigidBody, simplex: [simd_float3]) {
        self.bodyA = a
        self.bodyB = b
    
        let collision = PhysicsManager.generateContactData(colliderA: bodyA.colliders[0],
                                                           colliderB: bodyB.colliders[0],
                                                           simplex: simplex)
        friction = sqrtf(bodyA.friction * bodyB.friction)
        manifold.append(collision)
    }
    
    func update(newManifold: [Contact], bodyA: RigidBody, bodyB: RigidBody) {
        
        var mergedContacts: [Contact] = .init(repeating: Contact(), count: manifold.count)
        
        for i in 0..<newManifold.count {
            var cNew = newManifold[i]
            var k = -1
            for j in 0..<manifold.count {
                let cOld = manifold[j]
                if cOld.contactPointA == cNew.contactPointA {
                    k = j; break
                }
            }
            
            if k > -1 {
                let cOld = manifold[k]
                if Preferences.physics.accumulateImpulses {
                    cNew.pn = cOld.pn
                    cNew.pta = cOld.pta
                    cNew.ptb = cOld.ptb
                    cNew.pnb = cOld.pnb
                } else {
                    cNew.pn = 0.0
                    cNew.pta = 0.0
                    cNew.ptb = 0.0
                    cNew.pnb = 0.0
                }
                mergedContacts[i] = cNew
            } else {
                mergedContacts[i] = cNew
            }
        }
        
        self.manifold = mergedContacts
        
    }
    
    func preStep(deltaTime: Float) {
        let allowedPenetration: Float = 0.01
        let biasFactor: Float = Preferences.physics.positionCorrection ? 0.2 : 0.0
        
        for i in 0..<manifold.count{
            var c = manifold[i]
            
            let r1 = c.position - bodyA.position
            let r2 = c.position - bodyB.position

            // Precompute normal mass
            let rn1 = dot(r1, c.contactNormal)
            let rn2 = dot(r2, c.contactNormal)
            var kNormal = bodyA.invMass + bodyB.invMass
            // TODO: Replace 1.0 with invInertiaTensor!
            kNormal += 1.0 * (dot(r1, r1) - rn1 * rn1)
            kNormal += 1.0 * (dot(r2, r2) - rn2 * rn2)
            c.massNormal = 1.0 / kNormal
            
            // Precompute tangent masses
            var tangent = c.contactTangentA!
            var rt1 = dot(r1, tangent)
            var rt2 = dot(r2, tangent)
            var kTangent = bodyA.invMass + bodyB.invMass
            kTangent += 1.0 * (dot(r1, r1) - rt1 * rt1)
            kTangent += 1.0 * (dot(r2, r2) - rt2 * rt2)
            c.massTangentA = 1.0 / kTangent
            
            tangent = c.contactTangentB!
            rt1 = dot(r1, tangent)
            rt2 = dot(r2, tangent)
            kTangent = bodyA.invMass + bodyB.invMass
            kTangent += 1.0 * (dot(r1, r1) - rt1 * rt1)
            kTangent += 1.0 * (dot(r2, r2) - rt2 * rt2)
            c.massTangentB = 1.0 / kTangent
            
            // Precompute bias
            c.bias = -biasFactor * (1.0 / deltaTime) * min(0.0, -c.depth + allowedPenetration)
            
            manifold[i] = c
            
            if Preferences.physics.accumulateImpulses {
                let p: simd_float3 = c.pn * c.contactNormal * tangent
                
                bodyA.linearVelocity -= bodyA.invMass * p
                bodyA.angularVelocity -= bodyA.invMass * cross(c.r1, p)
                
                bodyB.linearVelocity += bodyB.invMass * p
                bodyB.angularVelocity += bodyB.invMass * cross(c.r2, p)
            }
        }
    }
    
    func applyImpulse() {
        for i in 0..<manifold.count {
            var c = manifold[i]
            
            c.r1 = c.position - bodyA.position
            c.r2 = c.position - bodyB.position
            
            // Relative velocity at contact point
            var dv: simd_float3 = bodyB.linearVelocity + cross(bodyB.angularVelocity, c.r2) - bodyA.linearVelocity + cross(bodyA.angularVelocity, c.r1)

            let vn = dot(dv, c.contactNormal) // Relative velocity along normal
            
            Debug.viewStateCenter.param1 = c.bias
            var dPn: Float = c.massNormal * (-vn + c.bias) // Magnitude of normal impulse
            
            if Preferences.physics.accumulateImpulses {
                // Clamp the accumulated impulse
                let pn0 = c.pn!
                c.pn = max(pn0 + dPn, 0.0)
                dPn = c.pn - pn0
            } else {
                // Clamp the normal impulse
                dPn = max(dPn, 0.0)
            }
            
            // Apply normal/contact impulse
            let pn = dPn * c.contactNormal // Normal impulse
            
            bodyA.linearVelocity -= bodyA.invMass * pn
            //bodyA.angularVelocity -= bodyA.invMass * cross(c.r1, pn)
            
            bodyB.linearVelocity += bodyB.invMass * pn
            //bodyB.angularVelocity += bodyB.invMass * cross(c.r2, pn)
            
            // TANGENT A
            dv = bodyB.linearVelocity + cross(bodyB.angularVelocity, c.r2) - bodyA.linearVelocity + cross(bodyA.angularVelocity, c.r1)
            
            var tangent = c.contactTangentA!
            var vt = dot(dv, tangent) // Relative velocity along tangent
            var dPt = c.massTangentA * -vt
            
            if Preferences.physics.accumulateImpulses {
                let maxPt = friction * c.pn
                
                let pt0 = c.pta!
                c.pta = simd_clamp(pt0 + dPt, -maxPt, maxPt)
                dPt = c.pta - pt0
            } else {
                let maxPt = friction * dPn * 0.2
                dPt = simd_clamp(dPt, -maxPt, maxPt)
            }
            
            var pt = dPt * tangent
            
            bodyA.linearVelocity -= bodyA.invMass * pt
            //bodyA.angularVelocity -= bodyA.invMass * cross(c.r1, pt)
            
            bodyB.linearVelocity += bodyB.invMass * pt
            //bodyB.angularVelocity += bodyB.invMass * cross(c.r2, pt)
            
            // TANGENT B
            dv = bodyB.linearVelocity + cross(bodyB.angularVelocity, c.r2) - bodyA.linearVelocity + cross(bodyA.angularVelocity, c.r1)
        
            tangent = c.contactTangentB!
            vt = dot(dv, tangent) // Relative velocity along tangent
            dPt = c.massTangentB * -vt
            
            if Preferences.physics.accumulateImpulses {
                let maxPt = friction * c.pn
                
                let pt0 = c.ptb!
                c.ptb = simd_clamp(pt0 + dPt, -maxPt, maxPt)
                dPt = c.ptb - pt0
            } else {
                let maxPt = friction * dPn * 0.2
                dPt = simd_clamp(dPt, -maxPt, maxPt)
            }
            
            pt = dPt * tangent
            
            bodyA.linearVelocity -= bodyA.invMass * pt
            //bodyA.angularVelocity -= bodyA.invMass * cross(c.r1, pt)
            
            bodyB.linearVelocity += bodyB.invMass * pt
            //bodyB.angularVelocity += bodyB.invMass * cross(c.r2, pt)
            
            manifold[i] = c
        }
    }
}
