
import MetalKit

//This is a test class
class Triangle: Node {
    
    var time: Float = 0.0;
    var material: Material = Material()
    
    init() {
        super.init("Triangle")
        self.material.color = simd_float4(0.2, 1.0, 0.1, 1.0)
        self.material.roughness = 0;
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        setRotY(sin(time))
        time += deltaTime
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        MRM.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        MRM.setDepthStencilState(GPLibrary.depthStencilStates[.Less]) //MRM version doesn't work right now!!!
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&material, length: Material.stride, index: 1)
        AssetLibrary.meshes[.Object].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
