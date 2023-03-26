#ifndef TH_SHADOW_INCLUDED
#define TH_SHADOW_INCLUDED

#include "THCommon.hlsl"

struct appdata
{
    float4 vertex       : POSITION;
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
SAMPLER(sampler_MainTex);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

v2f vert(appdata v)
{
    v2f o = (v2f)0;
    UNITY_SETUP_INSTANCE_ID(o);
    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
    
    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _MainTex_ST);
    o.uv = v.texcoord * baseST.xy + baseST.zw;
    return o;
}

float4 frag(v2f input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

#if defined(_CLIPPING)
    clip(mainTex.a - UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff));
#endif

    return float4(0, 0, 0, 1);
}
#endif