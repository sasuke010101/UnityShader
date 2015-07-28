Shader "Custom/parallaxMapping" {
	 Properties {
      _BumpMap ("Normal Map", 2D) = "bump" {}
      _ParallaxMap ("Heightmap (in A)", 2D) = "black" {}
      _Parallax ("Max Height", Float) = 0.01
      _MaxTexCoordOffset ("Max Texture Coordinate Offset", Float) = 
         0.01
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _SpecColor ("Specular Material Color", Color) = (1,1,1,1) 
      _Shininess ("Shininess", Float) = 10
   }
   SubShader {
      Pass {      
         Tags { "LightMode" = "ForwardBase" } 
            // pass for ambient light and first light source
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag  
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform sampler2D _BumpMap; 
         uniform float4 _BumpMap_ST;
         uniform sampler2D _ParallaxMap; 
         uniform float4 _ParallaxMap_ST;
         uniform float _Parallax;
         uniform float _MaxTexCoordOffset;
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float4 texcoord : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
               // position of the vertex (and fragment) in world space 
            float4 tex : TEXCOORD1;
            float3 tangentWorld : TEXCOORD2;  
            float3 normalWorld : TEXCOORD3;
            float3 binormalWorld : TEXCOORD4;
            float3 viewDirWorld : TEXCOORD5; 
            float3 viewDirInScaledSurfaceCoords : TEXCOORD6;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // unity_Scale.w is unnecessary 
 
            output.tangentWorld = normalize(
               mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
            output.normalWorld = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.binormalWorld = normalize(
               cross(output.normalWorld, output.tangentWorld) 
               * input.tangent.w); // tangent.w is specific to Unity
 
 
            float3 binormal = cross(input.normal, input.tangent.xyz) 
              * input.tangent.w;
               // appropriately scaled tangent and binormal 
               // to map distances from object space to texture space
              
             float3 viewDirInObjectCoords = mul(
               modelMatrixInverse, float4(_WorldSpaceCameraPos, 1.0)).xyz 
               - input.vertex.xyz;
            float3x3 localSurface2ScaledObjectT = 
               float3x3(input.tangent.xyz, binormal, input.normal); 
               // vectors are orthogonal
            output.viewDirInScaledSurfaceCoords = 
               mul(localSurface2ScaledObjectT, viewDirInObjectCoords); 
               // we multiply with the transpose to multiply with 
               // the "inverse" (apart from the scaling)
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.viewDirWorld = normalize(
               _WorldSpaceCameraPos - output.posWorld.xyz);
            output.tex = input.texcoord;
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
          
         float4 frag(vertexOutput input) : COLOR
         {
            // parallax mapping: compute height and 
            // find offset in texture coordinates 
            // for the intersection of the view ray 
            // with the surface at this height
         
            float height = _Parallax 
               * (-0.5 + tex2D(_ParallaxMap, _ParallaxMap_ST.xy 
               * input.tex.xy + _ParallaxMap_ST.zw).x);
               
            float2 texCoordOffsets = 
              clamp(height * input.viewDirInScaledSurfaceCoords.xy 
              / input.viewDirInScaledSurfaceCoords.z,
              -_MaxTexCoordOffset, +_MaxTexCoordOffset); 
              
            // normal mapping: lookup and decode normal from bump map
 
            // in principle we have to normalize tangentWorld,
            // binormalWorld, and normalWorld again; however, the  
            // potential problems are small since we use this 
            // matrix only to compute "normalDirection", 
            // which we normalize anyways

            float4 encodedNormal = tex2D(_BumpMap, 
               _BumpMap_ST.xy * (input.tex.xy + texCoordOffsets) 
               + _BumpMap_ST.zw);                             
            float3 localCoords = float3(2.0 * encodedNormal.a - 1.0, 
                2.0 * encodedNormal.g - 1.0, 0.0);
            localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
               // approximation without sqrt:  localCoords.z = 
               // 1.0 - 0.5 * dot(localCoords, localCoords);
 
            float3x3 local2WorldTranspose = float3x3(
               input.tangentWorld, 
               input.binormalWorld, 
               input.normalWorld);
            float3 normalDirection = 
               normalize(mul(localCoords, local2WorldTranspose));
 
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
                  input.viewDirWorld)), _Shininess);
            }
            return float4(ambientLighting + diffuseReflection 
               + specularReflection, 1.0);
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
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         // User-specified properties
         uniform sampler2D _BumpMap; 
         uniform float4 _BumpMap_ST;
         uniform sampler2D _ParallaxMap; 
         uniform float4 _ParallaxMap_ST;
         uniform float _Parallax;
         uniform float _MaxTexCoordOffset;
         uniform float4 _Color; 
         uniform float4 _SpecColor; 
         uniform float _Shininess;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float4 texcoord : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
               // position of the vertex (and fragment) in world space 
            float4 tex : TEXCOORD1;
            float3 tangentWorld : TEXCOORD2;  
            float3 normalWorld : TEXCOORD3;
            float3 binormalWorld : TEXCOORD4;
            float3 viewDirWorld : TEXCOORD5; 
            float3 viewDirInScaledSurfaceCoords : TEXCOORD6;
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // unity_Scale.w is unnecessary 
 
            output.tangentWorld = normalize(
               mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
            output.normalWorld = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            output.binormalWorld = normalize(
               cross(output.normalWorld, output.tangentWorld) 
               * input.tangent.w); // tangent.w is specific to Unity
 
 
            float3 binormal = cross(input.normal, input.tangent.xyz) 
              * input.tangent.w;
               // appropriately scaled tangent and binormal 
               // to map distances from object space to texture space
              
             float3 viewDirInObjectCoords = mul(
               modelMatrixInverse, float4(_WorldSpaceCameraPos, 1.0)).xyz 
               - input.vertex.xyz;
            float3x3 localSurface2ScaledObjectT = 
               float3x3(input.tangent.xyz, binormal, input.normal); 
               // vectors are orthogonal
            output.viewDirInScaledSurfaceCoords = 
               mul(localSurface2ScaledObjectT, viewDirInObjectCoords); 
               // we multiply with the transpose to multiply with 
               // the "inverse" (apart from the scaling)
 
            output.posWorld = mul(modelMatrix, input.vertex);
            output.viewDirWorld = normalize(
               _WorldSpaceCameraPos - output.posWorld.xyz);
            output.tex = input.texcoord;
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
          
         float4 frag(vertexOutput input) : COLOR
         {
            // parallax mapping: compute height and 
            // find offset in texture coordinates 
            // for the intersection of the view ray 
            // with the surface at this height
         
            float height = _Parallax 
               * (-0.5 + tex2D(_ParallaxMap, _ParallaxMap_ST.xy 
               * input.tex.xy + _ParallaxMap_ST.zw).x);
               
            float2 texCoordOffsets = 
              clamp(height * input.viewDirInScaledSurfaceCoords.xy 
              / input.viewDirInScaledSurfaceCoords.z,
              -_MaxTexCoordOffset, +_MaxTexCoordOffset); 
              
            // normal mapping: lookup and decode normal from bump map
 
            // in principle we have to normalize tangentWorld,
            // binormalWorld, and normalWorld again; however, the  
            // potential problems are small since we use this 
            // matrix only to compute "normalDirection", 
            // which we normalize anyways

            float4 encodedNormal = tex2D(_BumpMap, 
               _BumpMap_ST.xy * (input.tex.xy + texCoordOffsets) 
               + _BumpMap_ST.zw);                             
            float3 localCoords = float3(2.0 * encodedNormal.a - 1.0, 
                2.0 * encodedNormal.g - 1.0, 0.0);
            localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
               // approximation without sqrt:  localCoords.z = 
               // 1.0 - 0.5 * dot(localCoords, localCoords);
 
            float3x3 local2WorldTranspose = float3x3(
               input.tangentWorld, 
               input.binormalWorld, 
               input.normalWorld);
            float3 normalDirection = 
               normalize(mul(localCoords, local2WorldTranspose));
 
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
                  input.viewDirWorld)), _Shininess);
            } 
            return float4(diffuseReflection + specularReflection, 
               1.0);
         }
         ENDCG
      } 
   }
}
