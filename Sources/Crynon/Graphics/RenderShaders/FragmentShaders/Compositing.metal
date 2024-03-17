
#include <metal_stdlib>
#import "../Shared.metal"
using namespace metal;

constexpr sampler sampler2d (mag_filter::linear,
                             min_filter::linear,
                             address::clamp_to_edge);

fragment float4 compositing_fragment(VertexIn VerIn [[ stage_in ]],
                                    texture2d<float> shadedImage [[ texture(0) ]],
                                    texture2d<float> bloomTexture [[ texture(1) ]]) {
    float3 finalColor = float3(0, 0, 0);
    
    float4 shaded = shadedImage.sample(sampler2d, VerIn.textureCoordinate);
    float4 bloom = bloomTexture.sample(sampler2d, VerIn.textureCoordinate);
    
    float3 composite = float4(shaded + bloom).rgb;
    finalColor = pow(finalColor, 1.0f / 2.2f).rgb;
    
    return float4(composite, 1.0f);
}
