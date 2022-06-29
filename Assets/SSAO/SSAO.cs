using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSAO : PostEffectsBase
{
    public Shader shader;
    private Material mat;
    
    public float sampleCount = 64f;
    public float sampleRadius = 0.01f;

    private Material material
    {
        get
        {
            if (mat == null && shader != null)
            {
                mat = new Material(shader);
                mat.SetMatrix("_Matrix_I_P", Matrix4x4.Inverse(GetComponent<Camera>().projectionMatrix));
                mat.SetFloat("_SampleCount", sampleCount);
                mat.SetFloat("_SampleRadius", sampleRadius);
            }
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
