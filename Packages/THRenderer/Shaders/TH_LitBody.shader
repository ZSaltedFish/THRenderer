Shader "THRenderer/LitBody"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("InputTex", 2D) = "white" {}
        //_Metallic ("Metallic", range(0, 1)) = 0
        //_Smoothness ("Smoothness", range(0, 1)) = 0
        _ExtendTexture ("Extend Texture", 2D) = "black" {}
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineSize ("Out line Size", float) = 1
        // Color
        _SpecColor ("Spec Color", Color) = (0.95, 0.95, 0.95, 1)
        _WarmColor ("Warm Color", Color) = (0.94, 0.93, 0.68, 1)
        _CoodColor ("Cood Color", Color) = (0.34, 0.37, 0.50, 1)
        _darkThreshold ("Dark Threshold", range(0, 1)) = 0.3
        _lightThreshold ("Light Threshold", range(0, 1)) = 0.7
        _lightPower ("Light power", float) = 2
        _fresnelPower ("Fresnel power", float) = 1

        _lightShowMap ("Light Shadow Map", 2D) = "white" {}

        _CutOff ("Cut Off", range(0, 1)) = 0.5
        [Toggle(_CLIPPING)] _Clipping("Enable Alpha Clipping", Float) = 0
        [Toggle(_PREMULTIPLY_ALPHA)] _PREMULTIPLY_ALPHA ("Premultiply Alpha", Float) = 0
        [Toggle(_AUTO_SCREEN_SIZE_OUTLINE)] _AUTO_SCREEN_SIZE_OUTLINE("Auto Screen size Outline", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("Src Blend", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("Dst Blend", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 1
        [Enum(Off, 0, On, 1)] _ZWrite("Z Write", float) = 1
     }

     SubShader
     {
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"} 
            Blend [_SrcBlend] [_DstBlend]
            Cull [_CullMode]
            Zwrite [_ZWrite]

            HLSLPROGRAM
            #pragma multi_compile_instancing
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma shader_feature_local _PREMULTIPLY_ALPHA
            #pragma shader_feature_local _CLIPPING
            #include "Include/THForwardLit.hlsl"
            #pragma vertex LightingVertex
            #pragma fragment LightingFragment
            #pragma target 3.5
            ENDHLSL
        }

        Pass
        {
            Name "Outline"
            Tags{ "LightMode" = "SRPDefaultUnlit" }
            Blend [_SrcBlend] [_DstBlend]
            Cull front
            Zwrite On

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
            ZWrite on

            Tags {"LightMode" = "ShadowCaster"}
            HLSLPROGRAM
            #pragma multi_compile_instancing
            #include "Include/THShadow.hlsl"
            #pragma shader_feature_local _CLIPPING
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.5
            ENDHLSL
        }
    }
}
