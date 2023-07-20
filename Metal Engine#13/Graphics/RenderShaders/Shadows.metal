
#include <metal_stdlib>
using namespace metal;

constexpr sampler sampler2d (mag_filter::linear,
                           min_filter::linear);

class Shadows {
public:
    static float getBrightness(depth2d<float> shadowMap1,
                               float3 lightSpacePosition) {
        
        float2 samplerCoord = float2(lightSpacePosition.xy) * float2(0.5, -0.5) + 0.5;
        
        if (!is_null_texture(shadowMap1)) {
            if (shadowMap1.sample(sampler2d, samplerCoord) < lightSpacePosition.z) {
                return 0;
            } else {
                return 1;;
            }
        } else {
            return 1;
        }
    }
};
