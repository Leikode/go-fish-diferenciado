shader_type canvas_item;

uniform vec2 position;
uniform float radius;
uniform float border_width = 0.02;
uniform float burn_mult = 0.135;
uniform sampler2D noise_texture;
uniform vec4 burn_color : source_color;

uniform vec2 mouse_uv = vec2(-1.);
uniform float rotation_strength : hint_range(0.0, 2.0) = 1.2;

uniform bool is_selected = false;


void vertex() {
	if (mouse_uv != vec2(-1.)) {
		vec2 centered = mouse_uv - vec2(0.5);
		
    	float angle_y = -centered.x * rotation_strength; 
		float angle_x = centered.y * rotation_strength;  

		mat3 rotation_matrix_y = mat3(
		    vec3(cos(angle_y), 0, sin(angle_y)),
		    vec3(0, 1, 0),
		    vec3(-sin(angle_y), 0, cos(angle_y))
		);

		mat3 rotation_matrix_x = mat3(
		    vec3(1, 0, 0),
		    vec3(0, cos(angle_x), -sin(angle_x)),
		    vec3(0, sin(angle_x), cos(angle_x))
		);
		
		vec3 result = rotation_matrix_y * rotation_matrix_x * vec3(VERTEX, 1.0);
		VERTEX = result.xy;
	} else if (mouse_uv == vec2(-1.) && !is_selected) {
		mat3 rotation_matrix_z = mat3(vec3(cos(sin(TIME * 6.) * 0.2),-sin(sin(TIME * 6.) * 0.2),0),vec3(sin(sin(TIME * 6.) * 0.2),cos(sin(TIME * 6.) * 0.2),0),vec3(0,0,1));
		VERTEX = (rotation_matrix_z * vec3(VERTEX, 1.0)).xy;
	}
}

void fragment() {
	float dist = length(position - UV) + (texture(noise_texture, UV).b) * burn_mult;
	COLOR.rgb = mix(COLOR.rgb, burn_color.rgb, float(dist < radius + border_width));
	COLOR.a *= 1.0 - (float(dist < radius));
}

