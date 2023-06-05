
import MetalKit

enum DepthStencilType {
    case Less
}

class DepthStencilStateLibrary: Library<DepthStencilType, MTLDepthStencilState> {
    
    private var library: [DepthStencilType : DepthStencilState] = [:]
    
    override func fillLibrary() {
        library.updateValue(Less_DepthStencilDescriptor(), forKey: .Less)
    }
    
    override subscript(type: DepthStencilType) -> MTLDepthStencilState! {
        return library[type]?.state
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
