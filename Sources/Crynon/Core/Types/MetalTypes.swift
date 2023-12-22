
import MetalKit

//Any type that needs MemoryLayout information to be checked, can be extended with sizeable.
public protocol sizeable {}

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
extension UInt32: sizeable {}
extension simd_float2: sizeable {}
extension simd_float3: sizeable {}
extension simd_float4: sizeable {}
extension matrix_float4x4: sizeable {}

//===== Types that are used with Metal =====

public struct Vertex: sizeable {
    var position: simd_float3 = simd_float3(0,0,0)
    var color: simd_float4 = simd_float4(0,0,0,0)
    var textureCoordinate: simd_float2 = simd_float2(0,0)
    var normal: simd_float3 = simd_float3(0,0,0)
    var tangent: simd_float3 = simd_float3(0, 0, 0)
}

public struct PointVertex: sizeable {
    var position: simd_float3 = simd_float3(0,0,0)
    var pointSize: Float = 1
}

struct ModelConstant: sizeable {
    var modelMatrix = matrix_identity_float4x4
}

struct VertexSceneConstant: sizeable {
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
}

struct FragmentSceneConstant: sizeable {
    var cameraPosition: simd_float3 = simd_float3(0,0,0)
    var fogDensity: Float = 1.0
}

public struct LightData: sizeable {
    public var brightness: Float = 1.0
    public var color: simd_float4 = simd_float4(1,1,1,1)
    public var position: simd_float3 = simd_float3()
    public var direction: simd_float3 = simd_float3(0,0,0)
    public var useDirection: Bool = false
    public var cutoff: Float = 0.0
    public var cutoffInner: Float = 0.0
}

public struct ShaderMaterial: sizeable {
    public var color: simd_float4 = simd_float4(1,1,1,1)
    public var emission: simd_float4 = simd_float4(0, 0, 0, 0)
    public var roughness: Float = 0.5
    public var metallic: Float = 0.0
    public var ior: Float = 1.45
}
