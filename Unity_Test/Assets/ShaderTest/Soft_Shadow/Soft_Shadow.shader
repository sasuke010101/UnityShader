﻿Shader "Custom/Soft_Shadow" {
	Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
      _SpherePosition ("Sphere Position", Vector) = (0,0,0,1)
      _SphereRadius ("Sphere Radius", Float) = 1
      _LightSourceRadius ("Light Source Radius", Float) = 0.005
   }
   SubShader {
      Pass {      
         Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #pragma target 3.0
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float4 _SpherePosition; 
            // center of shadow-casting sphere in world coordinates
         uniform float _SphereRadius; 
            // radius of shadow-casting sphere
         uniform float _LightSourceRadius; 
            // in radians for directional light sources
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float3 normalDir : TEXCOORD1;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // multiplication with unity_Scale.w is unnecessary 
               // because we normalize transformed vectors
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.normalDir = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float3 normalDirection = normalize(input.normalDir);
 
            float3 viewDirection = normalize(
               _WorldSpaceCameraPos - input.posWorld.xyz);
            float3 lightDirection;
            float lightDistance;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = 
                  normalize(_WorldSpaceLightPos0.xyz);
               lightDistance = 1.0;
            } 
            else // point or spot light
            {
               lightDirection = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               lightDistance = length(lightDirection);
               attenuation = 1.0 / lightDistance; // linear attenuation
               lightDirection = lightDirection / lightDistance;
            }
 
            // computation of level of shadowing w  
            float3 sphereDirection = 
               _SpherePosition.xyz - input.posWorld.xyz;
            float sphereDistance = length(sphereDirection);
            sphereDirection = sphereDirection / sphereDistance;
            float d = lightDistance 
               * (asin(min(1.0, 
               length(cross(lightDirection, sphereDirection)))) 
               - asin(min(1.0, _SphereRadius / sphereDistance)));
            float w = smoothstep(-1.0, 1.0, -d / _LightSourceRadius);
            w = w * smoothstep(0.0, 0.2, 
               dot(lightDirection, sphereDirection));
            if (0.0 != _WorldSpaceLightPos0.w) // point light source?
            {
               w = w * smoothstep(0.0, _SphereRadius, 
                  lightDistance - sphereDistance);
            }
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
               // light source on the wrong side?
            {
               specularReflection = float3(0.0, 0.0, 0.0); 
                  // no specular reflection
            }
            else // light source on the right side
            {
               specularReflection = attenuation * _LightColor0.rgb 
                  * _SpecColor.rgb * pow(max(0.0, dot(
                  reflect(-lightDirection, normalDirection), 
                  viewDirection)), _Shininess);
            }
 
            return float4(ambientLighting 
               + (1.0 - w) * (diffuseReflection + specularReflection), 
               1.0);
         }
 
         ENDCG
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources
         Blend One One // additive blending 
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #pragma target 3.0
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float4 _SpherePosition; 
            // center of shadow-casting sphere in world coordinates
         uniform float _SphereRadius; 
            // radius of shadow-casting sphere
         uniform float _LightSourceRadius; 
            // in radians for directional light sources
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float3 normalDir : TEXCOORD1;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // multiplication with unity_Scale.w is unnecessary 
               // because we normalize transformed vectors
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.normalDir = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float3 normalDirection = normalize(input.normalDir);
 
            float3 viewDirection = normalize(
               _WorldSpaceCameraPos - input.posWorld.xyz);
            float3 lightDirection;
            float lightDistance;
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
               lightDistance = 1.0;
            } 
            else // point or spot light
            {
               lightDirection =
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               lightDistance = length(lightDirection);
               attenuation = 1.0 / lightDistance; // linear attenuation
               lightDirection = lightDirection / lightDistance;
            }
 
            // computation of level of shadowing w  
            float3 sphereDirection = 
               _SpherePosition.xyz - input.posWorld.xyz;
            float sphereDistance = length(sphereDirection);
            sphereDirection = sphereDirection / sphereDistance;
            float d = lightDistance 
               * (asin(min(1.0, 
               length(cross(lightDirection, sphereDirection)))) 
               - asin(min(1.0, _SphereRadius / sphereDistance)));
            float w = smoothstep(-1.0, 1.0, -d / _LightSourceRadius);
            w = w * smoothstep(0.0, 0.2, 
               dot(lightDirection, sphereDirection));
            if (0.0 != _WorldSpaceLightPos0.w) // point light source?
            {
               w = w * smoothstep(0.0, _SphereRadius, 
                  lightDistance - sphereDistance);
            }
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float3 specularReflection;
            if (dot(normalDirection, lightDirection) < 0.0) 
               // light source on the wrong side?
            {
               specularReflection = float3(0.0, 0.0, 0.0); 
                  // no specular reflection
            }
            else // light source on the right side
            {
               specularReflection = attenuation * _LightColor0.rgb 
                  * _SpecColor.rgb * pow(max(0.0, dot(
                  reflect(-lightDirection, normalDirection), 
                  viewDirection)), _Shininess);
            }
 
            return float4((1.0 - w) * (diffuseReflection 
               + specularReflection), 1.0);
         }
 
         ENDCG
      }
   } 
}
