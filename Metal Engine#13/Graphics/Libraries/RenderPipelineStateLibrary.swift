
import MetalKit
import Metal

enum RenderPipelineStateType {
    case Geometry
    case Lighting
    case Final
    case Shadow
    case PointAndLine
    case InitTransparency
    case Transparent
    case TransparentBlending
    case Sky
    case Vector
}

class RenderPipelineStateLibrary: Library<RenderPipelineStateType, MTLRenderPipelineState> {
    
    private var _library: [RenderPipelineStateType : RenderPipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Geometry_RenderPipelineState(), forKey: .Geometry)
        _library.updateValue(Lighting_RenderPipelineState(), forKey: .Lighting)
        _library.updateValue(Final_RenderPipelineState(), forKey: .Final)
        _library.updateValue(Shadow_RenderPipelineState(), forKey: .Shadow)
        _library.updateValue(PointAndLine_RenderPipelineState(), forKey: .PointAndLine)
        _library.updateValue(InitTransparency(), forKey: .InitTransparency)
        _library.updateValue(Transparent_RenderPipelineState(), forKey: .Transparent)
        _library.updateValue(TransparentBlending_RenderPipelineState(), forKey: .TransparentBlending)
        _library.updateValue(SkySphere_RenderPipelineState(), forKey: .Sky)
        _library.updateValue(Vector_RenderPipelineState(), forKey: .Vector)
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
    descriptor.colorAttachments[1].pixelFormat = Preferences.pixelFormat
    descriptor.colorAttachments[2].pixelFormat = Preferences.floatPixelFormat
    descriptor.colorAttachments[3].pixelFormat = Preferences.signedPixelFormat
    descriptor.colorAttachments[4].pixelFormat = .r32Float
    descriptor.colorAttachments[5].pixelFormat = Preferences.pixelFormat
}

// Deprecated
class Forward_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.colorAttachments[0].writeMask = []
        descriptor.colorAttachments[0].isBlendingEnabled = true
        descriptor.colorAttachments[0].rgbBlendOperation = .add
        descriptor.colorAttachments[0].alphaBlendOperation = .add
        descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
        descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
        descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Default]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Forward]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Forward RenderPipelineState"
        create()
    }
}

class Geometry_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Default]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Deferred]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Geometry RenderPipelineState"
        create()
    }
}

class Lighting_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].isBlendingEnabled = false
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Final]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Lighting]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Lighting RenderPipelineState"
        create()
    }
}

class Final_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].writeMask = []
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
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
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
        tileDescriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        tileDescriptor.colorAttachments[1].pixelFormat = Preferences.pixelFormat
        tileDescriptor.colorAttachments[2].pixelFormat = Preferences.floatPixelFormat
        tileDescriptor.colorAttachments[3].pixelFormat = Preferences.signedPixelFormat
        tileDescriptor.colorAttachments[4].pixelFormat = .r32Float
        tileDescriptor.colorAttachments[5].pixelFormat = Preferences.pixelFormat
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
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Default]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Transparent]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Transparent RenderPipelineState"
        create()
    }
}

/// WRITE MASKS MUST BE THE SOLUTION

class TransparentBlending_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].isBlendingEnabled = false
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Final]
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
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Sky]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Deferred]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "SkySphere RenderPipelineState"
        create()
    }
}

class Vector_RenderPipelineState: RenderPipelineState {
    override init() {
        super.init()
        descriptor = MTLRenderPipelineDescriptor()
        descriptor.colorAttachments[0].pixelFormat = Preferences.pixelFormat
        descriptor.colorAttachments[0].writeMask = []
        addColorAttachments(descriptor: descriptor)
        descriptor.depthAttachmentPixelFormat = Preferences.depthFormat
        descriptor.vertexFunction = GPLibrary.vertexShaders[.Vector]
        descriptor.fragmentFunction = GPLibrary.fragmentShaders[.Deferred]
        descriptor.vertexDescriptor = GPLibrary.vertexDescriptors[.Basic]
        descriptor.label = "Vector-Geometry RenderPipelineState"
        create()
    }
}
