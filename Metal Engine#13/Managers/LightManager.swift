
import MetalKit

class LightManager {
    
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
    
    func tick(deltaTime: Float) {
        for light in _lights {
            light.tick(deltaTime)
        }
    }
    
    func render(_ renderCommandEncoder: MTLRenderCommandEncoder) {
        for light in _lights  {
            light.render(renderCommandEncoder)
        }
    }
}
