
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex VertexOut shadow_vertex(VertexIn VerIn [[ stage_in ]],
                               constant ModelConstant &modelConstant [[ buffer(1) ]],
                               constant float4x4 &viewMatrix [[ buffer(3) ]]) {
    VertexOut VerOut;
    float4 worldPosition = modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.position = viewMatrix * worldPosition;
    VerOut.worldPosition = worldPosition.xyz;
    VerOut.textureCoordinate = VerIn.textureCoordinate;
    
    return VerOut;
}

static constexpr sampler sampler2d = sampler(min_filter::nearest,
                                             mag_filter::nearest);

fragment void shadow_fragment(VertexOut VerOut [[ stage_in]],
                              texture2d<float> textureColor [[ texture(3) ]]) {
    if (!is_null_texture(textureColor)) {
        half sample = textureColor.sample(sampler2d, VerOut.textureCoordinate).a;
        if (sample < 0.5) {
            discard_fragment();
        }
    }
}
