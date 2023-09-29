
#include <metal_stdlib>
#include "../Shared.metal"
using namespace metal;

vertex VertexOut vector_vertex(VertexIn VerIn [[ stage_in ]],
                               constant ModelConstant &modelConstant [[ buffer(1) ]],
                               constant VertexSceneConstant &sceneConstant [[ buffer(2) ]],
                               constant float4x4 &depthViewMatrix [[ buffer(3) ]],
                               constant float4x4 &lookAtMatrix [[ buffer(4) ]] ) {
    
    VertexOut VerOut;
    float4 worldPosition = lookAtMatrix * modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.position = sceneConstant.projectionMatrix * sceneConstant.viewMatrix * worldPosition;
    
    VerOut.color = VerIn.color;
    VerOut.normal = (lookAtMatrix * modelConstant.modelMatrix * float4(VerIn.normal, 0)).xyz;
    VerOut.worldPosition = worldPosition.xyz;
    VerOut.textureCoordinate = VerIn.textureCoordinate;
    VerOut.lightSpacePosition = depthViewMatrix * worldPosition;
    
    return VerOut;
}
