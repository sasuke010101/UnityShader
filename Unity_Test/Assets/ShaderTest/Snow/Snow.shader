Shader "Custom/Snow" {
	Properties {  
    _MainTex ("Base (RGB)", 2D) = "white" {}  
    _SnowTex ("SnowTexture(RGB)",2D) = "white"{}  
    _SnowCount ("SnowCount", Range (0.0, 1)) = 0.078  
	}  
  
	SubShader {  
	    Tags { "RenderType"="Opaque" }  
	    LOD 100  
	      
	    Pass {    
	        CGPROGRAM  
	            #pragma vertex vert  
	            #pragma fragment frag  
	            #pragma multi_compile_fog  
	             
	            #include "UnityCG.cginc"  
	  
	            struct appdata_t {  
	                float4 vertex : POSITION;  
	                float2 texcoord : TEXCOORD0;  
	                float3 normal : NORMAL;  
	            };  
	  
	            struct v2f {  
	                float4 vertex : SV_POSITION;  
	                half2 texcoord : TEXCOORD0;  
	                half2 snowUV : TEXCOORD1  ;  
	                fixed4 snow : COLOR;  
//	                UNITY_FOG_COORDS(1)  
	            };  
	  
	            sampler2D _MainTex;  
	            sampler2D _SnowTex;  
	            float4 _MainTex_ST,_SnowTex_ST;  
	            float _SnowCount;  
	            v2f vert (appdata_t v)  
	            {  
	                v2f o;  
	                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);  
	                float3 worldNormal = mul((float3x3)_Object2World ,v.normal );  
	                float rim = 1-saturate(dot(float3(0,1,0),worldNormal ));  
	                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  
	                o.snowUV = TRANSFORM_TEX(v.texcoord , _SnowTex);  
	                o.snow = pow(rim,_SnowCount*64);                                  
//	                UNITY_TRANSFER_FOG(o,o.vertex);  
	                return o;  
	            }  
	              
	            fixed4 frag (v2f i) : SV_Target  
	            {  
	                fixed4 col = tex2D(_MainTex, i.texcoord);  
	                fixed4 snow = tex2D(_SnowTex,i.snowUV);  
	                col = lerp(snow,col,saturate(i.snow));  
//	                UNITY_APPLY_FOG(i.fogCoord, col);  
//	                UNITY_OPAQUE_ALPHA(col.a);  
	              
	                return col;  
	            }  
	        ENDCG  
	    }  
	}  
}
