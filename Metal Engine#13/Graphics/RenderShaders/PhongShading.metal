//
//  PhongShading.metal
//  Metal Engine#13
//
//  Created by Kuutti Taavitsainen on 16.7.2023.
//

#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

class PhongShading {
public:
    static float4 getPhongColor(float3 worldPosition,
                  float3 unitNormal,
                  constant LightData *ld,
                  int ldc) {
        float3 ambientColor = float3(0,0,0);
        float3 diffuseColor = float3(0,0,0);
        float3 specularColor = float3(0,0,0);
        
        for (int i = 0; i < ldc; i++) {
            LightData data = ld[i];
            
            float3 toLightVector = normalize(data.position - worldPosition);
            
            diffuseColor = dot(unitNormal, toLightVector);
        }
        
        return float4(ambientColor + diffuseColor + specularColor, 1);
    }
};
