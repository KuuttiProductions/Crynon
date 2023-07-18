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
    static float4 getPhongLight(float3 worldPosition,
                                float3 unitNormal,
                                constant LightData *ld,
                                int ldc,
                                constant Material &mt,
                                float3 cameraPos) {
        
        float4 totalAmbientColor = float4(0,0,0,0);
        float4 totalDiffuseColor = float4(0,0,0,0);
        float4 totalSpecularColor = float4(0,0,0,0);
        
        for (int i = 0; i < ldc; i++) {
            LightData data = ld[i];
            float3 toLightVector = normalize(data.position - worldPosition);
            float3 toCameraVector = normalize(cameraPos - worldPosition);
            float3 halfwayVector = normalize(toLightVector + toCameraVector);
            
            float diffuseness = (mt.metallic * -1 + 1);
            float specularness = max(((mt.roughness * -1 + 1) * 100), 1.0);
            
            float4 ambientColor = (float4(1,1,1,1) * data.color) * 0.03 * data.brightness * data.color;
            totalAmbientColor += clamp(ambientColor, 0.0, 1.0);
            
            float4 diffuseColor = dot(unitNormal, toLightVector) * diffuseness * data.brightness * data.color;
            totalDiffuseColor += clamp(diffuseColor, 0.0, 1.0);
            
            float specularDot = dot(halfwayVector, unitNormal);
            float4 specularColor = pow(specularDot, specularness) * data.brightness * data.color;
            totalSpecularColor += clamp(specularColor, 0.0, 1.0);
        }
        
        return totalAmbientColor + totalDiffuseColor + totalSpecularColor;
    }
};
