
import MetalKit

enum VertexDescriptorType {
    case Basic
    case PointAndLine
    case Simple
}

class VertexDescriptorLibrary: Library<VertexDescriptorType, MTLVertexDescriptor> {
    
    var library: [VertexDescriptorType : VertexDescriptor] = [:]
    
    override func fillLibrary() {
        library.updateValue(Basic_VertexDescriptor(), forKey: .Basic)
        library.updateValue(PointAndLine_VertexDescriptor(), forKey: .PointAndLine)
        library.updateValue(Simple_VertexDescriptor(), forKey: .Simple)
    }
    
    override subscript(type: VertexDescriptorType) -> MTLVertexDescriptor! {
        return library[type]?.descriptor
    }
}

class VertexDescriptor {
    var descriptor: MTLVertexDescriptor!
}

class Basic_VertexDescriptor: VertexDescriptor {
    override init() {
        super.init()
        descriptor = MTLVertexDescriptor()
        
        var totalOffset = 0
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = totalOffset
        totalOffset += simd_float3.stride
        
        descriptor.attributes[1].format = .float4
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = totalOffset
        totalOffset += simd_float4.stride
        
        descriptor.attributes[2].format = .float2
        descriptor.attributes[2].bufferIndex = 0
        descriptor.attributes[2].offset = totalOffset
        totalOffset += simd_float3.stride
        
        descriptor.attributes[3].format = .float3
        descriptor.attributes[3].bufferIndex = 0
        descriptor.attributes[3].offset = totalOffset
        totalOffset += simd_float3.stride
        
        descriptor.attributes[4].format = .float3
        descriptor.attributes[4].bufferIndex = 0
        descriptor.attributes[4].offset = totalOffset
        totalOffset += simd_float3.stride
        
        descriptor.layouts[0].stride = Vertex.stride
    }
}

class PointAndLine_VertexDescriptor: VertexDescriptor {
    override init() {
        super.init()
        descriptor = MTLVertexDescriptor()
        
        var totalOffset = 0
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = totalOffset
        totalOffset += simd_float3.stride
        
        descriptor.attributes[1].format = .float
        descriptor.attributes[1].bufferIndex = 0
        descriptor.attributes[1].offset = totalOffset
        totalOffset += Float.stride
        
        descriptor.layouts[0].stride = PointVertex.stride
    }
}

class Simple_VertexDescriptor: VertexDescriptor {
    override init() {
        super.init()
        descriptor = MTLVertexDescriptor()
        
        descriptor.attributes[0].format = .float3
        descriptor.attributes[0].bufferIndex = 0
        descriptor.attributes[0].offset = 0
        
        descriptor.layouts[0].stride = simd_float3.stride
    }
}