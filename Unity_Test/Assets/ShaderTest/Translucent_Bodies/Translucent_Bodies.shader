Shader "Custom/Translucent_Bodies" {
	Properties {
      _Color ("Diffuse Color", Color) = (1,1,1,1) 
      _Waxiness ("Waxiness", Range(0,1)) = 0
      _SpecColor ("Specular Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
      _TranslucentColor ("Translucent Color", Color) = (0,0,0,1)
   }
   SubShader {
      Pass {      
         Tags { "LightMode" = "ForwardBase" } // pass for 
            // ambient light and first light source on back faces
         Cull Front // render back faces only
         Blend One Zero // mark rasterized pixels in framebuffer 
            // with alpha = 0 (usually they should have alpha = 1)
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float _Waxiness;
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float4 _TranslucentColor; 
 
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
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 ambientLighting = _TranslucentColor.rgb
               * UNITY_LIGHTMODEL_AMBIENT.rgb;
 
            float3 diffuseReflection = _TranslucentColor.rgb
               * attenuation * _LightColor0.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
 
            float silhouetteness = 
               1.0 - abs(dot(viewDirection, normalDirection));
 
            return float4(silhouetteness 
               * (ambientLighting + diffuseReflection), 0.0);
         }
 
         ENDCG
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources on back faces
         Cull Front // render back faces only
         Blend One One // additive blending 
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float _Waxiness;
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float4 _TranslucentColor; 
 
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
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 diffuseReflection = _TranslucentColor.rgb
               * attenuation * _LightColor0.rgb
               * max(0.0, dot(normalDirection, lightDirection));
 
            float silhouetteness = 
               1.0 - abs(dot(viewDirection, normalDirection));
 
            return float4(silhouetteness * diffuseReflection, 0.0);
         }
 
         ENDCG
      }
 
      Pass {	
         Tags { "LightMode" = "ForwardBase" } // pass for 
            // setting pixels that were not rasterized to black
         Cull Back // render front faces only (default behavior)
         Blend Zero OneMinusDstAlpha // set colors of pixels 
            // with alpha = 1 to black by multiplying with 1-alpha
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         float4 vert(float4 vertexPos : POSITION) : SV_POSITION 
         {
            return mul(UNITY_MATRIX_MVP, vertexPos);
         }
 
         float4 frag(void) : COLOR 
         {
            return float4(0.0, 0.0, 0.0, 0.0); 
         }
         ENDCG  
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardBase" } // pass for 
            // ambient light and first light source on front faces
         Cull Back // render front faces only
         Blend One SrcAlpha // multiply color in framebuffer 
            // with silhouetteness in fragment's alpha and add colors
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float _Waxiness;
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float4 _TranslucentColor; 
 
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
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 ambientLighting = 
               UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb
               * (_Waxiness + (1.0 - _Waxiness) 
               * max(0.0, dot(normalDirection, lightDirection)));
 
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
 
            float silhouetteness = 
               1.0 - abs(dot(viewDirection, normalDirection));
 
            return float4(ambientLighting + diffuseReflection 
               + specularReflection, silhouetteness);
         }
 
         ENDCG 
      }
 
      Pass {      
         Tags { "LightMode" = "ForwardAdd" } 
            // pass for additional light sources on front faces
         Cull Back // render front faces only
         Blend One One // additive blending 
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform float4 _Color; 
         uniform float _Waxiness;
         uniform float4 _SpecColor; 
         uniform float _Shininess;
         uniform float4 _TranslucentColor; 
 
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
            float attenuation;
 
            if (0.0 == _WorldSpaceLightPos0.w) // directional light?
            {
               attenuation = 1.0; // no attenuation
               lightDirection = normalize(_WorldSpaceLightPos0.xyz);
            } 
            else // point or spot light
            {
               float3 vertexToLightSource = 
                  _WorldSpaceLightPos0.xyz - input.posWorld.xyz;
               float distance = length(vertexToLightSource);
               attenuation = 1.0 / distance; // linear attenuation 
               lightDirection = normalize(vertexToLightSource);
            }
 
            float3 diffuseReflection = 
               attenuation * _LightColor0.rgb * _Color.rgb
               * (_Waxiness + (1.0 - _Waxiness) 
               * max(0.0, dot(normalDirection, lightDirection)));
 
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
 
            float silhouetteness = 
               1.0 - abs(dot(viewDirection, normalDirection));
 
            return float4(diffuseReflection 
               + specularReflection, silhouetteness);
         }
 
         ENDCG 
      }
   } 
}
