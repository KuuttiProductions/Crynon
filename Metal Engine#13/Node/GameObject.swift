
import MetalKit

class GameObject: Node {
    
    var material: Material = Material()
    var mesh: MeshType = .Quad
    var textureColor: String = ""
    
    override init(_ name: String) {
        super.init(name)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[material.shader])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[material.shader == .Transparent ? .NoWrite : .Less])
        renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[textureColor], index: 3)
        renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Casting shadow with \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Shadow])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[textureColor], index: 3)
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setCullMode(.back)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.castShadow(renderCommandEncoder)
    }
}
