
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex VertexOut sky_vertex(VertexIn VerIn [[ stage_in]],
                            constant ModelConstant &mc [[ buffer(1) ]],
                            constant float4x4 &skyViewMatrix [[ buffer(4) ]]) {
    VertexOut verOut;
    
    verOut.position = skyViewMatrix * mc.modelMatrix * float4(VerIn.position, 1);
    
    return verOut;
}
