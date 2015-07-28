Shader "Custom/TexturedSphere" {
	Properties {
		_MainTex ("Texture Image", 2D) = "white" {}
	}
	SubShader {
		Pass
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			
			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				output.tex = input.texcoord;
				output.pos = mul (UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				return tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);
			}
			ENDCG
		}	
	} 
}
