
import MetalKit

//This is a test class
class Triangle: Node {
    
    var time: Float = 0.0;
    
    init() {
        super.init("Triangle")
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        setPosX(sin(time))
        time += deltaTime
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        MRM.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        MRM.setDepthStencilState(GPLibrary.depthStencilStates[.Less]) //MRM version doesn't work right now!!!
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        AssetLibrary.meshes[.Object].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
