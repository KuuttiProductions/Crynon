
import MetalKit

enum ComputePipelineStateType {
    case Jitter
}

class ComputePipelineStateLibrary: Library<ComputePipelineStateType, MTLComputePipelineState> {
    
    private var _library: [ComputePipelineStateType : ComputePipelineState] = [:]
    
    override func fillLibrary() {
        _library.updateValue(ComputePipelineState(functionName: "jitter", functionLabel: "Jitter function"), forKey: .Jitter)
    }
    
    override subscript(type: ComputePipelineStateType) -> MTLComputePipelineState! {
        _library[type]?.pipelineState
    }
}

class ComputePipelineState {
    var pipelineState: MTLComputePipelineState!
    init(functionName: String, functionLabel: String = "") {
        do {
            let function = Core.defaultLibrary.makeFunction(name: functionName)!
            function.label = functionLabel
            pipelineState = try Core.device.makeComputePipelineState(function: function)
        } catch let error {
            print("Error creating computePipelineState: \(error)")
        }
    }
}
