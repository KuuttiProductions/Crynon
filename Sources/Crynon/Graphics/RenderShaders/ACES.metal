
#include <metal_stdlib>
using namespace metal;

class ACES {
public:
    static float3 aces_approx(float3 v) {
        v *= 0.6f;
        float a = 2.51f;
        float b = 0.03f;
        float c = 2.43f;
        float d = 0.59f;
        float e = 0.14f;
        return clamp((v*(a*v+b))/(v*(c*v+d)+e), 0.0f, 1.0f);
    }
    
    static float3 RRT(float4 input) {
        float aces[3] = { input.r, input.g, input.b };
        
        float rgbOces[3] = { };
        
        return float3(rgbOces[0], rgbOces[1], rgbOces[2]);
    };
private:
    
};
