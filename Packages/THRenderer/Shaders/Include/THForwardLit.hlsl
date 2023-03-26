#ifndef TH_LIGHTING_INCLUDED
#define TH_LIGHTING_INCLUDED

#include "THCommon.hlsl"
#include "TH_IO_Define.hlsl"
#include "BRDF.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_ExtendTexture);
SAMPLER(sampler_ExtendTexture);
TEXTURE2D(_lightShowMap);
SAMPLER(sampler_lightShowMap);

#if defined(_PBR_SHADER)
    TEXTURE2D(_MeSmoo);
    SAMPLER(sampler_MeSmoo);
#endif

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float4, _WarmColor)
UNITY_DEFINE_INSTANCED_PROP(float4, _CoodColor)
UNITY_DEFINE_INSTANCED_PROP(float4, _SpecColor)
UNITY_DEFINE_INSTANCED_PROP(float, _darkThreshold)
UNITY_DEFINE_INSTANCED_PROP(float, _lightThreshold)
UNITY_DEFINE_INSTANCED_PROP(float, _lightPower)
UNITY_DEFINE_INSTANCED_PROP(float, _fresnelPower)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

#include "THCartoon.hlsl"
#include "THSetup.hlsl"

Varyings LightingVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    float4 positionCS = TransformWorldToHClip(positionWS);
    output.positionCS = positionCS;
    output.positionWS = float4(positionWS, 1);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS = float4(TransformObjectToWorldNormal(input.tangentOS.xyz), 1);
    output.viewDirWS = GetWorldSpaceViewDir(positionWS);
    
    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
    output.uv = input.texcoord * baseST.xy + baseST.zw;
    output.color = input.color;
    return output;
}

float4 LightingFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);

#if defined(_CLIPPING)
    clip(mainTex.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff));
#endif

    Surface surface = (Surface)0;
    SetupSurface(input, mainTex, surface);

    //BRDF brdf = GetBRDF(surface);
    float4 shadowCoord = TransformWorldToShadowCoord(surface.position);
    Light light = GetMainLight(shadowCoord);
    //float3 color = GetLighting(surface, brdf);
    Cartoon toon = (Cartoon)0;
    SetupCartoon(input, toon);

    float3 color = mainTex.rgb;
    color = MixColor(surface, light, toon, mainTex.rgb);
    uint lightCount = GetAdditionalLightsCount();
    for (int i = 0; i < lightCount; ++i)
    {
        Light light = GetAdditionalLight(i, surface.position);
        color += MixColor(surface, light, toon, mainTex.rgb);
    }
    //return input.color;
    return float4(color.rgb, mainTex.a);
}

float4 LightingPBRFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv) * UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    float4 extendTex = SAMPLE_TEXTURE2D(_ExtendTexture, sampler_MainTex, input.uv);

#if defined(_CLIPPING)
    clip(mainTex.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff));
#endif

    Surface surface = (Surface)0;
    SetupSurface(input, mainTex, surface);
    Cartoon toon = (Cartoon)0;
    SetupCartoon(input, toon);

    float4 shadowCoord = TransformWorldToShadowCoord(surface.position);
    Light mainLight = GetMainLight(shadowCoord);
    float3 color = mainTex.rgb;
    
    float3 toonColor = MixColor(surface, mainLight, toon, mainTex.rgb);
    uint lightCount = GetAdditionalLightsCount();
    for (int i = 0; i < lightCount; ++i)
    {
        Light additionalLight = GetAdditionalLight(i, surface.position);
        toonColor += MixColor(surface, additionalLight, toon, mainTex.rgb);
    }
    float3 finalColor = toonColor;
    return float4(finalColor, mainTex.a);
}
#endif