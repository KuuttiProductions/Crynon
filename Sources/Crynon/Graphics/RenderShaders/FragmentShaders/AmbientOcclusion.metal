
#include <metal_stdlib>
#import "../Shared.metal"
#import "../Random/rng_header.metal"
using namespace metal;

constexpr sampler samplerTiling(min_filter::nearest,
                              mag_filter::nearest,
                              address::repeat);

constexpr sampler samplerFragment (min_filter::linear,
                                   mag_filter::linear);

fragment float ssao_fragment(VertexOut VerOut [[ stage_in ]],
                             constant float3 *sampleKernel [[ buffer(0) ]],
                             constant float2 &screenSize [[ buffer(1) ]],
                             constant float4x4 &projMat [[ buffer(2) ]],
                             texture2d<float> normalTex [[ texture(0) ]],
                             texture2d<float> positionTex [[ texture(1) ]],
                             texture2d<float> jitterTex [[ texture(2) ]]) {
    float radius = 0.3f;
    float bias = 0.01;
    int kernelSize = 16;
    
    float2 texelSize = float2(screenSize.x / 4.0f, screenSize.y / 4.0f);
    float2 tCoord = VerOut.textureCoordinate;
    
    float3 fragPos = positionTex.sample(samplerFragment, tCoord).xyz;
    float3 normal = normalTex.sample(samplerFragment, tCoord).xyz;
    float3 randomVec = float3(jitterTex.sample(samplerTiling, tCoord * texelSize).xy, 0.0f);
    
    float3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    float3 bitangent = cross(normal, tangent);
    float3x3 TBN = float3x3();
    TBN[0] = tangent;
    TBN[1] = bitangent;
    TBN[2] = normal;
    
    float occlusion = 0.0f;
    for (int i = 0; i < kernelSize; i++) {
        float3 samplePos = TBN * sampleKernel[i];
        samplePos = fragPos + samplePos * radius;
        
        float4 offset = float4(samplePos, 1.0f);
        offset = projMat * offset;
        offset.xyz = offset.xyz / offset.w;
        offset.xz = offset.xz * 0.5f + 0.5f;
        offset.y = offset.y * -0.5f + 0.5f;

        float sampleDepth = positionTex.sample(samplerFragment, offset.xy).z;
        float rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));
        float depthDifference = sampleDepth - (fragPos.z + bias);
        occlusion += (depthDifference > 0.0 ? 1.0 : 0.0) * rangeCheck;
    }
    
    return 1.0f - (occlusion / float(kernelSize));
}
