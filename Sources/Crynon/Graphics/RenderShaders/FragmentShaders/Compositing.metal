
#include <metal_stdlib>
#import "../Shared.metal"
using namespace metal;

constexpr sampler sampler2d (mag_filter::linear,
                             min_filter::linear,
                             address::clamp_to_edge);

fragment half4 compositing_fragment(VertexIn VerIn [[ stage_in ]],
                                    texture2d<float> shadedImage [[ texture(0) ]],
                                    texture2d<float> bloomTexture [[ texture(1) ]]) {
    half3 finalColor = half3(0, 0, 0);
    
    float4 shaded = shadedImage.sample(sampler2d, VerIn.textureCoordinate);
    float4 bloom = bloomTexture.sample(sampler2d, VerIn.textureCoordinate);
    
    half4 composite = half4(shaded + bloom);
    
    finalColor = pow(composite, 1.0f / 2.2f).rgb;
    
    return half4(finalColor, 1.0f);
}
