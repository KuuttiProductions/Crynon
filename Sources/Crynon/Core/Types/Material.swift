
import simd

//Material is a CPU-side type. ShaderMaterial variable is sent to the GPU
//Textures are used only if defined. ShaderMaterial.color is used if
//textureColor isn't defined.
//textureAoRoughMetal is preferred to setting these textures separetly.
public struct Material {
    public var name: String = ""
    public var shaderMaterial: ShaderMaterial = ShaderMaterial()
    public var textureColor: String = ""
    public var textureNormal: String = ""
    public var textureEmission: String = ""
    public var textureMetallic: String = ""
    public var textureRoughness: String = ""
    public var textureAoRoughMetal: String = ""
    public var visible: Bool = true

    private var _shader: RenderPipelineStateType = .gBuffer
    public var shader: RenderPipelineStateType { return _shader }
    
    private var _depthStencil: DepthStencilType = .Less
    public var depthStencil : DepthStencilType { return _depthStencil }
    
    private var _renderState: RenderState = .Opaque
    public var renderState: RenderState { return _renderState }
    
    public init(_ shader: RenderPipelineStateType = .gBuffer, _ name: String = "New material") {
        self._shader = shader
        self.name = name
        switch shader {
        case .gBuffer:
            self._depthStencil = .Less
            self._renderState = .Opaque
        case .Transparent:
            self._depthStencil = .NoWriteLess
            self._renderState = .Alpha
        case .Sky:
            self._depthStencil = .NoWriteLess
            self._renderState = .Opaque
        default:
            self._depthStencil = .Less
            self._renderState = .Opaque
        }
    }
}
