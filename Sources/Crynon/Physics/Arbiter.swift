
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
    var manifold: [Contact] = []
    
    var bodyA: RigidBody
    var bodyB: RigidBody
    
    init(a: RigidBody, b: RigidBody) {
        self.bodyA = a
        self.bodyB = b
        
        let simplex = PhysicsManager.GJK(colliderA: bodyA.colliders[0], colliderB: bodyB.colliders[0])
        if !simplex.overlap { return }
        let collision = PhysicsManager.generateContactData(colliderA: bodyA.colliders[0],
                                                           colliderB: bodyB.colliders[0],
                                                           simplex: simplex.simplex)
        
        manifold.append(collision)
    }
    
    func update(newManifold: [Contact], bodyA: RigidBody, bodyB: RigidBody) {
        
        var mergedContacts: [Contact] = .init(repeating: Contact(), count: manifold.count)
        
        for i in 0..<newManifold.count {
            var cNew = manifold[i]
            var k = -1
            for j in 0..<manifold.count {
                let cOld = manifold[j]
                if cOld.contactNormal == cNew.contactNormal { // this line here!!!!!
                    k = j; break
                }
            }
            
            if k > -1 {
                let cOld = manifold[k]
                if Preferences.physics.accumulateImpulses {
                    cNew.pn = cOld.pn
                    cNew.pt = cOld.pt
                    cNew.pnb = cOld.pnb
                } else {
                    cNew.pn = 0.0
                    cNew.pt = 0.0
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
        
    }
    
    func applyImpulse() {
        
    }
}
