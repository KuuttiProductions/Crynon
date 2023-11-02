
import MetalKit

enum FragmentShaderType {
    case Forward
    case Deferred
    case Lighting
    case Final
    case Shadow
    case PointAndLine
    case Transparent
    case TransparentBlending
}

class FragmentShaderLibrary: Library<FragmentShaderType, MTLFunction> {
    
    private var _library: [FragmentShaderType : FragmentShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(FragmentShader("forward_fragment", "Basic Fragment Function"), forKey: .Forward)
        _library.updateValue(FragmentShader("deferred_fragment", "Deferred Fragment Function"), forKey: .Deferred)
        _library.updateValue(FragmentShader("lighting_fragment", "Lighting Fragment Function"), forKey: .Lighting)
        _library.updateValue(FragmentShader("final_fragment", "Final Fragment Function"), forKey: .Final)
        _library.updateValue(FragmentShader("shadow_fragment", "Shadow Fragment Function"), forKey: .Shadow)
        _library.updateValue(FragmentShader("pointAndLine_fragment", "Point and Line Fragment Function"), forKey: .PointAndLine)
        _library.updateValue(FragmentShader("transparent_fragment", "Transparent Fragment Function"), forKey: .Transparent)
        _library.updateValue(FragmentShader("blendTransparent_fragment", "Transparency Blending Fragment Functino"), forKey: .TransparentBlending)
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
