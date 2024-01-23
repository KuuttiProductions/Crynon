
#include <metal_stdlib>
#import "../Shared.metal"
#import "../Random/rng_header.metal"
using namespace metal;

constexpr sampler samplerSSAO(min_filter::nearest,
                              mag_filter::nearest,
                              address::repeat);

struct SamplePos {
    float3 position;
};

fragment float ssao_fragment(VertexOut VerOut [[ stage_in ]],
                             constant SamplePos *sampleKernel [[ buffer(0) ]],
                             texture2d<float> normalShadowTex [[ texture(0) ]],
                             texture2d<float> depthTex [[ texture(1) ]],
                             texture2d<float> jitterTex [[ texture(2) ]]) {
    float bias = 0.01;
    float radius = 0.1;
    int kernelSize = 32;
    
    float2 tCoord = VerOut.textureCoordinate;
    float3 normal = normalShadowTex.sample(samplerSSAO, tCoord).xyz;
    float compareDepth = depthTex.sample(samplerSSAO, tCoord).r;
    
    float3 randomVec = float3(1, 1, 1);
    float3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    float3 bitangent = cross(normal, tangent);
    float3x3 TBN = float3x3(tangent, bitangent, normal);
    
    float totalLightness = 0;
    
    for (int i = 0; i < kernelSize; i++) {
        float3 samplePos = sampleKernel[i].position;
        samplePos = samplePos * radius;
        
        float depth = depthTex.sample(samplerSSAO, tCoord + samplePos.xy).r;
        if (depth >= compareDepth) { totalLightness += 1; }
    }
    
    return (totalLightness / float(kernelSize)) * 2.0f;
}
