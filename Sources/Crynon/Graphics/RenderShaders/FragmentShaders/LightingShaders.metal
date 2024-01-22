
#include <metal_stdlib>
#import "../Shared.metal"
#import "../PhongShading.metal"
using namespace metal;

fragment half4 lighting_fragment(VertexOut VerOut [[ stage_in ]],
                                 constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                 constant LightData *lightData [[ buffer(3) ]],
                                 constant int &lightCount [[ buffer(4) ]],
                                 texture2d<half> gBufferTransparency [[ texture(0) ]],
                                 texture2d<half> gBufferColor [[ texture(1) ]],
                                 texture2d<float> gBufferPosition [[ texture(2) ]],
                                 texture2d<float> gBufferNormalShadow [[ texture(3) ]],
                                 texture2d<float> gBufferDepth [[ texture(4) ]],
                                 texture2d<float> gBufferMetalRoughAoIOR [[ texture(5) ]],
                                 texture2d<half> gBufferEmission [[ texture(6) ]],
                                 texture2d<half> gBufferSSAO [[ texture(7) ]]) {

    half4 gBTransparency = gBufferTransparency.sample(samplerFragment, VerOut.textureCoordinate);
    half4 gBColor = gBufferColor.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBPosition = gBufferPosition.sample(samplerFragment, VerOut.textureCoordinate);
    half4 gBEmission = gBufferEmission.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBNormalShadow = gBufferNormalShadow.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBMetalRoughAoIOR = gBufferMetalRoughAoIOR.sample(samplerFragment, VerOut.textureCoordinate);
    float gBSSAO = gBufferSSAO.sample(samplerFragment, VerOut.textureCoordinate).r;
    
    half4 color = gBColor;
    
    if (!lightData) {
        color = half4(0, 0, 0, 1);
        return color;
    }
    
    // Get ambient term with effect from AO textures and SSAO buffer
    float ambientTerm = max(gBSSAO - gBMetalRoughAoIOR.b, 0.0f);
    
    // Add Phong Shading
    if (gBEmission.a != 1.0) {
        ShaderMaterial sMat;
        sMat.color = float4(gBColor);
        sMat.metallic = gBMetalRoughAoIOR.r;
        sMat.roughness = gBMetalRoughAoIOR.g;
        sMat.emission = float4(gBEmission);
        sMat.ior = gBMetalRoughAoIOR.a;
        
        half3 lighting = half3(PhongShading::getPhongLight(gBPosition.xyz,
                                                           normalize(gBNormalShadow.xyz),
                                                           lightData,
                                                           lightCount,
                                                           sMat,
                                                           fragmentSceneConstant.cameraPosition,
                                                           gBNormalShadow.a,
                                                           ambientTerm));
        color *= half4(lighting, 1);
    }
    
    // Blend Transparency on top of the opaque image
    color.rgb = gBTransparency.rgb + (1.0h - gBTransparency.a) * color.rgb;
    
//    FOG DISABLED FOR NOW
//    float density = fragmentSceneConstant.fogDensity;
//    float gradient = 100;
//    color *= density == 0 ? 1.0 : clamp(exp(-pow(gBDepth*density, gradient)), 0.0, 1.0);
    
    return color;
}
