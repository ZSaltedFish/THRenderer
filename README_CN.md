# THRenderer

THRenderer 是一个 **基于 PBR 的卡通渲染 Shader**，支持 **Fresnel 边缘光、描边、金属反射** 等效果，适用于 **Unity URP**（Universal Render Pipeline）。

## 特性
- **基于 PBR（物理渲染）**：支持金属度（Metallic）、光滑度（Smoothness）、环境光遮蔽（AO）。
- **卡通风格**：
  - **Fresnel 边缘光（Rim Lighting）** 增强角色轮廓。
  - **描边（Outline）** 实现动漫风格外框。
- **自定义光照模型**：结合 Unity URP 光照，实现更自然的卡通渲染效果。
- **支持多光源 & 阴影**：兼容 Unity 的主光源与额外光源。

---

## 🛠 安装 & 使用
### 1**环境要求**
- Unity **2022 及以上**
- **URP（Universal Render Pipeline）**

### 2**通过 Package Manager 导入**
1. 打开 **Unity**，进入 **Edit → Project Settings**，确认你的 **Scriptable Render Pipeline** 使用的是 **URP**。
2. **打开 Unity Package Manager（Window → Package Manager）**。
3. 点击左上角 **`+`** 按钮，选择 **`Add package from git URL...`**。
4. 输入以下 Git URL：https://github.com/ZSaltedFish/THRenderer.git?path=Packages/THRenderer
5. 等待 Unity 下载并导入 Shader。

---

## 效果展示
![2780904d201ca2876a5c910b8823b28a](https://github.com/user-attachments/assets/09bd43bc-6dce-4d23-b48f-777e16792183)

> **注**：上图展示了 **THRenderer** 在 Unity URP 中的渲染效果，包含描边、金属反射和 PBR 光照。

## 参数说明
![image](https://github.com/user-attachments/assets/a27a8585-1838-4a77-8f75-cd2eaa6aaf74)
| **参数名称**             | **说明** |
|-------------------------|---------|
| **Main Texture**        | 主要颜色贴图（Albedo）。 |
| **Shadow Texture**      | 阴影贴图，影响 Toon 阴影计算。 |
| **PBR Texture (smo:RGB)** | PBR 贴图，R=光滑度，G=金属度，B=环境遮蔽。 |
| **Normal Texture**      | 法线贴图，控制表面细节。 |
| **Fresnel Enable**      | 是否启用 Fresnel 边缘光。 |
| **Cartoon Fresnel**     | 控制边缘光强度 |
| **Outline Color**       | 描边颜色。 |
| **Outline Size**        | 描边粗细，影响轮廓线宽度。 |
| **Auto Screen Size Outline** | 是否根据屏幕尺寸自适应描边大小。 |
