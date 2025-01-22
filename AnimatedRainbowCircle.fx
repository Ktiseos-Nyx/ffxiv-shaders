// Customizable settings for the animated rainbow circle

uniform float CircleRadius <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 0.5;
    ui_label = "Circle Radius";
    ui_tooltip = "Adjusts the size of the circle";
> = 0.3;

uniform float OutlineWidth <
    ui_type = "slider";
    ui_min = 0.01; ui_max = 0.1;
    ui_label = "Outline Width";
    ui_tooltip = "Determines the thickness of the circle's outline";
> = 0.02;

uniform float AnimationSpeed <
    ui_type = "slider";
    ui_min = 0.1; ui_max = 5.0;
    ui_label = "Animation Speed";
    ui_tooltip = "Adjusts how fast the rainbow colors change";
> = 1.0;

uniform bool EnablePulsatingEffect <
    ui_type = "checkbox";
    ui_label = "Enable Pulsating Effect";
    ui_tooltip = "Toggles the pulsating color effect on or off";
> = false;

uniform int ColorTransitionMode <
    ui_type = "combo";
    ui_items = "Rainbow\0Custom Colors\0";
    ui_label = "Color Transition Mode";
    ui_tooltip = "Selects the color transition mode";
> = 0;

uniform float3 CustomColor1 <
    ui_type = "color";
    ui_label = "Custom Color 1";
> = float3(1.0, 0.0, 0.0);

uniform float3 CustomColor2 <
    ui_type = "color";
    ui_label = "Custom Color 2";
> = float3(0.0, 1.0, 0.0);

uniform float3 CustomColor3 <
    ui_type = "color";
    ui_label = "Custom Color 3";
> = float3(0.0, 0.0, 1.0);

uniform float Time < source = "timer"; >;

// Function to calculate color based on time and selected mode
float3 calculateColor(float t)
{
    if (EnablePulsatingEffect)
    {
        float pulse = sin(t * 2.0) * 0.25 + 0.75;
        if (ColorTransitionMode == 0)
        {
            // Rainbow mode with pulsation
            float r = sin(t) * pulse * 0.5 + 0.5;
            float g = sin(t + 2.094) * pulse * 0.5 + 0.5;
            float b = sin(t + 4.188) * pulse * 0.5 + 0.5;
            return float3(r, g, b);
        }
        else
        {
            // Custom colors mode with pulsation
            float segment = floor(t / 2.0);
            float blend = frac(t / 2.0);
            if (segment == 0.0) return lerp(CustomColor1, CustomColor2, blend);
            else if (segment == 1.0) return lerp(CustomColor2, CustomColor3, blend);
            else return lerp(CustomColor3, CustomColor1, blend);
        }
    }
    else
    {
        if (ColorTransitionMode == 0)
        {
            // Rainbow mode without pulsation
            float r = sin(t) * 0.5 + 0.5;
            float g = sin(t + 2.094) * 0.5 + 0.5;
            float b = sin(t + 4.188) * 0.5 + 0.5;
            return float3(r, g, b);
        }
        else
        {
            // Custom colors mode without pulsation
            float segment = floor(t / 2.0);
            float blend = frac(t / 2.0);
            if (segment == 0.0) return lerp(CustomColor1, CustomColor2, blend);
            else if (segment == 1.0) return lerp(CustomColor2, CustomColor3, blend);
            else return lerp(CustomColor3, CustomColor1, blend);
        }
    }
}

// Main pixel shader function
float4 PS_RainbowCircle(float4 pos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_TARGET
{
    // Center the coordinates
    float2 centeredCoord = texcoord - 0.5;
    
    // Calculate the distance from the center
    float dist = length(centeredCoord);
    
    // Calculate the time-based animation factor
    float t = Time * AnimationSpeed;
    
    // Get the color based on the current settings
    float3 color = calculateColor(t);
    
    // Adjust outline width based on pulsating effect setting
    float dynamicOutlineWidth = OutlineWidth * (EnablePulsatingEffect ? (sin(t) * 0.5 + 1.0) : 1.0);
    
    // Determine if the pixel is on the circle outline
    float circleOutline = smoothstep(CircleRadius - dynamicOutlineWidth, CircleRadius, dist) - smoothstep(CircleRadius, CircleRadius + dynamicOutlineWidth, dist);
    
    // Create the final color with transparency
    float4 finalColor = float4(color * circleOutline, circleOutline);
    
    return finalColor;
}

// Technique definition
technique RainbowCircle
{
    pass P0
    {
        VertexShader = PostProcessVS;
        PixelShader = PS_RainbowCircle;
    }
}
