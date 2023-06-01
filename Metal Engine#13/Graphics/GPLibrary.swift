
class GPLibrary {
    
    private static var _vertexShaderLibrary: VertexShaderLibrary!
    public static var vertexShaders: VertexShaderLibrary { return _vertexShaderLibrary }
    
    private static var _fragmentShaderLibrary: FragmentShaderLibrary!
    public static var fragmentShaders: FragmentShaderLibrary { return _fragmentShaderLibrary }
    
    private static var _VertexDescriptorLibrary: VertexDescriptorLibrary!
    public static var vertexDescriptors: VertexDescriptorLibrary { return _VertexDescriptorLibrary}
    
    private static var _renderPipelineStateLibrary: RenderPipelineStateLibrary!
    public static var renderPipelineStates: RenderPipelineStateLibrary { return _renderPipelineStateLibrary }
    
    static func initialize() {
        _vertexShaderLibrary = VertexShaderLibrary()
        _fragmentShaderLibrary = FragmentShaderLibrary()
        _VertexDescriptorLibrary = VertexDescriptorLibrary()
        _renderPipelineStateLibrary = RenderPipelineStateLibrary()
    }
}
