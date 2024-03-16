
#include <metal_stdlib>
using namespace metal;

constexpr sampler sampler2d (mag_filter::nearest,
                             min_filter::nearest,
                             border_color::opaque_white,
                             address::clamp_to_border);

constexpr sampler sampler2dx (mag_filter::nearest,
                              min_filter::nearest,
                              border_color::opaque_white,
                              address::repeat);

class Shadows {
public:
    
    static float getLightness(depth2d<float> shadowMap1,
                              float3 lightSpacePosition,
                              texture2d<float> jitterTexture,
                              float2 fragPos,
                              float2 screenSize) {
                
        int sampleCount = 16;
        int halfSquareSample = sqrt(float(sampleCount))/2;

        float2 samplePositionDefault = float2(lightSpacePosition.xy) * float2(0.5, -0.5) + 0.5;
        
        if (lightSpacePosition.z > 1.0) {
            return 1;
        }
        
        float shadowness = 0;
        
        float texelSizeWidth = 1.0/shadowMap1.get_width();
        float texelSizeHeight = 1.0/shadowMap1.get_height();
        float2 texelSize = float2(texelSizeWidth, texelSizeHeight);
        
        float bias = 0.0001;
        
        float2 texCoord = float2(fragPos.x / screenSize.x, fragPos.y / screenSize.y);
        float2 texelSizeSampler = float2(screenSize.x / 4.0f, screenSize.y / 4.0f);
        float rotator = jitterTexture.sample(sampler2dx, fragPos * texelSizeSampler).x * 2 * 3.14159;
        
        int index = 0;
        for (short x = -halfSquareSample; x <= halfSquareSample; x++) {
            for (short y = -halfSquareSample; y <= halfSquareSample; y++) {
                float2 samplePosition =  float2(x, y) * texelSize;
                //samplePosition.x = samplePosition.x*cos(rotator) - y*sin(rotator);
                //samplePosition.y = samplePosition.x*sin(rotator) + y*cos(rotator);
                samplePosition += samplePositionDefault;
                float closestDepth = clamp(shadowMap1.sample(sampler2d, samplePosition), 0.0, 1.0);
                float surfaceDepth = lightSpacePosition.z - bias;
                shadowness += surfaceDepth < closestDepth ? 0.0 : 1.0;
                index++;
            }
        }
    
        return clamp(1-(shadowness/sampleCount), 0.0, 1.0);
    }
};
