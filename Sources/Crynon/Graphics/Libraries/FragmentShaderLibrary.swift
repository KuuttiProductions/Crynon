
import MetalKit

enum FragmentShaderType {
    case GBuffer
    case Lighting
    case Shadow
    case SSAO
    case PointAndLine
    case Transparent
    case TransparentBlending
    case Compositing
}

class FragmentShaderLibrary: Library<FragmentShaderType, MTLFunction> {
    
    private var _library: [FragmentShaderType : FragmentShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(FragmentShader("gBuffer_fragment", "GBuffer Fragment Function"), forKey: .GBuffer)
        _library.updateValue(FragmentShader("lighting_fragment", "Lighting Fragment Function"), forKey: .Lighting)
        _library.updateValue(FragmentShader("shadow_fragment", "Shadow Fragment Function"), forKey: .Shadow)
        _library.updateValue(FragmentShader("ssao_fragment", "SSAO Fragment Function"), forKey: .SSAO)
        _library.updateValue(FragmentShader("pointAndLine_fragment", "Point and Line Fragment Function"), forKey: .PointAndLine)
        _library.updateValue(FragmentShader("transparent_fragment", "Transparent Fragment Function"), forKey: .Transparent)
        _library.updateValue(FragmentShader("blendTransparent_fragment", "Transparency Blending Fragment Function"), forKey: .TransparentBlending)
        _library.updateValue(FragmentShader("compositing_fragment", "Compositing Fragment Function"), forKey: .Compositing)
    }
    
    override subscript(type: FragmentShaderType) -> MTLFunction! {
        return _library[type]?.function
    }
}

class FragmentShader {
    var function: MTLFunction!
    init(_ name: String, _ label: String = "") {
        function = Core.defaultLibrary.makeFunction(name: name)
        function.label = label
    }
}
