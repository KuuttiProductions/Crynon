
import MetalKit

open class EnvironmentSphere: Node {
    
    public var texture: String!
    private var material: ShaderMaterial = ShaderMaterial()
    
    public override init(_ name: String) {
        super.init(name)
        self.setScale(999)
        self.material.emission = simd_float4(0, 0, 0, 1)
    }
    
    override func render(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        if Preferences.graphics.useSkySphere == true && Renderer.currentBlendMode == .Opaque {
            renderCommandEncoder.pushDebugGroup("Rendering \(name!)")
            renderCommandEncoder.setRenderPipelineState(GPLibrary.renderPipelineStates[.Sky])
            renderCommandEncoder.setDepthStencilState(GPLibrary.depthStencilStates[.NoWriteLess])
            renderCommandEncoder.setVertexBytes(&self.modelConstant, length: ModelConstant.stride, index: 1)
            renderCommandEncoder.setFragmentBytes(&material, length: ShaderMaterial.stride, index: 1)
            renderCommandEncoder.setFragmentTexture(AssetLibrary.textures[texture], index: 3)
            AssetLibrary.meshes["Sphere"].draw(renderCommandEncoder)
            super.render(renderCommandEncoder)
        }
    }
}
