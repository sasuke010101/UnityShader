Shader "Custom/alpha_discard" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Float) = 0.5
	}
	SubShader {
		Pass
		{
			Cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform sampler2D _MainTex;
			uniform float _Cutoff;
			
			struct vertexInput {
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
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float4 textureColor = tex2D(_MainTex, input.tex.xy);
				if(textureColor.a < _Cutoff)
				{
					discard;
				}
				return textureColor;
			}
			
			ENDCG
		}
	}
}
