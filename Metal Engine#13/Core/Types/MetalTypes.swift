
import MetalKit

//Any type that needs MemoryLayout information to be taken off, can be extended with sizeable.
protocol sizeable {}

extension sizeable {
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
    
    static var size: Int {
        return MemoryLayout<Self>.size
    }
    
    static func stride(count: Int) -> Int {
        return MemoryLayout<Self>.stride * count
    }
    
    static func size(count: Int) -> Int {
        return MemoryLayout<Self>.size * count
    }
}

extension Float: sizeable {}
extension Int: sizeable {}
extension UInt: sizeable {}
extension simd_float2: sizeable {}
extension simd_float3: sizeable {}
extension simd_float4: sizeable {}

//Types that are used with Metal
struct Vertex: sizeable {
    var position: simd_float3
    var color: simd_float4
}
