
import MetalKit
import Metal

public enum RenderPipelineStateType {
    case gBuffer
    case Lighting
    case Final
    case Shadow
    case PointAndLine
    case InitTransparency
    case Transparent
    case TransparentBlending
    case Sky
    case Simple
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateType, MTLRenderPipelineState> {
    
    private var _library: [RenderPipelineStateType : RenderPipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(gBuffer_RenderPipelineState(), forKey: .gBuffer)
        _library.updateValue(Lighting_RenderPipelineState(), forKey: .Lighting)
        _library.updateValue(Lighting_RenderPipelineState(), forKey: .Lighting)
        _library.updateValue(Shadow_RenderPipelineState(), forKey: .Shadow)
        _library.updateValue(PointAndLine_RenderPipelineState(), forKey: .PointAndLine)
        _library.updateValue(InitTransparency(), forKey: .InitTransparency)
        _library.updateValue(Transparent_RenderPipelineState(), forKey: .Transparent)
        _library.updateValue(TransparentBlending_RenderPipelineState(), forKey: .TransparentBlending)
        _library.updateValue(SkySphere_RenderPipelineState(), forKey: .Sky)
        _library.updateValue(Simple_RenderPipelineState(), forKey: .Simple)
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

func addColorAttachments(descriptor: MTLRenderPipelineDescriptor) {
    descriptor.colorAttachments[0].pixelFormat = Preferences.metal.pixelFormat
    descriptor.colorAttachments[1].pixelFormat = Preferences.metal.pixelFormat
    descriptor.colorAttachments[2].pixelFormat = Preferences.metal.floatPixelFormat
    descriptor.colorAttachments[3].pixelFormat = Preferences.metal.signedPixelFormat
    descriptor.colorAttachments[4].pixelFormat = .r32Float
    descriptor.colorAttachments[5].pixelFormat = Preferences.metal.pixelFormat
    descriptor.colorAttachments[6].pixelFormat = Preferences.metal.pixelFormat
}

class gBuffer_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Default]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.GBuffer]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Geometry RenderPipelineState"
        create()
    }
}

class Lighting_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.metal.pixelFormat
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Quad]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Lighting]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Lighting RenderPipelineState"
        create()
    }
}

class Shadow_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Shadow]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Shadow]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Shadow RenderPipelineState"
        create()
    }
}

class PointAndLine_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.metal.pixelFormat
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.PointAndLine]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.PointAndLine]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.PointAndLine]
        descriptor.label = "PointAndLine RenderPipelineState"
        create()
    }
}

class InitTransparency: RenderPipelineState {
    var tileDescriptor: MTLTileRenderPipelineDescriptor = MTLTileRenderPipelineDescriptor()
    override init() {
        super.init()
        tileDescriptor.colorAttachments[0].pixelFormat = Preferences.metal.pixelFormat
        tileDescriptor.colorAttachments[1].pixelFormat = Preferences.metal.pixelFormat
        tileDescriptor.colorAttachments[2].pixelFormat = Preferences.metal.floatPixelFormat
        tileDescriptor.colorAttachments[3].pixelFormat = Preferences.metal.signedPixelFormat
        tileDescriptor.colorAttachments[4].pixelFormat = .r32Float
        tileDescriptor.colorAttachments[5].pixelFormat = Preferences.metal.pixelFormat
        tileDescriptor.colorAttachments[6].pixelFormat = Preferences.metal.pixelFormat
        tileDescriptor.tileFunction = Core.defaultLibrary.makeFunction(name: "initTransparentFragmentStore")!
        tileDescriptor.threadgroupSizeMatchesTileSize = true
        tileDescriptor.label = "Init Transparency RenderPipelineState"
        create()
    }
    
    override func create() {
        do {
            renderPipelineState = try Core.device.makeRenderPipelineState(tileDescriptor: tileDescriptor, options: [], reflection: nil)
        } catch let error {
            print(error)
        }
    }
}

class Transparent_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].isBlendingEnabled = false
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Default]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Transparent]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Transparent RenderPipelineState"
        create()
    }
}

class TransparentBlending_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].isBlendingEnabled = false
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Quad]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.TransparentBlending]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "TransparentBlending RenderPipelineState"
        create()
    }
}

class SkySphere_RenderPipelineState : RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Sky]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.GBuffer]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "SkySphere RenderPipelineState"
        create()
    }
}

class Simple_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.metal.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Simple]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.GBuffer]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Simple]
        descriptor.label = "Simple RenderPipelineState"
        create()
    }
}
