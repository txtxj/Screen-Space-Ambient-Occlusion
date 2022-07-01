using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SSAO : PostEffectsBase
{
    public Shader ssaoShader;
    public Shader blurShader;
    private Material ssaoMat;
    private Material blurMat;
    
    public float sampleCount = 128f;
    public float sampleRadius = 0.618f;
    public float depthRange = 0.0005f;
    public bool onlyOcclusion = false;
    public bool blur = true;

    private Material ssaoMaterial
    {
        get
        {
            if (ssaoMat == null && ssaoShader != null)
            {
                ssaoMat = new Material(ssaoShader);
#if UNITY_EDITOR
            }
#endif
            ssaoMat.SetFloat("_SampleCount", sampleCount);
            ssaoMat.SetFloat("_SampleRadius", sampleRadius);
            ssaoMat.SetFloat("_DepthRange", depthRange);
#if UNITY_EDITOR
#else
            }
#endif
            return ssaoMat;
        }
    }
    private Material blurMaterial
    {
        get
        {
            if (blurMat == null && blurShader != null)
            {
                blurMat = new Material(blurShader);
#if UNITY_EDITOR
            }
#endif
            blurMat.SetFloat("_OnlyOcclusion", onlyOcclusion ? 1f : 0f);
            blurMat.SetFloat("_IfBlur", blur ? 1f : 0f);
#if UNITY_EDITOR
#else
            }
#endif
            return blurMat;
        }
    }
    
    private void Start()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (ssaoMaterial != null && blurMaterial != null)
        {
            RenderTexture temp = RenderTexture.GetTemporary(src.descriptor);
            Graphics.Blit(src, temp, ssaoMaterial, -1);
            Graphics.Blit(temp, dest, blurMaterial, -1);
            RenderTexture.ReleaseTemporary(temp);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
