shader_type spatial;

uniform sampler2D noise_texture;
uniform vec4 fire_color1 : source_color = vec4(1.0, 0.8, 0.0, 1.0);
uniform vec4 fire_color2 : source_color = vec4(1.0, 0.3, 0.0, 1.0);
uniform float fire_speed : hint_range(0.1, 5.0) = 1.0;
uniform float fire_intensity : hint_range(1.0, 10.0) = 5.0;

void fragment() {
    // Animate UVs for fire effect
    vec2 uv = UV;
    uv.y -= TIME * fire_speed;
    
    // Sample noise texture
    float noise = texture(noise_texture, uv).r;
    
    // Create fire gradient
    vec4 fire_color = mix(fire_color2, fire_color1, noise);
    
    // Apply the colors
    ALBEDO = fire_color.rgb;
    
    // Add emission for glow
    EMISSION = fire_color.rgb * fire_intensity;
    
    // Make the edges more transparent
    ALPHA = smoothstep(0.0, 0.5, noise);
}
