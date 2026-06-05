extends RefCounted

const DEFAULT_CLASSES: PackedStringArray = ["arcano", "invocador", "necromante"]
const DEFAULT_SEEDS: PackedInt64Array = [20260518]
const DEFAULT_POLICIES: PackedStringArray = ["baseline"]
const DEFAULT_OUTPUT_DIR: String = "user://run_lab"
const DEFAULT_PRESET: String = "smoke"
const DEFAULT_SIMULATION_MODE: String = "macro_route_v1"

const PRESET_SEED_COUNTS: Dictionary = {
	"smoke": 1,
	"golden": 1,
	"quick": 10,
	"balance": 100,
	"stress": 1000
}
const PRESET_POLICIES: Dictionary = {
	"smoke": ["baseline"],
	"golden": ["baseline"],
	"quick": ["baseline"],
	"balance": ["baseline", "defensive", "no_shop"],
	"stress": ["baseline", "defensive", "thin_deck", "big_deck", "no_shop", "high_shop"]
}

static func parse_options(args: PackedStringArray) -> Dictionary:
	var raw: Dictionary = {
		"preset": DEFAULT_PRESET,
		"out": DEFAULT_OUTPUT_DIR,
		"compare_golden": false,
		"require_golden": false,
		"strict_golden": false,
		"compare_baseline": false,
		"save_baseline": false,
		"baseline_path": "",
		"mode": "explore",
		"stop_on_failure": false,
		"timeline": true
	}
	var class_override: PackedStringArray = PackedStringArray()
	var seed_override: PackedInt64Array = PackedInt64Array()
	var policy_override: PackedStringArray = PackedStringArray()
	var seed_start: int = 20260518
	var seed_count: int = -1
	var has_seed_range: bool = false

	for arg: String in args:
		if arg.begins_with("--preset="):
			raw["preset"] = arg.trim_prefix("--preset=")
		elif arg.begins_with("--class="):
			class_override = PackedStringArray([arg.trim_prefix("--class=")])
		elif arg.begins_with("--classes="):
			class_override = _split_string_list(arg.trim_prefix("--classes="))
		elif arg.begins_with("--seed="):
			seed_override = PackedInt64Array([int(arg.trim_prefix("--seed="))])
		elif arg.begins_with("--seeds="):
			seed_override = _split_int_list(arg.trim_prefix("--seeds="))
		elif arg.begins_with("--seed-start="):
			seed_start = int(arg.trim_prefix("--seed-start="))
			has_seed_range = true
		elif arg.begins_with("--seed-count="):
			seed_count = int(arg.trim_prefix("--seed-count="))
			has_seed_range = true
		elif arg.begins_with("--policy="):
			policy_override = PackedStringArray([arg.trim_prefix("--policy=")])
		elif arg.begins_with("--policies="):
			policy_override = _split_string_list(arg.trim_prefix("--policies="))
		elif arg.begins_with("--out="):
			raw["out"] = arg.trim_prefix("--out=")
		elif arg == "--compare-golden" or arg == "--golden":
			raw["compare_golden"] = true
		elif arg == "--require-golden":
			raw["require_golden"] = true
			raw["compare_golden"] = true
		elif arg == "--strict-golden":
			raw["strict_golden"] = true
			raw["compare_golden"] = true
		elif arg == "--compare-baseline":
			raw["compare_baseline"] = true
		elif arg == "--save-baseline":
			raw["save_baseline"] = true
		elif arg.begins_with("--baseline="):
			raw["baseline_path"] = arg.trim_prefix("--baseline=")
		elif arg.begins_with("--baseline-path="):
			raw["baseline_path"] = arg.trim_prefix("--baseline-path=")
		elif arg.begins_with("--mode="):
			raw["mode"] = arg.trim_prefix("--mode=")
		elif arg == "--stop-on-failure":
			raw["stop_on_failure"] = true
		elif arg == "--no-timeline":
			raw["timeline"] = false

	var preset: String = str(raw.get("preset", DEFAULT_PRESET))
	if not PRESET_SEED_COUNTS.has(preset):
		preset = DEFAULT_PRESET
		raw["preset"] = preset
	var preset_seed_count: int = int(PRESET_SEED_COUNTS.get(preset, 1))
	var classes: PackedStringArray = DEFAULT_CLASSES if class_override.is_empty() else class_override
	var policies: PackedStringArray = PackedStringArray(PRESET_POLICIES.get(preset, DEFAULT_POLICIES)) if policy_override.is_empty() else policy_override
	var seeds: PackedInt64Array = DEFAULT_SEEDS
	if not seed_override.is_empty():
		seeds = seed_override
	elif has_seed_range:
		seeds = _range_seeds(seed_start, seed_count if seed_count > 0 else preset_seed_count)
	elif preset_seed_count > 1:
		seeds = _range_seeds(seed_start, preset_seed_count)

	raw["classes"] = classes
	raw["seeds"] = seeds
	raw["policies"] = policies
	raw["case_count"] = classes.size() * seeds.size() * policies.size()
	raw["simulation_mode"] = DEFAULT_SIMULATION_MODE
	return raw

static func build_cases(options: Dictionary) -> Array[Dictionary]:
	var cases: Array[Dictionary] = []
	for class_id: String in PackedStringArray(options.get("classes", DEFAULT_CLASSES)):
		for seed: int in PackedInt64Array(options.get("seeds", DEFAULT_SEEDS)):
			for policy_id: String in PackedStringArray(options.get("policies", DEFAULT_POLICIES)):
				var policy: Dictionary = policy_contract(policy_id)
				cases.append({
					"case_id": "%s:%d:%s" % [class_id, seed, policy_id],
					"class_id": class_id,
					"seed": seed,
					"policy_id": policy_id,
					"route_policy": str(policy.get("route_policy", "linear_track02")),
					"reward_policy": str(policy.get("reward_policy", "baseline")),
					"shop_policy": str(policy.get("shop_policy", "baseline_recovery")),
					"simulation_mode": str(options.get("simulation_mode", DEFAULT_SIMULATION_MODE))
				})
	return cases

static func policy_contract(policy_id: String) -> Dictionary:
	match policy_id:
		"greedy", "greedy_power":
			return {"route_policy": "linear_track02", "reward_policy": "rarity_first", "shop_policy": "power_greedy"}
		"defensive":
			return {"route_policy": "linear_track02", "reward_policy": "defensive", "shop_policy": "defensive"}
		"thin_deck":
			return {"route_policy": "linear_track02", "reward_policy": "thin_deck", "shop_policy": "thin_deck"}
		"big_deck":
			return {"route_policy": "linear_track02", "reward_policy": "rarity_first", "shop_policy": "big_deck"}
		"no_shop":
			return {"route_policy": "linear_track02", "reward_policy": "baseline", "shop_policy": "none"}
		"high_shop":
			return {"route_policy": "linear_track02", "reward_policy": "rarity_first", "shop_policy": "high_shop"}
		_:
			return {"route_policy": "linear_track02", "reward_policy": "baseline", "shop_policy": "baseline_recovery"}

static func describe_options(options: Dictionary) -> String:
	return "preset=%s classes=%s seeds=%d policies=%s cases=%d mode=%s" % [
		str(options.get("preset", DEFAULT_PRESET)),
		",".join(PackedStringArray(options.get("classes", DEFAULT_CLASSES))),
		PackedInt64Array(options.get("seeds", DEFAULT_SEEDS)).size(),
		",".join(PackedStringArray(options.get("policies", DEFAULT_POLICIES))),
		int(options.get("case_count", 0)),
		str(options.get("mode", "explore"))
	]

static func _split_string_list(value: String) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	for item: String in value.split(",", false):
		var trimmed: String = item.strip_edges()
		if trimmed != "":
			result.append(trimmed)
	return result

static func _split_int_list(value: String) -> PackedInt64Array:
	var result: PackedInt64Array = PackedInt64Array()
	for item: String in value.split(",", false):
		var trimmed: String = item.strip_edges()
		if trimmed != "":
			result.append(int(trimmed))
	return result

static func _range_seeds(seed_start: int, seed_count: int) -> PackedInt64Array:
	var result: PackedInt64Array = PackedInt64Array()
	for offset: int in range(maxi(1, seed_count)):
		result.append(seed_start + offset)
	return result
