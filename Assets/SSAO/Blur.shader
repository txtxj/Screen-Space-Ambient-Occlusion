Shader "Custom/Gauss Blur"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        [MaterialToggle] _OnlyOcclusion ("Only Occlusion", float) = 0
        [MaterialToggle] _IfBlur ("Blur", float) = 0
    }
    SubShader
    {
        
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;

            float _OnlyOcclusion;
            float _IfBlur;

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 color = fixed4(tex2D(_MainTex, i.uv).rgb, 1);
                fixed ssao = 0;
                if (_IfBlur)
                {
                    const float kernel[5][5] =
                    {
                        {2, 4, 5, 4, 2},
                        {4, 9, 12, 9, 4},
                        {5, 12, 15, 12, 5},
                        {4, 9, 12, 9, 4},
                        {2, 4, 5, 4, 2},
                    };
                    [unroll]
                    for (int j = -2; j < 3; j++)
                    {
                        [unroll]
                        for (int k = -2; k < 3; k++)
                        {
                            ssao += tex2D(_MainTex, i.uv + float2(j, k) * _MainTex_TexelSize).a * kernel[j + 2][k + 2] / 159;
                        }
                    }
                }
                else
                {
                    ssao = tex2D(_MainTex, i.uv).a;
                }
                return _OnlyOcclusion > 0 ? ssao : color * ssao;
            }
            
            ENDCG
        }
    }
    Fallback "Diffuse"
}
