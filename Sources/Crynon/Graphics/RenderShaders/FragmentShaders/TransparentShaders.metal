
#include <metal_stdlib>
#import "../Shared.metal"
#import "../PhongShading.metal"
#import "../Shadows.metal"
using namespace metal;

static constexpr constant short tLayersCount = 4; //Number of transparent layers stored in tile memory

struct TransparentFragmentValues {
    half4 colors [[ raster_order_group(1) ]] [tLayersCount];
    float depths [[ raster_order_group(1) ]] [tLayersCount];
};

struct TransparentFragmentStore {
    TransparentFragmentValues values [[ imageblock_data ]];
    
};

constexpr sampler samplerFragment (min_filter::linear,
                                   mag_filter::linear,
                                   address::repeat);

kernel void initTransparentFragmentStore(imageblock<TransparentFragmentValues, imageblock_layout_explicit> blockData,
                                         ushort2 posInThreadGroup [[ thread_position_in_threadgroup ]]) {
    threadgroup_imageblock TransparentFragmentValues* fragmentValues = blockData.data(posInThreadGroup);
    for (short i = 0; i < tLayersCount; i++) {
        fragmentValues->colors[i] = half4(0.0h);
        fragmentValues->depths[i] = half(INFINITY);
    }
}

fragment TransparentFragmentStore transparent_fragment(VertexOut VerOut [[ stage_in ]],
                                                       constant ShaderMaterial &material [[ buffer(1) ]],
                                                       constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                                       constant LightData *lightData [[ buffer(3) ]],
                                                       constant int &lightCount [[ buffer(4) ]],
                                                       constant float2 &screenSize [[ buffer(5) ]],
                                                       depth2d<float> shadowMap1 [[ texture(0) ]],
                                                       texture2d<float> textureColor [[ texture(3) ]],
                                                       texture2d<float> textureJitter [[ texture(9) ]],
                                                       TransparentFragmentValues fragmentValues [[ imageblock_data ]]) {
    TransparentFragmentStore out;
    half4 color = half4(material.color);
    
    float2 texCoord = VerOut.textureCoordinate;
    
    if (!is_null_texture(textureColor)) {
        color = half4(textureColor.sample(samplerFragment, texCoord));
    }
    
    color.rgb *= color.a;

    float3 lightSpacePosition = VerOut.lightSpacePosition.xyz / VerOut.lightSpacePosition.w;
    float shadowTerm = 1.0f;
    if (!is_null_texture(shadowMap1)) {
        shadowTerm = Shadows::getLightness(shadowMap1, lightSpacePosition, textureJitter, VerOut.position.xy, screenSize);
    }
    
    float3 lighting = PhongShading::getPhongLight(VerOut.position.xyz,
                                                  normalize(VerOut.normal),
                                                  lightData,
                                                  lightCount,
                                                  material,
                                                  fragmentSceneConstant.cameraPosition,
                                                  shadowTerm,
                                                  0.3f);
    
    color.rgb *= half3(lighting);
    
    float depth = VerOut.position.z / VerOut.position.w;
    
    for (short i = 0; i < tLayersCount; i++) {
        half4 layerColor = fragmentValues.colors[i];
        float layerDepth = fragmentValues.depths[i];
        
        bool insert = (depth <= layerDepth) ? true : false;
        fragmentValues.colors[i] = insert ? color : layerColor;
        fragmentValues.depths[i] = insert ? depth : layerDepth;
        
        color = insert ? layerColor : color;
        depth = insert ? layerDepth : depth;
    }
    out.values = fragmentValues;
    
    return out;
}

fragment half4 blendTransparent_fragment(TransparentFragmentValues fragmentValues [[ imageblock_data ]]) {
    
    half4 color = half4(0, 0, 0, 0);
    
    for (short i = tLayersCount -1; i >= 0; i--) {
        half4 layerColor = fragmentValues.colors[i];
        color.rgb = layerColor.rgb + (1.0h - layerColor.a) * color.rgb;
        color.a = max(color.a, layerColor.a);
    }
    
    return color;
}

