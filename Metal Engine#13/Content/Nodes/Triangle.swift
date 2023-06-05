
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
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        AssetLibrary.meshes[.Triangle].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
