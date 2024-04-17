
import simd

public struct rayCastResult {
    var position: simd_float3
    var normal: simd_float3
    var distance: Float
    var node: Node?
    
    init(position: simd_float3 = simd_float3(),
         normal: simd_float3 = simd_float3(),
         distance: Float = 0.0,
         node: RigidBody? = nil
    ) {
        self.position = position
        self.normal = normal
        self.distance = distance
        self.node = node != nil ? node : nil
    }
}

//Generated in the collision detection algorithm
internal struct Contact {
    var position: simd_float3!
    var contactPointA: simd_float3!
    var contactPointB: simd_float3!
    var localContactPointA: simd_float3!
    var localContactPointB: simd_float3!
    
    var contactNormal: simd_float3!
    
    var contactTangentA: simd_float3!
    var contactTangentB: simd_float3!
    
    var depth: Float!
    
    var pn: Float!
    var pt: Float!
    var pnb: Float!
    
    var massNormal: Float!
    var massTangent: Float!
    var bias: Float!
    
    var r1: simd_float3!
    var r2: simd_float3!
}
