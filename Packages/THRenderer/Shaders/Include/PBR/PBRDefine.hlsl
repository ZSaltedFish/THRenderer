#ifndef PBR_DEFINE_INCLUDED
#define PBR_DEFINE_INCLUDED

#define SPECULAR_VALUE 0.04;

struct LitSurfaceX
{
    float3 normal;
    float3 position;
    float3 viewDir;
    float3 diffuse;
    float3 specular;
    float roughness;
    float perceptualRoughness;
};

LitSurfaceX GetLitSurface(float3 normal, float3 position, float3 viewDir, float3 color, float smoothnes)
{
    LitSurfaceX lit = (LitSurfaceX)0;
    lit.normal = normal;
    lit.position = position;
    lit.viewDir = viewDir;
    lit.diffuse = color;

    lit.specular = SPECULAR_VALUE;
    lit.perceptualRoughness = 1.0 - smoothnes;
    lit.roughness = lit.perceptualRoughness * lit.perceptualRoughness;

    return lit;
}

float3 LightSurface(LitSurfaceX s, float3 lightDir)
{
    float3 color = s.diffuse;
    color *= saturate(dot(s.normal, lightDir));
    return color;
}

float3 GenericLight(Light light, LitSurfaceX s)
{
    float3 color = LightSurface(s, light.direction);
    return color * light.color;
}
#endif