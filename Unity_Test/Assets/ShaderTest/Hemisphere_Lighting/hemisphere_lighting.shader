Shader "Custom/hemisphere_lighting" {
	Properties {
      _Color ("Diffuse Material Color", Color) = (1,1,1,1) 
      _UpperHemisphereColor ("Upper Hemisphere Color", Color) 
         = (1,1,1,1) 
      _LowerHemisphereColor ("Lower Hemisphere Color", Color) 
         = (1,1,1,1) 
      _UpVector ("Up Vector", Vector) = (0,1,0,0) 
   }
   SubShader {
      Pass {      
         CGPROGRAM
 
         #pragma vertex vert  
         #pragma fragment frag 
 
         #include "UnityCG.cginc"
 
         // shader properties specified by users
         uniform float4 _Color; 
         uniform float4 _UpperHemisphereColor;
         uniform float4 _LowerHemisphereColor;
         uniform float4 _UpVector;
 
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 col : COLOR;
               // the hemisphere lighting computed in the vertex shader
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
            float3 upDirection = normalize(_UpVector);
 
            float w = 0.5 * (1.0 + dot(upDirection, normalDirection));
            output.col = (w * _UpperHemisphereColor 
               + (1.0 - w) * _LowerHemisphereColor) * _Color;
 
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
