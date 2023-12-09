
import simd

//Material is a CPU-side type. ShaderMaterial variable is sent to the GPU
//Textures are used only if defined. ShaderMaterial.color is used if
//textureColor isn't defined.
public struct Material {
    public var shaderMaterial: ShaderMaterial = ShaderMaterial()
    public var textureColor: String = ""
    public var textureNormal: String = ""
    public var textureEmission: String = ""
    public var textureMetallic: String = ""
    public var textureRoughness: String = ""
    public var shader: RenderPipelineStateType = .Geometry
    public var blendMode: BlendMode = .Opaque
    public var visible: Bool = true
}
