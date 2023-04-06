#ifndef PBR_CARTOON_RENDERER_FUNCTION
#define PBR_CARTOON_RENDERER_FUNCTION

float3 CartoonDiffuse(PBRCartoon cartoon, Light light)
{
    float3 N = normalize(cartoon.normal);
    float3 L = normalize(light.direction);
    float NdotL = max(dot(N, L), 1e-5);
    
    float yUV = NdotL;
    float3 shadowColor = SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, float2(0, yUV)).rgb;
    return shadowColor;
}

float3 CartoonDiffuseEasy(float NdotL, float shadow)
{
    float yUV = saturate(NdotL * shadow);
    return SAMPLE_TEXTURE2D(_ShadowTex, sampler_ShadowTex, float2(0, yUV)).rgb;
}

#endif