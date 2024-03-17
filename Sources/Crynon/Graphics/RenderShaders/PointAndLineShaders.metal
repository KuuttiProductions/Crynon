
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
    
    po.position = sceneConstant.projectionMatrix * sceneConstant.viewMatrix * float4(In.position, 1);
    po.pointSize = In.pointSize / po.position.w;
    
    return po;
}

fragment GBuffer pointAndLine_fragment(PointOut PointOut [[ stage_in]],
                                     constant float4 &color [[ buffer(1) ]]) {
    
    GBuffer gBuffer;
    
    gBuffer.color = color;
    gBuffer.depth = PointOut.position.z;
    
    return gBuffer;
}
