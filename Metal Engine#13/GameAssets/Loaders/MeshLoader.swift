
import MetalKit
import ModelIO

class MeshLoader {

    static func loadNormalMesh(_ name: String, _ extension: String = "obj")-> Mesh {
        let descriptor = MTKModelIOVertexDescriptorFromMetal(GPLibrary.vertexDescriptors[.Basic])
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        let url = Bundle.main.url(forResource: name, withExtension: `extension`)
        let bufferAllocator = MTKMeshBufferAllocator.init(device: Core.device)
        var error: NSError?
        let asset = MDLAsset.init(url: url!,
                                  vertexDescriptor: descriptor,
                                  bufferAllocator: bufferAllocator,
                                  preserveTopology: false,
                                  error: &error)
        
        var mdlMesh: MDLMesh!
        var mtkMesh: MTKMesh!
        var submeshes: [Submesh] = []
        do {
            mdlMesh = try MTKMesh.newMeshes(asset: asset, device: Core.device).modelIOMeshes[0]
            mtkMesh = try MTKMesh.init(mesh: mdlMesh, device: Core.device)
        } catch let error as NSError {
            print(error)
        }
        
        for sub in mtkMesh.submeshes {
            let submesh = Submesh(sub)
            submeshes.append(submesh)
        }
        
        let vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        vertexBuffer.label = "Model MeshBuffer"
        let mesh = Mesh(vertexBuffer, submeshes)
        return mesh
    }
}
