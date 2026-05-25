extends GutTest

const SessionStoreScript = preload("res://online/session_store.gd")

func test_progression_lab_generated_saves_cover_manual_smoke_milestones() -> void:
	var doc := _read_json("res://docs/progression-lab/generated/healthy_saves.json")
	var saves := _as_array(doc.get("saves", []))
	var ids := {}
	for item: Variant in saves:
		var save := _as_dictionary(item)
		ids[str(save.get("id", ""))] = true
	assert_true(bool(ids.get("free_100_rewards_2h", false)))
	assert_true(bool(ids.get("free_100_rewards_10h", false)))
	assert_true(bool(ids.get("free_100_rewards_20h", false)))
	assert_eq(saves.size(), 25)

func test_session_store_accepts_progression_lab_snapshot_cache() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	var applied := store.apply_snapshot_cache({
		"cache_version": 1,
		"auth": {
			"access_token": "token",
			"refresh_token": "refresh",
			"expires_at": now + 3600,
			"user_id": "auth-user",
		},
		"session_id": "11111111-1111-4111-8111-111111111111",
		"guest_request_id": "22222222-2222-4222-8222-222222222222",
		"player": {
			"id": "player-1",
			"username": "plab_free_100_rewards_10h",
			"level": 14,
			"power": 1517,
		},
		"resources": {
			"player_id": "player-1",
			"almas": 194,
			"energia": 115,
			"sangue": 145,
			"cristais": 11,
			"ossos": 33,
			"diamante": 1,
		},
		"build": {
			"player_id": "player-1",
			"weapon_type": "varinha_cinzas",
			"weapon_quality": "starter",
			"weapon_level": 11,
			"spell_slots": ["descarga_nervosa", "sussurro_medo"],
			"spells_unlocked": ["sussurro_medo", "descarga_nervosa"],
			"pet_id": null,
			"pet_level": 0,
			"passive_id": "anatomista_profano",
			"passive_level": 1,
		},
	})
	assert_true(applied)
	assert_true(store.has_account_state())
	assert_eq(str(store.player.get("username", "")), "plab_free_100_rewards_10h")
	assert_eq(int(store.resources.get("energia", 0)), 115)
	store.free()

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return _as_dictionary(parsed)

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _as_array(value: Variant) -> Array:
	return value if value is Array else []
