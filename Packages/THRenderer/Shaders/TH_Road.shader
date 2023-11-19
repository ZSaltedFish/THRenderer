Shader "THRenderer/TH Road"
{
    Properties
    {
        _Color ("Color", color) = (1, 1, 1, 1)
        _MainTex ("Input Texture", 2D) = "white" {}
        _RoadTex ("Road Texture", 2D) = "white" {}
        _GrassMask ("Grass mask", 2D) = "white" {}
        _Smoothness ("Smoothness", range(0, 1)) = 0.5
        _Metallic ("Metallic", range(0, 1)) = 0
        _CartoonFresnel ("Cartoon Fresnel", float) = 5

        _CutOff ("Cut off", range(0, 1)) = 0.5
        [Toggle(_CLIPPING)] _CLIPPING ("Enable Alpha Clipping", float) = 0
        [Toggle(_PREMULTIPLY_ALPHA)] _PREMULTIPLY_ALPHA ("Premultiply Alpha", float) = 0
        [Toggle(_AUTO_SCREEN_SIZE_OUTLINE)] _AUTO_SCREEN_SIZE_OUTLINE ("Auto Screen size Outline", float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", float) = 10.0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", float) = 1
        [Enum(off, 0, On, 1)] _ZWrite ("Z Write", float) = 1
    }

    SubShader
    {
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            Blend [_SrcBlend] [_DstBlend]
            Cull [_CullMode]
            ZWrite [_ZWrite]

            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma shader_feature_local _PBR_TEXTURE_USED
            #pragma shader_feature_local _CLIPPING
            #include "Include/Road/RoadPBR.hlsl"
            #pragma vertex PBRVertex
            #pragma fragment RoadPBRFragment
            ENDHLSL
        }
    }
}