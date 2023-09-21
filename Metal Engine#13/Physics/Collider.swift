
import simd

class Collider {
    var mass: Float!
    var localInertiaTensor: simd_float3x3!
    var localCenterOfMass: simd_float3!
    
    init(_ useDebugValues: Bool = false) {
        if useDebugValues {
            self.mass = 1
            self.localInertiaTensor = simd_float3x3()
            self.localInertiaTensor.columns = (
                simd_float3(1, 0, 0),
                simd_float3(0, 1, 0),
                simd_float3(0, 0, 1)
            )
            self.localCenterOfMass = simd_float3(0, 0, 0)
        }
    }
}
