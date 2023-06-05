
import MetalKit

enum MeshType {
    case Triangle
    case Cube
}

class MeshLibrary: Library<MeshType, Mesh> {
    
    var library: [MeshType : Mesh] = [:]
    
    override func fillLibrary() {
        library.updateValue(Triangle_Mesh(), forKey: .Triangle)
        library.updateValue(MeshLoader.loadMesh("Cube"), forKey: .Cube)
    }
    
    override subscript(type: MeshType) -> Mesh! {
        return library[type]
    }
}

//Mesh class is for storing vertices and being able to draw them on call.
//Contains vertices and a vertex buffer with other attributes in the future.
class Mesh {
    var vertices: [Vertex] = []
    var vertexBuffer: MTLBuffer!
    var submesh: Submesh!
    var instanceCount: Int = 1
    
    init() {
        createVertices()
        createVertexBuffer()
    }
    
    init(_ vertexBuffer: MTLBuffer, _ submesh: Submesh) {
        self.vertexBuffer = vertexBuffer
        self.submesh = submesh
    }

    func createVertices() {}
    
    func createVertexBuffer() {
        vertexBuffer = Core.device.makeBuffer(bytes: vertices, length: Vertex.stride(count: vertices.count))!
        vertexBuffer.label = "Custom MeshBuffer"
    }
    
    func draw(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        MRM.setVertexBuffer(vertexBuffer, 0)
        if submesh == nil {
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        } else {
            renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                       indexCount: submesh.indexCount,
                                                       indexType: submesh.indexType,
                                                       indexBuffer: submesh.indexBuffer,
                                                       indexBufferOffset: 0,
                                                       instanceCount: instanceCount)
        }
    }
}

class Submesh {
    
    private var _primitiveType: MTLPrimitiveType
    public var primitiveType: MTLPrimitiveType { return _primitiveType}
    
    private var _indexCount: Int
    public var indexCount: Int { return _indexCount }
    
    private var _indexType: MTLIndexType
    public var indexType: MTLIndexType { return _indexType }
    
    private var _indexBuffer: MTLBuffer
    public var indexBuffer: MTLBuffer { return _indexBuffer }
    
    init(_ primitiveType: MTLPrimitiveType, _ indexCount: Int, _ indexType: MTLIndexType, _ indexBuffer: MTLBuffer) {
        self._primitiveType = primitiveType
        self._indexCount = indexCount
        self._indexType = indexType
        self._indexBuffer = indexBuffer
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

