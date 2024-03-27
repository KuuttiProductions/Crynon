
#include <metal_stdlib>
#import "../Shared.metal"
#import "../ACES.metal"
using namespace metal;

constexpr sampler sampler2d (mag_filter::linear,
                             min_filter::linear,
                             address::clamp_to_edge);

struct CompositionConstant {
    float bloomIntensity;
};

fragment float4 compositing_fragment(VertexIn VerIn [[ stage_in ]],
                                     constant CompositionConstant &cc [[ buffer(0) ]],
                                     texture2d<float> shadedImage [[ texture(0) ]],
                                     texture2d<float> bloomTexture [[ texture(1) ]]) {
    float3 finalColor = float3(0, 0, 0);
    ACES aces = ACES();
    
    float4 shaded = shadedImage.sample(sampler2d, VerIn.textureCoordinate);
    float4 bloom = bloomTexture.sample(sampler2d, VerIn.textureCoordinate);
    
    float4 composite = shaded + bloom * cc.bloomIntensity / 10.0f;
    finalColor = aces.ACES_FAST(composite.rgb, 1.0f);
    
    return float4(finalColor, 1.0f);
}
