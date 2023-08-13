
import MetalKit

enum VertexShaderType {
    case Forward
    case Deferred
    case Final
    case Shadow
    case PointAndLine
}

class VertexShaderLibrary: Library<VertexShaderType, MTLFunction> {
    
    private var _library: [VertexShaderType : VertexShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(VertexShader("forward_vertex", "Basic Vertex Function"), forKey: .Forward)
        _library.updateValue(VertexShader("deferred_vertex", "Deferred Vertex Function"), forKey: .Deferred)
        _library.updateValue(VertexShader("final_vertex", "Final Vertex Function"), forKey: .Final)
        _library.updateValue(VertexShader("shadow_vertex", "Shadow Vertex Function"), forKey: .Shadow)
        _library.updateValue(VertexShader("pointAndLine_vertex", "Line and Point Vertex Function"), forKey: .PointAndLine)
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
