Shader "Custom/Dissolve" {
	Properties {  
	    _MainTex ("Base (RGB)", 2D) = "white" {}  
	    _DissolveTex ("DissolveTex (RGB)", 2D) = "white" {}  
	    _Tile("DissolveTile", Range (0.1, 1)) = 1  
	      
	    _Amount ("DissAmount", Range (0, 1)) = 0.5                       
	    _DissSize("DissSize", Range (0, 1)) = 0.1   
	      
	    _DissColor ("DissColor", Color) = (1,0,0,1)  
	    _AddColor ("AddColor", Color) = (1,1,0,1)  
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
	  
	            sampler2D _MainTex,_DissolveTex;    
	            fixed4 _MainTex_ST,_DissolveTex_ST;                        
	            half _Tile,_Amount,_DissSize;                           
	            half4 _DissColor,_AddColor;           
	              
	                        
	            struct appdata_t {  
	                float4 vertex : POSITION;  
	                float2 texcoord : TEXCOORD0;          
	            };  
	  
	            struct v2f {  
	                float4 vertex : SV_POSITION;  
	                half2 texcoord : TEXCOORD0;  
//	                UNITY_FOG_COORDS(1);
	            };  
	              
	            v2f vert (appdata_t v)  
	            {  
	                v2f o;  
	                o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);  
	                o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);  
//	                UNITY_TRANSFER_FOG(o,o.vertex);  
	                return o;  
	            }  
	              
	            fixed4 frag (v2f i) : SV_Target  
	            {  
	                fixed4 col = tex2D(_MainTex, i.texcoord);  
	                float ClipTex = tex2D (_DissolveTex, i.texcoord/_Tile).r;  
	                float ClipAmount = ClipTex - _Amount;   
	                if(_Amount > 0)  
	                {  
	                    if(ClipAmount < 0)  
	                    {  
	                        clip(-0.1);  
	                    }  
	                    else{  
	                        if(ClipAmount < _DissSize)   
	                        {  
	                            float4 finalColor=lerp(_DissColor,_AddColor,ClipAmount/_DissSize)*2;  
	                            col = col * finalColor;  
	                        }  
	                    }  
	                }  
//	                UNITY_APPLY_FOG(i.fogCoord, col);
//	                UNITY_OPAQUE_ALPHA(col.a);  
	                return col;
	            }  
	        ENDCG  
	    }  
	}  
}
