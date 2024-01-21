
#include <metal_stdlib>
#import "../Shared.metal"
using namespace metal;

fragment float ssao_fragment(VertexOut VerOut [[ stage_in ]],
                             texture2d<float> normalShadowTex [[ texture(0) ]],
                             texture2d<float> depthTex [[ texture(1) ]]) {
    int totalLight = 0;
    float compareDepth = depthTex.sample(samplerFragment, VerOut.textureCoordinate).r;
    
    for (int x = -2; x < 2; x++) {
        for (int y = -2; y < 2; y++) {
            float offsetX = VerOut.textureCoordinate.x + (0.01 * x);
            float offsetY = VerOut.textureCoordinate.y + (0.01 * y);
            float depth = depthTex.sample(samplerFragment, float2(offsetX, offsetY)).r;
            if (depth <= compareDepth) {
                totalLight += 1;
            }
        }
    }
    
    return totalLight / 25;
}
