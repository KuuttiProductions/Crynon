
#include <metal_stdlib>
using namespace metal;

//This is based on https://github.com/YoussefV/Loki/tree/master

class Rng {
private:
    thread float seed;
    unsigned TausStep(const unsigned z, const int s1, const int s2, const int s3, const unsigned M);

public:
    thread Rng(const unsigned seed1, const unsigned seed2 = 1, const unsigned seed3 = 1);

    thread float rand();
};
