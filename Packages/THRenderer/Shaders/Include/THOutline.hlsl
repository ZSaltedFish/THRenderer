#ifndef TH_OUTLINE_INCLUDED
#define TH_OUTLINE_INCLUDED

#include "THCommon.hlsl"
#include "TH_IO_Define.hlsl"

struct appdata
{
    float4 vertex       : POSITION;
    float3 normal       : NORMAL;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
    float4 pos  : SV_POSITION;
    float2 uv   : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

TEXTURE2D(_MainTex);
TEXTURE2D(_ExtendTexture);
SAMPLER(sampler_MainTex);
SAMPLER(sampler_ExtendTexture);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _ExtendTexture_ST)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
UNITY_DEFINE_INSTANCED_PROP(float4, _OutlineColor)
UNITY_DEFINE_INSTANCED_PROP(float, _OutlineSize)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

THVaryings OutlineVertex(THAttributes input)
{
    THVaryings output = (THVaryings) 0;
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);

    float4 scaledScreenParams = GetScaledScreenParams();
    float scaleX = abs(scaledScreenParams.x / scaledScreenParams.y);

    float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    output.viewDirWS = GetWorldSpaceViewDir(positionWS);
    float4 positionCS = TransformWorldToHClip(positionWS);
    positionCS.z -= input.color.g * 0.001;
    output.positionCS = positionCS;
    output.positionWS = float4(positionWS, 1);
    float3 normalCS = TransformWorldToHClipDir(normalWS);
    float2 extendDis = normalize(normalCS.xy) * UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _OutlineSize) * 0.01 * input.color.r;
    extendDis.x /= scaleX;
#if defined(_AUTO_SCREEN_SIZE_OUTLINE)
    output.positionCS.xy += extendDis;
#else
    output.positionCS.xy += extendDis * output.positionCS.w;
    //output.positionCS.xy += float2(0, 0);
#endif

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
    output.uv = input.texcoord * baseST.xy + baseST.zw;
    output.color = input.color;
    return output;
}

float4 OutlineFragment(THVaryings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    float4 baseColor = color * mainTex;

    clip(input.color.r - 0.0001);

#if defined(_CLIPPING)
    clip(baseColor.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff));
#endif
    float4 outlineColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _OutlineColor);
    //return input.color;
    return float4(outlineColor.rgb, 1);
}

#endif