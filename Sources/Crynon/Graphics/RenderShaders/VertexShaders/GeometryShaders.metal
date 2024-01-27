
#include <metal_stdlib>
#include "../Shared.metal"
using namespace metal;

vertex VertexOut default_vertex(VertexIn VerIn [[ stage_in ]],
                                constant ModelConstant &modelConstant [[ buffer(1) ]],
                                constant VertexSceneConstant &sceneConstant [[ buffer(2) ]],
                                constant float4x4 &depthViewMatrix [[ buffer(3) ]]) {
    
    VertexOut VerOut;
    float4 worldPosition = modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.position = sceneConstant.projectionMatrix * sceneConstant.viewMatrix * worldPosition;
    
    VerOut.color = VerIn.color;
    VerOut.textureCoordinate = VerIn.textureCoordinate;
    VerOut.worldPosition = worldPosition.xyz;

    VerOut.normal = (modelConstant.modelMatrix * float4(VerIn.normal, 0)).xyz;
    VerOut.tangent = (modelConstant.modelMatrix * float4(VerIn.tangent, 0)).xyz;
    VerOut.bitangent = cross(VerOut.normal, VerOut.tangent);
    
    VerOut.lightSpacePosition = (depthViewMatrix * worldPosition);
    
    VerOut.color = sceneConstant.viewMatrix * worldPosition;
    
    return VerOut;
}
