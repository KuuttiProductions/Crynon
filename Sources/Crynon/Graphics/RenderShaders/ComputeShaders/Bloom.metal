
#include <metal_stdlib>
#import "../Shared.metal"
using namespace metal;

kernel void bloomDownsample(texture2d<float, access::read> textureIn [[ texture(0) ]],
                            texture2d<float, access::write> textureOut [[ texture(1) ]],
                            const ushort2 posInGrid [[ thread_position_in_grid() ]]) {
    
    short o = 2;
    ushort2 offsets = (ushort2(-o, o),
                       ushort2( 0, o),
                       ushort2( o, o),
                       ushort2(-o, 0),
                       ushort2( 0, 0),
                       ushort2( o, 0),
                       ushort2(-o,-o),
                       ushort2( 0,-o),
                       ushort2( o,-o));
    
    float sampleKernel[9] = {
        -1, -1, -1,
        -1,  9, -1,
        -1, -1, -1};
    
    float3 samples[9];
    for (int i = 0; i < 9; i++) {
        samples[i] = textureIn.read(posInGrid + offsets[i]).xyz;
    }
    float3 color = float3(0, 0, 0);
    for (int i = 0; i < 9; i++) {
        color += samples[i] * sampleKernel[i];
    }
    textureOut.write(float4(color, 1), posInGrid);
}

kernel void bloomUpsample(texture2d<float> textureIn [[ texture(0) ]],
                  texture2d<float> textureOut [[ texture(1) ]]) {
    
}

