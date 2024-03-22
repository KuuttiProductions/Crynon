
#include <metal_stdlib>
#import "../Shared.metal"
#import "../ACES.metal"
using namespace metal;

constexpr sampler sampler2d (mag_filter::linear,
                             min_filter::linear,
                             address::clamp_to_edge);

fragment float4 compositing_fragment(VertexIn VerIn [[ stage_in ]],
                                     constant float &maxBrightness [[ buffer(0) ]],
                                     texture2d<float> shadedImage [[ texture(0) ]],
                                     texture2d<float> bloomTexture [[ texture(1) ]]) {
    float3 finalColor = float3(0, 0, 0);
    ACES aces = ACES();
    
    float4 shaded = shadedImage.sample(sampler2d, VerIn.textureCoordinate);
    float4 bloom = bloomTexture.sample(sampler2d, VerIn.textureCoordinate);
    
    float4 composite = shaded + bloom;
    finalColor = aces.ACES_FAST(composite.rgb, 1.0);
    
    return float4(finalColor, 1.0f);
}
