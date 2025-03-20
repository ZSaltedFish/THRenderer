# THRenderer

THRenderer is a PBR-based toon shading shader for Unity URP, supporting Fresnel rim lighting, outline effects, and metallic reflections.

## Features
- PBR-based rendering with support for Metallic, Smoothness, and Ambient Occlusion (AO).
- Toon-style effects:
  - Fresnel rim lighting enhances character silhouettes.
  - Outline rendering creates an anime-style border effect.
- Custom lighting model that integrates with Unity URP for a natural toon shading experience.
- Supports multiple light sources and shadows.

## Installation & Usage
### Requirements
- Unity 2022 or later
- Universal Render Pipeline (URP)

### Install via Package Manager
1. Open Unity and go to Edit → Project Settings. Ensure that your Scriptable Render Pipeline is set to URP.
2. Open Unity Package Manager (Window → Package Manager).
3. Click the `+` button at the top left and select `Add package from git URL...`.
4. Enter the following Git URL: https://github.com/ZSaltedFish/THRenderer.git?path=Packages/THRenderer
5. Wait for Unity to download and import the shader.

## Showcase
![2780904d201ca2876a5c910b8823b28a](https://github.com/user-attachments/assets/09bd43bc-6dce-4d23-b48f-777e16792183)

The image above showcases THRenderer in Unity URP, featuring outlines, metallic reflections, and PBR lighting.

## Parameter Overview
![image](https://github.com/user-attachments/assets/a27a8585-1838-4a77-8f75-cd2eaa6aaf74)

| Parameter                | Description |
|-------------------------|-------------|
| Main Texture            | Albedo texture, controlling the base color. |
| Shadow Texture          | Shadow map affecting toon-style shading. |
| PBR Texture (smo:RGB)   | PBR texture channels: R = Smoothness, G = Metallic, B = Ambient Occlusion (AO). |
| Normal Texture          | Normal map, defining surface details. |
| Fresnel Enable          | Enables Fresnel rim lighting. |
| Cartoon Fresnel         | Adjusts rim lighting intensity (higher values reduce the effect). |
| Outline Color           | Sets the color of the outline. |
| Outline Size            | Adjusts the thickness of the outline. |
| Auto Screen Size Outline | Whether the outline adapts to screen size. |
