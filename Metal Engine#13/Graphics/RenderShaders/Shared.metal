
#include <metal_stdlib>
using namespace metal;

struct GBuffer {
    half4 final [[ color(0), raster_order_group(2) ]];
    half4 color [[ color(1), raster_order_group(1) ]];
    float4 positionShadow [[ color(2), raster_order_group(1) ]];
    float4 normal [[ color(3), raster_order_group(1) ]];
    float depth [[ color(4), raster_order_group(1) ]];
    float4 metalRoughEmissionIOR [[ color(5), raster_order_group(1) ]];
};

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
    float3 normal [[ attribute(3) ]];
};

struct VertexOut {
    float4 position [[ position, invariant ]];
    float4 color;
    float2 textureCoordinate;
    float3 normal;
    float3 worldPosition;
    float4 lightSpacePosition;
    float pointSize [[ point_size ]];
};

struct ModelConstant {
    float4x4 modelMatrix;
};

struct VertexSceneConstant {
    float4x4 viewMatrix;
};

struct FragmentSceneConstant {
    float3 cameraPosition;
};

struct LightData {
    float brightness;
    float4 color;
    float3 position;
    float3 direction;
    bool useDirection;
    float cutoff;
    float cutoffInner;
};

struct ShaderMaterial {
    float4 color;
    float metallic;
    float roughness;
    float emission;
    float ior;
};
