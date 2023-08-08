
import MetalKit

enum DepthStencilType {
    case Less
    case NoWrite
    case No
}

class DepthStencilStateLibrary: Library<DepthStencilType, MTLDepthStencilState> {
    
    private var _library: [DepthStencilType : DepthStencilState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(Less_DepthStencilDescriptor(), forKey: .Less)
        _library.updateValue(NoWrite_DepthStencilDescriptor(), forKey: .NoWrite)
        _library.updateValue(No_DepthStencilDescriptor(), forKey: .No)
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

class NoWrite_DepthStencilDescriptor: DepthStencilState {
    override init() {
        super.init()
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = false
        descriptor.label = "NoWrite_DepthStencilState"
        create(descriptor)
    }
}

class No_DepthStencilDescriptor: DepthStencilState {
    override init() {
        super.init()
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.isDepthWriteEnabled = false
        descriptor.depthCompareFunction = .always
        descriptor.frontFaceStencil = nil
        descriptor.backFaceStencil = nil
        descriptor.label = "No_DepthStencilState"
        create(descriptor)
    }
}
