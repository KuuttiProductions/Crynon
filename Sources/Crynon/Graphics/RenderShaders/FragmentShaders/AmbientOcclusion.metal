
#include <metal_stdlib>
#import "../Shared.metal"
#import "../Random/rng_header.metal"
using namespace metal;

constexpr sampler samplerSSAO(min_filter::nearest,
                              mag_filter::nearest,
                              address::repeat);

fragment float ssao_fragment(VertexOut VerOut [[ stage_in ]],
                             constant float3 *sampleKernel [[ buffer(0) ]],
                             texture2d<float> depthTex [[ texture(0) ]],
                             texture2d<float> jitterTex [[ texture(1) ]]) {
    float bias = 0.05f;
    float radius = 0.05f;
    int kernelSize = 32;
    
    float2 tCoord = VerOut.textureCoordinate;
    float depth = depthTex.sample(samplerSSAO, tCoord).r;
    
    float totalLightness = 0;
    
    for (int i = 0; i < kernelSize; i++) {
        float2 samplePos = sampleKernel[i].xy;
        samplePos = samplePos * radius;
        
        float angle = 6.283185 * jitterTex.sample(samplerSSAO, tCoord*64).x;
        
        samplePos.x = samplePos.x * cos(angle) - samplePos.y * sin(angle);
        samplePos.y = samplePos.x * sin(angle) + samplePos.y * cos(angle);
    
        float sampleDepth = depthTex.sample(samplerSSAO, tCoord + samplePos).r;
        if (sampleDepth >= depth) {
            totalLightness += 1;
        }
    }
    
    return (totalLightness / float(kernelSize));
}
