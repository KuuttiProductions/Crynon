
import MetalKit

class SkySphere: Node {
    
    var texture: String = "OceanSky"
    var mesh: String = "Sphere"
    var material: ShaderMaterial = ShaderMaterial()
    
    override init(_ name: String) {
        super.init(name)
        self.setScale(999)
        self.material.emission = 1
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        if Preferences.useSkySphere == true {
            renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Sky])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteLess])
            renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&material, length: ShaderMaterial.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[texture], index: 3)
            AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
            super.render(renderCommandEncoder)
        }
    }
}
