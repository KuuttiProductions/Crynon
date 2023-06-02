
import MetalKit

typealias MRM = MetalResourceManager

//Metal Resource Manager AKA ´MRM´
//Keeps all Metal bindings in memory:
//Set new bindings though this class
//for automatic redundant binding check.
class MetalResourceManager {
    
    private static var _currentRenderCommandEncoder: MTLRenderCommandEncoder!
    
    private static var _currentRenderPipelineState: MTLRenderPipelineState!
    
    static func setRenderCommandEncoder(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        _currentRenderCommandEncoder = renderCommandEncoder
        clearAll()
    }
    
    static func setRenderPipelineState(_ renderPipelineState: MTLRenderPipelineState!) {
        if validityCheck() {
            if _currentRenderPipelineState == nil {
                _currentRenderPipelineState = renderPipelineState
                _currentRenderCommandEncoder.setRenderPipelineState(renderPipelineState)
            } else if _currentRenderPipelineState.label != renderPipelineState.label {
                _currentRenderPipelineState = renderPipelineState
                _currentRenderCommandEncoder.setRenderPipelineState(renderPipelineState)
            }
        }
    }
    
    static func validityCheck() -> Bool {
        if _currentRenderCommandEncoder != nil {
            return true
        } else {
            return false
        }
    }
    
    static func clearAll() {
        _currentRenderPipelineState = nil
    }
    
    //===== Non-Metal-object setters =====
    static func setVertexBuffer(_ vertexBuffer: MTLBuffer!, _ index: Int) {
        if validityCheck() {
            _currentRenderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)
        }
    }
    
    static func setVertexBytes(_ vertexBytes: MTLBuffer!, _ index: Int) {
        var bytes = vertexBytes
        if validityCheck() {
            _currentRenderCommandEncoder.setVertexBytes(&bytes, length: 0, index: index)
        }
    }
}
