
import MetalKit

class RigidBody: Node {
    
    //var orientation: simd_float3x3 = simd_float3x3()
    var mesh: MeshType = .Cube
    
    var mass: Float = 1
    var force: simd_float3 = simd_float3(0, 0, 0)
    var linearVelocity: simd_float3 = simd_float3(0, 0, 0)
    //var angularVelocity: simd_float3 = simd_float3()
    
    override init(_ name: String) {
        super.init(name)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
