//
//  BasicShaders.metal
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 31.5.2023.
//

#include <metal_stdlib>
#include "PhongShading.metal"
using namespace metal;

vertex VertexOut basic_vertex(VertexIn VerIn [[ stage_in ]],
                              constant ModelConstant &modelConstant [[ buffer(1) ]],
                              constant VertexSceneConstant &sceneConstant [[ buffer(2) ]]) {
    
    VertexOut VerOut;
    float4 worldPosition = modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.position = sceneConstant.viewMatrix * worldPosition;
    
    VerOut.color = VerIn.color;
    VerOut.normal = (modelConstant.modelMatrix * float4(VerIn.normal, 0)).xyz;
    VerOut.worldPosition = worldPosition.xyz;
    
    return VerOut;
}

fragment half4 basic_fragment(VertexOut VerOut [[ stage_in ]],
                              constant Material &material [[ buffer(1) ]],
                              constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                              constant LightData *lightData [[ buffer(3) ]],
                              constant int &lightCount [[ buffer(4) ]]) {
    
    float4 color = material.color;
    float3 unitNormal = normalize(VerOut.normal);
    
    color *= PhongShading::getPhongLight(VerOut.worldPosition,
                                         unitNormal,
                                         lightData,
                                         lightCount,
                                         material,
                                         fragmentSceneConstant.cameraPosition);
    
    return half4(color.r, color.g, color.b, color.a);
}
