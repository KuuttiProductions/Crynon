
import simd

class Collider {
    var mass: Float!
    var localInertiaTensor: simd_float3x3!
    var localCenterOfMass: simd_float3!
    
    var body: RigidBody!
    var mesh: MeshType!
    
    var vertices: [simd_float3] = []
    
    //Debug value initializer
    init(_ useDebugValues: Int = 0) {
        if useDebugValues == 0 {
            self.mass = 1
            self.localInertiaTensor = simd_float3x3()
            self.localInertiaTensor.columns = (
                simd_float3(1, 0, 0),
                simd_float3(0, 1, 0),
                simd_float3(0, 0, 1)
            )
            self.localCenterOfMass = simd_float3(0, 0, 0)
            
            self.vertices = [
                simd_float3(-10, -1, -10),
                simd_float3(-10,  1,  10),
                simd_float3(-10, -1,  10),
                simd_float3(-10,  1, -10),
                simd_float3( 10, -1, -10),
                simd_float3( 10,  1,  10),
                simd_float3( 10, -1,  10),
                simd_float3( 10,  1, -10),
            ]
        } else if useDebugValues == 1 {
            self.mass = 1
            self.localInertiaTensor = simd_float3x3()
            self.localInertiaTensor.columns = (
                simd_float3(1, 0, 0),
                simd_float3(0, 1, 0),
                simd_float3(0, 0, 1)
            )
            self.localCenterOfMass = simd_float3(0, 0, 0)
            
            self.mesh = .Sphere
            
            let verticePointer = AssetLibrary.meshes[mesh].vertexBuffer.contents()
            for i in 0..<AssetLibrary.meshes[mesh].vertexBuffer.length/Vertex.stride {
                let vertex = verticePointer.load(fromByteOffset: Vertex.stride(count: i), as: Vertex.self).position
                vertices.append(vertex)
            }
        }
    }
    
    init(mesh: MeshType) {
        self.mesh = mesh
        self.mass = 1
        self.localInertiaTensor = simd_float3x3()
        self.localInertiaTensor.columns = (
            simd_float3(1, 0, 0),
            simd_float3(0, 1, 0),
            simd_float3(0, 0, 1)
        )
        self.localCenterOfMass = simd_float3(0, 0, 0)
        
        let verticePointer = AssetLibrary.meshes[mesh].vertexBuffer.contents()
        for i in 0..<AssetLibrary.meshes[mesh].vertexBuffer.length/Vertex.stride {
            let vertex = verticePointer.load(fromByteOffset: Vertex.stride(count: i), as: Vertex.self).position
            vertices.append(vertex)
        }
    }
    
    func support(direction: simd_float3)-> simd_float3 {
        var highest: Float = 0
        var index: Int = 0
        
        for (i, vertex) in vertices.enumerated() {
            let test: Float = dot(vertex * body.scaleMatrix, direction)
            if test > highest {
                highest = test
                index = i
            }
        }
        return vertices[index] * body.scaleMatrix
    }
}
