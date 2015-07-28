Shader "Custom/CgBasicShader" {
	SubShader {
		Pass{
			CGPROGRAM
			#pragma vertex vert
			//specifies the vert function as the vertex shader
			#pragma fragment frag
			//specifies the frag function as the fragment shader
			
			float4 vert(float4 vertexPos : POSITION) : SV_POSITION
			{
				return mul(UNITY_MATRIX_MVP, float4(1.0, 0.1 ,1.0, 1.0) * vertexPos);
			}
			
			float4 frag(void) : COLOR
			{
				return float4(0.6, 1.0, 0.0, 1.0);
			}
			
			ENDCG
		}
	} 
}
