
#include <metal_stdlib>
#include "../Shared.metal"
using namespace metal;

vertex VertexOut sky_vertex(VertexIn VerIn [[ stage_in]],
                            constant ModelConstant &mc [[ buffer(1) ]],
                            constant float4x4 &depthViewMatrix [[ buffer(3) ]],
                            constant float4x4 &skyViewMatrix [[ buffer(4) ]]) {
    VertexOut verOut;
    
    float4 worldPosition = mc.modelMatrix * float4(VerIn.position, 1);
    verOut.position = skyViewMatrix * worldPosition;
    verOut.worldPosition = worldPosition;
    verOut.textureCoordinate = VerIn.textureCoordinate;
    verOut.color = VerIn.color;
    verOut.normal = VerIn.normal;
    verOut.lightSpacePosition = depthViewMatrix * worldPosition;
    
    return verOut;
}
