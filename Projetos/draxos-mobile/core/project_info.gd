class_name ProjectInfo
extends RefCounted

const PROJECT_NAME := "DraxosMobile"
const GODOT_VERSION := "4.6.2-stable"
const GUT_VERSION := "9.6.0"
const ACTIVE_TRACK := "Track 03 - Internal Alpha v0"
const RELEASE_CHANNEL := "internal_alpha"
const APP_VERSION := "0.0.19-alpha.0"
const APP_VERSION_CODE := 19
const MANIFEST_SCHEMA_VERSION := "internal_alpha_manifest_v1"
const MVP_MODE := "MVP_ONLY"
const FIRST_SLICE_MODE := "FIRST_SLICE_SIM"
const DEFAULT_BATTLE_MODE := FIRST_SLICE_MODE

static func boot_actions() -> PackedStringArray:
	return PackedStringArray([
		"Criar conta",
		"Entrar com email",
		"Entrar como guest dev",
		"Sincronizar sessao",
		"Checar update",
		"Resetar sessao local",
		"Resetar save ativo",
		"Solicitar batalha",
		"Ver resultado",
		"Ver base",
		"Acompanhar producao do Refugio",
		"Evoluir predio do Refugio",
		"Ver social",
		"Adicionar amigo",
		"Criar guilda",
		"Entrar guilda",
		"Enviar chat guilda",
		"Preview matchmaking",
		"Ver ranking",
		"Ver loja",
		"Comprar Energia na Loja",
		"Comprar premium",
		"Recompensa diaria"
	])

static func unchecked_update_status(manifest_url: String = "") -> Dictionary:
	return {
		"checked": false,
		"status": "unchecked",
		"block_online": false,
		"update_available": false,
		"manifest_url": manifest_url,
		"summary": "Update ainda nao verificado.",
		"detail": "O jogo vai checar o manifest remoto antes do teste fechado.",
		"manifest": {},
	}

static func update_status_error(code: String, message: String, manifest_url: String = "") -> Dictionary:
	return {
		"checked": true,
		"status": "unavailable",
		"block_online": false,
		"update_available": false,
		"manifest_url": manifest_url,
		"summary": "Nao foi possivel checar updates.",
		"detail": "%s: %s" % [code, message],
		"manifest": {},
	}

static func update_status_from_manifest(payload: Dictionary, manifest_url: String = "") -> Dictionary:
	var manifest := _manifest_payload(payload)
	var schema_version := str(manifest.get("schema_version", ""))
	var channel := str(manifest.get("channel", ""))
	if schema_version != MANIFEST_SCHEMA_VERSION:
		return update_status_error("INVALID_MANIFEST", "Manifest de update com schema desconhecido.", manifest_url)
	if channel != RELEASE_CHANNEL:
		return update_status_error("INVALID_CHANNEL", "Manifest de outro canal: %s." % channel, manifest_url)

	var latest_version := str(manifest.get("latest_version", APP_VERSION))
	var minimum_version := str(manifest.get("minimum_supported_version", APP_VERSION))
	var latest_code := int(manifest.get("latest_version_code", 0))
	var minimum_code := int(manifest.get("minimum_supported_version_code", 0))
	var requires_save_reset := bool(manifest.get("requires_save_reset", false))
	var status := "current"
	var block_online := false
	var update_available := false

	if _is_remote_version_newer(minimum_version, minimum_code):
		status = "required"
		block_online = true
		update_available = true
	elif _is_remote_version_newer(latest_version, latest_code):
		status = "recommended"
		update_available = true

	return {
		"checked": true,
		"status": status,
		"block_online": block_online,
		"update_available": update_available,
		"manifest_url": manifest_url,
		"summary": _update_summary(status, latest_version, minimum_version),
		"detail": _update_detail(status, manifest, requires_save_reset),
		"latest_version": latest_version,
		"minimum_supported_version": minimum_version,
		"requires_save_reset": requires_save_reset,
		"manifest": manifest,
	}

static func compare_versions(left: String, right: String) -> int:
	var left_parts := _version_parts(left)
	var right_parts := _version_parts(right)
	var size: int = int(max(left_parts.size(), right_parts.size()))
	for index: int in size:
		var left_value: int = int(left_parts[index]) if index < left_parts.size() else 0
		var right_value: int = int(right_parts[index]) if index < right_parts.size() else 0
		if left_value < right_value:
			return -1
		if left_value > right_value:
			return 1
	return 0

static func current_platform_key() -> String:
	if OS.has_feature("web"):
		return "web"
	if OS.get_name() == "Android":
		return "android"
	return "pc_windows"

static func _manifest_payload(payload: Dictionary) -> Dictionary:
	if payload.get("manifest", null) is Dictionary:
		return Dictionary(payload.get("manifest", {}))
	return payload

static func _is_remote_version_newer(remote_version: String, remote_code: int) -> bool:
	if remote_code > 0:
		return APP_VERSION_CODE < remote_code
	return compare_versions(APP_VERSION, remote_version) < 0

static func _update_summary(status: String, latest_version: String, minimum_version: String) -> String:
	match status:
		"required":
			return "Update obrigatorio: minimo %s, build atual %s." % [minimum_version, APP_VERSION]
		"recommended":
			return "Update disponivel: %s. Build atual: %s." % [latest_version, APP_VERSION]
	return "Build atualizada: %s." % APP_VERSION

static func _update_detail(status: String, manifest: Dictionary, requires_save_reset: bool) -> String:
	var notes := _string_array(manifest.get("notes", []))
	var note := notes[0] if not notes.is_empty() else "Sem notas de release."
	var reset_text := " Pode exigir reset de save." if requires_save_reset else ""
	match status:
		"required":
			return "Esta versao nao pode executar acoes online. Baixe a build nova pelo portal.%s %s" % [reset_text, note]
		"recommended":
			return "Existe build mais nova no portal, mas esta versao ainda pode jogar.%s %s" % [reset_text, note]
	return "Voce esta na versao esperada para este canal. %s" % note

static func _version_parts(version: String) -> Array[int]:
	var result: Array[int] = []
	var current := ""
	for index in version.length():
		var code := version.unicode_at(index)
		if code >= 48 and code <= 57:
			current += version.substr(index, 1)
		elif current != "":
			result.append(int(current))
			current = ""
	if current != "":
		result.append(int(current))
	return result

static func _string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is Array:
		for item in Array(value):
			result.append(str(item))
	return result
