
import simd

//Material is a CPU-side type. ShaderMaterial variable is sent to the GPU
//Textures are used only if defined. ShaderMaterial.color is used if
//textureColor isn't defined.
struct Material {
    var shaderMaterial: ShaderMaterial = ShaderMaterial()
    var textureColor: String = ""
    var textureNormal: String = ""
    var textureEmission: String = ""
    var textureMetallic: String = ""
    var textureRoughness: String = ""
    var shader: RenderPipelineStateType = .Geometry
    var blendMode: BlendMode = .Opaque
    var visible: Bool = true
}
