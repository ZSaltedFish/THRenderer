#ifndef TH_FACE_FUNCTION_INCLUDED
#define TH_FACE_FUNCTION_INCLUDED

float3 FaceLightReflection(THFaceInput face, Light light)
{
    float3 N = normalize(face.normal);
    float3 L = normalize(light.direction);
    float NdotL = max(dot(N, L), 1e-5);
    float shadow = light.shadowAttenuation * light.distanceAttenuation;
    
    return face.baseColor.rgb * NdotL * shadow * light.color;
}

float3 FaceRenderer(THFaceInput face)
{
    float4 shadowCoord = TransformWorldToShadowCoord(face.position);
    Light mainLight = GetMainLight(shadowCoord);

    float3 diff = FaceLightReflection(face, mainLight);
    uint lightCount = GetAdditionalLightsCount();

    for (int i = 0; i < lightCount; ++i)
    {
        Light addLight = GetAdditionalLight(i, face.position);
        diff += FaceLightReflection(face, addLight);
    }
    
    return diff;

}
#endif