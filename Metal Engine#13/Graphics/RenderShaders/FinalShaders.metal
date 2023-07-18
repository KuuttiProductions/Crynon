
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex VertexOut final_vertex(VertexIn VerIn [[ stage_in ]]) {
    VertexOut VerOut;
    VerOut.position = float4(VerIn.position, 1);
    VerOut.textureCoordinate = VerIn.textureCoordinate;
    
    return VerOut;
}

fragment half4 final_fragment(VertexOut VerOut [[ stage_in ]],
                              texture2d<float> renderTargetColor [[ texture(0) ]],
                              sampler sampler [[ sampler(0) ]]) {
    float4 color = VerOut.color;
    
    if (!is_null_texture(renderTargetColor)) {
        color = renderTargetColor.sample(sampler, VerOut.textureCoordinate);
    }
    
    return half4(color);
}
