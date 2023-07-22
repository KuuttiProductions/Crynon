
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
    
    return VerOut;
}
