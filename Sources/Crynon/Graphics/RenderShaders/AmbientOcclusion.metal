
#include <metal_stdlib>
using namespace metal;

class AmbientOcclusion {
public:
    static float getAmbientTerm(float3 normal,
                                half depth,
                                float aoBaked) {
        return 0.03 * aoBaked;
        
        for (int x = -3; x < 3; x++) {
            for (int y = -3; y < 3; y++) {
                float x = depth;
            }
        }
    }
};
