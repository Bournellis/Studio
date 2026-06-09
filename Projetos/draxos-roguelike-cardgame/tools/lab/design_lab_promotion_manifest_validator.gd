extends RefCounted

const REQUIRED_VALIDATION_NEEDLES: Array[String] = [
	"run_design_lab",
	"run_card_impact",
	"run_lab",
	"validate.gd"
]

const PROMOTABLE_CLASSIFICATIONS: Array[String] = [
	"recommended",
	"viable"
]

static func validate_manifest(manifest: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if int(manifest.get("schema_version", 0)) != 1:
		errors.append("schema_version must be 1.")
	if str(manifest.get("pack_id", "")).strip_edges() == "":
		errors.append("pack_id is required.")
	if str(manifest.get("generated_by", "")).strip_edges() == "":
		errors.append("generated_by is required.")
	if not bool(manifest.get("manual_approval_required", false)):
		errors.append("manual_approval_required must be true.")
	if typeof(manifest.get("selected_candidates", [])) != TYPE_ARRAY:
		errors.append("selected_candidates must be an array.")
	if typeof(manifest.get("blocked_mechanics", [])) != TYPE_ARRAY:
		errors.append("blocked_mechanics must be an array.")

	var selected_candidates: Array = Array(manifest.get("selected_candidates", []))
	for index: int in range(selected_candidates.size()):
		var value: Variant = selected_candidates[index]
		if typeof(value) != TYPE_DICTIONARY:
			errors.append("selected_candidates[%d] must be an object." % index)
			continue
		_validate_selected_candidate(Dictionary(value), index, errors)
	return {"ok": errors.is_empty(), "errors": errors}

static func assert_valid_manifest(manifest: Dictionary) -> Dictionary:
	var result: Dictionary = validate_manifest(manifest)
	if not bool(result.get("ok", false)):
		return {
			"ok": false,
			"message": "Invalid Design Lab promotion manifest: %s" % "; ".join(Array(result.get("errors", []))),
			"errors": Array(result.get("errors", [])).duplicate()
		}
	return {"ok": true, "message": "", "errors": []}

static func _validate_selected_candidate(candidate: Dictionary, index: int, errors: Array[String]) -> void:
	for key: String in ["card_id", "variant_id", "owner", "role", "classification"]:
		if str(candidate.get(key, "")).strip_edges() == "":
			errors.append("selected_candidates[%d].%s is required." % [index, key])
	if not PROMOTABLE_CLASSIFICATIONS.has(str(candidate.get("classification", ""))):
		errors.append("selected_candidates[%d].classification must be recommended or viable." % index)
	if typeof(candidate.get("numbers", {})) != TYPE_DICTIONARY:
		errors.append("selected_candidates[%d].numbers must be an object." % index)
	if typeof(candidate.get("suggested_diffs", [])) != TYPE_ARRAY:
		errors.append("selected_candidates[%d].suggested_diffs must be an array." % index)
	if typeof(candidate.get("required_validations", [])) != TYPE_ARRAY:
		errors.append("selected_candidates[%d].required_validations must be an array." % index)
		return
	var validations: Array = Array(candidate.get("required_validations", []))
	var joined: String = _joined_strings(validations)
	for needle: String in REQUIRED_VALIDATION_NEEDLES:
		if not joined.contains(needle):
			errors.append("selected_candidates[%d].required_validations must include %s." % [index, needle])

static func _joined_strings(values: Array) -> String:
	var items: Array[String] = []
	for value: Variant in values:
		items.append(str(value))
	return "\n".join(items)
