#ifndef TH_FACE_SOURCE_INCLUDE
#define TH_FACE_SOURCE_INCLUDE

#include "..\\THCommon.hlsl"
#include "..\\TH_IO_Define.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_ShadowTex);
SAMPLER(sampler_ShadowTex);

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _ShadowTex_ST)
#if defined(_CLIPPING)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
#endif
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

THVaryings FaceVertex(THAttributes input)
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

#include "THFaceInput.hlsl"
#include "THFaceFunction.hlsl"

float4 FaceFragment(THVaryings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    THFaceInput face = GetTHFaceInput(input);
    
#if defined(_CLIPPING)
    float c = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CutOff);
    clip(face.baseColor - c);
#endif
    float3 diff = FaceRenderer(face);
    return float4(diff, face.baseColor.a);

}
#endif