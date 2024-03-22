
import MetalKit

public class MeshLibrary: Library<String, Mesh> {
    
    private var meshLoader = MeshLoader()
    private var _library: [String : Mesh] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Quad_Mesh(), forKey: "Quad")
        _library.updateValue(meshLoader.loadNormalMesh("Cube", engineContent: true), forKey: "Cube")
        _library.updateValue(meshLoader.loadNormalMesh("Sphere", engineContent: true), forKey: "Sphere")
        _library.updateValue(meshLoader.loadNormalMesh("Metamesh", engineContent: true), forKey: "Metamesh")
        _library.updateValue(meshLoader.loadNormalMesh("Vector", engineContent: true), forKey: "Vector")
    }
    
    public func addMesh(meshName: String) {
        _library.updateValue(meshLoader.loadNormalMesh(meshName, engineContent: false), forKey: meshName)
    }
    
    override subscript(type: String) -> Mesh! {
        return _library[type]
    }
}

//Mesh class is for storing vertices and being able to draw them on call.
//Contains vertices and a vertex buffer with other attributes in the future.
public class Mesh {
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
    
    func draw(_ renderCommandEncoder: MTLRenderCommandEncoder!, materials: [Material]! = []) {
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        if submeshes.count > 0 {
            for (i, submesh) in submeshes.enumerated() {
                if materials.count == 1 {
                    submesh.materialOverride = materials[0]
                } else if materials.count > i {
                    submesh.materialOverride = materials[i]
                }
                submesh.applyMaterial(renderCommandEncoder: renderCommandEncoder)
                renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                           indexCount: submesh.indexCount,
                                                           indexType: submesh.indexType,
                                                           indexBuffer: submesh.indexBuffer.buffer,
                                                           indexBufferOffset: 0,
                                                           instanceCount: instanceCount)
            }
        } else {
            var shaderMat = materials.count >= 1 ? materials![0] : nil
            if var material = shaderMat {
                renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
                renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
                renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureNormal], index: 4)
                renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureEmission], index: 5)
                renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureRoughness], index: 6)
                renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureMetallic], index: 7)
                renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureAoRoughMetal], index: 8)
            }
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
    
    private var _material: Material
    public var material: Material { return _material }
    
    public var materialOverride: Material!
    
    init(_ sub: MTKSubmesh) {
        self._primitiveType = sub.primitiveType
        self._indexCount = sub.indexCount
        self._indexType = sub.indexType
        self._indexBuffer = sub.indexBuffer
        self._material = Material()
    }
    
    func addMaterial(_ sub: MDLMesh) {
        
    }
    
    func applyMaterial(renderCommandEncoder: MTLRenderCommandEncoder) {
        var applyMat = materialOverride != nil ? materialOverride! : _material
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureColor], index: 3)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureNormal], index: 4)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureEmission], index: 5)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureRoughness], index: 6)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureMetallic], index: 7)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureAoRoughMetal], index: 8)
        renderCommandEncoder.setFragmentBytes(&applyMat.shaderMaterial, length: ShaderMaterial.stride, index: 1)
    }
}

class Quad_Mesh: Mesh {
    override func createVertices() {
        vertices = [
            Vertex(position: simd_float3(-1, -1, 0), textureCoordinate: simd_float2(0,1), normal: simd_float3(0, 0, -1)),
            Vertex(position: simd_float3(-1,  1, 0), textureCoordinate: simd_float2(0,0), normal: simd_float3(0, 0, -1)),
            Vertex(position: simd_float3( 1, -1, 0), textureCoordinate: simd_float2(1,1), normal: simd_float3(0, 0, -1)),
            Vertex(position: simd_float3(-1,  1, 0), textureCoordinate: simd_float2(0,0), normal: simd_float3(0, 0, -1)),
            Vertex(position: simd_float3( 1,  1, 0), textureCoordinate: simd_float2(1,0), normal: simd_float3(0, 0, -1)),
            Vertex(position: simd_float3( 1, -1, 0), textureCoordinate: simd_float2(1,1), normal: simd_float3(0, 0, -1))
        ]
    }
}

