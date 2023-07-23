
#include <metal_stdlib>
#import "Random/rng_header.metal"
using namespace metal;

kernel void jitter(texture3d<half, access::write> jitterTexture [[ texture(0) ]],
                   const uint3 posInGrid [[ thread_position_in_grid ]]) {
    
    Rng rng = Rng(posInGrid.x, posInGrid.y, posInGrid.z);
    
    float randomX = rng.rand();
    float randomY = rng.rand();
    jitterTexture.write(half4(randomX, randomY, 1, 1),
                        ushort3(posInGrid.x, posInGrid.y, posInGrid.z));
}
