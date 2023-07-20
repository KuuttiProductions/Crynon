
import MetalKit

enum VertexShaderType {
    case Basic
    case Final
    case Shadow
}

class VertexShaderLibrary: Library<VertexShaderType, MTLFunction> {
    
    private var _library: [VertexShaderType : VertexShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(VertexShader("basic_vertex", "Basic Vertex Function"), forKey: .Basic)
        _library.updateValue(VertexShader("final_vertex", "Final Vertex Function"), forKey: .Final)
        _library.updateValue(VertexShader("shadow_vertex", "Shadow Vertex Function"), forKey: .Shadow)
    }
    
    override subscript(type: VertexShaderType) -> MTLFunction! {
        return _library[type]?.function
    }
}

class VertexShader {
    var function: MTLFunction!
    init(_ name: String, _ label: String = "") {
        function = Core.defaultLibrary.makeFunction(name: name)
        function.label = label
    }
}
