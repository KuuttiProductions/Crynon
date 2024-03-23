
import MetalKit
import ModelIO

class MeshLoader {

    func loadNormalMesh(_ name: String, _ extension: String = "obj", engineContent: Bool = false)-> Mesh {
        let descriptor = MTKModelIOVertexDescriptorFromMetal(GPLibrary.vertexDescriptors[.Basic])
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        (descriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeTangent
        
        var url: URL!
        if engineContent {
            url = Bundle.module.url(forResource: name, withExtension: `extension`)
        } else {
            url = Bundle.main.url(forResource: name, withExtension: `extension`)
        }
        let bufferAllocator = MTKMeshBufferAllocator.init(device: Core.device)
        let asset = MDLAsset.init(url: url!,
                                  vertexDescriptor: descriptor,
                                  bufferAllocator: bufferAllocator)
        
        asset.loadTextures()
        
        var mdlMesh: MDLMesh!
        var mtkMesh: MTKMesh!
        var submeshes: [Submesh] = []
        do {
            mdlMesh = try MTKMesh.newMeshes(asset: asset, device: Core.device).modelIOMeshes[0]
            mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
                                    tangentAttributeNamed: MDLVertexAttributeTangent,
                                    bitangentAttributeNamed: MDLVertexAttributeBitangent)
            mtkMesh = try MTKMesh.init(mesh: mdlMesh, device: Core.device)
        } catch let error as NSError {
            print(error)
        }
        
        for (i, sub) in mtkMesh.submeshes.enumerated() {
            let submesh = Submesh(sub, mdlMesh.submeshes![i] as! MDLSubmesh)
            submeshes.append(submesh)
        }
        
        let vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        vertexBuffer.label = "Model MeshBuffer"
        let mesh = Mesh(vertexBuffer, submeshes)
        return mesh
    }
}
