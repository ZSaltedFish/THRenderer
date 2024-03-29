#ifndef THPBR_INCLUDE
#define THPBR_INCLUDE

#include "..\\THCommon.hlsl"
#include "..\\TH_IO_Define.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_ShadowTex);
SAMPLER(sampler_ShadowTex);

#if _NORMAL_TEX_ENABLE
TEXTURE2D(_NormalTex);
SAMPLER(sampler_NormalTex);
#endif

#if _PBR_TEXTURE_USED
TEXTURE2D(_PBRTex);
SAMPLER(sampler_PBRTex);
#endif

#if defined(_SDF_SHADOW)
TEXTURE2D(_SDFTexture);
SAMPLER(sampler_SDFTexture);
#endif

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
#if _FRESNEL_ENABLE
UNITY_DEFINE_INSTANCED_PROP(float, _CartoonFresnel)
#endif
#if _PBR_TEXTURE_USED
UNITY_DEFINE_INSTANCED_PROP(float4, _PBRTex_ST)
#else
UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
#endif

#if _NORMAL_TEX_ENABLE
UNITY_DEFINE_INSTANCED_PROP(float4, _NormalTex_ST)
#endif

#if defined(_SDF_SHADOW)
UNITY_DEFINE_INSTANCED_PROP(float4, _SDFTexture_ST)
#endif
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
    output.bitTangentWS = cross (output.normalWS, output.tangentWS);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
    output.uv = input.texcoord * baseST.xy + baseST.zw;
    output.color = input.color;

    return output;
}

#include "PBRCartoon.hlsl"
#include "PBRCartoonRendererFunction.hlsl"
#include "PBRFunction.hlsl"

float4 PBRFragment(THVaryings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    PBRCartoon cartoon = GetPBRCartoon(input);
    
#if defined(_CLIPPING)
    float cutoff = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff);
    clip(cartoon.baseColor.a - cutoff);
#endif
    float3 lightColor = CartoonPBRRender(cartoon);
    return float4(lightColor, cartoon.baseColor.a);
}

float4 PBRFragmentVertexColor(THVaryings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    PBRCartoon cartoon = GetPBRCartoon(input);

    float4 mainColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    cartoon.baseColor = mainColor * input.color;
#if defined(_CLIPPING)
    float cutoff = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff);
    clip(cartoon.baseColor.a - cutoff);
#endif
    float3 lightColor = CartoonPBRRender(cartoon);
    return float4(lightColor, cartoon.baseColor.a);
}
#endif