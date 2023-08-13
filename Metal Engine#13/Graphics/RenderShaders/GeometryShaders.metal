
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex VertexOut default_vertex(VertexIn VerIn [[ stage_in ]],
                              constant ModelConstant &modelConstant [[ buffer(1) ]],
                              constant VertexSceneConstant &sceneConstant [[ buffer(2) ]],
                              constant float4x4 &depthViewMatrix [[ buffer(3) ]]) {
    
    VertexOut VerOut;
    float4 worldPosition = modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.position = sceneConstant.viewMatrix * worldPosition;
    
    VerOut.color = VerIn.color;
    VerOut.normal = (modelConstant.modelMatrix * float4(VerIn.normal, 0)).xyz;
    VerOut.worldPosition = worldPosition.xyz;
    VerOut.textureCoordinate = VerIn.textureCoordinate;
    VerOut.lightSpacePosition = depthViewMatrix * worldPosition;
    
    return VerOut;
}
