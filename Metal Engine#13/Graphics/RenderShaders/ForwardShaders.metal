
#include <metal_stdlib>
#include "PhongShading.metal"
#include "Shadows.metal"
using namespace metal;

vertex VertexOut basic_vertex(VertexIn VerIn [[ stage_in ]],
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
    VerOut.pointSize = 10;
    
    return VerOut;
}

fragment half4 basic_fragment(VertexOut VerOut [[ stage_in ]],
                              constant Material &material [[ buffer(1) ]],
                              constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                              constant LightData *lightData [[ buffer(3) ]],
                              constant int &lightCount [[ buffer(4) ]],
                              depth2d<float> shadowMap1 [[ texture(0) ]],
                              texture2d<float> textureColor [[ texture(3) ]]) {
    
    float4 color = material.color;
    float3 unitNormal = normalize(VerOut.normal);
    float lightness = 0;
    
    if (!is_null_texture(textureColor)) {
        color = textureColor.sample(sampler2d, VerOut.textureCoordinate);
    }
    
    if (color.a < 0.01) {
        discard_fragment();
    }
    
    float3 surfacePosition = VerOut.lightSpacePosition.xyz / VerOut.lightSpacePosition.w;
    if (!is_null_texture(shadowMap1)) {
        lightness = 1-clamp(Shadows::getShadowness(shadowMap1, surfacePosition), 0.0, 1.0);
    }
    
    color.rgb *= PhongShading::getPhongLight(VerOut.worldPosition,
                                         unitNormal,
                                         lightData,
                                         lightCount,
                                         material,
                                         fragmentSceneConstant.cameraPosition,
                                         lightness);
    
    return half4(color.r, color.g, color.b, color.a);
}
