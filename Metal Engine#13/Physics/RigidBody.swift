
import MetalKit

class RigidBody: Collider {
    
    //var orientation: simd_float3x3 = simd_float3x3()
    
    var mass: Float = 1
    var force: simd_float3 = simd_float3(0, 0, 0)
    var linearVelocity: simd_float3 = simd_float3(0, 0, 0)
    //var angularVelocity: simd_float3 = simd_float3()
    
    var corners: [Vertex] = [Vertex(), Vertex(), Vertex(), Vertex(),  Vertex(), Vertex(), Vertex(), Vertex(), Vertex()]
    var cornersPro: [Vertex] = [Vertex(), Vertex(), Vertex(), Vertex(),  Vertex(), Vertex(), Vertex(), Vertex()]
    
    override init(_ name: String) {
        super.init(name)
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        
        self.addRotX(deltaTime/5)
        self.addRotY(deltaTime/5)
        self.addRotZ(deltaTime/5)
        
        if InputManager.mouseLeftButton {
            self.force.y += 13
        }
        
        var index = 0
        for point in self.aabbSimple {
            corners[index].position = point
            index += 1
        }
        
        for i in 0..<8 {
            switch i {
            case 0:
                cornersPro[i].position = aabbMin
            case 1:
                cornersPro[i].position = simd_float3(aabbMin.x, aabbMin.y, aabbMax.z)
            case 2:
                cornersPro[i].position = simd_float3(aabbMin.x, aabbMax.y, aabbMin.z)
            case 3:
                cornersPro[i].position = simd_float3(aabbMin.x, aabbMax.y, aabbMax.z)
            case 4:
                cornersPro[i].position = aabbMax
            case 5:
                cornersPro[i].position = simd_float3(aabbMax.x, aabbMax.y, aabbMin.z)
            case 6:
                cornersPro[i].position = simd_float3(aabbMax.x, aabbMin.y, aabbMax.z)
            case 7:
                cornersPro[i].position = simd_float3(aabbMax.x, aabbMin.y, aabbMin.z)
            default:
                continue
            }
        }
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        
        var emptyModelConstant = ModelConstant()
        renderCommandEncoder.setVertexBytes(&emptyModelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setVertexBytes(&cornersPro, length: Vertex.stride(count: cornersPro.count), index: 0)
        renderCommandEncoder.drawPrimitives(type: .lineStrip, vertexStart: 0, vertexCount: cornersPro.count)
        
        renderCommandEncoder.setVertexBytes(&corners, length: Vertex.stride(count: corners.count), index: 0)
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: corners.count)
        
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
