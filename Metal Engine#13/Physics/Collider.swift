
import simd

class Collider {
    var mass: Float!
    var localInertiaTensor: simd_float3x3!
    var localCenterOfMass: simd_float3!
    
    var body: RigidBody!
    
    var vertices: [simd_float3] = []
    
    init(_ useDebugValues: Int = 0) {
        if useDebugValues == 1 {
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
        } else if useDebugValues == 2 {
            self.mass = 1
            self.localInertiaTensor = simd_float3x3()
            self.localInertiaTensor.columns = (
                simd_float3(1, 0, 0),
                simd_float3(0, 1, 0),
                simd_float3(0, 0, 1)
            )
            self.localCenterOfMass = simd_float3(0, 0, 0)
            
            self.vertices = []
            for _ in 0...499 {
                let direction = simd_float3(Float.random(in: -1...1),
                                            Float.random(in: -1...1),
                                            Float.random(in: -1...1))
                self.vertices.append(normalize(direction))
            }
        }
    }
    
    func support(direction: simd_float3)-> simd_float3 {
        var highest: Float = 0
        var index: Int = 0
        
        for (i, vertex) in vertices.enumerated() {
            let test: Float = dot(vertex, direction)
            if test > highest {
                highest = test
                index = i
            }
        }
        return vertices[index]
    }
}
