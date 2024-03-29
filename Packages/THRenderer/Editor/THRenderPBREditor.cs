using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace ZKnight.THRenderer.Editor
{
    public class THRenderPBREditor : ShaderGUI
    {
        private static class Contents
        {
            public static readonly GUIContent MAIN_COLOR = new GUIContent("Main Color");
            public static readonly GUIContent MAIN_TEXTURE = new GUIContent("Main Texture");
        }

        private Dictionary<string, MaterialProperty> _materialProps;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            if (_materialProps == null)
            {
                InitMaterialProperties(properties);
            }

            var mat = materialEditor.target as Material;
            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                _ = materialEditor.ColorProperty(_materialProps["_Color"], "Main Color");
                _ = materialEditor.TextureProperty(_materialProps["_MainTex"], "Main Texture");
                _ = materialEditor.TextureProperty(_materialProps["_ShadowTex"], "Shadow Texture");
            }

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                DrawDefaultGUI(materialEditor, "_FRESNEL_ENABLE", "Fresnel enable");

                var fresnelEnable = Array.IndexOf(mat.shaderKeywords, "_FRESNEL_ENABLE") != -1;
                if (fresnelEnable)
                {
                    _ = materialEditor.FloatProperty(_materialProps["_CartoonFresnel"], "Cartoon Fresnel");
                }
            }

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                using (var check = new EditorGUI.ChangeCheckScope())
                {
                    var pbrTex = materialEditor.TextureProperty(_materialProps["_PBRTex"], "PBR Texture (smo:RGB)");
                    if (check.changed)
                    {
                        if (pbrTex)
                        {
                            mat.EnableKeyword("_PBR_TEXTURE_USED");
                        }
                        else
                        {
                            mat.DisableKeyword("_PBR_TEXTURE_USED");
                        }
                    }

                    if (!pbrTex)
                    {
                        materialEditor.RangeProperty(_materialProps["_Smoothness"], "Smoonthess");
                        materialEditor.RangeProperty(_materialProps["_Metallic"], "Metallic");
                    }
                }
            }

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                using (var changed = new EditorGUI.ChangeCheckScope())
                {
                    var normalTex = materialEditor.TextureProperty(_materialProps["_NormalTex"], "Normal Texture");
                    if (changed.changed)
                    {
                        if (normalTex)
                        {
                            mat.EnableKeyword("_NORMAL_TEX_ENABLE");
                        }
                        else
                        {
                            mat.DisableKeyword("_NORMAL_TEX_ENABLE");
                        }
                    }
                }

            }

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                _ = materialEditor.ColorProperty(_materialProps["_OutlineColor"], "Outline color");
                _ = materialEditor.FloatProperty(_materialProps["_OutlineSize"], "Outline size");
                DrawDefaultGUI(materialEditor, "_AUTO_SCREEN_SIZE_OUTLINE", "Auto Screen size outline");
            }

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                DrawDefaultGUI(materialEditor, "_CLIPPING", "Clipping");
                var cut = Array.IndexOf(mat.shaderKeywords, "_CLIPPING") != -1;
                if (cut)
                {
                    materialEditor.RangeProperty(_materialProps["_CutOff"], "Cut off");
                }
            }

            var defaultGUI = new MaterialProperty[] {
                _materialProps["_PREMULTIPLY_ALPHA"],
                _materialProps["_SrcBlend"],
                _materialProps["_DstBlend"],
                _materialProps["_CullMode"],
                _materialProps["_ZWrite"]
            };

            using (new EditorGUILayout.VerticalScope(EditorStyles.helpBox))
            {
                materialEditor.PropertiesDefaultGUI(defaultGUI);
            }
        }

        private void DrawDefaultGUI(MaterialEditor editor, string name, string label)
        {
            editor.ShaderProperty(_materialProps[name], label);
        }

        private void InitMaterialProperties(MaterialProperty[] properties)
        {
            _materialProps = new Dictionary<string, MaterialProperty>();
            foreach (var prop in properties)
            {
                var name = prop.name;
                _materialProps.Add(name, prop);
            }
        }
    }
}