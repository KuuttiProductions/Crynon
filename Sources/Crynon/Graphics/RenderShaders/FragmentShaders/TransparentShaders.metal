
#include <metal_stdlib>
#import "../Shared.metal"
using namespace metal;

static constexpr constant short tLayersCount = 4; //Number of transparent layers stored in tile memory

struct TransparentFragmentValues {
    rgba8unorm<half4> colors [[ raster_order_group(1) ]] [tLayersCount];
    float depths [[ raster_order_group(1) ]] [tLayersCount];
};

struct TransparentFragmentStore {
    TransparentFragmentValues values [[ imageblock_data ]];
    
};

kernel void initTransparentFragmentStore(imageblock<TransparentFragmentValues, imageblock_layout_explicit> blockData,
                                         ushort2 posInThreadGroup [[ thread_position_in_threadgroup ]]) {
    threadgroup_imageblock TransparentFragmentValues* fragmentValues = blockData.data(posInThreadGroup);
    for (short i = 0; i < tLayersCount; i++) {
        fragmentValues->colors[i] = half4(0.0h);
        fragmentValues->depths[i] = half(INFINITY);
    }
}

constexpr sampler sampler2d = sampler(min_filter::linear,
                                      mag_filter::linear);

fragment TransparentFragmentStore transparent_fragment(VertexOut VerOut [[ stage_in ]],
                                                       constant ShaderMaterial &material [[ buffer(1) ]],
                                                       constant FragmentSceneConstant &fragmentSceneConstant [[ buffer(2) ]],
                                                       constant LightData *lightData [[ buffer(3) ]],
                                                       constant int &lightCount [[ buffer(4) ]],
                                                       depth2d<float> shadowMap1 [[ texture(0) ]],
                                                       texture2d<float> textureColor [[ texture(3) ]],
                                                       TransparentFragmentValues fragmentValues [[ imageblock_data ]]) {
    TransparentFragmentStore out;
    half4 color = half4(material.color);
    
    float2 texCoord = VerOut.textureCoordinate;
    
    if (!is_null_texture(textureColor)) {
        color = half4(textureColor.sample(sampler2d, texCoord));
    }
    
    color.rgb *= color.a;
    
    half depth = VerOut.position.z / VerOut.position.w;
    
    for (short i = 0; i < tLayersCount; i++) {
        half4 layerColor = fragmentValues.colors[i];
        half layerDepth = fragmentValues.depths[i];
        
        bool insert = (depth <= layerDepth) ? true : false;
        fragmentValues.colors[i] = insert ? color : layerColor;
        fragmentValues.depths[i] = insert ? depth : layerDepth;
        
        color = insert ? layerColor : color;
        depth = insert ? layerDepth : depth;
    }
    out.values = fragmentValues;
    
    return out;
}

struct TransparencyOut {
    half4 color [[ color(1), raster_order_group(0) ]];
    half4 normalShadow [[ color(6), raster_order_group(0) ]];
};

fragment TransparencyOut blendTransparent_fragment(TransparentFragmentValues fragmentValues [[ imageblock_data ]],
                                                   half4 opaqueColors [[ color(1), raster_order_group(0) ]],
                                                   half4 opaqueDepth [[ color(2), raster_order_group(1) ]]) {
    TransparencyOut to;
    half4 color;
    color.rgb = opaqueColors.rgb;
    
    for (short i = tLayersCount -1; i >= 0; i--) {
        half4 layerColor = fragmentValues.colors[i];
        color.rgb = layerColor.rgb + (1.0h - layerColor.a) * color.rgb;
    }
    
    color.a = 1.0;
    to.color = color;
    
    return to;
}

