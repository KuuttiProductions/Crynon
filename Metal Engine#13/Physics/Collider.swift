
import simd

class Collider: Node {
    
    var mesh: MeshType = .Cube
    var aabbSimple: [simd_float3] = []
    var aabbMin: simd_float3 = simd_float3(repeating: 0)
    var aabbMax: simd_float3 = simd_float3(repeating: 0)
    
    override func tick(_ deltaTime: Float) {
        
        var min: simd_float3 = simd_float3(repeating: .infinity)
        var max: simd_float3 = simd_float3(repeating: -.infinity)
        
        for pos in aabbSimple {
            let comparePos = matrix_multiply(self.modelMatrix, simd_float4(pos, 1))
            
            if comparePos.x < min.x {
                min.x = comparePos.x
            }
            if comparePos.x > max.x {
                max.x = comparePos.x
            }

            if comparePos.y < min.y {
                min.y = comparePos.y
            }
            if comparePos.y > max.y {
                max.y = comparePos.y
            }

            if comparePos.z < min.z {
                min.z = comparePos.z
            }
            if comparePos.z > max.z {
                max.z = comparePos.z
            }
        }
        
        aabbMin = min
        aabbMax = max
    }
    
    override init(_ name: String) {
        super.init(name)
        
        let verticePointer = AssetLibrary.meshes[mesh].vertexBuffer.contents()
        var positions: [simd_float3] = []
        
        for i in 0..<AssetLibrary.meshes[mesh].vertexBuffer.length/Vertex.stride {
            let item = verticePointer.load(fromByteOffset: Vertex.stride(count: i), as: Vertex.self).position
            positions.append(item)
        }
        
        var minX: Float = .infinity
        var minY: Float = .infinity
        var minZ: Float = .infinity
        var maxX: Float = -.infinity
        var maxY: Float = -.infinity
        var maxZ: Float = -.infinity
        
        for pos in positions {
            
            if pos.x < minX {
                minX = pos.x
            }
            if pos.x > maxX {
                maxX = pos.x
            }

            if pos.y < minY {
                minY = pos.y
            }
            if pos.y > maxY {
                maxY = pos.y
            }

            if pos.z < minZ {
                minZ = pos.z
            }
            if pos.z > maxZ {
                maxZ = pos.z
            }
        }
        
        aabbSimple = [
            simd_float3(minX, minY, minZ),
            simd_float3(minX, minY, maxZ),
            simd_float3(minX, maxY, minZ),
            simd_float3(minX, maxY, maxZ),
            simd_float3(maxX, maxY, maxZ),
            simd_float3(maxX, maxY, minZ),
            simd_float3(maxX, minY, maxZ),
            simd_float3(maxX, minY, minZ)
        ]
    }
}
