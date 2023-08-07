
import MetalKit

enum RenderPipelineStateType {
    case Basic
    case Final
    case Shadow
    case PointAndLine
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateType, MTLRenderPipelineState> {
    
    private var _library: [RenderPipelineStateType : RenderPipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Basic_RenderPipelineState(), forKey: .Basic)
        _library.updateValue(Final_RenderPipelineState(), forKey: .Final)
        _library.updateValue(Shadow_RenderPipelineState(), forKey: .Shadow)
        _library.updateValue(PointAndLine_RenderPipelineState(), forKey: .PointAndLine)
    }
    
    override subscript(type: RenderPipelineStateType) -> MTLRenderPipelineState! {
        return _library[type]?.renderPipelineState
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
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = .add
        descriptor.colorAttachments[0].alphaBlendOperation = .add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Basic]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Basic]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Basic RenderPipelineState"
        create()
    }
}

class Final_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Final]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Final]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Final RenderPipelineState"
        create()
    }
}

class Shadow_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Shadow]
        descriptor.fragmentFunction = nil
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Shadow RenderPipelineState"
        create()
    }
}

class PointAndLine_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.PointAndLine]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.PointAndLine]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.PointAndLine]
        descriptor.label = "Basic RenderPipelineState"
        create()
    }
}
