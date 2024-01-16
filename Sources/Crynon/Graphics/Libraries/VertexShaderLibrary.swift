
import MetalKit

enum VertexShaderType {
    case Default
    case Quad
    case Shadow
    case PointAndLine
    case Sky
    case Simple
}

class VertexShaderLibrary: Library<VertexShaderType, MTLFunction> {
    
    private var _library: [VertexShaderType : VertexShader] = [:]
    
    override func fillLibrary() {
        _library.updateValue(VertexShader("default_vertex", "Default Vertex Function"), forKey: .Default)
        _library.updateValue(VertexShader("quad_vertex", "Quad Vertex Function"), forKey: .Quad)
        _library.updateValue(VertexShader("shadow_vertex", "Shadow Vertex Function"), forKey: .Shadow)
        _library.updateValue(VertexShader("pointAndLine_vertex", "Line and Point Vertex Function"), forKey: .PointAndLine)
        _library.updateValue(VertexShader("sky_vertex", "Sky Sphere Vertex Function"), forKey: .Sky)
        _library.updateValue(VertexShader("simple_vertex", "Simple Vertex Function"), forKey: .Simple)
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
