
#include <metal_stdlib>
#include "PhongShading.metal"
#include "Shadows.metal"
using namespace metal;

// DEPRECATED
fragment half4 forward_fragment(VertexOut VerOut [[ stage_in ]],
                              constant ShaderMaterial &material [[ buffer(1) ]],
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
        lightness = Shadows::getLightness(shadowMap1, surfacePosition);
    }
    
    color.rgb *= PhongShading::getPhongLight(VerOut.worldPosition,
                                         unitNormal,
                                         lightData,
                                         lightCount,
                                         material,
                                         fragmentSceneConstant.cameraPosition,
                                         lightness, 0.1);
    
    return half4(color.r, color.g, color.b, color.a);
}
