Shader "Custom/Glossy" {
	Properties {
		_MainTex ("Texture For Diffuse Material Color", 2D) = "white" {}
		_Color ("Overall Diffuse Material Color Filter", Color) = (1, 1, 1, 1)
		_SpecColor ("Specular Marerial Color", Color) = (1, 1, 1, 1)
		_Shininess ("Shininess", Float) = 10
	}
	SubShader {
		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"	
			
			uniform sampler2D _MainTex;
			uniform float4 _LightColor0;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct vertexOutput 
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float3 tex : TEXCOORD2;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				output.posWorld = mul(modelMatrix, input.vertex);
				output.normalDir = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float3 normalDirection = normalize(input.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDirection;
				float attenuation;
				
				float4 textureColor = tex2D(_MainTex, input.tex.xy);
				
				if(0.0 == _WorldSpaceLightPos0.w)
				{
					attenuation = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance;
					lightDirection = normalize(vertexToLightSource);
				}
				
				float3 ambientLighting = textureColor.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				float3 diffuseReflection = textureColor.rgb *  attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));
				
				float3 specularReflection;
				if(dot(normalDirection, lightDirection) < 0.0)
				{
					specularReflection = (0.0, 0.0, 0.0);
				}else
				{
					specularReflection = attenuation *  _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				}
				
				return float4(ambientLighting + diffuseReflection + specularReflection, 1.0);
			}

			ENDCG
		}
		
		Pass
		{
			Tags {"LightMode" = "ForwardAdd"}
			
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"	
			
			uniform sampler2D _MainTex;
			uniform float4 _LightColor0;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			
			struct vertexOutput 
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float3 tex : TEXCOORD2;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				output.posWorld = mul(modelMatrix, input.vertex);
				output.normalDir = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				float3 normalDirection = normalize(input.normalDir);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - input.posWorld.xyz);
				float3 lightDirection;
				float attenuation;
				
				float4 textureColor = tex2D(_MainTex, input.tex.xy);
				
				if(0.0 == _WorldSpaceLightPos0.w)
				{
					attenuation = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else
				{
					float3 vertexToLightSource = _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
					float distance = length(vertexToLightSource);
					attenuation = 1.0 / distance;
					lightDirection = normalize(vertexToLightSource);
				}
				
//				float3 ambientLighting = textureColor.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				float3 diffuseReflection = textureColor.rgb *  attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));
				
				float3 specularReflection;
				if(dot(normalDirection, lightDirection) < 0.0)
				{
					specularReflection = (0.0, 0.0, 0.0);
				}else
				{
					specularReflection = attenuation *  _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				}
				
				return float4(diffuseReflection + specularReflection, 1.0);
			}
			ENDCG
		}
	} 
}
