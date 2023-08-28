
import simd

struct hitResult {
    var position: simd_float3
    var normal: simd_float3
    var distance: Float
    
    init(position: simd_float3 = simd_float3(),
         normal: simd_float3 = simd_float3(),
         distance: Float = 0.0) {
        self.position = position
        self.normal = normal
        self.distance = distance
    }
}
