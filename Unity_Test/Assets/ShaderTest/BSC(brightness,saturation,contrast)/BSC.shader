Shader "Custom/BSC" {
	Properties {  
    _MainTex ("Base (RGB)", 2D) = "white" {}  
    _BrightnessAmount ("Brightness Amount", Range(0.0, 2.0)) = 1.0  
    _SaturationAmount ("Saturation Amount", Range(0.0, 1.0)) = 1.0  
    _ContrastAmount ("Contrast Amount", Range(0.0, 1.0)) = 1.0  
	}  
	SubShader {  
    Pass {  
    
        CGPROGRAM  
        #pragma vertex vert_img  
        #pragma fragment frag  
          
        #include "UnityCG.cginc"  
          
        uniform sampler2D _MainTex;  
        fixed _BrightnessAmount;  
        fixed _SaturationAmount;  
        fixed _ContrastAmount;
        
        float3 ContrastSaturationBrightness (float3 color, float brt, float sat, float con) {  
		    // Increase or decrease these values to  
		    // adjust r, g and b color channels separately  
		    float avgLumR = 0.5;  
		    float avgLumG = 0.5;  
		    float avgLumB = 0.5;  
		      
		    // Luminance coefficients for getting luminance from the image  
		    float3 LuminanceCoeff = float3 (0.2125, 0.7154, 0.0721);  
		      
		    // Operation for brightmess  
		    float3 avgLumin = float3 (avgLumR, avgLumG, avgLumB);  
		    float3 brtColor = color * brt;  
		    float intensityf = dot (brtColor, LuminanceCoeff);  
		    float3 intensity = float3 (intensityf, intensityf, intensityf);  
		      
		    // Operation for saturation  
		    float3 satColor = lerp (intensity, brtColor, sat);  
		      
		    // Operation for contrast  
		    float3 conColor = lerp (avgLumin, satColor, con);  
		      
		    return conColor;  
		}  
		fixed4 frag(v2f_img i) : COLOR {  
		    //Get the colors from the RenderTexture and the uv's  
		    //from the v2f_img struct  
		    fixed4 renderTex = tex2D(_MainTex, i.uv);  
		      
		    //Apply the brightness, saturation, contrast operations  
		    renderTex.rgb = ContrastSaturationBrightness (renderTex.rgb, _BrightnessAmount, _SaturationAmount, _ContrastAmount);  
		      
		    return renderTex;  
		}  
		
		ENDCG
	}
	}
}