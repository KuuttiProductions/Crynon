
import MetalKit

enum ComputePipelineStateType {
    case Jitter
    case BloomDownsample
    case BloomUpsample
}

class ComputePipelineStateLibrary: Library<ComputePipelineStateType, MTLComputePipelineState> {
    
    private var _library: [ComputePipelineStateType : ComputePipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(ComputePipelineState(functionName: "jitter", "Jitter Function"), forKey: .Jitter)
        _library.updateValue(ComputePipelineState(functionName: "bloomDownsample", "BloomDownsampling Function"), forKey: .BloomDownsample)
        _library.updateValue(ComputePipelineState(functionName: "bloomUpsample", "BloomUpsampling Function"), forKey: .BloomUpsample)
    }
    
    override subscript(type: ComputePipelineStateType) -> MTLComputePipelineState! {
        _library[type]?.pipelineState
    }
}

class ComputePipelineState {
    var pipelineState: MTLComputePipelineState!
    init(functionName: String, _ label: String = "") {
        do {
            let function = Core.defaultLibrary.makeFunction(name: functionName)!
            function.label = label
            pipelineState = try Core.device.makeComputePipelineState(function: function)
        } catch let error {
            print("Error creating computePipelineState: \(error)")
        }
    }
}
