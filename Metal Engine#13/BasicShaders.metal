//
//  BasicShaders.metal
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 31.5.2023.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float4 color;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

vertex VertexOut basic_vertex(constant VertexIn *VerIn [[ buffer(0) ]],
                           uint verID [[ vertex_id ]]) {
    
    VertexOut VerOut;
    VerOut.position = float4(VerIn[verID].position, 1);
    VerOut.color = VerIn[verID].color;
    
    return VerOut;
}

fragment half4 basic_fragment(VertexOut VerOut [[ stage_in ]]) {
    
    float4 color = VerOut.color;
    
    return half4(color.r, color.g, color.b, color.a);
}
