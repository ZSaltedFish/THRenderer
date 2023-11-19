#ifndef ROAD_PBR_INCLUDED
#define ROAD_PBR_INCLUDED

#include "..\\THCommon.hlsl"
#include "..\\TH_IO_Define.hlsl"

TEXTURE2D (_MainTex);
SAMPLER (sampler_MainTex);
TEXTURE2D (_RoadTex);
SAMPLER (sampler_RoadTex);
TEXTURE2D (_ShadowTex);
SAMPLER(sampler_ShadowTex);
TEXTURE2D (_GrassMask);
SAMPLER(sampler_GrassMask);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float, _Cutoff)
UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
UNITY_DEFINE_INSTANCED_PROP(float, _CartoonFresnel)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

THVaryings PBRVertex(THAttributes input)
{
    THVaryings output = (THVaryings) 0;

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

#include "..\\PBR\\PBRCartoon.hlsl"
#include "..\\PBR\\PBRCartoonRendererFunction.hlsl"
#include "..\\PBR\\PBRFunction.hlsl"

float4 RoadTextureMerge(THVaryings input)
{
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    float4 roadTex = SAMPLE_TEXTURE2D(_RoadTex, sampler_RoadTex, input.uv);
    float4 maskTex = SAMPLE_TEXTURE2D(_GrassMask, sampler_GrassMask, input.uv);
    return lerp(mainTex, roadTex, maskTex.r);
}

float4 RoadPBRFragment(THVaryings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    PBRCartoon cartoon = GetRoadPBRCartoon(input);
    float4 mainColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    cartoon.baseColor = RoadTextureMerge(input);

    float3 lightColor = CartoonPBRRender(cartoon);
    return float4(lightColor, cartoon.baseColor.a);
}

#endif