
import simd

class Constraint {
    
    var manifold: CollisionData!
    var bodyA: RigidBody
    var bodyB: RigidBody
    var massMatrix: [Float]!
    var jacobian: Float?
    var area: Float?
    var l_acc: Float?
    
    init(a: RigidBody, b: RigidBody) {
        self.bodyA = a
        self.bodyB = b
    }
    
    private func _jacobian(manifold: CollisionData, deltaTime: Float) {
        
    }
    
    func reset() {
        
    }
}
