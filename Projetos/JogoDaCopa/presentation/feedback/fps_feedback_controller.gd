class_name FpsFeedbackController
extends Node3D

const SAMPLE_RATE: int = 22050
const PLAYER_COLOR: Color = Color(0.28, 0.92, 1.0, 1.0)
const HIT_COLOR: Color = Color(0.52, 1.0, 0.58, 1.0)
const MISS_COLOR: Color = Color(0.62, 0.76, 0.9, 0.72)
const BOT_COLOR: Color = Color(1.0, 0.58, 0.22, 1.0)
const DAMAGE_COLOR: Color = Color(1.0, 0.14, 0.08, 1.0)
const PLASMA_COLOR: Color = Color(0.38, 0.98, 1.0, 1.0)
const OVERCHARGE_COLOR: Color = Color(0.78, 0.46, 1.0, 1.0)
const HEALTH_COLOR: Color = Color(0.38, 1.0, 0.52, 1.0)
const JUMP_PAD_COLOR: Color = Color(0.18, 0.78, 1.0, 1.0)
const VOID_COLOR: Color = Color(0.95, 0.22, 0.72, 1.0)
const FOOTBALL_COLOR: Color = Color(0.36, 1.0, 0.58, 1.0)
const FOOTBALL_STRONG_COLOR: Color = Color(0.34, 0.88, 1.0, 1.0)
const FOOTBALL_GOAL_COLOR: Color = Color(1.0, 0.86, 0.22, 1.0)

var active_effects: Array[Dictionary] = []
var last_event: StringName = &""
var player_shot_count: int = 0
var hit_count: int = 0
var miss_count: int = 0
var player_damage_count: int = 0
var bot_tell_count: int = 0
var bot_shot_count: int = 0
var bot_miss_count: int = 0
var knockback_count: int = 0
var round_end_count: int = 0
var plasma_shot_count: int = 0
var plasma_hit_count: int = 0
var plasma_miss_count: int = 0
var pickup_count: int = 0
var jump_pad_count: int = 0
var fall_penalty_count: int = 0
var football_kick_count: int = 0
var football_goal_count: int = 0
var boost_trail_count: int = 0
var skid_dust_count: int = 0
var confetti_count: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	for index in range(active_effects.size() - 1, -1, -1):
		var entry := active_effects[index]
		entry["time"] = float(entry["time"]) - delta
		active_effects[index] = entry
		if float(entry["time"]) > 0.0:
			continue
		var effect_node: Node = entry["node"]
		if is_instance_valid(effect_node):
			effect_node.queue_free()
		active_effects.remove_at(index)

func play_player_shot(origin: Vector3, direction: Vector3) -> void:
	last_event = &"player_shot"
	player_shot_count += 1
	var shot_direction := direction.normalized()
	_spawn_sphere(origin + shot_direction * 0.18, 0.08, PLAYER_COLOR, 0.055, true)
	_spawn_light(origin + shot_direction * 0.22, PLAYER_COLOR, 1.45, 1.1, 0.045)
	_spawn_tone(origin, 760.0, 0.045, -11.0)

func play_plasma_shot(origin: Vector3, direction: Vector3, overcharged: bool) -> void:
	last_event = &"plasma_shot"
	plasma_shot_count += 1
	var shot_direction := direction.normalized()
	var color := OVERCHARGE_COLOR if overcharged else PLASMA_COLOR
	_spawn_sphere(origin + shot_direction * 0.16, 0.16 if overcharged else 0.12, color, 0.09, true)
	_spawn_light(origin + shot_direction * 0.22, color, 2.2 if overcharged else 1.65, 1.9, 0.08)
	_spawn_tone(origin, 610.0 if overcharged else 520.0, 0.075, -11.5)

func play_plasma_hit(impact_position: Vector3, overcharged: bool) -> void:
	last_event = &"plasma_hit"
	plasma_hit_count += 1
	var color := OVERCHARGE_COLOR if overcharged else PLASMA_COLOR
	_spawn_sphere(impact_position, 0.36 if overcharged else 0.28, color, 0.18, true)
	_spawn_light(impact_position, color, 3.7 if overcharged else 2.8, 3.2, 0.16)
	_spawn_tone(impact_position, 760.0 if overcharged else 640.0, 0.09, -8.8)

func play_plasma_miss(impact_position: Vector3, overcharged: bool) -> void:
	last_event = &"plasma_miss"
	plasma_miss_count += 1
	var color := OVERCHARGE_COLOR if overcharged else PLASMA_COLOR
	_spawn_sphere(impact_position, 0.18, Color(color.r, color.g, color.b, 0.68), 0.11, true)
	_spawn_light(impact_position, color, 1.5, 1.7, 0.08)
	_spawn_tone(impact_position, 310.0, 0.055, -15.5)

func play_hit(origin: Vector3, impact_position: Vector3) -> void:
	last_event = &"hit"
	hit_count += 1
	_spawn_beam(origin, impact_position, PLAYER_COLOR, 0.045, 0.08)
	_spawn_sphere(impact_position, 0.24, HIT_COLOR, 0.16, true)
	_spawn_light(impact_position, HIT_COLOR, 2.8, 2.2, 0.12)
	_spawn_tone(impact_position, 1180.0, 0.055, -8.5)

func play_miss(origin: Vector3, miss_position: Vector3) -> void:
	last_event = &"miss"
	miss_count += 1
	_spawn_beam(origin, miss_position, MISS_COLOR, 0.028, 0.06)
	_spawn_tone(origin, 540.0, 0.035, -16.0)

func play_player_damage(amount: float, remaining_fraction: float, global_position_hint: Vector3 = Vector3.ZERO) -> void:
	last_event = &"player_damage"
	player_damage_count += 1
	var intensity := clampf(1.0 - remaining_fraction + amount / 80.0, 0.35, 1.0)
	_spawn_light(global_position_hint + Vector3.UP * 0.6, DAMAGE_COLOR, 2.6 * intensity, 2.0, 0.13)
	_spawn_tone(global_position_hint, 180.0, 0.08, -9.5)

func play_pickup(pickup_position: Vector3, pickup_kind: StringName) -> void:
	last_event = &"pickup"
	pickup_count += 1
	var color := HEALTH_COLOR if pickup_kind == &"health" else OVERCHARGE_COLOR
	_spawn_sphere(pickup_position, 0.28, color, 0.16, true)
	_spawn_light(pickup_position, color, 2.9, 2.6, 0.15)
	_spawn_tone(pickup_position, 920.0 if pickup_kind == &"health" else 1040.0, 0.08, -10.0)

func play_jump_pad(pad_position: Vector3, launch_velocity: Vector3) -> void:
	last_event = &"jump_pad"
	jump_pad_count += 1
	var launch_direction := launch_velocity.normalized() if launch_velocity.length_squared() > 0.0001 else Vector3.UP
	_spawn_beam(pad_position + Vector3.UP * 0.1, pad_position + launch_direction * 1.8 + Vector3.UP * 0.75, JUMP_PAD_COLOR, 0.052, 0.16)
	_spawn_sphere(pad_position + Vector3.UP * 0.16, 0.34, JUMP_PAD_COLOR, 0.18, true)
	_spawn_light(pad_position + Vector3.UP * 0.25, JUMP_PAD_COLOR, 3.6, 3.4, 0.16)
	_spawn_tone(pad_position, 980.0, 0.08, -10.0)

func play_fall_penalty(effect_position: Vector3, for_player: bool) -> void:
	last_event = &"fall_penalty"
	fall_penalty_count += 1
	var color := DAMAGE_COLOR if for_player else VOID_COLOR
	_spawn_sphere(effect_position + Vector3.UP * 0.35, 0.44, color, 0.22, true)
	_spawn_light(effect_position + Vector3.UP * 0.7, color, 4.2, 4.0, 0.22)
	_spawn_tone(effect_position, 120.0 if for_player else 170.0, 0.12, -8.8)

func play_football_kick(ball_position: Vector3, direction: Vector3, strong: bool) -> void:
	last_event = &"football_strong_kick" if strong else &"football_kick"
	football_kick_count += 1
	var kick_direction := direction.normalized() if direction.length_squared() > 0.0001 else Vector3.FORWARD
	var color := FOOTBALL_STRONG_COLOR if strong else FOOTBALL_COLOR
	var reach := 1.4 if strong else 0.9
	_spawn_beam(ball_position + Vector3.UP * 0.08, ball_position + kick_direction * reach + Vector3.UP * 0.18, color, 0.05 if strong else 0.035, 0.13)
	_spawn_sphere(ball_position, 0.26 if strong else 0.2, color, 0.14, true)
	_spawn_particle_burst(ball_position, color, 26 if strong else 14, 0.24 if strong else 0.16, 1.8 if strong else 1.1)
	_spawn_light(ball_position + Vector3.UP * 0.28, color, 2.8 if strong else 1.9, 2.6, 0.12)
	_spawn_tone(ball_position, 520.0 if strong else 390.0, 0.065, -10.5 if strong else -12.0)

func play_football_goal(goal_position: Vector3, player_scored: bool) -> void:
	last_event = &"football_goal"
	football_goal_count += 1
	var color := FOOTBALL_GOAL_COLOR if player_scored else DAMAGE_COLOR
	_spawn_sphere(goal_position + Vector3.UP * 0.7, 0.72, color, 0.42, true)
	_spawn_particle_burst(goal_position + Vector3.UP * 1.0, color, 96, 0.7, 5.8)
	_spawn_particle_burst(goal_position + Vector3.UP * 1.35, Color(0.34, 0.88, 1.0, 1.0), 44, 0.55, 4.0)
	_spawn_light(goal_position + Vector3.UP * 1.2, color, 6.0, 8.0, 0.52)
	_spawn_tone(goal_position, 980.0 if player_scored else 220.0, 0.16, -7.5)

func play_arcade_confetti(effect_position: Vector3, player_colored: bool) -> void:
	last_event = &"arcade_confetti"
	confetti_count += 1
	var primary := FOOTBALL_GOAL_COLOR if player_colored else BOT_COLOR
	_spawn_particle_burst(effect_position + Vector3.UP * 1.35, primary, 48, 0.5, 3.8)
	_spawn_particle_burst(effect_position + Vector3.UP * 1.55, Color(0.34, 0.88, 1.0, 1.0), 28, 0.44, 3.0)
	_spawn_light(effect_position + Vector3.UP * 1.25, primary, 3.4, 4.4, 0.34)
	_spawn_tone(effect_position, 1120.0 if player_colored else 260.0, 0.09, -10.0)

func play_boost_trail(_player_position: Vector3, _direction: Vector3) -> void:
	boost_trail_count += 1

func play_skid_dust(_player_position: Vector3) -> void:
	skid_dust_count += 1

func play_bot_tell(origin: Vector3, target_position: Vector3, duration: float) -> void:
	last_event = &"bot_tell"
	bot_tell_count += 1
	_spawn_beam(origin, target_position, Color(1.0, 0.74, 0.2, 0.58), 0.035, maxf(0.05, duration))
	_spawn_sphere(origin, 0.16, BOT_COLOR, maxf(0.05, duration), true)
	_spawn_light(origin, BOT_COLOR, 2.0, 2.0, maxf(0.05, duration))
	_spawn_tone(origin, 420.0, 0.055, -14.0)

func play_bot_shot(origin: Vector3, target_position: Vector3) -> void:
	last_event = &"bot_shot"
	bot_shot_count += 1
	_spawn_beam(origin, target_position, BOT_COLOR, 0.052, 0.1)
	_spawn_sphere(origin, 0.2, BOT_COLOR, 0.1, true)
	_spawn_light(origin, BOT_COLOR, 2.5, 2.4, 0.09)
	_spawn_tone(origin, 320.0, 0.06, -10.5)

func play_bot_miss(origin: Vector3, miss_position: Vector3) -> void:
	last_event = &"bot_miss"
	bot_miss_count += 1
	_spawn_beam(origin, miss_position, Color(1.0, 0.52, 0.2, 0.52), 0.032, 0.075)
	_spawn_light(origin, BOT_COLOR, 1.2, 1.4, 0.055)
	_spawn_tone(origin, 250.0, 0.045, -16.0)

func play_knockback(body_position: Vector3, direction: Vector3, force: float, from_player: bool) -> void:
	knockback_count += 1
	var flat := Vector3(direction.x, 0.0, direction.z)
	if flat.length_squared() <= 0.0001:
		flat = Vector3.FORWARD
	flat = flat.normalized()
	var color := PLAYER_COLOR if from_player else BOT_COLOR
	var pulse_distance := clampf(force * 0.16, 0.42, 1.35)
	var end_position := body_position + flat * pulse_distance + Vector3.UP * 0.12
	var start_position := body_position + Vector3.UP * 0.12
	_spawn_beam(start_position, end_position, color, 0.035, 0.085)
	_spawn_sphere(start_position, 0.14, color, 0.09, true)
	_spawn_light(start_position, color, 1.8, 1.65, 0.075)
	_spawn_tone(start_position, 135.0 if from_player else 105.0, 0.055, -14.5)

func play_round_end(player_won: bool) -> void:
	last_event = &"round_end"
	round_end_count += 1
	var color := HIT_COLOR if player_won else DAMAGE_COLOR
	_spawn_light(Vector3(0.0, 4.0, 0.0), color, 4.0, 12.0, 0.7)
	_spawn_tone(Vector3.ZERO, 880.0 if player_won else 150.0, 0.18, -8.0)

func clear_effects() -> void:
	for entry: Dictionary in active_effects:
		var effect_node: Node = entry["node"]
		if is_instance_valid(effect_node):
			effect_node.queue_free()
	active_effects.clear()

func debug_active_effect_count() -> int:
	return active_effects.size()

func debug_get_boost_trail_count() -> int:
	return boost_trail_count

func debug_get_skid_dust_count() -> int:
	return skid_dust_count

func debug_get_confetti_count() -> int:
	return confetti_count

func debug_make_synthetic_stream(frequency: float, duration: float) -> AudioStreamWAV:
	return _build_tone_stream(frequency, duration)

func _spawn_beam(start_position: Vector3, end_position: Vector3, color: Color, thickness: float, lifetime: float) -> void:
	var delta := end_position - start_position
	if delta.length_squared() <= 0.0001:
		return
	var pivot := Node3D.new()
	pivot.name = "FeedbackBeam"
	add_child(pivot)
	pivot.global_position = start_position + delta * 0.5
	var up := Vector3.UP
	if absf(delta.normalized().dot(Vector3.UP)) > 0.94:
		up = Vector3.RIGHT
	pivot.look_at(end_position, up)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "BeamMesh"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(thickness, thickness, delta.length())
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_material(color, true)
	pivot.add_child(mesh_instance)
	_track_effect(pivot, lifetime)

func _spawn_sphere(effect_position: Vector3, radius: float, color: Color, lifetime: float, unshaded: bool) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "FeedbackSphere"
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_material(color, unshaded)
	add_child(mesh_instance)
	mesh_instance.global_position = effect_position
	_track_effect(mesh_instance, lifetime)

func _spawn_light(effect_position: Vector3, color: Color, energy: float, radius: float, lifetime: float) -> void:
	var light := OmniLight3D.new()
	light.name = "FeedbackLight"
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	add_child(light)
	light.global_position = effect_position
	_track_effect(light, lifetime)

func _spawn_particle_burst(effect_position: Vector3, color: Color, amount: int, lifetime: float, speed: float) -> void:
	var particles := GPUParticles3D.new()
	particles.name = "FeedbackParticles"
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.randomness = 0.72
	particles.emitting = true
	particles.local_coords = false
	var process_material := ParticleProcessMaterial.new()
	process_material.gravity = Vector3(0.0, -1.2, 0.0)
	process_material.initial_velocity_min = speed * 0.45
	process_material.initial_velocity_max = speed
	process_material.spread = 52.0
	process_material.scale_min = 0.16
	process_material.scale_max = 0.58
	particles.process_material = process_material
	var mesh := SphereMesh.new()
	mesh.radius = 0.045
	mesh.height = 0.09
	mesh.radial_segments = 8
	mesh.rings = 4
	var material := _build_material(color, true)
	mesh.material = material
	particles.draw_pass_1 = mesh
	add_child(particles)
	particles.global_position = effect_position
	_track_effect(particles, lifetime + 0.18)

func _spawn_tone(effect_position: Vector3, frequency: float, duration: float, volume_db: float) -> void:
	var player := AudioStreamPlayer3D.new()
	player.name = "FeedbackTone"
	player.stream = _build_tone_stream(frequency, duration)
	player.volume_db = volume_db
	player.unit_size = 7.0
	add_child(player)
	player.global_position = effect_position
	player.play()
	_track_effect(player, duration + 0.05)

func _track_effect(effect_node: Node, lifetime: float) -> void:
	active_effects.append({
		"node": effect_node,
		"time": maxf(0.01, lifetime)
	})

func _build_material(color: Color, unshaded: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.8
	material.roughness = 0.35
	if unshaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _build_tone_stream(frequency: float, duration: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	var sample_count := maxi(1, int(float(SAMPLE_RATE) * maxf(0.01, duration)))
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var t := float(sample_index) / float(SAMPLE_RATE)
		var fade := 1.0 - (float(sample_index) / float(sample_count))
		var wave := sin(TAU * frequency * t) * fade
		var sample := int(clampf(wave, -1.0, 1.0) * 18000.0)
		var encoded := sample
		if encoded < 0:
			encoded = 65536 + encoded
		var byte_index := sample_index * 2
		data[byte_index] = encoded & 0xff
		data[byte_index + 1] = (encoded >> 8) & 0xff
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream
