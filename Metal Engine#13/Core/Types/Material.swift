
import simd

struct Material {
    var shaderMaterial: ShaderMaterial = ShaderMaterial()
    var textureColor: String = ""
    var textureNormal: String = ""
    var textureEmission: String = ""
    var textureMetallic: String = ""
    var textureRoughness: String = ""
    var shader: RenderPipelineStateType = .Forward
    var blendMode: BlendMode = .Opaque
}
