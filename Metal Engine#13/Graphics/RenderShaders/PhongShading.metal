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
            float diffuseness = (mt.metallic * -1 + 1);
            float specularness = ((mt.roughness * -1 + 1) * 1000);
            
            float4 ambientColor = (float4(1,1,1,1) * data.color) * 0.1 * data.brightness;
            totalAmbientColor += ambientColor;
            
            float4 diffuseColor = dot(unitNormal, toLightVector) * diffuseness * data.brightness;
            totalDiffuseColor += diffuseColor;
            
            float specularDot = dot(toLightVector, toCameraVector);
            float4 specularColor = pow(specularDot, specularness) * data.brightness;
            totalSpecularColor += specularColor;
        }
        
        return totalAmbientColor + totalDiffuseColor + totalSpecularColor;
    }
};
