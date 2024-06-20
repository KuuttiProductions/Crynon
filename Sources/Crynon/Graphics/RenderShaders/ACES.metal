
#include <metal_stdlib>
#import "ACESUtils.metal"
using namespace metal;

// Based on the RRTs and ODTs found in
// https://github.com/ampas/aces-dev/tree/dev
// (Except aces_approx)

class ACES {
public:
    ACESUtils utils = ACESUtils();
    
    const float RRT_GLOW_GAIN = 0.05;
    const float RRT_GLOW_MID = 0.08;
    
    const float RRT_RED_SCALE = 0.82;
    const float RRT_RED_PIVOT = 0.03;
    const float RRT_RED_HUE = 0.;
    const float RRT_RED_WIDTH = 135.;
    
    float3 ACES_FAST(float3 color, float white) {
        const float exposure_bias = 1.8f;
        const float A = 0.0245786f;
        const float B = 0.000090537f;
        const float C = 0.983729f;
        const float D = 0.432951f;
        const float E = 0.238081f;
        
        const float3x3 rgb_to_rrt = float3x3(
                float3(0.59719f * exposure_bias, 0.35458f * exposure_bias, 0.04823f * exposure_bias),
                float3(0.07600f * exposure_bias, 0.90834f * exposure_bias, 0.01566f * exposure_bias),
                float3(0.02840f * exposure_bias, 0.13383f * exposure_bias, 0.83777f * exposure_bias));

        const float3x3 odt_to_rgb = float3x3(
                float3(1.60475f, -0.53108f, -0.07367f),
                float3(-0.10208f, 1.10813f, -0.00605f),
                float3(-0.00327f, -0.07276f, 1.07602f));

        color *= rgb_to_rrt;
        float3 color_tonemapped = (color * (color + A) - B) / (color * (C * color + D) + E);
        color_tonemapped *= odt_to_rgb;

        white *= exposure_bias;
        float white_tonemapped = (white * (white + A) - B) / (white * (C * white + D) + E);
        
        return color_tonemapped / white_tonemapped;
    }
};
