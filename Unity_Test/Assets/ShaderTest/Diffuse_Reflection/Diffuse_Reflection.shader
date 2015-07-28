Shader "Custom/Diffuse_Reflection" {
	Properties {
		_Color ("Diffuse Material Color", Color) = (1, 1, 1, 1)
	}
	SubShader {
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform float4 _LightColor0;
			uniform float4 _Color;
			
			struct vertexInput 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				float3 normalDirection = normalize(mul(float4(input.normal,0.0), modelMatrixInverse).xyz);
				float3 lightDirection;
				float attenuation;
				
				if(0.0 == _WorldSpaceLightPos0.w)
				{
					attenuation = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(modelMatrix, input.vertex).xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance;
					lightDirection = normalize(vertexToLightSource);
				}
				
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));
				
				output.col = float4(diffuseReflection, 1.0);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				return input.col;
			}
			
			ENDCG
		}
		
		Pass
		{
			Tags { "LightMode"="ForwardAdd" }
			
			Blend One One
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			uniform float4 _LightColor0;
			uniform float4 _Color;
			
			struct vertexInput 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				float3 normalDirection = normalize(mul(float4(input.normal,0.0), modelMatrixInverse).xyz);
				float3 lightDirection;
				float attenuation;
				
				if(0.0 == _WorldSpaceLightPos0.w)
				{
					attenuation = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - mul(modelMatrix, input.vertex).xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance;
					lightDirection = normalize(vertexToLightSource);
				}
				
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));
				
				output.col = float4(diffuseReflection, 1.0);
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				return input.col;
			}
			ENDCG
		}
	} 
}
