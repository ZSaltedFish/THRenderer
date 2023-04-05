#ifndef PBR_FUNCTION_INCLUDED
#define PBR_FUNCTION_INCLUDED

#define PI 3.141592653
float D_Function(float NdotH, float roughness)
{
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH2 = NdotH * NdotH;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = denom * PI * denom;
    return a2 / denom;
}

float PBR_G_SubFunction(float NdotW, float k)
{
    return NdotW / lerp(NdotW, 1.0, k);
}

float PBR_G_Function(float NdotL, float NdotV, float roughness)
{
    float k = (1.0 + roughness) * (1.0 + roughness) / 8;
    return PBR_G_SubFunction(NdotL, k) * PBR_G_SubFunction(NdotV, k);
}

float PBR_F_Light_Function(float HdotL, float3 F0)
{
    float fresnel = exp2((-5.55473 * HdotL - 6.98316) * HdotL);
    return lerp(fresnel, 1.0, F0);
}

float3 PBR_F_IndireLight_Function(float NdotV, float roughness, float3 F0)
{
    float fresnel = exp2((-5.55473 * NdotV - 6.98316) * NdotV);
    return F0 + fresnel * saturate(1 - roughness - F0);
}

float2 LUT_Approx(float roughness, float NoV)
{
    // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
    // Adaptation to fit our G term.
    const float4 c0 = { -1, -0.0275, -0.572, 0.022 };
    const float4 c1 = { 1, 0.0425, 1.04, -0.04 };
    float4 r = roughness * c0 + c1;
    float a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y;
    float2 AB = float2(-1.04, 1.04) * a004 + r.zw;
    return saturate(AB);
}

float3 DirectionLightFunction(float roughness, float3 F0, float3 mainLightColor, float NdotH, float NdotL, float NdotV, float HdotL)
{
    float D = D_Function(NdotH, roughness);
    float G = PBR_G_Function(NdotL, NdotV, roughness);
    float F = PBR_F_Light_Function(HdotL, F0);
    float3 BRDFSpeSection = D * G * F / (4 * NdotL * NdotV);
    return BRDFSpeSection * mainLightColor * NdotL * PI;
}

float3 DiffuseLightFunction(float HdotL, float NdotL, float3 baseColor, float3 mainLightColor, float metallic, float shadow, float3 F0)
{
    float3 KS = PBR_F_Light_Function(HdotL, F0);
    float3 KD = (1 - KS) * (1 - metallic);
    return KD * baseColor * mainLightColor * NdotL * shadow;
}

float3 IndireDiff_Function(float NdotV, float3 N, float metallic, float3 baseColor, float roughness, float occlusion, float3 F0, float3 ambient)
{
    float3 SHColor = ambient;
    float3 KS = PBR_F_IndireLight_Function(NdotV, roughness, F0);
    float3 KD = (1 - KS) * (1 - metallic);
    return SHColor * KD * baseColor * occlusion;
}

float3 IndireSpec_Function(float3 envColor, float roughness, float NdotV, float occlusion, float3 F0)
{
    float2 LUT = LUT_Approx(roughness, NdotV);
    float3 indireLight = PBR_F_IndireLight_Function(NdotV, roughness, F0);
    float3 factor = envColor * (indireLight * LUT.r + LUT.g);
    return factor * occlusion;
}

float3 ReflectEEnvironment(float roughness, float3 normalWS)
{
    float3 environment = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, normalWS, 0.0).rgb;
    environment /= roughness * roughness + 1.0;
    return environment;
}

float3 DirectionLightCalc(PBRCartoon cartoon, Light light, float3 N, float3 V, float3 NdotV)
{
    float3 L = normalize(light.direction);
    float3 H = normalize(L + V);
    float HdotN = max(dot(H, N), 1e-5);
    float HdotL = max(dot(H, L), 1e-5);
    float NdotL = max(dot(N, L), 1e-5);

    float shadow = light.shadowAttenuation * light.distanceAttenuation;
    float3 direLight = DirectionLightFunction(cartoon.roughness, cartoon.F0, light.color, HdotN, NdotL, NdotV, HdotL);
    float3 diffuseLight = DiffuseLightFunction(HdotL, NdotL, cartoon.baseColor, light.color, cartoon.metallic, shadow, cartoon.F0);

    return direLight + diffuseLight;
}

float3 CartoonPBRRender(PBRCartoon cartoon)
{
    float3 ambient = float3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
    
    float3 N = normalize(cartoon.normal);
    float3 V = normalize(cartoon.viewDir);
    
    float NdotV = max(dot(N, V), 1e-5);
    float3 envColor = ReflectEEnvironment(cartoon.roughness, N);
    float3 indireLight = IndireDiff_Function(NdotV, N, cartoon.metallic, cartoon.baseColor, cartoon.roughness, 1.0, cartoon.F0, ambient);
    float3 indireSpecLight = IndireSpec_Function(envColor, cartoon.roughness, NdotV, 1.0, cartoon.F0);
    
    float4 shadowCoord = TransformWorldToShadowCoord(cartoon.position);
    Light mainLight = GetMainLight(shadowCoord);

    float3 direLight = DirectionLightCalc(cartoon, mainLight, N, V, NdotV);
    uint additionLightCount = GetAdditionalLightsCount();
    for (int i = 0; i < additionLightCount; ++i)
    {
        Light additionalLight = GetAdditionalLight(i, cartoon.position);
        direLight += DirectionLightCalc(cartoon, additionalLight, N, V, NdotV);
    }
    
    return direLight + indireLight + indireSpecLight;

}
#endif