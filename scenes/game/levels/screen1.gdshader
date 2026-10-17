shader_type spatial;
render_mode unshaded, cull_face back;

uniform float time = 0.0;
uniform float wave_speed = 2.0;
uniform float amplitude = 0.5;

void vertex() {
	// Анимация вершин (для живых волн)
}

void fragment() {
	vec3 norm = normalize(vec3(0,0,1));
	float wave = sin(norm.y * 5.0 + time) * amplitude;
	COLOR = vec4(vec3(0, 1 - wave/2.0, wave), 0.9);
}
