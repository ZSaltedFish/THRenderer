Shader "THRenderer/DefaultPBR"
{
    Properties
    {
        _Color ("Color", color) = (1, 1, 1, 1)
        _MainTex ("Input Texture", 2D) = "white" {}
        _PBRTex("PBR Texture", 2D) = "white" {}
        _Smoothness ("Smoothness", range(0, 1)) = 0.5
        _Metallic ("Metallic", range(0, 1)) = 0

        _OutlineColor ("Outlinee Color", color) = (0, 0, 0, 1)
        _OutlineSize ("Out line size", float) = 1

        _CutOff ("Cut off", range(0, 1)) = 0.5
        [Toggle(_CLIPPING)] _Clipping ("Enable Alpha Clipping", float) = 0
        [Toggle(_PREMULTIPLY_ALPHA)] _PREMULTIPLY_ALPHA ("Premultiply Alpha", float) = 0
        [Toggle(_AUTO_SCREEN_SIZE_OUTLINE)] _AUTO_SCREEN_SIZE_OUTLINE ("Auto Screen size Outline", float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend", float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend", float) = 0
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
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma shader_feature_local _PBR_TEXTURE_USED
            #pragma shader_feature_local _CLIPPING
            #include "Include/PBR/THPBR.hlsl"
            #pragma vertex PBRVertex
            #pragma fragment PBRFragment
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags {"LightMode" = "SRPDefaultUnlit"}
            Blend [_SrcBlend] [_DstBlend]
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

        Pass
        {
            Name "ShadowCast"
            Blend One Zero
            Cull back
            Zwrite On

            Tags {"LightMode" = "ShadowCaster"}
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #include "Include/THShadow.hlsl"
            #pragma shader_feature_local
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            ENDHLSL
        }
    }

    CustomEditor "ZKnight.THRenderer.Editor.THRenderPBREditor"
}