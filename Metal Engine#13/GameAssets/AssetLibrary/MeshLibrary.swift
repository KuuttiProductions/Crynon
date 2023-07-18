
import MetalKit

enum MeshType {
    case Quad
    case Cube
    case Object
}

class MeshLibrary: Library<MeshType, Mesh> {
    
    private var _library: [MeshType : Mesh] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Quad_Mesh(), forKey: .Quad)
        _library.updateValue(MeshLoader.loadNormalMesh("Cube"), forKey: .Cube)
        _library.updateValue(MeshLoader.loadNormalMesh("Object"), forKey: .Object)
    }
    
    override subscript(type: MeshType) -> Mesh! {
        return _library[type]
    }
}

//Mesh class is for storing vertices and being able to draw them on call.
//Contains vertices and a vertex buffer with other attributes in the future.
class Mesh {
    var vertices: [Vertex] = []
    var vertexBuffer: MTLBuffer!
    var submeshes: [Submesh] = []
    var instanceCount: Int = 1
    
    init() {
        createVertices()
        createVertexBuffer()
    }
    
    init(_ vertexBuffer: MTLBuffer, _ submeshes: [Submesh]) {
        self.vertexBuffer = vertexBuffer
        self.submeshes = submeshes
    }

    func createVertices() {}
    
    func createVertexBuffer() {
        vertexBuffer = Core.device.makeBuffer(bytes: vertices, length: Vertex.stride(count: vertices.count))!
        vertexBuffer.label = "Custom MeshBuffer"
    }
    
    func draw(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        MRM.setVertexBuffer(vertexBuffer, 0)
        if submeshes.count > 0 {
            for submesh in submeshes {
                renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                           indexCount: submesh.indexCount,
                                                           indexType: submesh.indexType,
                                                           indexBuffer: submesh.indexBuffer.buffer,
                                                           indexBufferOffset: 0,
                                                           instanceCount: instanceCount)
            }
        } else {
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
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
    
    private var _indexBuffer: MTKMeshBuffer
    public var indexBuffer: MTKMeshBuffer { return _indexBuffer }
    
    init(_ sub: MTKSubmesh) {
        self._primitiveType = sub.primitiveType
        self._indexCount = sub.indexCount
        self._indexType = sub.indexType
        self._indexBuffer = sub.indexBuffer
    }
}

class Quad_Mesh: Mesh {
    override func createVertices() {
        vertices = [
            Vertex(position: simd_float3(-1, -1, 0), textureCoordinate: simd_float2(0,1)),
            Vertex(position: simd_float3(-1,  1, 0), textureCoordinate: simd_float2(0,0)),
            Vertex(position: simd_float3( 1, -1, 0), textureCoordinate: simd_float2(1,1)),
            Vertex(position: simd_float3(-1,  1, 0), textureCoordinate: simd_float2(0,0)),
            Vertex(position: simd_float3( 1,  1, 0), textureCoordinate: simd_float2(1,0)),
            Vertex(position: simd_float3( 1, -1, 0), textureCoordinate: simd_float2(1,1))
        ]
    }
}

