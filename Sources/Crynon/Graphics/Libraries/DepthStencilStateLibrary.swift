
import MetalKit

public enum DepthStencilType {
    case Less
    case NoWriteLess
    case NoWriteAlways
    case Never
}

class DepthStencilStateLibrary: Library<DepthStencilType, MTLDepthStencilState> {
    
    private var _library: [DepthStencilType : DepthStencilState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Less_DepthStencilDescriptor(), forKey: .Less)
        _library.updateValue(NoWriteLess_DepthStencilDescriptor(), forKey: .NoWriteLess)
        _library.updateValue(NoWriteAlways_DepthStencilDescriptor(), forKey: .NoWriteAlways)
        _library.updateValue(Never_DepthStencilDescriptor(), forKey: .Never)
    }
    
    override subscript(type: DepthStencilType) -> MTLDepthStencilState! {
        return _library[type]?.state
    }
}

class DepthStencilState {
    var state: MTLDepthStencilState!
    func create(_ descriptor: MTLDepthStencilDescriptor) {
        state = Core.device.makeDepthStencilState(descriptor: descriptor)
    }
}

class Less_DepthStencilDescriptor: DepthStencilState {
    override init() {
        super.init()
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        descriptor.label = "Less_DepthStencilState"
        create(descriptor)
    }
}

class NoWriteLess_DepthStencilDescriptor: DepthStencilState {
    override init() {
        super.init()
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = false
        descriptor.label = "NoWrite_DepthStencilState"
        create(descriptor)
    }
}

class NoWriteAlways_DepthStencilDescriptor: DepthStencilState {
    override init() {
        super.init()
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = false
        descriptor.depthCompareFunction = .always
        descriptor.frontFaceStencil = nil
        descriptor.backFaceStencil = nil
        descriptor.label = "NoWriteAlways_DepthStencilState"
        create(descriptor)
    }
}

class Never_DepthStencilDescriptor: DepthStencilState {
    override init() {
        super.init()
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = false
        descriptor.depthCompareFunction = .never
        descriptor.label = "Never_DepthStencilState"
        create(descriptor)
    }
}
