shader_type canvas_item;

// This creates a slider in the Inspector from 0 (full color) to 1 (fully gray)
uniform float desaturation : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculate the gray value based on human eye light sensitivity
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Mix the original color with the gray color based on our slider
    COLOR.rgb = mix(tex_color.rgb, vec3(gray), desaturation);
    COLOR.a = tex_color.a; // Keep the original transparency
}