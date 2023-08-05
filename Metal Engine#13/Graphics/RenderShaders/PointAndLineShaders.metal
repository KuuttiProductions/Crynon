//
//  PointAndLineShaders.metal
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 4.8.2023.
//

#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

struct PointIn {
    float3 position [[ attribute(0) ]];
    float pointSize [[ attribute(1) ]];
};

struct PointOut {
    float4 position [[ position ]];
    float pointSize [[ point_size ]];
};

vertex PointOut pointAndLine_vertex(PointIn In [[ stage_in ]],
                             constant VertexSceneConstant &sceneConstant [[ buffer(2) ]]) {
    
    PointOut po;
    
    po.position = sceneConstant.viewMatrix * float4(In.position, 1);
    po.pointSize = In.pointSize;
    
    return po;
}

fragment half4 pointAndLine_fragment(PointOut PointOut [[ stage_in]],
                                     constant float4 &color [[ buffer(1) ]]) {
    
    return half4(color.r, color.g, color.b, color.a);
}
