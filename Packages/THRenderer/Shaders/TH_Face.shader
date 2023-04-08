Shader "THRenderer/TH_Face"
{
    Properties
    {
        _Color ("Color", color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _SDFTexture("SDF Texture", 2D) = "white" {}
        _ShadowTex("Shadow Color", 2D) = "gray" {}
        _CutOff ("Alpha Cut off", Range(0, 1)) = 0.5
        _CartoonFresnel("Cartoon Fresnel", float) = 5
        _Smoothness("Smoothness", range(0, 1)) = 0.5
        _Metallic("Metallic", range(0, 1)) = 0

        _OutlineColor("Outline Color", color) = (0, 0, 0, 1)
        _OutlineSize("Out line size", float) = 1

        [Toggle(_CLIPPING)] _CLIPPING ("Enable Alpha Clipping", float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", float) = 10.0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode ("Cull Mode", float) = 1.0
        [Enum(off, 0, On, 1)] _ZWrite ("Z Write", float) = 1.0
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
            #pragma multi_complie_instancing
            #pragma multi_compile _SDF_SHADOW
            #pragma shader_feature_local _CLIPPING
            #include "Include/PBR/THPBR.hlsl"
            #pragma vertex PBRVertex
            #pragma fragment PBRFragment
            #pragma target 3.5
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags {"LightMode" = "SRPDefaultUnlit"}
            Blend[_SrcBlend][_DstBlend]
            Cull front
            ZWrite On

            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma shader_feature_local _CLIPPING
            #pragma shader_feature_local _AUTO_SCREEN_SIZE_OUTLINE
            #include "Include/THOutline.hlsl"
            #pragma vertex OutlineVertex
            #pragma fragment OutlineFragment
            #pragma target 3.5
            ENDHLSL
        }
    }
}
