
#include <metal_stdlib>
#import "../Shared.metal"
#import "../Shadows.metal"
using namespace metal;

constexpr static sampler samplerFragment (min_filter::linear,
                                          mag_filter::linear);

fragment GBuffer gBuffer_fragment(VertexOut VerOut [[ stage_in ]],
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
        float3 sampleNormal = textureNormal.sample(samplerFragment, VerOut.textureCoordinate).xyz;
        float3x3 TBN = float3x3();
        TBN.columns[0] = VerOut.tangent;
        TBN.columns[1] = VerOut.bitangent;
        TBN.columns[2] = VerOut.normal;
        gBuffer.normalShadow.xyz = TBN * (sampleNormal * 2.0f - 1.0f);
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
