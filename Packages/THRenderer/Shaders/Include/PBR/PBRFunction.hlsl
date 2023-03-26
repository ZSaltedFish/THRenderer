#ifndef PBR_FUNCTION_INCLUDED
#define PBR_FUNCTION_INCLUDED

#define PI 3.141592653
float D_Function(float NdotH, float roughness)
{
    float a2 = roughness * roughness;
    float NdotH2 = NdotH * NdotH;
    float d = (NdotH2 * (a2 - 1) + 1);
    d = d * d;
    return a2 / d / PI;
}
#endif