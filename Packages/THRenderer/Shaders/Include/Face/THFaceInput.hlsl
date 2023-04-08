#ifndef TH_FACE_INPUT_INCLUDE
#define TH_FACE_INPUT_INCLUDE

struct THFaceInput
{
    float4 baseColor;
    float3 normal;
    float3 viewDir;
    float3 position;
};

THFaceInput GetTHFaceInput(THVaryings input)
{
    THFaceInput face = (THFaceInput) 0;
    
    float4 color = UNITY_ACCESS_INSTANCED_PROP(UnityPerMaterial, _Color);
    float4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    
    face.baseColor = color * mainTex;
    face.normal = input.normalWS;
    face.viewDir = input.viewDirWS;
    face.position = input.positionWS;
    
    return face;
}

#endif