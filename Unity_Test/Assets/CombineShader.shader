Shader "Custom/CombineShader" {
	Properties {
		_Blue ("Base (RGB)", 2D) = "white" {}
		_Red ("Base (RGB)", 2D) = "white" {}
		_Org ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _Blue;
		sampler2D _Red;
		sampler2D _Org;

		struct Input {
			float2 uv_BlueTex;
			float2 uv_RedTex;
			float2 uv_OrgTex;
			float4 color:COLOR;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 colorIn;
			if(IN .color.a < 0.33)
			{
				colorIn = tex2D(_Red,IN.uv_RedTex);
			}else 
			if(IN.color.a < 0.6)
			{
				colorIn = tex2D(_Blue,IN.uv_BlueTex);
			}else
			{
				colorIn = tex2D(_Org,IN.uv_OrgTex);
			}
			
			o.Albedo = colorIn.rgb;
			o.Alpha = colorIn.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
