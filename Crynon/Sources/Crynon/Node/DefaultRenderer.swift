
import MetalKit

class DefaultRenderer {
    
    static func render(material: Material, name: String, renderCommandEncoder: MTLRenderCommandEncoder) {
        if material.blendMode == Renderer.currentBlendMode {
            renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[material.shader])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[material.shader == .Transparent ? .NoWriteLess : .Less])
            renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[material.textureColor], index: 3)
            renderCommandEncoder.setFragmentBytes(&material.shaderMaterial, length: ShaderMaterial.stride, index: 1)
            AssetLibrary.meshes[self.mesh].draw(renderCommandEncoder)
            super.render(renderCommandEncoder)
        }
    }
}
