//
//  BasicShaders.metal
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 31.5.2023.
//

#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

vertex VertexOut basic_vertex(VertexIn VerIn [[ stage_in ]],
                              constant ModelConstant &modelConstant [[ buffer(1) ]]) {
    
    VertexOut VerOut;
    VerOut.position = modelConstant.modelMatrix * float4(VerIn.position, 1);
    VerOut.color = VerIn.color;
    
    return VerOut;
}

fragment half4 basic_fragment(VertexOut VerOut [[ stage_in ]]) {
    
    float4 color = VerOut.color;
    
    return half4(color.r, color.g, color.b, color.a);
}
