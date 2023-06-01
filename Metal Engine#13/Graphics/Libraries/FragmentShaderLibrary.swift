
import MetalKit

enum FragmentShaderType {
    case Basic
}

class FragmentShaderLibrary: Library<FragmentShaderType, MTLFunction> {
    
    var library: [FragmentShaderType : FragmentShader] = [:]
    
    override func fillLibrary() {
        library.updateValue(FragmentShader("basic_fragment", "Basic Fragment Function"), forKey: .Basic)
    }
    
    override subscript(type: FragmentShaderType) -> MTLFunction! {
        return library[type]?.function
    }
}

class FragmentShader {
    var function: MTLFunction!
    init(_ name: String, _ label: String = "") {
        function = Core.defaultLibrary.makeFunction(name: name)
        function.label = label
    }
}
