
#include <metal_stdlib>
#import "Random/rng_header.metal"
using namespace metal;

constexpr sampler sampler2d (mag_filter::nearest,
                             min_filter::nearest,
                             border_color::opaque_white,
                             address::clamp_to_border);

class Shadows {
public:
    
    static float getShadowness(depth2d<float> shadowMap1,
                               float3 lightSpacePosition) {
                
        int sampleCount = 16;
        int halfSquareSample = sqrt(float(sampleCount))/2;

        float2 samplePositionDefault = float2(lightSpacePosition.xy) * float2(0.5, -0.5) + 0.5;
        
        if (lightSpacePosition.z > 1.0) {
            return 0;
        }
        
        float shadowness = 0;
        
        float texelSizeWidth = 1.0/shadowMap1.get_width();
        float texelSizeHeight = 1.0/shadowMap1.get_height();
        float2 texelSize = float2(texelSizeWidth, texelSizeHeight);
        
        int index = 0;
        for (int x = -halfSquareSample; x <= halfSquareSample; x++) {
            for (int y = -halfSquareSample; y <= halfSquareSample; y++) {
                float2 samplePosition =  float2(x, y) * texelSize;
                samplePosition += samplePositionDefault;
                float closestDepth = clamp(shadowMap1.sample(sampler2d, samplePosition), 0.0, 1.0);
                float surfaceDepth = lightSpacePosition.z - 0.0001;
                shadowness += surfaceDepth < closestDepth ? 0.0 : 1.0;
                index++;
            }
        }
        
        return shadowness/sampleCount;
    }
};
