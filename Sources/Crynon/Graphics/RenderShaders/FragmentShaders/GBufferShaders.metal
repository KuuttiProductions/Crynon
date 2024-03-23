
#include <metal_stdlib>
#import "../Shared.metal"
#import "../Shadows.metal"
using namespace metal;

constexpr sampler samplerFragment (min_filter::linear,
                                   mag_filter::linear,
                                   mip_filter::linear);

fragment GBuffer gBuffer_fragment(VertexOut VerOut [[ stage_in ]],
                                  constant ShaderMaterial &mat [[ buffer(1) ]],
                                  constant float2 &screenSize [[ buffer(2) ]],
                                  depth2d<float> shadowMap1 [[ texture(0) ]],
                                  depth2d<float> shadowMap2 [[ texture(1) ]],
                                  depth2d<float> shadowMap3 [[ texture(2) ]],
                                  texture2d<float> textureJitter [[ texture(9) ]],
                                   
                                  texture2d<float> textureColor [[ texture(3) ]],
                                  texture2d<float> textureNormal [[ texture(4) ]],
                                  texture2d<float> textureEmission [[ texture(5) ]],
                                  texture2d<float> textureRoughness [[ texture(6) ]],
                                  texture2d<float> textureMetallic [[ texture(7) ]],
                                  texture2d<float> textureAoRoughMetal [[ texture(8) ]]) {
    GBuffer gBuffer;
    
    gBuffer.color = float4(mat.color.rgb, mat.emission.a);
    gBuffer.depth = VerOut.position.z;
    gBuffer.position = VerOut.worldPosition;
    gBuffer.metalRoughAoIOR.r = mat.metallic;
    gBuffer.metalRoughAoIOR.g = mat.roughness;
    gBuffer.metalRoughAoIOR.b = 1.0;
    gBuffer.metalRoughAoIOR.a = mat.ior;
    
    //Color
    if (!is_null_texture(textureColor)) {
        gBuffer.color.rgb = textureColor.sample(samplerFragment, VerOut.textureCoordinate).rgb;
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
        gBuffer.normalShadow.xyz = normalize(VerOut.normal);
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
    float4 emission = mat.emission;
    if (!is_null_texture(textureEmission)) { emission = textureEmission.sample(samplerFragment, VerOut.textureCoordinate); }
    gBuffer.color.rgb = emission.rgb * clamp(emission.a, 0.0f, 1.0f) + (1.0f - clamp(emission.a, 0.0f, 1.0f)) * gBuffer.color.rgb;
    gBuffer.color.rgb = clamp(gBuffer.color.rgb, 0.0, 32000);
    gBuffer.color.a = clamp(emission.a, 0.0f, 1.0f);
    
    //Shadow
    float3 lightSpacePosition = VerOut.lightSpacePosition.xyz / VerOut.lightSpacePosition.w;
    if (!is_null_texture(shadowMap1)) {
        gBuffer.normalShadow.a = Shadows::getLightness(shadowMap1, lightSpacePosition, textureJitter, VerOut.position.xy, screenSize);
    }
    
    return gBuffer;
}
