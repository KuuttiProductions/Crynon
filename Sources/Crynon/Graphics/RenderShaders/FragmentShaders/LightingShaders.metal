
#include <metal_stdlib>
#import "../Shared.metal"
#import "../PhongShading.metal"
#import "../AmbientOcclusion.metal"
using namespace metal;

constexpr static sampler samplerFragment (min_filter::linear,
                                          mag_filter::linear);

fragment half4 lighting_fragment(VertexOut VerOut [[ stage_in ]],
                                 constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                 constant LightData *lightData [[ buffer(3) ]],
                                 constant int &lightCount [[ buffer(4) ]],
                                 texture2d<float> gBufferColor [[ texture(0) ]],
                                 texture2d<float> gBufferPosition [[ texture(1) ]],
                                 texture2d<float> gBufferNormalShadow [[ texture(2) ]],
                                 texture2d<float> gBufferDepth [[ texture(3) ]],
                                 texture2d<float> gBufferMetalRoughAoIOR [[ texture(4) ]],
                                 texture2d<float> gBufferEmission [[ texture(5) ]]) {

    half4 color;
    color = half4(gBufferColor.sample(samplerFragment, VerOut.textureCoordinate));
    
//    if (!lightData) {
//        color = half4(0, 0, 0, 1);
//        return color;
//    }
//    
//    float ambientTerm = AmbientOcclusion::getAmbientTerm(gBufferNormalShadow.xyz,
//                                                         gBufferDepth,
//                                                         gBufferMetalRoughAoIOR.b);
//    
//    if (gBuffer.emission.a != 1.0) {
//        ShaderMaterial sm;
//        sm.color = float4(gBuffer.color);
//        sm.metallic = gBuffer.metalRoughAoIOR.r;
//        sm.roughness = gBuffer.metalRoughAoIOR.g;
//        sm.emission = float4(gBuffer.emission);
//        sm.ior = gBuffer.metalRoughAoIOR.a;
//        
//        half3 lighting = half3(PhongShading::getPhongLight(gBufferPosition.xyz,
//                                                           normalize(gBufferNormalShadow.xyz),
//                                                           lightData,
//                                                           lightCount,
//                                                           sm,
//                                                           fragmentSceneConstant.cameraPosition,
//                                                           gBufferNormalShadow.a,
//                                                           ambientTerm));
//        fc.color *= half4(lighting, 1);
//        
//        float diffuse = dot(-lightData[0].direction, gBufferNormalShadow.xyz);
//        
//    } else {
//        fc.color += gBuffer.emission;
//    }
//    
//    float density = fragmentSceneConstant.fogDensity;
//    float gradient = 100;
//    fc.color *= density == 0 ? 1.0 : clamp(exp(-pow(gBuffer.depth*density, gradient)), 0.0, 1.0);
    
    return color;
}
