shader_type canvas_item;

uniform vec2 position;
uniform float radius;
uniform float border_width = 0.02;
uniform float burn_mult = 0.135;
uniform sampler2D noise_texture;
uniform vec4 burn_color : source_color;

void fragment() {
	float dist = length(position - UV) + (texture(noise_texture, UV).b) * burn_mult;
	COLOR.rgb = mix(COLOR.rgb, burn_color.rgb, float(dist<radius+border_width));
	COLOR.a *= 1.0-(float(dist<radius));
}

