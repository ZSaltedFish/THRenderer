#ifndef TH_IO_DEFINE_INCLUDED
#define TH_IO_DEFINE_INCLUDED

#include "THCommon.hlsl"
struct THAttributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 color        : COLOR0;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};
struct THVaryings
{
    float2 uv           : TEXCOORD0;
    float4 positionWS   : TEXCOORD1;
    float3 normalWS     : TEXCOORD2;
    float4 tangentWS    : TEXCOORD3;
    float3 viewDirWS    : TEXCOORD4;
    float4 positionCS   : SV_POSITION;
    float4 screenPos    : TEXCOORD5;
    float4 color        : TEXCOORD6;
    float3 bitTangentWS : TEXCOORD7;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

#endif