
import MetalKit

enum FragmentShaderType {
    case Basic
    case Final
    case PointAndLine
    case Transparent
    case TransparentBlending
}

class FragmentShaderLibrary: Library<FragmentShaderType, MTLFunction> {
    
    private var _library: [FragmentShaderType : FragmentShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(FragmentShader("basic_fragment", "Basic Fragment Function"), forKey: .Basic)
        _library.updateValue(FragmentShader("final_fragment", "Final Fragment Function"), forKey: .Final)
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
