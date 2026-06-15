class_name FootballWorldEnvironment
extends RefCounted


static func add_world_environment(parent: Node, render_profile_script: Object) -> WorldEnvironment:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	environment.environment = build_night_environment(render_profile_script)
	parent.add_child(environment)
	return environment


static func build_night_environment(render_profile_script: Object) -> Environment:
	var render_settings: Dictionary = render_profile_script.get_environment_settings()
	var env := Environment.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.004, 0.01, 0.04, 1.0)
	sky_material.sky_horizon_color = Color(0.02, 0.065, 0.14, 1.0)
	sky_material.sky_curve = 0.18
	sky_material.sky_energy_multiplier = 0.72
	sky_material.ground_bottom_color = Color(0.012, 0.02, 0.028, 1.0)
	sky_material.ground_horizon_color = Color(0.02, 0.05, 0.08, 1.0)
	sky_material.ground_curve = 0.12
	sky_material.ground_energy_multiplier = 0.36
	sky_material.sun_angle_max = 1.0
	sky_material.sun_curve = 0.04
	sky_material.sky_cover = _build_star_cover_texture()
	sky_material.sky_cover_modulate = Color(1.0, 1.0, 1.0, 0.18)

	var sky := Sky.new()
	sky.sky_material = sky_material

	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.background_energy_multiplier = float(render_settings["background_energy_multiplier"])
	env.background_intensity = float(render_settings["background_intensity"])
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.44, 0.58, 0.72, 1.0)
	env.ambient_light_energy = float(render_settings["ambient_light_energy"])
	env.ambient_light_sky_contribution = float(render_settings["ambient_light_sky_contribution"])
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = float(render_settings["tonemap_exposure"])
	env.tonemap_white = float(render_settings["tonemap_white"])

	env.glow_enabled = bool(render_settings["glow_enabled"])
	env.set("glow_levels/1", false)
	env.set("glow_levels/2", true)
	env.set("glow_levels/3", true)
	env.set("glow_levels/4", true)
	env.set("glow_levels/5", false)
	env.set("glow_levels/6", false)
	env.set("glow_levels/7", false)
	env.glow_normalized = true
	env.glow_intensity = float(render_settings["glow_intensity"])
	env.glow_strength = float(render_settings["glow_strength"])
	env.glow_bloom = float(render_settings["glow_bloom"])
	env.glow_hdr_threshold = float(render_settings["glow_hdr_threshold"])
	env.glow_hdr_scale = float(render_settings["glow_hdr_scale"])
	env.glow_hdr_luminance_cap = float(render_settings["glow_hdr_luminance_cap"])

	env.ssao_enabled = bool(render_settings["ssao_enabled"])
	env.ssao_radius = float(render_settings["ssao_radius"])
	env.ssao_intensity = float(render_settings["ssao_intensity"])
	env.ssao_power = float(render_settings["ssao_power"])
	env.ssao_detail = float(render_settings["ssao_detail"])
	env.ssao_sharpness = float(render_settings["ssao_sharpness"])
	env.ssao_light_affect = float(render_settings["ssao_light_affect"])

	env.fog_enabled = bool(render_settings["fog_enabled"])
	env.fog_light_color = Color(0.12, 0.22, 0.36, 1.0)
	env.fog_light_energy = float(render_settings["fog_light_energy"])
	env.fog_density = float(render_settings["fog_density"])
	env.fog_aerial_perspective = float(render_settings["fog_aerial_perspective"])
	env.fog_sky_affect = float(render_settings["fog_sky_affect"])
	env.fog_depth_begin = float(render_settings["fog_depth_begin"])
	env.fog_depth_end = float(render_settings["fog_depth_end"])
	env.fog_depth_curve = float(render_settings["fog_depth_curve"])
	return env


static func add_stadium_key_light(parent: Node) -> DirectionalLight3D:
	var key_light := DirectionalLight3D.new()
	key_light.name = "StadiumKeyLight"
	key_light.rotation_degrees = Vector3(-56.0, -34.0, 0.0)
	key_light.light_color = Color(0.74, 0.86, 1.0, 1.0)
	key_light.light_energy = 1.85
	key_light.light_indirect_energy = 0.44
	key_light.light_specular = 0.64
	key_light.shadow_enabled = true
	key_light.directional_shadow_max_distance = 88.0
	key_light.directional_shadow_fade_start = 0.74
	key_light.shadow_bias = 0.045
	key_light.shadow_normal_bias = 0.82
	parent.add_child(key_light)
	return key_light


static func _build_star_cover_texture() -> Texture2D:
	var noise := FastNoiseLite.new()
	noise.seed = 20260610
	noise.frequency = 0.032
	noise.fractal_octaves = 1
	var texture := NoiseTexture2D.new()
	texture.width = 512
	texture.height = 256
	texture.normalize = true
	texture.noise = noise
	return texture
