using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSAO : PostEffectsBase
{
    public Shader shader;
    private Material mat;
    
    public float sampleCount = 128f;
    public float sampleRadius = 0.618f;
    public float depthRange = 0.01f;
    public bool onlyOcclusion = false;

    private Material material
    {
        get
        {
            if (mat == null && shader != null)
            {
                mat = new Material(shader);
#if UNITY_EDITOR
            }
#endif
            mat.SetFloat("_SampleCount", sampleCount);
            mat.SetFloat("_SampleRadius", sampleRadius);
            mat.SetFloat("_OnlyOcclusion", onlyOcclusion ? 1f : 0f);
            mat.SetFloat("_DepthRange", depthRange);
#if UNITY_EDITOR
#else
            }
#endif
            return mat;
        }
    }
    
    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            Graphics.Blit(src, dest, material, -1);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
