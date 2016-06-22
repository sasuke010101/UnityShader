Shader "Custom/billboard" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		pass{
			Cull Off
			ZTest Always
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			sampler2D _MainTex;
			struct v2f {
				float4 pos:SV_POSITION;
				float2 texc:TEXCOORD0;
			};
			v2f vert(appdata_base v)
			{
				v2f o;
				float4 ori=mul(UNITY_MATRIX_MV,float4(0,0,0,1));
				float4 vt=v.vertex;
				vt.y=vt.z;//这个平面是沿xz平面 展开的
				vt.z=0;//所以只关心其平面上的信息

				//通过加上Object Space的原点在ViewSpace的信息，保持其透视大小
				vt.xyz+=ori.xyz;//result is vt.z==ori.z ,so the distance to camera keeped ,and screen size keeped
				o.pos=mul(UNITY_MATRIX_P,vt);

				o.texc=v.texcoord;
				return o;
			}
			float4 frag(v2f i):COLOR
			{
				return tex2D(_MainTex,i.texc);
			}
			ENDCG
		}//endpass
	} 
}
