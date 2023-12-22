
import MetalKit

open class GameObject: Node {
    
    public var material: Material = Material()
    public var mesh: String = "Quad"
    
    public override init(_ name: String) {
        super.init(name)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
        if material.blendMode == Renderer.currentBlendMode && material.visible {
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[material.shader])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[material.shader == .Transparent ? .NoWriteLess : .Less])
            renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureNormal], index: 4)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureEmission], index: 5)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureRoughness], index: 6)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureMetallic], index: 7)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureAoRoughMetal], index: 8)
            renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
            AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        }
        super.render(renderCommandEncoder)
    }
    
    override func castShadow(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        renderCommandEncoder.pushDebugGroup("Casting shadow with \(name!)")
        renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Shadow])
        renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.Less])
        renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
        renderCommandEncoder.setVertexBytes(&modelConstant, length: ModelConstant.stride, index: 1)
        renderCommandEncoder.setCullMode(.back)
        AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
        super.castShadow(renderCommandEncoder)
    }
}
