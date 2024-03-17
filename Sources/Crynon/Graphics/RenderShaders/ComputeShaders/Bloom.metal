
#include <metal_stdlib>
using namespace metal;

kernel void bloomThreshold(texture2d<float, access::read> textureIn [[ texture(0) ]],
                           texture2d<float, access::write> textureOut [[ texture(1) ]],
                           constant float &bloomThreshold [[ buffer(0) ]],
                           const ushort2 posInGrid [[ thread_position_in_grid() ]]) {
    
    float4 value = textureIn.read(posInGrid);
    float brightness = max(value.r, max(value.g, value.b));
    value *= max((brightness - bloomThreshold) / max(brightness, 0.0001), 0.0);
    textureOut.write(value, posInGrid);
}

kernel void bloomDownsample(texture2d<float, access::read> textureIn [[ texture(0) ]],
                            texture2d<float, access::write> textureOut [[ texture(1) ]],
                            constant uint2 &screenSize [[ buffer(0) ]],
                            const ushort2 posInGrid [[ thread_position_in_grid() ]]) {
    
    short minVal = short(0);
    short maxValWidth = short(screenSize.x - 1);
    short maxValHeight = short(screenSize.y - 1);
    ushort2 positions[13] = {
        ushort2(clamp(short(posInGrid.x - 2), minVal, maxValWidth), clamp(short(posInGrid.y + 2), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x    ), minVal, maxValWidth), clamp(short(posInGrid.y + 2), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + 2), minVal, maxValWidth), clamp(short(posInGrid.y + 2), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x - 2), minVal, maxValWidth), clamp(short(posInGrid.y    ), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x    ), minVal, maxValWidth), clamp(short(posInGrid.y    ), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + 2), minVal, maxValWidth), clamp(short(posInGrid.y    ), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x - 2), minVal, maxValWidth), clamp(short(posInGrid.y - 2), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x    ), minVal, maxValWidth), clamp(short(posInGrid.y - 2), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + 2), minVal, maxValWidth), clamp(short(posInGrid.y - 2), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x - 1), minVal, maxValWidth), clamp(short(posInGrid.y + 1), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + 1), minVal, maxValWidth), clamp(short(posInGrid.y + 1), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x - 1), minVal, maxValWidth), clamp(short(posInGrid.y - 1), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + 1), minVal, maxValWidth), clamp(short(posInGrid.y - 1), minVal, maxValHeight))
    };
    
    float3 a = textureIn.read(positions[ 0] * 2).xyz;
    float3 b = textureIn.read(positions[ 1] * 2).xyz;
    float3 c = textureIn.read(positions[ 2] * 2).xyz;
    
    float3 d = textureIn.read(positions[ 3] * 2).xyz;
    float3 e = textureIn.read(positions[ 4] * 2).xyz;
    float3 f = textureIn.read(positions[ 5] * 2).xyz;
    
    float3 g = textureIn.read(positions[ 6] * 2).xyz;
    float3 h = textureIn.read(positions[ 7] * 2).xyz;
    float3 i = textureIn.read(positions[ 8] * 2).xyz;
    
    float3 j = textureIn.read(positions[ 9] * 2).xyz;
    float3 k = textureIn.read(positions[10] * 2).xyz;
    float3 l = textureIn.read(positions[11] * 2).xyz;
    float3 m = textureIn.read(positions[12] * 2).xyz;
    
    float3 downsample = e * 0.125;
    downsample += (a + c + g + i) * 0.03125f;
    downsample += (b + d + f + h) * 0.0625f;
    downsample += (j + k + l + m) * 0.125f;
 
    textureOut.write(float4(max(downsample, 0.0001), 1), posInGrid);
}

kernel void bloomUpsample(texture2d<float, access::read> textureIn [[ texture(0) ]],
                          texture2d<float, access::write> textureOut [[ texture(1) ]],
                          constant uint2 &screenSize [[ buffer(0) ]],
                          const ushort2 posInGrid [[ thread_position_in_grid() ]]) {
    const short s = 1;
    float3 upsample = float3(0, 0, 0);
    
    short minVal = short(0);
    short maxValWidth = short(screenSize.x - 1);
    short maxValHeight = short(screenSize.y - 1);
    
    ushort2 positions[13] = {
        ushort2(clamp(short(posInGrid.x - s), minVal, maxValWidth), clamp(short(posInGrid.y + s), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x    ), minVal, maxValWidth), clamp(short(posInGrid.y + s), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + s), minVal, maxValWidth), clamp(short(posInGrid.y + s), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x - s), minVal, maxValWidth), clamp(short(posInGrid.y    ), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x    ), minVal, maxValWidth), clamp(short(posInGrid.y    ), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + s), minVal, maxValWidth), clamp(short(posInGrid.y    ), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x - s), minVal, maxValWidth), clamp(short(posInGrid.y - s), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x    ), minVal, maxValWidth), clamp(short(posInGrid.y - s), minVal, maxValHeight)),
        ushort2(clamp(short(posInGrid.x + s), minVal, maxValWidth), clamp(short(posInGrid.y - s), minVal, maxValHeight))
    };
    
    float3 a = textureIn.read(positions[0] / 2).xyz;
    float3 b = textureIn.read(positions[1] / 2).xyz;
    float3 c = textureIn.read(positions[2] / 2).xyz;
    
    float3 d = textureIn.read(positions[3] / 2).xyz;
    float3 e = textureIn.read(positions[4] / 2).xyz;
    float3 f = textureIn.read(positions[5] / 2).xyz;
    
    float3 g = textureIn.read(positions[6] / 2).xyz;
    float3 h = textureIn.read(positions[7] / 2).xyz;
    float3 i = textureIn.read(positions[8] / 2).xyz;
    
    upsample += (a+c+g+i);
    upsample += (b+d+f+h) * 2;
    upsample += e * 4;
    upsample *= 0.0625;
    
    textureOut.write(float4(upsample, 1), posInGrid);
}

