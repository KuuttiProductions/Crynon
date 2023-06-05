
import MetalKit

typealias MRM = MetalResourceManager

//Metal Resource Manager AKA ´MRM´
//Keeps all Metal bindings in memory:
//Set new bindings though this class
//for automatic redundant binding check.
class MetalResourceManager {
    
    private static var _currentRenderCommandEncoder: MTLRenderCommandEncoder!
    
    private static var _currentRenderPipelineState: MTLRenderPipelineState!
    private static var _currentDepthStencilState: MTLDepthStencilState!
    
    //===== Metal-object setters =====
    static func setRenderCommandEncoder(_ renderCommandEncoder: MTLRenderCommandEncoder!) {
        resetAll()
        _currentRenderCommandEncoder = renderCommandEncoder
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
    
    static func setDepthStencilState(_ depthStencilState: MTLDepthStencilState!) {
        if validityCheck() {
            if _currentDepthStencilState == nil {
                _currentDepthStencilState = depthStencilState
                _currentRenderCommandEncoder.setDepthStencilState(depthStencilState)
            } else if _currentDepthStencilState.label != depthStencilState.label {
                _currentDepthStencilState = depthStencilState
                _currentRenderCommandEncoder.setDepthStencilState(depthStencilState)
            }
        }
    }
    
    //===== Non-Metal-object setters =====
    static func setVertexBuffer(_ vertexBuffer: MTLBuffer!, _ index: Int) {
        if validityCheck() {
            _currentRenderCommandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: index)
        }
    }
    
    //===== Functions =====
    static func validityCheck() -> Bool {
        if _currentRenderCommandEncoder != nil {
            return true
        } else {
            return false
        }
    }
    
    static func resetAll() {
        _currentRenderCommandEncoder = nil
        _currentRenderPipelineState = nil
    }
}
