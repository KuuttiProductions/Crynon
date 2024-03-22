
#include <metal_stdlib>
using namespace metal;

class ACESUtils {
public:
    const float M_PI = 3.1415927;
    const float FLT_NAN = 0.0 / 0.0; // Maybe don't use actual NaNs?
    
    float max_f3(float3 rgb) {
        return max(rgb.r, max(rgb.g, rgb.b));
    }
    float min_f3(float3 rgb) {
        return min(rgb.r, min(rgb.g, rgb.b));
    }
    
    float3 clamp_f3(float3 rgb, float clampMin, float clampMax) {
        float3 out;
        out.r = clamp(rgb.r, clampMin, clampMax);
        out.g = clamp(rgb.g, clampMin, clampMax);
        out.b = clamp(rgb.b, clampMin, clampMax);
        return out;
    }
    
    float rgb_2_saturation(float3 rgb) {
        const float TINY = 1e-10;
        return (max(max_f3(rgb), TINY) - max(min_f3(rgb), TINY)) / max(max_f3(rgb), 1e-2);
    }
    
    float rgb_2_yc(float3 rgb, float ycRadiusWeight = 1.75) {
        // Converts RGB to luminance proxy (YC)
        float r = rgb.r;
        float g = rgb.g;
        float b = rgb.b;
        
        float chroma = sqrt(b*(b-g)+g*(g-r)+r*(r-b));
        
        return (b + g + r * ycRadiusWeight * chroma) / 3.;
    }
    
    float sigmoid_shaper(float x) {
        float t = max(1. - fabs(x / 2.), 0.);
        float y = 1. + sign(x) * (1. - t * t);
        
        return y / 2.;
    }
    
    float glow_fwd(float ycIn, float glowGainIn, float glowMid) {
        float glowGainOut;
        
        if (ycIn <= 2./3. * glowMid) {
            glowGainOut = glowGainIn;
        } else if (ycIn >= 2. * glowMid) {
            glowGainOut = 0.;
        } else {
            glowGainOut = glowGainIn * (glowMid / ycIn - 1./2.);
        }
        
        return glowGainOut;
    }
    
    float rgb_2_hue(float3 rgb) {
        float hue;
        if (rgb.r == rgb.g && rgb.g == rgb.b) {
            hue = FLT_NAN;
        } else {
            hue = (180./M_PI) * atan2(sqrt(3.)*(rgb.g - rgb.b), 2*rgb.r-rgb.g-rgb.b);
        }
        
        if (hue < 0.) hue = hue + 360.;
        
        return hue;
    }
    
    float center_hue(float hue, float centerH) {
        float hueCentered = hue - centerH;
        if (hueCentered < -180.) hueCentered = hueCentered + 360.;
        else if (hueCentered > 180.) hueCentered = hueCentered - 360.;
        return hueCentered;
    }
    
    float cubic_basis_shaper(float x, float w) {
        float M[4][4] = { { -1./6,  3./6, -3./6,  1./6 },
                          {  3./6, -6./6,  3./6,  0./6 },
                          { -3./6,  0./6,  3./6,  0./6 },
                          {  1./6,  4./6,  1./6,  0./6 } };
        
        float knots[5] = { -w/2.,
                           -w/4.,
                           0.,
                           w/4.,
                           w/2. };
        
        float y = 0;
        if ((x > knots[0]) && (x < knots[4])) {
          float knot_coord = (x - knots[0]) * 4./w;
          int j = knot_coord;
          float t = knot_coord - j;
            
          float monomials[4] = { t*t*t, t*t, t, 1. };

          if ( j == 3) {
            y = monomials[0] * M[0][0] + monomials[1] * M[1][0] +
                monomials[2] * M[2][0] + monomials[3] * M[3][0];
          } else if ( j == 2) {
            y = monomials[0] * M[0][1] + monomials[1] * M[1][1] +
                monomials[2] * M[2][1] + monomials[3] * M[3][1];
          } else if ( j == 1) {
            y = monomials[0] * M[0][2] + monomials[1] * M[1][2] +
                monomials[2] * M[2][2] + monomials[3] * M[3][2];
          } else if ( j == 0) {
            y = monomials[0] * M[0][3] + monomials[1] * M[1][3] +
                monomials[2] * M[2][3] + monomials[3] * M[3][3];
          } else {
            y = 0.0;
          }
        }
        
        return y * 3/2.;
    }
};
