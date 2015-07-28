Shader "Custom/LTS" {
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
				float4 tex : TEXCOORD0;
				float3 diffuseColor : TEXCOORD1;
				float3 specularColor : TEXCOORD2;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				float3 normalDirection = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, input.vertex).xyz);
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
				
				float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));
				
				float3 specularReflection;
				if(dot(normalDirection, lightDirection) < 0.0)
				{
					specularReflection = (0.0, 0.0, 0.0);
				}else
				{
					specularReflection = attenuation *  _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				}
				
				output.diffuseColor = ambientLighting + diffuseReflection;
				output.specularColor = specularReflection;
				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				return float4(input.specularColor + input.diffuseColor * tex2D(_MainTex, input.tex.xy), 1.0);
			}

//			//glossy mobile version
//			float4 frag(vertexOutput input) : COLOR
//			{
//				float4 textureColor = tex2D(_MainTex, input.tex.xy);
//				return float4(input.specularColor * (1.0 - textureColor.a) + input.diffuseColor * textureColor.rgb, 1.0);
//			}
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
				float4 tex : TEXCOORD0;
				float3 diffuseColor : TEXCOORD1;
				float3 specularColor : TEXCOORD2;
			};
			
			vertexOutput vert(vertexInput input)
			{
				vertexOutput output;
				float4x4 modelMatrix = _Object2World;
				float4x4 modelMatrixInverse = _World2Object;
				
				float3 normalDirection = normalize(mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
				float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, input.vertex).xyz);
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
				
//				float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection));
				
				float3 specularReflection;
				if(dot(normalDirection, lightDirection) < 0.0)
				{
					specularReflection = (0.0, 0.0, 0.0);
				}else
				{
					specularReflection = attenuation *  _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
				}
				
				output.diffuseColor = diffuseReflection;
				output.specularColor = specularReflection;
				output.tex = input.texcoord;
				output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
				return output;
			}
			
			float4 frag(vertexOutput input) : COLOR
			{
				return float4(input.specularColor + input.diffuseColor * tex2D(_MainTex, input.tex.xy), 1.0);
			}
//			//glossy mobile version
//			float4 frag(vertexOutput input) : COLOR
//			{
//				float4 textureColor = tex2D(_MainTex, input.tex.xy);
//				return float4(input.specularColor * (1.0 - textureColor.a) + input.diffuseColor * textureColor.rgb, 1.0);
//			}
			ENDCG
		}
	} 
}
