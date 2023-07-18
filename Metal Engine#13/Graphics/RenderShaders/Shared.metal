
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinate [[ attribute(2) ]];
    float3 normal [[ attribute(3) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoordinate;
    float3 normal;
    float3 worldPosition;
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
    float radius;
    float3 position;
};

struct Material {
    float4 color;
    float metallic;
    float roughness;
};
