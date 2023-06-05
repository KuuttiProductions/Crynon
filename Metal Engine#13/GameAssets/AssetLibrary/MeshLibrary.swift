
import MetalKit

enum MeshType {
    case Triangle
}

class MeshLibrary: Library<MeshType, Mesh> {
    
    var library: [MeshType : Mesh] = [:]
    
    override func fillLibrary() {
        library.updateValue(Triangle_Mesh(), forKey: .Triangle)
    }
    
    override subscript(type: MeshType) -> Mesh! {
        return library[type]
    }
}

//Mesh class is for storing vertices and being able to draw them on call.
//Contains vertices and a vertex buffer with other attributes in the future.
class Mesh {
    var vertices: [Vertex]!
    var vertexBuffer: MTLBuffer!
    
    init() {
        createVertices()
        createVertexBuffer()
    }
    
    func createVertices() {}
    
    func createVertexBuffer() {
        vertexBuffer = Core.device.makeBuffer(bytes: vertices, length: Vertex.stride(count: vertices.count))!
        vertexBuffer.label = "MeshBuffer"
    }
    
    func draw(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        MRM.setVertexBuffer(vertexBuffer, 0)
        renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
    }
}

class Triangle_Mesh: Mesh {
    override func createVertices() {
        vertices = [
            Vertex(position: simd_float3(-1, -1, 0), color: simd_float4(1, 0, 0, 1)),
            Vertex(position: simd_float3( 0,  1, 0), color: simd_float4(0, 1, 0, 1)),
            Vertex(position: simd_float3( 1, -1, 0), color: simd_float4(0, 0, 1, 1))
        ]
    }
}

