Shader "Custom/basedOnAlpha" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "Queue"="Transparent" }
		Pass
		{
			Cull Front
			Zwrite Off
			
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform sampler2D _MainTex;
			uniform float _Cutoff;
			
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
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float4 color = tex2D(_MainTex, input.tex.xy);
				if(color.a > 0.5)
				{
					color = float4(0.0, 0.0, 0.2, 1.0);
				}else
				{
					color = float4(0.0, 0.0, 1.0, 0.3);
				}
				return color;
			}
			
			ENDCG
		}
		
		Pass
		{
			Cull Back
			Zwrite Off
			
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			uniform sampler2D _MainTex;
			uniform float _Cutoff;
			
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
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float4 color = tex2D(_MainTex, input.tex.xy);
				if(color.a > 0.5)
				{
					color = float4(0.0, 1.0, 0.0, 1.0);
				}else
				{
					color = float4(0.0, 0.0, 1.0, 0.3);
				}
				return color;
			}
			
			ENDCG
		}
	} 
}
