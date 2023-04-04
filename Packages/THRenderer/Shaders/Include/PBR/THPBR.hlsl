#ifndef THPBR_INCLUDE
#define THPBR_INCLUDE

#include "..\\THCommon.hlsl"
#include "..\\TH_IO_Define.hlsl"
#include "PBRFunction.hlsl"
#include "PBRDefine.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

#if _PBR_TEXTURE_USED
TEXTURE2D(_PBRTex);
SAMPLER(sampler_PBRTex);
#endif

UNITY_INSTANCING_BUFFER_START(UnityPerMaterial)
UNITY_DEFINE_INSTANCED_PROP(float4, _MainTex_ST)
UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
UNITY_DEFINE_INSTANCED_PROP(float, _CutOff)
#if _PBR_TEXTURE_USED
UNITY_DEFINE_INSTANCED_PROP(float4, _PBRTex_ST)
#else
UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
UNITY_DEFINE_INSTANCED_PROP(float, _Metallic)
#endif
UNITY_INSTANCING_BUFFER_END(UnityPerMaterial)

Varyings PBRVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(intput, output);
    float3 positionWS = TransformObjectToWorld(input.positionOS);
    float4 positionCS = TransformWorldToHClip(positionWS);
    output.positionCS = positionCS;
    output.positionWS = float4(positionWS, 1);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangentWS = float4(TransformObjectToWorldNormal(input.tangentOS.xyz), 1);
    output.viewDirWS = GetWorldSpaceViewDir(positionWS);

    float4 baseST = UNITY_ACCESS_INSTANCED_PROP(UnityPermaterial, _MainTex_ST);
    output.uv = input.texcoord * baseST.xy + baseST.zw;
    output.color = input.color;

    return output;
}

float3 ReflectEEnvironment(float roughness, float3 normalWS)
{
    float3 environment = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, normalWS, 0.0).rgb;
    environment /= roughness * roughness + 1.0;
    return environment;
}

float4 PBRFragment(Varyings input) : SV_TARGET
{
    UNITY_SETUP_INSTANCE_ID(input);
    float3 mainColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
#if _PBR_TEXTURE_USED
    float3 pbrTex = SAMPLE_TEXTURE2D(_PBRTex, sampler_PBRTex, input.uv).rgb;
    float smoothness = pbrTex.r;
    float metallic = pbrTex.g;
#else
    float smoothness = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Smoothness);
    float metallic = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Metallic);
#endif
    float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
    Light mainLight = GetMainLight(shadowCoord);
    
    float3 ambient = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
    float3 L = normalize(mainLight.direction);
    float3 N = normalize(input.normalWS);
    float3 V = normalize(input.viewDirWS);
    float3 H = normalize(L + V);

    LitSurfaceX surface = GetLitSurface(N, input.positionWS.xyz, V, mainColor * mainTex.rgb, smoothness);

    float HdotN = max(dot(H, N), 1e-5);
    float HdotL = max(dot(H, L), 1e-5);
    float NdotL = max(dot(N, L), 1e-5);
    float NdotV = max(dot(N, V), 1e-5);
    
    float roughness = max(1 - smoothness, 0.05);
    float3 baseColor = mainColor * mainTex.rgb;
    float F0 = lerp(0.04, baseColor, metallic);
    float shadow = mainLight.shadowAttenuation * mainLight.distanceAttenuation;

    float3 direLight = DirectionLightFunction(roughness, F0, mainLight.color, HdotN, NdotL, NdotV, HdotL);
    float3 diffuseLight = DiffuseLightFunction(HdotL, NdotL, baseColor, mainLight.color, metallic, shadow, F0);
    float3 environment = ReflectEEnvironment(roughness, N);

    float3 indireLight = IndireDiff_Function(NdotV, N, metallic, baseColor, roughness, 1, F0, environment);
    float3 indireSpecLight = IndireSpec_Function(environment, roughness, NdotV, 1.0, F0);
    
    float3 dLight = direLight + diffuseLight;
    float3 indLight = indireLight + indireSpecLight;
    return float4(dLight + indLight, 1);
    /*roughness *= (1.7 - 0.7 * roughness) * 0.98;
    roughness += 0.02;
    metallic = 1 - metallic;
    metallic *= 0.98;


    float a2 = roughness * roughness;
    float d = D_GGX_Custom(a2, HdotN);
    float g = G_Function(NdotL, NdotV, roughness);

    float3 f0 = F0_Function(mainColor.rgb + environment, metallic);
    float3 f = FresnelSchlick(HdotL, f0);
    //float specular = lerp(0.04, mainLight.color, metallic);

    //float3 f = environment * LocalFresnel(NdotL, 0.04, smoothness) + mainColor * mainTex;
    float3 bpdfSpecSection = (d * g) * f / (4 * NdotL * NdotV);
    float3 directSpecColor = bpdfSpecSection * mainLight.color * NdotL * PI;
    */

    //return float4(f, 1);
    //float3 color = GenericLight(mainLight, surface);

    //return float4(color, 1);
}

#endif