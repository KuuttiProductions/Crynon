
#include <metal_stdlib>
using namespace metal;

class AmbientOcclusion {
public:
    static float getAmbientTerm(float3 normal,
                                half depth,
                                float aoBaked) {
        return 0.03 * aoBaked;
    }
};
