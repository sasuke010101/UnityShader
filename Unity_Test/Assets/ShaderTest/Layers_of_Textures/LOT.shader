Shader "Custom/LOT" {
	Properties {
	      _DecalTex ("Daytime Earth", 2D) = "white" {}
	      _MainTex ("Nighttime Earth", 2D) = "white" {} 
	      _Color ("Nighttime Color Filter", Color) = (1,1,1,1)
   	}

	 SubShader {
      Pass {	
         Tags { "LightMode" = "ForwardBase" } 
            // pass for the first, directional light 
 
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
         uniform float4 _LightColor0; 
            // color of light source (from "Lighting.cginc")
 
         uniform sampler2D _MainTex;
         uniform sampler2D _DecalTex;
         uniform float4 _Color; 
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
            float levelOfLighting : TEXCOORD1;
               // level of diffuse lighting computed in vertex shader
         };
 
         vertexOutput vert(vertexInput input) 
         {
            vertexOutput output;
 
            float4x4 modelMatrix = _Object2World;
            float4x4 modelMatrixInverse = _World2Object; 
               // multiplication with unity_Scale.w is unnecessary 
               // because we normalize transformed vectors
 
            float3 normalDirection = normalize(
               mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
            float3 lightDirection = normalize(
               _WorldSpaceLightPos0.xyz);
 
            output.levelOfLighting = 
               max(0.0, dot(normalDirection, lightDirection));
            output.tex = input.texcoord;
            output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
            return output;
         }
 
         float4 frag(vertexOutput input) : COLOR
         {
            float4 nighttimeColor = 
               tex2D(_MainTex, input.tex.xy);    
            float4 daytimeColor = 
               tex2D(_DecalTex, input.tex.xy);    
            return lerp(nighttimeColor, daytimeColor, 
               input.levelOfLighting);
               // = daytimeColor * levelOfLighting 
               // + nighttimeColor * (1.0 - levelOfLighting)
         }
 
         ENDCG
      }
   } 
}
