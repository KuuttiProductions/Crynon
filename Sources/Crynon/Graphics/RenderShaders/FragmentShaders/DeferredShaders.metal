
#include <metal_stdlib>
#import "../Shared.metal"
#import "../Shadows.metal"
#import "../PhongShading.metal"
#import "../AmbientOcclusion.metal"
using namespace metal;

constexpr static sampler samplerFragment (min_filter::linear,
                                          mag_filter::linear);

fragment GBuffer deferred_fragment(VertexOut VerOut [[ stage_in ]],
                                   constant ShaderMaterial &mat [[ buffer(1) ]],
                                   depth2d<float> shadowMap1 [[ texture(0) ]],
                                   depth2d<float> shadowMap2 [[ texture(1) ]],
                                   depth2d<float> shadowMap3 [[ texture(2) ]],
                                   
                                   texture2d<float> textureColor [[ texture(3) ]],
                                   texture2d<float> textureNormal [[ texture(4) ]],
                                   texture2d<float> textureEmission [[ texture(5) ]],
                                   texture2d<float> textureRoughness [[ texture(6) ]],
                                   texture2d<float> textureMetallic [[ texture(7) ]],
                                   texture2d<float> textureAoRoughMetal [[ texture(8) ]]) {
    GBuffer gBuffer;
    
    gBuffer.color = half4(mat.color);
    gBuffer.depth = VerOut.position.z;
    gBuffer.position.xyz = VerOut.worldPosition;
    gBuffer.position.w = VerOut.position.w;
    gBuffer.metalRoughAoIOR.r = mat.metallic;
    gBuffer.metalRoughAoIOR.g = mat.roughness;
    gBuffer.metalRoughAoIOR.b = 1.0;
    gBuffer.metalRoughAoIOR.a = mat.ior;
    gBuffer.emission = half4(mat.emission);
    
    //Color
    if (!is_null_texture(textureColor)) {
        gBuffer.color = half4(textureColor.sample(samplerFragment, VerOut.textureCoordinate));
        if (gBuffer.color.a == 0) {
            discard_fragment();
        }
    }
    
    //Normal
    if (!is_null_texture(textureNormal)) {
        gBuffer.normalShadow.xyz = textureNormal.sample(samplerFragment, VerOut.textureCoordinate).xyz;
    } else {
        gBuffer.normalShadow.xyz = VerOut.normal;
    }
    
    //Roughness and Metallic
    if (!is_null_texture(textureAoRoughMetal)) {
        float3 aoRoughMetal = textureAoRoughMetal.sample(samplerFragment, VerOut.textureCoordinate).rgb;
        gBuffer.metalRoughAoIOR.r = aoRoughMetal.b;
        gBuffer.metalRoughAoIOR.g = aoRoughMetal.g;
        gBuffer.metalRoughAoIOR.b = aoRoughMetal.r;
    } else {
        if (!is_null_texture(textureRoughness)) {
            gBuffer.metalRoughAoIOR.g = textureRoughness.sample(samplerFragment, VerOut.textureCoordinate).r;
        }
        if (!is_null_texture(textureMetallic)) {
            gBuffer.metalRoughAoIOR.r = textureMetallic.sample(samplerFragment, VerOut.textureCoordinate).r;
        }
    }
    
    //Emission
    if (!is_null_texture(textureEmission)) {
        gBuffer.emission = half4(textureEmission.sample(samplerFragment, VerOut.textureCoordinate));
    }
    
    //Shadow
    float3 lightSpacePosition = VerOut.lightSpacePosition.xyz / VerOut.lightSpacePosition.w;
    if (!is_null_texture(shadowMap1)) {
        gBuffer.normalShadow.a = Shadows::getLightness(shadowMap1, lightSpacePosition);
    }
    
    return gBuffer;
}

struct finalColor {
    half4 color [[ color(1), raster_order_group(1) ]];
};

fragment finalColor lighting_fragment(VertexOut VerOut [[ stage_in ]],
                                      GBuffer gBuffer,
                                      constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                      constant LightData *lightData [[ buffer(3) ]],
                                      constant int &lightCount [[ buffer(4) ]]) {

    finalColor fc;
    fc.color = gBuffer.color;
    
    if (!lightData) {
        fc.color = half4(0, 0, 0, 1);
        return fc;
    }
    
    float ambientTerm = AmbientOcclusion::getAmbientTerm(gBuffer.normalShadow.xyz,
                                                         gBuffer.depth,
                                                         gBuffer.metalRoughAoIOR.b);
    
    if (gBuffer.emission.a != 1.0) {
        ShaderMaterial sm;
        sm.color = float4(gBuffer.color);
        sm.metallic = gBuffer.metalRoughAoIOR.r;
        sm.roughness = gBuffer.metalRoughAoIOR.g;
        sm.emission = float4(gBuffer.emission);
        sm.ior = gBuffer.metalRoughAoIOR.a;
        
        half3 lighting = half3(PhongShading::getPhongLight(gBuffer.position.xyz,
                                                           normalize(gBuffer.normalShadow.xyz),
                                                           lightData,
                                                           lightCount,
                                                           sm,
                                                           fragmentSceneConstant.cameraPosition,
                                                           gBuffer.normalShadow.a,
                                                           ambientTerm));
        fc.color *= half4(lighting, 1);
    } else {
        fc.color += gBuffer.emission;
    }
    
    float density = fragmentSceneConstant.fogDensity;
    float gradient = 100;
    fc.color *= density == 0 ? 1.0 : clamp(exp(-pow(gBuffer.depth*density, gradient)), 0.0, 1.0);
    
    return fc;
}
