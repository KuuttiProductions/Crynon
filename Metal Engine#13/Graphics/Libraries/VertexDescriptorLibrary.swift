
import MetalKit

enum VertexDescriptorType {
    case Basic
}

class VertexDescriptorLibrary: Library<VertexDescriptorType, MTLVertexDescriptor> {
    
    var library: [VertexDescriptorType : VertexDescriptor] = [:]
    
    override func fillLibrary() {
        library.updateValue(Basic_VertexDescriptor(), forKey: .Basic)
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
        
        descriptor.layouts[0].stride = Vertex.stride
    }
}
