shader_type canvas_item;

uniform vec3 first_color: source_color = vec3(0.3, 0.22, 0.28);
uniform vec3 second_color: source_color = vec3(0.56, 0.47, 0.53);
uniform float square_size: hint_range(1.0, 100.) = 15.;
// Ajustar a velocidade baseando-se no número de cartas
uniform float speed: hint_range(0.0, 10.0) = 1.;
// Mudar a direção toda vez que for a vez do jogador
uniform vec2 direction = vec2(0, 1.);

void fragment() {
	vec2 pos = FRAGCOORD.xy / square_size;
	
	float time_offset = TIME * speed;
	vec2 movement = normalize(direction) * time_offset;
	
	pos -= movement;
	pos = floor(pos);
	
	float pattern_mask = mod(pos.x + mod(pos.y, 2.), 2.);
	COLOR.rgb = mix(first_color, second_color, pattern_mask);
} 
