
import MetalKit

enum VertexShaderType {
    case Basic
}

class VertexShaderLibrary: Library<VertexShaderType, MTLFunction> {
    
    var library: [VertexShaderType : VertexShader] = [:]
    
    override func fillLibrary() {
        library.updateValue(VertexShader("basic_vertex"), forKey: .Basic)
    }
    
    override subscript(type: VertexShaderType) -> MTLFunction! {
        return library[type]?.function
    }
}

class VertexShader {
    var function: MTLFunction!
    init(_ name: String) {
        function = Core.defaultLibrary.makeFunction(name: name)
    }
}
