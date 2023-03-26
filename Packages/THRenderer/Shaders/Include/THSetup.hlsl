#ifndef TH_SETUP_INCLUDED
#define TH_SETUP_INCLUDED

void SetupSurface(Varyings input, float4 color, inout Surface surface)
{
    surface.position = input.positionWS;
    surface.normal = normalize(input.normalWS);
    surface.viewDirection = normalize(_WorldSpaceCameraPos - input.positionWS);
    surface.color = color.rgb;
    surface.alpha = color.a;

#if defined(_PBR_SHADER)
    float4 pbrTex = SAMPLE_TEXTURE2D(_MeSmoo, sampler_MeSmoo, input.uv);
    surface.metallic = pbrTex.r;
    surface.smoothness = pbrTex.g;
#endif
}

void SetupCartoon(Varyings input, out Cartoon toon)
{
    float4 extendTex = SAMPLE_TEXTURE2D(_ExtendTexture, sampler_MainTex, input.uv);
    float4 darkColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _CoodColor);
    float4 warmColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _WarmColor);
    float4 specColor = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _SpecColor);
    float darkThreshold = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _darkThreshold);
    float specThreshold = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _lightThreshold);
    float lightPower = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _lightPower);
    float fresnelPower = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _fresnelPower);

    toon.darkColor = darkColor.rgb;
    toon.warmColor = warmColor.rgb;
    toon.specColor = specColor.rgb;
    toon.darkThreshold = darkThreshold;
    toon.specThreshold = specThreshold;
    toon.specPower = lightPower;
    toon.fresnelPower = fresnelPower;
    toon.extendTex = extendTex;
}

#endif