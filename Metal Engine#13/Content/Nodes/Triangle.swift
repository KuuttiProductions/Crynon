
import MetalKit

//This is a test class
class Triangle: Node {
    
    let mesh = Triangle_Mesh()
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
        mesh.draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
}
