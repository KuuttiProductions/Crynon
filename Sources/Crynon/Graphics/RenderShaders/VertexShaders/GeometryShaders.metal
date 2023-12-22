
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
    
    float3 normal = (modelConstant.modelMatrix * float4(VerIn.normal, 0)).xyz;
    float3 tangent = (modelConstant.modelMatrix * float4(VerIn.tangent, 0)).xyz;
    float3 bitangent = cross(normal, tangent);
    
    VerOut.tangent = tangent;
    VerOut.bitangent = bitangent;
    VerOut.normal = normal;
    float3x3 TBN = float3x3(tangent, bitangent, normal);
    TBN = transpose(TBN);
    
    VerOut.lightSpacePosition = (depthViewMatrix * worldPosition);
    
    return VerOut;
}
