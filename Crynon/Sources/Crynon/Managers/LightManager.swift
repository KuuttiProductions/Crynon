
import MetalKit

final class LightManager {
    
    private var _lights: [Light] = []
    
    func addLight(_ light: Light) {
        _lights.append(light)
    }
    
    func passLightData(renderCommandEncoder: MTLRenderCommandEncoder) {
        var data: [LightData] = []
        for light in _lights {
            data.append(light.lightData)
        }
        var lightCount: Int = data.count
        renderCommandEncoder.setFragmentBytes(&data, length: LightData.stride(count: lightCount), index: 3)
        renderCommandEncoder.setFragmentBytes(&lightCount, length: Int.stride, index: 4)
    }
    
    func passShadowLight(renderCommandEncoder: MTLRenderCommandEncoder!) {
        var viewMatrix: matrix_float4x4!
        for light in _lights {
            if light.shadows == true {
                viewMatrix = light.projectionMatrix * light.viewMatrix
                break
            }
        }
        renderCommandEncoder.setVertexBytes(&viewMatrix, length: matrix_float4x4.stride, index: 3)
    }
}
