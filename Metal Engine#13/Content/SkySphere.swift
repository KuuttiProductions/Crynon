
import MetalKit

class SkySphere: Node {
    
    var texture: String = "OceanSky"
    var mesh: MeshType = .Sphere
    
    override init(_ name: String) {
        super.init(name)
        self.setScale(9000)
        self.addRotZ(Float.pi/2)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        if Preferences.useSkySphere {
            renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Sky])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteLess])
            renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[texture], index: 3)
            AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
            super.render(renderCommandEncoder)
        }
    }
}
