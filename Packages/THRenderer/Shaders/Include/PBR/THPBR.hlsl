#ifndef THPBR_INCLUDE
#define THPBR_INCLUDE

#include "..\\THCommon.hlsl"
#include "..\\TH_IO_Define.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

#if _PBR_TEXTURE_USED
TEXTURE2D(_PBRTex);
SAMPLER(sampler_PBRTex);
#endif

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
#if _PBR_TEXTURE_USED
UNITY_DEFINE_INSTANCED_PROP(float4, _PBRTex_ST)
#else
UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
#endif
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

Varyings PBRVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(intput, output);
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    float4 positionCS = TransformWorldToHClip(positionWS);
    output.positionCS = positionCS;
    output.positionWS = float4(positionWS, 1);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS = float4(TransformObjectToWorldNormal(input.tangentOS.xyz), 1);
    output.viewDirWS = GetWorldSpaceViewDir(positionWS);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPermaterial, _MainTex_ST);
    output.uv = input.texcoord * baseST.xy + baseST.zw;
    output.color = input.color;

    return output;
}

#include "PBRCartoon.hlsl"
#include "PBRFunction.hlsl"
#include "PBRDefine.hlsl"

float4 PBRFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    PBRCartoon cartoon = GetPBRCartoon(input);
    float3 lightColor = CartoonPBRRender(cartoon);
    return float4(lightColor, 1);
}

#endif