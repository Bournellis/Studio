shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 panel_color = vec3(0.96, 0.97, 0.92);
uniform vec3 seam_color = vec3(0.03, 0.035, 0.04);
uniform vec3 accent_color = vec3(0.12, 0.42, 0.95);
uniform float seam_width = 0.055;

void fragment() {
	vec2 uv = UV;
	float longitude = abs(fract(uv.x * 10.0) - 0.5);
	float latitude = abs(fract((uv.y + sin(uv.x * 6.28318) * 0.045) * 6.0) - 0.5);
	float diagonal = abs(fract((uv.x + uv.y * 0.55) * 8.0) - 0.5);
	float seam = 1.0 - smoothstep(seam_width, seam_width + 0.012, min(min(longitude, latitude), diagonal));
	float accent = smoothstep(0.43, 0.5, abs(sin((uv.x * 5.0 + uv.y * 3.0) * 6.28318)));
	vec3 base = mix(panel_color, accent_color, accent * 0.18);
	ALBEDO = mix(base, seam_color, clamp(seam, 0.0, 1.0));
	EMISSION = accent_color * accent * 0.045;
	ROUGHNESS = 0.44;
}
