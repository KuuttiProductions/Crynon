
//Used for accessing Graphics libraries
class GPLibrary {
    
    private static var _vertexShaderLibrary: VertexShaderLibrary!
    public static var vertexShaders: VertexShaderLibrary { return _vertexShaderLibrary }
    
    private static var _fragmentShaderLibrary: FragmentShaderLibrary!
    public static var fragmentShaders: FragmentShaderLibrary { return _fragmentShaderLibrary }
    
    private static var _VertexDescriptorLibrary: VertexDescriptorLibrary!
    public static var vertexDescriptors: VertexDescriptorLibrary { return _VertexDescriptorLibrary}
    
    private static var _renderPipelineStateLibrary: RenderPipelineStateLibrary!
    public static var renderPipelineStates: RenderPipelineStateLibrary { return _renderPipelineStateLibrary }
    
    private static var _computePipelineStateLibrary: ComputePipelineStateLibrary!
    public static var computePipelineStates: ComputePipelineStateLibrary { return _computePipelineStateLibrary }
    
    private static var _depthStencilStateLibrary: DepthStencilStateLibrary!
    public static var depthStencilStates: DepthStencilStateLibrary { return _depthStencilStateLibrary }
    
    private static var _samplerStateLibrary: SamplerStateLibrary!
    public static var samplerStates: SamplerStateLibrary { return _samplerStateLibrary }
    
    static func initialize() {
        _vertexShaderLibrary = VertexShaderLibrary()
        _fragmentShaderLibrary = FragmentShaderLibrary()
        _depthStencilStateLibrary = DepthStencilStateLibrary()
        _VertexDescriptorLibrary = VertexDescriptorLibrary()
        _renderPipelineStateLibrary = RenderPipelineStateLibrary()
        _computePipelineStateLibrary = ComputePipelineStateLibrary()
        _samplerStateLibrary = SamplerStateLibrary()
    }
}
