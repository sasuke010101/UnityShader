Shader "Custom/SnowWithBump" {
	Properties {  
    _MainTex ("Base (RGB)", 2D) = "white" {}  
    _BumpMap ("BaseBump", 2D) = "bump" {}  
    _SnowTex ("SnowTexture(RGB)",2D) = "white"{}  
    _SnowCount ("SnowCount", Range (0.01, 1)) = 0.078  
}  
  
SubShader {  
    Tags { "RenderType"="Opaque" }  
    LOD 200  
      
    Pass {    
        CGPROGRAM  
            #pragma vertex vert  
            #pragma fragment frag  
//            #pragma multi_compile_fog  
             
            #include "UnityCG.cginc"  
  
  
            struct v2f {  
                float4 vertex : SV_POSITION;  
                half2 texcoord : TEXCOORD0;  
                half2 snowUV : TEXCOORD1  ;  
                // fixed4 snow : COLOR;  
                float3 tangent:TEXCOORD2;  
                float3 binormal : TEXCOORD3;  
                float3 normal : TEXCOORD4;  
//                UNITY_FOG_COORDS(1)  
            };  
  
            sampler2D _MainTex,_BumpMap;  
            sampler2D _SnowTex;  
            float4 _MainTex_ST,_SnowTex_ST;  
            float _SnowCount;  
            v2f vert (appdata_full v)  
            {  
                v2f o;  
                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);  
                o.tangent = v.tangent.xyz;  
                o.normal = v.normal;  
                o.binormal=cross(v.normal,v.tangent.xyz)*v.tangent.w;  
                  
                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  
                o.snowUV = TRANSFORM_TEX(v.texcoord , _SnowTex);  
//                                UNITY_TRANSFER_FOG(o,o.vertex);  
                return o;  
            }  
              
            fixed4 frag (v2f i) : SV_Target  
            {  
                fixed4 col = tex2D(_MainTex, i.texcoord);  
                fixed4 snow = tex2D(_SnowTex,i.snowUV);  
                float3x3 rotation=float3x3 (i.tangent.xyz,i.binormal,i.normal);  
                float3 N = UnpackNormal(tex2D(_BumpMap,i.texcoord));  
                N=normalize(mul(N,rotation));  
                N = mul((float3x3)_Object2World ,N );  
                float rim = 1-saturate(dot(float3(0,1,0),N));  
                float4 lerpsnow = pow(rim,_SnowCount*16);  
                col = lerp(snow,col,saturate(lerpsnow));  
//                UNITY_APPLY_FOG(i.fogCoord, col);  
//                UNITY_OPAQUE_ALPHA(col.a);  
              
                return col;  
            }  
        ENDCG  
    }  
}  
}
