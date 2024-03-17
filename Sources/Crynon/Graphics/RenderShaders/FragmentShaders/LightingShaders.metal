
#include <metal_stdlib>
#import "../Shared.metal"
#import "../PhongShading.metal"
using namespace metal;

constexpr sampler samplerFragment (min_filter::linear,
                                   mag_filter::linear);

fragment float4 lighting_fragment(VertexOut VerOut [[ stage_in ]],
                                 constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                 constant LightData *lightData [[ buffer(3) ]],
                                 constant int &lightCount [[ buffer(4) ]],
                                 constant float2 &screenSize [[ buffer(5) ]],
                                 texture2d<half> gBufferTransparency [[ texture(0) ]],
                                 texture2d<float> gBufferColor [[ texture(1) ]],
                                 texture2d<float> gBufferPosition [[ texture(2) ]],
                                 texture2d<float> gBufferNormalShadow [[ texture(3) ]],
                                 texture2d<float> gBufferDepth [[ texture(4) ]],
                                 texture2d<float> gBufferMetalRoughAoIOR [[ texture(5) ]],
                                 texture2d<half> gBufferSSAO [[ texture(6) ]]) {
    
    half4 gBTransparency = gBufferTransparency.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBColor = gBufferColor.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBPosition = gBufferPosition.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBNormalShadow = gBufferNormalShadow.sample(samplerFragment, VerOut.textureCoordinate);
    float4 gBMetalRoughAoIOR = gBufferMetalRoughAoIOR.sample(samplerFragment, VerOut.textureCoordinate);
    
    float4 color = gBColor;
    
    if (!lightData) {
        color = float4(0, 0, 0, 1.0f);
        return color;
    }
    
    float ambientTerm = 0.3f;
    if (!is_null_texture(gBufferSSAO)) {
        float offsetX = 1.0f / screenSize.x;
        float offsetY = 1.0f / screenSize.y;
        float gBSSAO0 = gBufferSSAO.sample(samplerFragment, VerOut.textureCoordinate).r;
        float gBSSAO1 = gBufferSSAO.sample(samplerFragment, VerOut.textureCoordinate + float2(-offsetX, offsetY)).r;
        float gBSSAO2 = gBufferSSAO.sample(samplerFragment, VerOut.textureCoordinate + float2(-offsetX, -offsetY)).r;
        float gBSSAO3 = gBufferSSAO.sample(samplerFragment, VerOut.textureCoordinate + float2(offsetX, offsetY)).r;
        float gBSSAO4 = gBufferSSAO.sample(samplerFragment, VerOut.textureCoordinate + float2(offsetX, -offsetY)).r;
        float SSAO = (gBSSAO0 + gBSSAO1 + gBSSAO2 + gBSSAO3 + gBSSAO4) / 5.0f;
        
        // Get ambient term with effect from AO textures and SSAO buffer
        ambientTerm = min(SSAO, gBMetalRoughAoIOR.b) * 0.3f;
    }
    
    // Add Phong Shading
    ShaderMaterial sMat;
    sMat.color = float4(gBColor);
    sMat.metallic = gBMetalRoughAoIOR.r;
    sMat.roughness = gBMetalRoughAoIOR.g;
    sMat.ior = gBMetalRoughAoIOR.a;
    
    float3 lighting = PhongShading::getPhongLight(gBPosition.xyz,
                                                  normalize(gBNormalShadow.xyz),
                                                  lightData,
                                                  lightCount,
                                                  sMat,
                                                  fragmentSceneConstant.cameraPosition,
                                                  gBNormalShadow.a,
                                                  ambientTerm);
    color.rgb = color.rgb * color.a + (1.0f - color.a) * lighting * color.rgb;
    
    // Blend Transparency on top of the opaque image
    color.rgb = float3(gBTransparency.rgb) + (1.0f - gBTransparency.a) * color.rgb;
    
    return color;
}
