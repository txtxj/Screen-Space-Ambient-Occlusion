using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSAO : PostEffectsBase
{
    public Shader shader;
    private Material mat;

    private Material material
    {
        get
        {
            if (mat == null && shader != null)
            {
                mat = new Material(shader);
                mat.SetMatrix("_Matrix_I_P", Matrix4x4.Inverse(GetComponent<Camera>().projectionMatrix));
            }
            return mat;
        }
    }

    public void OnRenderImage(RenderTexture src, RenderTexture dest)
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
