#ifndef TH_CARTOON_INCLUDED
#define TH_CARTOON_INCLUDED

struct Cartoon
{
    float3 darkColor;
    float3 warmColor;
    float3 specColor;
    float darkThreshold;
    float specThreshold;
    float specPower;
    float fresnelPower;
    float4 extendTex;
};

float4 DarknessColor(Surface surface, Light light, float4 darkColor, float4 warmColor, float darkThreshold)
{
    float darkness = saturate(dot(surface.normal, light.direction));
    float2 uv = float2(0, darkness);
    float4 reflectColor = SAMPLE_TEXTURE2D(_lightShowMap, sampler_lightShowMap, uv);
    //float4 c = ((darkness < darkThreshold) ? darkColor : warmColor) * float4(light.color, 1);
    float4 c = reflectColor * float4(light.color, 1);
    return c;
}

float3 SpecColor(Surface surface, Light light, Cartoon toon, float3 specColor)
{
    float3 halfVec = normalize((surface.viewDirection + light.direction) * 0.5);
    float dotValue = dot(surface.normal, halfVec);
    float spec = pow(dotValue, toon.specPower);
    float3 specI = (spec < toon.specThreshold) ? float3(0, 0, 0) : (specColor);
    return specI;
}

float FresnelEffect(float3 normal, float3 viewDir, float power)
{
    return pow(1.0 - dot(normal, viewDir), power);
}

float3 CartoonPBR(Surface surface, Light light, Cartoon toon, float3 color)
{
#if defined(_PBR_SHADER)
    float3 halfDir = normalize(surface.normal + surface.viewDirection);

    float VoN = dot(surface.viewDirection, surface.normal);
    float NoL = dot(surface.normal, light.direction);
    float NoH = dot(surface.normal, halfDir);

    float roughness = 1 - surface.smoothness;
    roughness *= (1.7 - 0.7 * roughness) * 0.98;
    roughness += 0.02;

    float mata = 0.98 * surface.metallic;
    float3 fresnel = FresnelSchlick(VoN, toon.fresnelPower);
    float3 fresnelOutline = fresnel;

    float atten = warp(light.shadowAttenuation, 0.3);

    float3 lambertDiff = saturate(NoL) * color;
    float3 diffuse = (1 - fresnel) * lambertDiff * atten;

    float Ndf = D_GGX(roughness * roughness, NoH);
    float3 unMatSpecular = fresnel * Ndf * light.color * atten;
    float3 matSpecular = unMatSpecular * color;

    /*Unity_GlossyEnvironmentData envData;
    envData.roughness = roughness;
    envData.reflUVW = reflect(-surface.viewDirection, surface.normal);
    float3 envSample = Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData);
    */
    float3 envSample = SHADERGRAPH_AMBIENT_SKY.rgb * roughness;
    float3 ambient = fresnel * envSample * color;

    float3 outColor = diffuse + lerp(unMatSpecular, matSpecular, mata) + ambient;
    return outColor;
#else
    return float3(0, 0, 0);
#endif
}

float3 MixColor(Surface surface, Light light, Cartoon toon, float3 color)
{
    float darkness = dot(surface.normal, light.direction);
    float exThreshold = toon.extendTex.b + (1 - light.shadowAttenuation) * (1 - toon.extendTex.r);
    float yUV = saturate(darkness + exThreshold);
    yUV = saturate(darkness);
    bool darknessPick = darkness < (toon.darkThreshold + exThreshold);

    float3 darkI, specColor;
    if (darknessPick)
    {
        //darkI = toon.darkColor * light.color;
        specColor = float3(0, 0, 0);
    }
    else
    {
        //darkI = toon.warmColor * light.color;
        specColor = toon.specColor * light.color.rgb;
    }
    darkI = SAMPLE_TEXTURE2D(_lightShowMap, sampler_lightShowMap, float2(0, yUV));
    float3 specI = SpecColor(surface, light, toon, specColor) * toon.extendTex.g;
    float3 fresnelColor = specColor * FresnelEffect(surface.normal, surface.viewDirection, toon.fresnelPower) * (1 - toon.extendTex.b);
    
#if defined(_PBR_SHADER)
    //return color * darkI + specI + fresnelColor + CartoonPBR(surface, light, toon, color);
    return CartoonPBR(surface, light, toon, color);
#endif
    return color * darkI + specI + fresnelColor;
}

#endif