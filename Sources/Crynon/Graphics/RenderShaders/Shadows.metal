
#include <metal_stdlib>
using namespace metal;

constexpr sampler sampler2d(filter::linear, address::repeat);

class Shadows {
public:
    static float random(float3 h, float w) {
        const float4 k = float4(0.3183099, 0.3678794, 0.5, 0.7071068);
        float n = dot(float4(h.x, h.y, h.z, w), k);
        n = fract(sin(n) * 43758.5453);
        n = n * 2.0 - 1.0;
        n = fract(n * n * 37738.5453);
        return n;
    }
    static float getLightness(depth2d<float> shadowMap1,
                              float3 lightSpacePosition,
                              float3 worldPosition,
                              float2 fragPos,
                              float2 screenSize,
                              sampler shadowSampler) {
        
        float penumbraSize = 5;
        int sampleCount = 16;
        float2 samples[32] = {
            float2( -0.94201624, -0.39906216 ),
            float2( 0.94558609, -0.76890725 ),
            float2( -0.094184101, -0.92938870 ),
            float2( 0.34495938, 0.29387760 ),
            float2( -0.91588581, 0.45771432 ),
            float2( -0.81544232, -0.87912464 ),
            float2( -0.38277543, 0.27676845 ),
            float2( 0.97484398, 0.75648379 ),
            float2( 0.44323325, -0.97511554 ),
            float2( 0.53742981, -0.47373420 ),
            float2( -0.26496911, -0.41893023 ),
            float2( 0.79197514, 0.19090188 ),
            float2( -0.24188840, 0.99706507 ),
            float2( -0.81409955, 0.91437590 ),
            float2( 0.19984126, 0.78641367 ),
            float2( 0.14383161, -0.14100790 )
        };
        
        float2 samplePositionDefault = float2(lightSpacePosition.xy) * float2(0.5, -0.5) + 0.5;
        
        if (lightSpacePosition.z > 1.0) {
            return 1;
        }
        
        float texelSizeWidth = 1.0/shadowMap1.get_width();
        float texelSizeHeight = 1.0/shadowMap1.get_height();
        float2 texelSize = float2(texelSizeWidth, texelSizeHeight);
        
        float bias = 0.001;
        
        float shadowness = 0;
        for (int i = 0; i < sampleCount; i++) {
            float r = random(worldPosition, i);
            float2 samplePosition = samplePositionDefault + normalize(samples[i]) * r * texelSize * penumbraSize;
            float sample = shadowMap1.sample(sampler2d, samplePosition);
            //shadowness += sample < lightSpacePosition.z - bias ? 1.0 : 0.0;
            shadowness += shadowMap1.sample_compare(shadowSampler, samplePosition, lightSpacePosition.z - bias);
        }

        return clamp(1-(shadowness / sampleCount), 0.0f, 1.0f);
    }
};
