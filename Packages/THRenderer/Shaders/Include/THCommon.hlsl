#ifndef TH_COMMON_INCLUDED
#define TH_COMMON_INCLUDED

#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

float Square(float v)
{
    return v * v;
}

float Pow5(float x)
{
    return x * x * x * x * x;
}

float3 FresnelSchlick(float VoN, float3 rF0)
{
    return rF0 + (1 - rF0) * Pow5(1 - VoN);
}

float D_GGX_Custom(float a2, float NoH)
{
    float d = (NoH * a2 - NoH) * NoH + 1;
    return a2 / (3.141592 * d * d + 0.000001);
}

float D_GGXaniso(float ax, float ay, float NoH, float3 H, float3 X, float3 Y)
{
    float XoH = dot(X, H);
    float YoH = dot(Y, H);
    float d = XoH * XoH / (ax * ax) + YoH * YoH / (ay * ay) + NoH * NoH;
    return 1 / (3.141592653 * ax * ay * d * d);
}

float warp(float x, float w)
{
    return (x + w) / (1 + w);
}

inline float G_SubSection(float dot, float k)
{
    return dot / lerp(dot, 1, k);
}

float G_Function(float NdotL, float NdotV, float roughness)
{
    float k = 1 + roughness;
    k = k * k * 0.5;

    return G_SubSection(NdotL, k) * G_SubSection(NdotV, k);
}

inline float3 F0_Function(float3 albedo, float metallic)
{
    return lerp(0.04, albedo, metallic);
}

float3 F_Function(float HdotL, float smoothness, float3 f)
{
    float fre = exp2((-5.55473 * HdotL - 6.98316) * HdotL);
    return lerp(fre.xxx, smoothness.xxx, f);
}

float LocalFresnel(float NdotL, float specular, float smoothness)
{
    float fresnel = Pow4(1.0 - NdotL);
    return lerp(specular, smoothness, fresnel);
}
#endif