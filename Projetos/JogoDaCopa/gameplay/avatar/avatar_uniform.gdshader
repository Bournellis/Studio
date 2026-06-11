shader_type spatial;
render_mode diffuse_lambert, specular_schlick_ggx;

uniform sampler2D skin_texture : source_color;
uniform vec4 skin_color : source_color = vec4(0.77, 0.50, 0.32, 1.0);
uniform vec4 shirt_primary : source_color = vec4(1.0, 0.86, 0.12, 1.0);
uniform vec4 shirt_secondary : source_color = vec4(0.06, 0.52, 0.22, 1.0);
uniform vec4 shorts_color : source_color = vec4(0.05, 0.20, 0.70, 1.0);
uniform vec4 sock_color : source_color = vec4(0.96, 0.96, 0.92, 1.0);
uniform vec4 boot_color : source_color = vec4(0.04, 0.045, 0.05, 1.0);
uniform float toon_intensity = 0.0;

const float REGION_SKIN = 1.0;
const float REGION_SHIRT = 2.0;
const float REGION_SHORTS = 3.0;
const float REGION_SOCK = 4.0;
const float REGION_BOOT = 5.0;

vec3 quantize_toon(vec3 color) {
	return floor(color * 3.0 + 0.5) / 3.0;
}

void fragment() {
	float region = floor(COLOR.r * 8.0 + 0.5);
	vec3 albedo = shirt_primary.rgb;

	if (region == REGION_SKIN) {
		vec3 skin_detail = texture(skin_texture, UV).rgb;
		float detail_luma = dot(skin_detail, vec3(0.299, 0.587, 0.114));
		vec3 detail = mix(vec3(detail_luma), skin_detail, 0.35);
		albedo = skin_color.rgb * mix(vec3(0.82), detail * 1.18, 0.72);
	} else if (region == REGION_SHIRT) {
		float stripe = step(0.43, UV.y) * (1.0 - step(0.55, UV.y));
		albedo = mix(shirt_primary.rgb, shirt_secondary.rgb, stripe);
	} else if (region == REGION_SHORTS) {
		albedo = shorts_color.rgb;
	} else if (region == REGION_SOCK) {
		albedo = sock_color.rgb;
	} else if (region == REGION_BOOT) {
		albedo = boot_color.rgb;
	}

	ALBEDO = mix(albedo, quantize_toon(albedo), toon_intensity);
	ROUGHNESS = mix(0.62, 0.82, toon_intensity);
	METALLIC = 0.0;
}
