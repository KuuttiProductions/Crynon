
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
    
    func plainDraw(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
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
    
    func draw(_ renderCommandEncoder: MTLRenderCommandEncoder!, materials: [Material]!) {
        renderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        if submeshes.count > 0 {
            for (i, submesh) in submeshes.enumerated() {
                var material: Material!
                if materials.count > i {
                    material = materials[i]
                }
                let render = submesh.applyMaterial(renderCommandEncoder: renderCommandEncoder, materialOverride: material)
                if !render { continue }
                renderCommandEncoder.drawIndexedPrimitives(type: submesh.primitiveType,
                                                           indexCount: submesh.indexCount,
                                                           indexType: submesh.indexType,
                                                           indexBuffer: submesh.indexBuffer.buffer,
                                                           indexBufferOffset: 0,
                                                           instanceCount: instanceCount)
            }
        } else {
            var shaderMat = materials.count >= 1 ? materials![0] : nil
            var render: Bool = true
            if var material = shaderMat {
                render = applyMaterial(renderCommandEncoder: renderCommandEncoder, material: material)
            }
            if !render { return }
            renderCommandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        }
    }
    
    func applyMaterial(renderCommandEncoder: MTLRenderCommandEncoder, material: Material)-> Bool {
        var mat = material
        if Renderer.currentRenderState == material.renderState && material.visible {
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[material.shader])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[material.shader == .Transparent ? .NoWriteLess : .Less])
            renderCommandEncoder.setFragmentBytes(&mat.shaderMaterial, length: ShaderMaterial.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureNormal], index: 4)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureEmission], index: 5)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureRoughness], index: 6)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureMetallic], index: 7)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureAoRoughMetal], index: 8)
            return true
        } else { return false }
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
    
    private var _material: Material!
    public var material: Material { return _material }
    
    init(_ sub: MTKSubmesh, _ subMDL: MDLSubmesh) {
        self._primitiveType = sub.primitiveType
        self._indexCount = sub.indexCount
        self._indexType = sub.indexType
        self._indexBuffer = sub.indexBuffer
        addMaterial(subMDL)
    }
    
    func addMaterial(_ sub: MDLSubmesh) {
        let mdlMat = sub.material!
        let texLoader = TextureLoader()
        if let property = mdlMat.property(with: .opacity)?.floatValue {
            _material = Material(property > 0.5 ? .gBuffer : .Transparent, mdlMat.name)
        } else { _material = Material(.gBuffer, mdlMat.name) }
        _material.shaderMaterial.color = mdlMat.property(with: .baseColor)!.float4Value
        _material.shaderMaterial.emission = mdlMat.property(with: .emission)!.float4Value
        _material.shaderMaterial.roughness = mdlMat.property(with: .roughness)!.floatValue
        _material.shaderMaterial.metallic = mdlMat.property(with: .metallic)!.floatValue
        _material.shaderMaterial.ior = mdlMat.property(with: .materialIndexOfRefraction)!.floatValue
        _material.textureColor = loadTexture(semantic: .baseColor, material: mdlMat)
        _material.textureNormal = loadTexture(semantic: .tangentSpaceNormal, material: mdlMat)
        _material.textureEmission = loadTexture(semantic: .emission, material: mdlMat)
        _material.textureMetallic = loadTexture(semantic: .metallic, material: mdlMat)
        _material.textureRoughness = loadTexture(semantic: .roughness, material: mdlMat)
        _material.textureAoRoughMetal = loadTexture(semantic: .ambientOcclusion, material: mdlMat)
        _material.visible = true
    }
    
    private func loadTexture(semantic: MDLMaterialSemantic, material: MDLMaterial)-> String {
        guard let property = material.property(with: semantic) else { return "" }
        guard let sourceTexture = property.textureSamplerValue?.texture else { return "" }
        return AssetLibrary.textures.addTextureMDL(sourceTexture)
    }
    
    func applyMaterial(renderCommandEncoder: MTLRenderCommandEncoder, materialOverride: Material!)-> Bool {
        var applyMat = materialOverride != nil ? materialOverride! : _material!
        if applyMat.renderState == Renderer.currentRenderState && applyMat.visible {
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[applyMat.shader])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[applyMat.depthStencil])
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureColor], index: 3)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureNormal], index: 4)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureEmission], index: 5)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureRoughness], index: 6)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureMetallic], index: 7)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[applyMat.textureAoRoughMetal], index: 8)
            renderCommandEncoder.setFragmentBytes(&applyMat.shaderMaterial, length: ShaderMaterial.stride, index: 1)
            return true
        } else {
            return false
        }
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

