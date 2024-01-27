
#include <metal_stdlib>
#import "Random/rng_header.metal"
using namespace metal;

kernel void jitter(texture2d<half, access::write> jitterTexture [[ texture(0) ]],
                   const uint2 posInGrid [[ thread_position_in_grid ]]) {
    
    Rng rng = Rng(posInGrid.x, posInGrid.y);
    
    half randomX = rng.rand() * 2.0f - 1.0f;
    half randomY = rng.rand() * 2.0f - 1.0f;
    half randomZ = rng.rand() * 2.0f - 1.0f;
    jitterTexture.write(half4(randomX, randomY, randomZ, 1.0h),
                        ushort2(posInGrid.x, posInGrid.y));
}
