#ifndef PBR_CARTOON_INCLUDE
#define PBR_CARTOON_INCLUDE

struct PBRCartoon
{
    float4 baseColor;
    float3 normal;
    float3 position;
    float3 viewDir;
    float3 F0;
    float roughness;
    float metallic;
    float smoothness;
    float occlusion;
#if defined (_FRESNEL_ENABLE)
    float cartoonFresnel;
#endif
#if defined (_SDF_SHADOW)
    float shadowSDF;
#endif
};

PBRCartoon GetPBRCartoon(THVaryings input)
{
    PBRCartoon cartoon = (PBRCartoon) 0;
    float4 mainColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
#if _PBR_TEXTURE_USED
    float3 pbrTex = SAMPLE_TEXTURE2D(_PBRTex, sampler_PBRTex, input.uv).rgb;
    float smoothness = pbrTex.r;
    float metallic = pbrTex.g;
    float occlusion = pbrTex.b;
#else
    float smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);
    float metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
    float occlusion = 1.0;
#endif
    
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    
    cartoon.baseColor = mainColor * mainTex;
#if _NORMAL_TEX_ENABLE
    float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, input.uv));
    cartoon.normal = mul(normalTS, float3x3(input.tangentWS.xyz, input.bitTangentWS.xyz, input.normalWS.xyz));
#else
    cartoon.normal = input.normalWS;
#endif
    cartoon.position = input.positionWS;
    cartoon.viewDir = input.viewDirWS;
    cartoon.roughness = max(1 - smoothness, 0.05);
    cartoon.metallic = metallic;
    cartoon.smoothness = smoothness;
    cartoon.occlusion = occlusion;
#if defined (_FRESNEL_ENABLE)
    cartoon.cartoonFresnel = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CartoonFresnel);
#endif
    cartoon.F0 = lerp(0.04.xxx, cartoon.baseColor.rgb, metallic);
    
#if defined(_SDF_SHADOW)
    cartoon.shadowSDF = SAMPLE_TEXTURE2D(_SDFTexture, sampler_SDFTexture, input.uv).r;
#endif
    
    return cartoon;
}

PBRCartoon GetRoadPBRCartoon(THVaryings input)
{
    PBRCartoon cartoon = (PBRCartoon)0;
    float4 mainColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
#if _PBR_TEXTURE_USED
    float3 pbrTex = SAMPLE_TEXTURE2D(_PBRTex, sampler_PBRTex, input.uv).rgb;
    float smoothness = pbrTex.r;
    float metallic = pbrTex.g;
#else
    float smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);
    float metallic = UNITY_ACCESS_INSTANCED_PROP(UNityPerMaterial, _Metallic);
#endif
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    cartoon.baseColor = mainColor * mainTex;
    cartoon.normal = input.normalWS;
    cartoon.position = input.positionWS;
    cartoon.viewDir = input.viewDirWS;
    cartoon.roughness = max(1 - smoothness, 0.05);
    cartoon.metallic = metallic;
    cartoon.smoothness = smoothness;
#if defined (_FRESNEL_ENABLE)
    cartoon.cartoonFresnel = 1;
#endif
    cartoon.F0 = lerp(0.04.xxx, cartoon.baseColor.rgb, metallic);

    return cartoon;
}

#endif