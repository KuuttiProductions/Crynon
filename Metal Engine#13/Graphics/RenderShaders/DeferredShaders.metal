
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

struct GBuffer {
    half4 final [[ color(0), raster_order_group(2) ]];
    half4 color [[ color(1), raster_order_group(1) ]];
    float4 position [[ color(2), raster_order_group(1) ]];
    float4 normal [[ color(3), raster_order_group(1) ]];
    float depth [[ color(4), raster_order_group(1) ]];
};

static constexpr sampler sampler2d = sampler(min_filter::linear,
                                             min_filter::linear);

fragment GBuffer deferred_fragment(VertexOut VerOut [[ stage_in ]],
                                   constant ShaderMaterial &mat [[ buffer(1) ]],
                                   texture2d<float> shadowMap1 [[ texture(0) ]],
                                   texture2d<float> textureColor [[ texture(3) ]]) {
    GBuffer gBuffer;
    
    gBuffer.color = half4(mat.color);
    gBuffer.depth = VerOut.position.z / VerOut.position.w;
    gBuffer.normal = float4(VerOut.normal, 1);
    gBuffer.position = float4(VerOut.worldPosition, 1);
    
    if (!is_null_texture(textureColor)) {
        gBuffer.color = half4(textureColor.sample(sampler2d, VerOut.textureCoordinate));
    }
    
    return gBuffer;
}

struct finalColor {
    half4 color [[ color(0), raster_order_group(2) ]];
};

fragment finalColor lighting_fragment(GBuffer gBuffer) {

    finalColor fc;
    fc.color = gBuffer.color;
    
    return fc;
}
