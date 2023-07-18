
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

//===== Types that are used with Metal =====

struct Vertex: sizeable {
    var position: simd_float3 = simd_float3(0,0,0)
    var color: simd_float4 = simd_float4(0,0,0,0)
    var textureCoordinate: simd_float2 = simd_float2(0,0)
    var normal: simd_float3 = simd_float3(0,0,0)
}

struct ModelConstant: sizeable {
    var modelMatrix = matrix_identity_float4x4
}

struct VertexSceneConstant: sizeable {
    var viewMatrix = matrix_identity_float4x4
}

struct FragmentSceneConstant: sizeable {
    var cameraPosition: simd_float3 = simd_float3(0,0,0)
}

struct LightData: sizeable {
    var brightness: Float = 1.0
    var color: simd_float4 = simd_float4(0,0,0,0)
    var radius: Float = 1.0
    var position: simd_float3 = simd_float3()
}

struct Material: sizeable {
    var color: simd_float4 = simd_float4(1,1,1,1)
    var metallic: Float = 0.0
    var roughness: Float = 0.5
}
