shader_type canvas_item;

uniform vec4 centre_colour : source_color = vec4(0.18, 0.22, 0.28, 1.0);
uniform vec4 edge_colour : source_color = vec4(0.06, 0.08, 0.12, 1.0);
uniform float falloff = 1.4;

void fragment() {
    vec2 centred_uv = UV - vec2(0.5);
    float distance_from_centre = length(centred_uv) * 2.0;
    float gradient = clamp(pow(distance_from_centre, falloff), 0.0, 1.0);

    COLOR = mix(centre_colour, edge_colour, gradient);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
