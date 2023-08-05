
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
                                float3 cameraPos,
                                float lightness) {
        
        float4 totalAmbientColor = float4(0,0,0,1);
        float4 totalDiffuseColor = float4(0,0,0,1);
        float4 totalSpecularColor = float4(0,0,0,1);
        
        for (int i = 0; i < ldc; i++) {
            LightData data = ld[i];
            float3 lightDirection = normalize(-data.direction);
            float3 toLightVector = normalize(data.position - worldPosition);
            float3 toCameraVector = normalize(cameraPos - worldPosition);
            float3 halfwayVector = normalize(data.useDirection ? lightDirection : toLightVector + toCameraVector);
            
            float diffuseness = (mt.metallic * -1 + 1);
            float specularness = max(((mt.roughness * -1 + 1) * 100), 1.0);
            
            float4 ambientColor = (float4(1,1,1,1) * data.color) * 0.03 * data.brightness * data.color;
            totalAmbientColor += clamp(ambientColor, 0.0, 1.0);
            
            float4 diffuseColor = dot(unitNormal, data.useDirection ? lightDirection : toLightVector) * diffuseness * data.brightness * data.color;
            totalDiffuseColor += clamp(diffuseColor, 0.0, 1.0);
            
            float specularDot = clamp(dot(halfwayVector, unitNormal), 0.0, 1.0);
            float4 specularColor = pow(specularDot, specularness) * data.brightness * data.color;
            totalSpecularColor += clamp(specularColor, 0.0, 1.0);
        }
        
        return totalAmbientColor + lightness * (totalDiffuseColor + totalSpecularColor);
    }
};
