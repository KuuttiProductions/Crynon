
import MetalKit

enum SamplerStateType {
    case Linear
}

class SamplerStateLibrary: Library<SamplerStateType, MTLSamplerState> {
    
    private var _library: [SamplerStateType : SamplerState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(LinearSamplerState(), forKey: .Linear)
    }
    
    override subscript(type: SamplerStateType) -> MTLSamplerState! {
        _library[type]?.samplerState
    }
}

class SamplerState {
    var samplerState: MTLSamplerState!
    var descriptor: MTLSamplerDescriptor!
    func create() {
        samplerState = Core.device.makeSamplerState(descriptor: descriptor)
    }
}

class LinearSamplerState: SamplerState {
    override init() {
        super.init()
        descriptor = MTLSamplerDescriptor()
        descriptor.magFilter = .linear
        descriptor.minFilter = .linear
        create()
    }
}
