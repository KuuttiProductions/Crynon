
import MetalKit
import GameController

//This is a test class
class Object: Node {
    
    var time: Float = 0.0;
    var material: Material = Material()
    var mesh: MeshType = .Cube
    
    init(mesh: MeshType) {
        super.init("Object")
        self.mesh = mesh
        self.material.color = simd_float4(1.0, 0.3, 0.0, 1.0)
        self.material.metallic = 0.0
        self.material.roughness = 0.5;
    }
    
    override func tick(_ deltaTime: Float) {
        super.tick(deltaTime)
        self.time += deltaTime
    }
    
    func rotate(positive: Bool, deltaTime: Float) {
        self.time += deltaTime
        if positive {
            self.setRotY(self.rotation.y + deltaTime)
        } else {
            self.setRotY(self.rotation.y - deltaTime)
        }
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
        MRM.setRenderPipelineState(GPLibrary.renderPipelineStates[.Basic])
        MRM.setDepthStencilState(GPLibrary.depthStencilStates[.Less]) //MRM version doesn't work right now!!!
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentBytes(&material, length: Material.stride, index: 1)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Casting shadow with \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Shadow])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setCullMode(.back)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.castShadow(renderCommandEncoder)
    }
}
