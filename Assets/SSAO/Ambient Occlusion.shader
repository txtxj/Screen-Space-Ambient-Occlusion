Shader "Custom/Ambient Occlusion"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _SampleCount ("Sample Count", float) = 128
        _SampleRadius ("Sample Radius", float) = 0.618
        _DepthRange ("Depth Range", float) = 0.0005
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
            sampler2D _CameraDepthNormalsTexture;
            float4x4 _Matrix_I_P;
            
            float _SampleCount;
            fixed _SampleRadius;
            float _DepthRange;

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv: TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            float fract(float x)
            {
                return x - floor(x);
            }

            float random(float2 st)
            {
                return fract(sin(dot(st.xy, float2(12.9898,78.233))) * 43758.5453123);
            }

            float3 random3(float2 seed)
            {
                float3 vec;
                vec.x = random(seed);
                vec.y = random(seed * seed);
                vec.z = random(seed * seed * seed);
                return normalize(vec);
            }

            float3 sampling(float2 seed)
            {
                float4 r;
                r.x = random(seed) * 2 - 1;
                r.y = random(seed * seed) * 2 - 1;
                r.z = random(seed * seed * seed);
                r.w = 1;
                r = normalize(r);
                return r.xyz;
            }

            v2f vert(appdata_full v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.screenPos = ComputeScreenPos(o.position);
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                float depth = 0;
                float3 normal = 0;
                // Get view space normal and lineal0-1 depth
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);
                normal.z *= -1;

                // screen space -> ndc -> clip space -> view space
                float4 ndc = i.screenPos / i.screenPos.w * 2 - 1;
                float4 clipPos = float4(ndc.xy, 1, 1) * _ProjectionParams.z;
                float4 viewPos = mul(unity_CameraInvProjection, clipPos);
                viewPos = viewPos / viewPos.w * depth;

                // Get normal direction hemisphere TBN matrix
                float3 tangent = random3(i.uv);
                float3 bitangent = cross(normal, tangent);
                tangent = cross(bitangent, normal);
                float3x3 TBN = float3x3(tangent, bitangent, normal);
                
                float ao = 0;
                int sampleCount = (int)_SampleCount;
                // Sampling
                for (int j = 1; j <= sampleCount; j++)
                {
                    // offset follows a uniform distribution
                    float3 offset = sampling(j * i.uv);
                    float scale = j / _SampleCount;
                    // Make offset follows a cubic uniform distribution
                    offset *= scale * scale;
                    offset = mul(offset, TBN);
                    float weight = smoothstep(0, 1, length(offset));
                    // samp: view space -> clip space -> ndc
                    float3 samp = viewPos + offset * _SampleRadius;
                    samp = mul(unity_CameraProjection, samp);
                    samp /= samp.z;
                    samp = (samp + 1) * 0.5;
                    float sampDepth = 0;
                    float3 sampNormal = 0;
                    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, samp.xy), sampDepth, sampNormal);
                    ao += abs(sampDepth - depth) < _DepthRange && depth > sampDepth + 0.0001 ? weight : 0;
                }
                return fixed4(tex2D(_MainTex, i.uv).rgb, 1 - ao / _SampleCount);
            }
            
            ENDCG
        }
    }
    Fallback "Diffuse"
}
