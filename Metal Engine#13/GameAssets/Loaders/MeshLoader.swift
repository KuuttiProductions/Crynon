
import MetalKit
import ModelIO

class MeshLoader {
    
    private static var descriptorLibrary: [VertexDescriptorType : MDLVertexDescriptor] = [:]
    
    init() {
        createVertexDescriptors()
    }
    
    func createVertexDescriptors() {
        let descriptor = MTKModelIOVertexDescriptorFromMetal(GPLibrary.vertexDescriptors[.Basic])
        (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
        (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeColor
        (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
        (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
        
        MeshLoader.descriptorLibrary.updateValue(descriptor, forKey: .Basic)
    }

    static func loadMesh(_ name: String, _ extension: String = "obj")-> Mesh {
        let url = Bundle.main.url(forResource: name, withExtension: `extension`)
        let bufferAllocator = MTKMeshBufferAllocator.init(device: Core.device)
        let asset = MDLAsset.init(url: url!,
                                  vertexDescriptor: descriptorLibrary[.Basic],
                                  bufferAllocator: bufferAllocator)
        
        var mdlMesh: MDLMesh!
        var mtkMesh: MTKMesh!
        var submesh: Submesh!
        do {
            mdlMesh = try MTKMesh.newMeshes(asset: asset, device: Core.device).modelIOMeshes[0]
            mtkMesh = try MTKMesh.init(mesh: mdlMesh, device: Core.device)
        } catch let error as NSError {
            print(error)
        }
        
        for sub in mtkMesh.submeshes {
            submesh = Submesh(sub.primitiveType, sub.indexCount, sub.indexType, sub.indexBuffer.buffer)
        }
        
        let vertexBuffer = mtkMesh.vertexBuffers[0].buffer
        vertexBuffer.label = "Model MeshBuffer"
        let mesh = Mesh(vertexBuffer, submesh)
        return mesh
    }
}
