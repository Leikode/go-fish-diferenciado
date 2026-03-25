shader_type canvas_item;

uniform vec3 outline_color : source_color = vec3(0.078, 0.733, 1.0);
uniform float line_thickness : hint_range(0.0, 1.0) = .5;
const float MAX_LINE_THICKNESS = 4.;

uniform vec2 mouse_uv = vec2(-1.);
uniform float rotation_strength : hint_range(0.0, 2.0) = 1.2;


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
	}
}

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness * MAX_LINE_THICKNESS * abs(sin(TIME));
	vec2 directions[8] = {
		vec2(size.x, 0.),
		vec2(-size.x, 0.),
		vec2(size.x, size.y),
		vec2(-size.x, size.y),
		vec2(size.x, -size.y),
		vec2(-size.x, -size.y),
		vec2(0., -size.y),
		vec2(0., size.y)
	};
	vec4 main_texture = texture(TEXTURE, UV);
	float outline = main_texture.a;

	outline += texture(TEXTURE, UV + directions[0]).a;
	outline += texture(TEXTURE, UV + directions[1]).a;
	outline += texture(TEXTURE, UV + directions[2]).a;
	outline += texture(TEXTURE, UV + directions[3]).a;
	outline += texture(TEXTURE, UV + directions[4]).a;
	outline += texture(TEXTURE, UV + directions[5]).a;
	outline += texture(TEXTURE, UV + directions[6]).a;
	outline += texture(TEXTURE, UV + directions[7]).a;

	outline = min(outline, 1.) - main_texture.a;
	COLOR.a = outline + main_texture.a;
	COLOR.rgb = outline * outline_color + main_texture.rgb;
}