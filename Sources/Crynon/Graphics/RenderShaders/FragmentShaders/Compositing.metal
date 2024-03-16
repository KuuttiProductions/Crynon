
#include <metal_stdlib>
#import "../Shared.metal"
using namespace metal;

constexpr sampler sampler2d;

fragment half4 compositing_fragment(VertexIn VerIn [[ stage_in ]],
                                    texture2d<float> shadedImage [[ texture(0) ]],
                                    texture2d<float> bloomTexture [[ texture(1) ]]) {
    float4 shaded = shadedImage.sample(sampler2d, VerIn.textureCoordinate);
    float4 bloom = bloomTexture.sample(sampler2d, VerIn.textureCoordinate);
    
    return half4(bloom);
}
