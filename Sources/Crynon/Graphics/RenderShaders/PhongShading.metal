
#include <metal_stdlib>
#include "Shared.metal"
using namespace metal;

class PhongShading {
public:
    static float3 getPhongLight(float3 worldPosition,
                                float3 unitNormal,
                                constant LightData *ld,
                                int ldc,
                                ShaderMaterial mt,
                                float3 cameraPos,
                                float lightness,
                                float ambientTerm) {
        
        float3 totalAmbientColor = float3(0,0,0);
        float3 totalDiffuseColor = float3(0,0,0);
        float3 totalSpecularColor = float3(0,0,0);
        
        for (int i = 0; i < ldc; i++) {
            LightData data = ld[i];
            float brightness = data.brightness;
            
            const float3 lightDirection = normalize(-data.direction);
            const float3 toLightVector = normalize(data.position - worldPosition);
            const float3 toCameraVector = normalize(cameraPos - worldPosition);
            const float3 halfwayVector = normalize(data.useDirection ? lightDirection : toLightVector + toCameraVector);
            const float distanceToLight = length(data.position - worldPosition);
            
            float diffuseness = (mt.metallic * -1 + 1);
            float specularness = max(((mt.roughness * -1 + 1) * 100), 1.0);
            
            const float theta = dot(toLightVector, lightDirection);
            if (data.cutoff != 0) {
                if (cos(data.cutoff) > theta) {
                    brightness = 0;
                } else {
                    float epsilon = cos(data.cutoffInner) - cos(data.cutoff);
                    brightness = smoothstep(0.0, 1.0, (theta - cos(data.cutoffInner)) / epsilon);
                }
            }
            
            float attenuation;
            if (data.useDirection == false) {
                attenuation = 1 / (1.0 + 0.09 * distanceToLight + 0.032 * pow(distanceToLight, 2));
            } else {
                attenuation = brightness;
            }
            
            float3 ambientColor = (float3(1,1,1) * data.color.rgb) * ambientTerm * attenuation * brightness * data.color.rgb;
            totalAmbientColor += clamp(ambientColor, 0.0, 1.0);
            
            float3 diffuseColor = dot(unitNormal, data.useDirection ? lightDirection : toLightVector) * diffuseness * attenuation * brightness * data.color.rgb * (mt.emission + 1);
            totalDiffuseColor += clamp(diffuseColor, 0.0, 1.0);
            if (data.useDirection == true) {
                totalDiffuseColor *= lightness;
            }
            
            float specularDot = clamp(dot(halfwayVector, unitNormal), 0.0, 1.0);
            float3 specularColor = pow(specularDot, specularness) * attenuation * brightness * data.color.rgb;
            totalSpecularColor += clamp(specularColor, 0.0, 1.0);
            if (data.useDirection == true) {
                totalSpecularColor *= lightness;
            }
        }
        
        return totalAmbientColor + totalDiffuseColor + totalSpecularColor;
    }
};
