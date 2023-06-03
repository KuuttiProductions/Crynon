//
//  Shared.metal
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 1.6.2023.
//

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
};

struct ModelConstant {
    float4x4 modelMatrix;
};

struct SceneConstant {
    float4x4 viewMatrix;
};
