
#include <metal_stdlib>
#import "Shared.metal"
#import "Shadows.metal"
#import "PhongShading.metal"
#import "AmbientOcclusion.metal"
using namespace metal;

constexpr static sampler samplerFragment (min_filter::linear,
                                          mag_filter::linear);

fragment GBuffer deferred_fragment(VertexOut VerOut [[ stage_in ]],
                                   constant ShaderMaterial &mat [[ buffer(1) ]],
                                   depth2d<float> shadowMap1 [[ texture(0) ]],
                                   texture2d<float> textureColor [[ texture(3) ]]) {
    GBuffer gBuffer;
    
    gBuffer.color = half4(mat.color);
    gBuffer.depth = VerOut.position.z;
    gBuffer.position.xyz = VerOut.worldPosition;
    gBuffer.position.w = VerOut.position.w;
    gBuffer.normalShadow.xyz = VerOut.normal;
    gBuffer.metalRoughEmissionIOR.r = mat.metallic;
    gBuffer.metalRoughEmissionIOR.g = mat.roughness;
    gBuffer.metalRoughEmissionIOR.b = mat.emission;
    gBuffer.metalRoughEmissionIOR.a = mat.ior;
    
    if (!is_null_texture(textureColor)) {
        gBuffer.color = half4(textureColor.sample(samplerFragment, VerOut.textureCoordinate));
        if (gBuffer.color.a == 0) {
            discard_fragment();
        }
    }
    
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
    
    float ambientTerm = AmbientOcclusion::getAmbientTerm(gBuffer.normalShadow.xyz,
                                                         gBuffer.depth);
    
    if (gBuffer.metalRoughEmissionIOR.b == 0) {
        ShaderMaterial sm;
        sm.color = float4(gBuffer.color);
        sm.metallic = gBuffer.metalRoughEmissionIOR.r;
        sm.roughness = gBuffer.metalRoughEmissionIOR.g;
        sm.emission = gBuffer.metalRoughEmissionIOR.b;
        sm.ior = gBuffer.metalRoughEmissionIOR.a;
        
        half3 lighting = half3(PhongShading::getPhongLight(gBuffer.position.xyz,
                                                           normalize(gBuffer.normalShadow.xyz),
                                                           lightData,
                                                           lightCount,
                                                           sm,
                                                           fragmentSceneConstant.cameraPosition,
                                                           gBuffer.normalShadow.a,
                                                           ambientTerm));
        fc.color *= half4(lighting, 1);
    }
    
    
    float density = fragmentSceneConstant.fogDensity;
    float gradient = 100;
    fc.color *= density == 0 ? 1.0 : clamp(exp(-pow(gBuffer.depth*density, gradient)), 0.0, 1.0);
    
    return fc;
}
