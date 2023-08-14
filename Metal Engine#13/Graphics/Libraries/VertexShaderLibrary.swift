
import MetalKit

enum VertexShaderType {
    case Default
    case Final
    case Shadow
    case PointAndLine
    case Sky
}

class VertexShaderLibrary: Library<VertexShaderType, MTLFunction> {
    
    private var _library: [VertexShaderType : VertexShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(VertexShader("default_vertex", "Default Vertex Function"), forKey: .Default)
        _library.updateValue(VertexShader("final_vertex", "Final Vertex Function"), forKey: .Final)
        _library.updateValue(VertexShader("shadow_vertex", "Shadow Vertex Function"), forKey: .Shadow)
        _library.updateValue(VertexShader("pointAndLine_vertex", "Line and Point Vertex Function"), forKey: .PointAndLine)
        _library.updateValue(VertexShader("sky_vertex", "Sky Sphere Vertex Function"), forKey: .Sky)
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
