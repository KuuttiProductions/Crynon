
import MetalKit

enum RenderPipelineStateType {
    case Basic
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateType, MTLRenderPipelineState> {
    
    private var library: [RenderPipelineStateType : RenderPipelineState] = [:]
    
    override func fillLibrary() {
        library.updateValue(Basic_RenderPipelineState(), forKey: .Basic)
    }
    
    override subscript(type: RenderPipelineStateType) -> MTLRenderPipelineState! {
        return library[type]?.renderPipelineState
    }
}

class RenderPipelineState {
    var renderPipelineState: MTLRenderPipelineState!
    var descriptor: MTLRenderPipelineDescriptor!
    func create() {
        do {
            renderPipelineState = try Core.device.makeRenderPipelineState(descriptor: descriptor)
        } catch let error as NSError {
            print(error)
        }
    }
}

class Basic_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Basic]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Basic]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Basic RenderPipelineState"
        create()
    }
}
