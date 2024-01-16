
#include <metal_stdlib>
#include "../Shared.metal"
using namespace metal;

struct SimpleVertexIn {
    float3 position [[ attribute(0) ]];
};

vertex VertexOut simple_vertex(SimpleVertexIn VerIn [[ stage_in ]],
                               constant ModelConstant &modelConstant [[ buffer(1) ]],
                               constant VertexSceneConstant &sceneConstant [[ buffer(2) ]],
                               constant float4x4 &depthViewMatrix [[ buffer(3) ]]) {
    
    VertexOut VerOut;
    float4 worldPosition = modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.position = sceneConstant.projectionMatrix * sceneConstant.viewMatrix * worldPosition;

    VerOut.worldPosition = worldPosition.xyz;
    VerOut.normal = normalize(VerIn.position);
    VerOut.lightSpacePosition = depthViewMatrix * worldPosition;
    
    return VerOut;
}

vertex VertexOut quad_vertex(VertexIn VerIn [[ stage_in ]],
                              constant VertexSceneConstant &sceneConstant) {
    VertexOut VerOut;
    VerOut.position = float4(VerIn.position, 1);
    VerOut.textureCoordinate = VerIn.textureCoordinate;
    return VerOut;
}
