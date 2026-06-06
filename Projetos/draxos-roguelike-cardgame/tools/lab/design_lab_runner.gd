extends RefCounted

const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")
const ContextBuilderScript = preload("res://tools/lab/design_lab_context_builder.gd")
const OverlayCatalogScript = preload("res://tools/lab/design_lab_overlay_catalog.gd")
const ProposalLoaderScript = preload("res://tools/lab/design_lab_proposal_loader.gd")
const ScorerScript = preload("res://tools/lab/design_lab_scorer.gd")
const VariantGeneratorScript = preload("res://tools/lab/design_lab_variant_generator.gd")

static func run(catalog, pack: Dictionary, registry: Dictionary, options: Dictionary = {}) -> Dictionary:
	var profiles_result: Dictionary = ProposalLoaderScript.load_profiles_result()
	var profile_id: String = str(options.get("profile", pack.get("scoring_profile", "default")))
	var profile: Dictionary = {}
	if bool(profiles_result.get("ok", false)):
		profile = ProposalLoaderScript.profile_by_id(Dictionary(profiles_result.get("profiles", {})), profile_id)
	var variant_result: Dictionary = VariantGeneratorScript.generate_variants(pack, registry, options)
	var variants: Array[Dictionary] = _typed_dictionary_array(Array(variant_result.get("variants", [])))
	var blocked_specs: Array[Dictionary] = _typed_dictionary_array(Array(variant_result.get("blocked_specs", [])))
	var overlay_result: Dictionary = OverlayCatalogScript.build_overlay(catalog, pack, variants)
	if not bool(overlay_result.get("ok", false)):
		return _error_report(pack, str(overlay_result.get("message", "")), options)
	var context_result: Dictionary = ContextBuilderScript.build_cases(pack, variants, options)
	var cases: Array[Dictionary] = _typed_dictionary_array(Array(context_result.get("cases", [])))
	var records: Array[Dictionary] = []
	var battle_summary: Dictionary = {}
	var components: PackedStringArray = PackedStringArray(options.get("components", PackedStringArray(["battle", "encounter"])))
	if components.has("battle") or components.has("encounter"):
		var battle_pack: Dictionary = {
			"pack_id": str(pack.get("pack_id", "")),
			"simulation_mode": "design_lab_v1"
		}
		var battle_options: Dictionary = {
			"mode": str(options.get("mode", "explore")),
			"stop_on_failure": bool(options.get("stop_on_failure", false)),
			"max_actions_per_turn": int(options.get("max_actions_per_turn", 2))
		}
		var battle_result: Dictionary = BattleRunnerScript.run_cases(overlay_result.get("catalog"), battle_pack, cases, battle_options)
		records = _typed_dictionary_array(Array(battle_result.get("records", [])))
		battle_summary = Dictionary(battle_result.get("summary", {}))
	var scoring: Dictionary = ScorerScript.score_variants(variants, records, blocked_specs, profile, pack)
	var blocked_mechanics: Array[Dictionary] = _blocked_mechanic_entries(blocked_specs)
	var summary: Dictionary = Dictionary(scoring.get("summary", {}))
	summary["mode"] = str(options.get("mode", "explore"))
	summary["profile_id"] = profile_id
	summary["variant_summary"] = Dictionary(variant_result.get("summary", {}))
	summary["context_summary"] = Dictionary(context_result.get("summary", {}))
	summary["battle_summary"] = battle_summary
	summary["official_card_count"] = int(overlay_result.get("official_card_count", 0))
	summary["overlay_card_count"] = int(overlay_result.get("overlay_card_count", 0))
	summary["blocked_mechanic_count"] = blocked_mechanics.size()
	if blocked_mechanics.size() > 0:
		summary["gate_ok"] = false
	return {
		"ok": bool(summary.get("gate_ok", false)),
		"schema_version": 1,
		"tool": "design_lab",
		"pack_id": str(pack.get("pack_id", "")),
		"design_goal": str(pack.get("design_goal", "")),
		"profile_id": profile_id,
		"profile": profile,
		"summary": summary,
		"variants": variants,
		"blocked_specs": blocked_specs,
		"blocked_mechanics": blocked_mechanics,
		"cases": cases,
		"records": records,
		"candidates": Array(scoring.get("candidates", [])).duplicate(true),
		"by_card": Dictionary(scoring.get("by_card", {})).duplicate(true),
		"recommendations": Array(scoring.get("recommendations", [])).duplicate(true),
		"errors": Array(variant_result.get("errors", [])).duplicate()
	}

static func _error_report(pack: Dictionary, message: String, options: Dictionary) -> Dictionary:
	return {
		"ok": false,
		"schema_version": 1,
		"tool": "design_lab",
		"pack_id": str(pack.get("pack_id", "")),
		"summary": {"gate_ok": false, "candidate_count": 0, "card_count": 0, "recommendation_count": 0, "errors": [message]},
		"variants": [],
		"blocked_specs": [],
		"blocked_mechanics": [],
		"cases": [],
		"records": [],
		"candidates": [],
		"by_card": {},
		"recommendations": [],
		"errors": [message]
	}

static func _blocked_mechanic_entries(blocked_specs: Array[Dictionary]) -> Array[Dictionary]:
	var by_id: Dictionary = {}
	for blocked: Dictionary in blocked_specs:
		for entry_value: Variant in Array(blocked.get("blocked_mechanics", [])):
			if typeof(entry_value) != TYPE_DICTIONARY:
				continue
			var entry: Dictionary = Dictionary(entry_value)
			var mechanic_id: String = str(entry.get("mechanic_id", ""))
			if mechanic_id != "":
				by_id[mechanic_id] = entry
	var result: Array[Dictionary] = []
	for key: String in _sorted_keys(by_id):
		result.append(Dictionary(by_id.get(key, {})))
	return result

static func _typed_dictionary_array(values: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in values:
		if typeof(value) == TYPE_DICTIONARY:
			result.append(Dictionary(value))
	return result

static func _sorted_keys(values: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key: Variant in values.keys():
		keys.append(str(key))
	keys.sort()
	return keys
