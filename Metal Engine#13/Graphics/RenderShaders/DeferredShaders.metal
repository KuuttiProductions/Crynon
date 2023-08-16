
#include <metal_stdlib>
#import "Shared.metal"
#import "Shadows.metal"
#import "PhongShading.metal"
using namespace metal;

fragment GBuffer deferred_fragment(VertexOut VerOut [[ stage_in ]],
                                   constant ShaderMaterial &mat [[ buffer(1) ]],
                                   depth2d<float> shadowMap1 [[ texture(0) ]],
                                   texture2d<float> textureColor [[ texture(3) ]]) {
    GBuffer gBuffer;
    
    gBuffer.color = half4(mat.color);
    gBuffer.depth = VerOut.position.z / VerOut.position.w;
    gBuffer.normal = float4(VerOut.normal, 1);
    gBuffer.positionShadow.xyz = VerOut.worldPosition;
    gBuffer.metalRoughEmissionIOR.r = mat.metallic;
    gBuffer.metalRoughEmissionIOR.g = mat.roughness;
    gBuffer.metalRoughEmissionIOR.b = mat.emission;
    gBuffer.metalRoughEmissionIOR.a = mat.ior;
    
    if (!is_null_texture(textureColor)) {
        gBuffer.color = half4(textureColor.sample(sampler2d, VerOut.textureCoordinate));
        if (gBuffer.color.a == 0) {
            discard_fragment();
        }
    }
    
    float3 lightSpacePosition = VerOut.lightSpacePosition.xyz / VerOut.lightSpacePosition.w;
    if (!is_null_texture(shadowMap1)) {
        gBuffer.positionShadow.a = Shadows::getLightness(shadowMap1, lightSpacePosition);
    }
    
    return gBuffer;
}

struct finalColor {
    half4 color [[ color(0), raster_order_group(2) ]];
};

fragment finalColor lighting_fragment(GBuffer gBuffer,
                                      constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                      constant LightData *lightData [[ buffer(3) ]],
                                      constant int &lightCount [[ buffer(4) ]]) {

    finalColor fc;
    fc.color = gBuffer.color;
    if (gBuffer.metalRoughEmissionIOR.b == 0) {
        ShaderMaterial sm;
        sm.color = float4(gBuffer.color);
        sm.metallic = gBuffer.metalRoughEmissionIOR.r;
        sm.roughness = gBuffer.metalRoughEmissionIOR.g;
        sm.emission = gBuffer.metalRoughEmissionIOR.b;
        sm.ior = gBuffer.metalRoughEmissionIOR.a;
        half3 lighting = half3(PhongShading::getPhongLight(gBuffer.positionShadow.xyz,
                                                           normalize(gBuffer.normal.xyz),
                                                           lightData,
                                                           lightCount,
                                                           sm,
                                                           fragmentSceneConstant.cameraPosition,
                                                           gBuffer.positionShadow.a));
        fc.color *= half4(lighting, 1);
    }
    
    return fc;
}
