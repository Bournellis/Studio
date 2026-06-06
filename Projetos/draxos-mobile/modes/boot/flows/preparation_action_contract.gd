extends RefCounted

const NETWORK_ERROR_CODES := {
	"NETWORK_UNAVAILABLE": true,
	"REQUEST_NOT_STARTED": true,
	"CLIENT_MISCONFIGURED": true,
	"INVALID_JSON": true,
}

static func error_payload(result: Dictionary) -> Dictionary:
	var payload := as_dictionary(result.get("error", {}))
	if payload.is_empty():
		var body := as_dictionary(result.get("body", {}))
		payload = as_dictionary(body.get("error", {}))
	if payload.is_empty():
		payload = {
			"code": "REQUEST_FAILED",
			"message": "Acao nao concluida.",
		}
	return payload

static func error_message(code: String) -> String:
	match code.strip_edges():
		"UNAUTHENTICATED", "AUTH_REQUIRES_EMAIL":
			return "Entre com email ou use guest dev para preparar a batalha."
		"POTION_NOT_OWNED":
			return "Voce ainda nao tem essa pocao. Prepare uma na Fogueira do Bosque."
		"INVALID_POTION":
			return "Essa pocao ainda nao pode ser usada na preparacao."
		"INVALID_WEAPON", "INVALID_WEAPON_QUALITY":
			return "Esse Instrumento Ritual ainda nao pode ser usado na preparacao."
		"WEAPON_LOCKED":
			return "Esse Instrumento Ritual ainda esta bloqueado para seu nivel."
		"SPELL_NOT_EQUIPPED":
			return "Essa magia nao esta equipada para batalha."
		"INVALID_SPELL":
			return "Magia invalida para esta preparacao."
		"SPELL_LOCKED", "SPELL_SLOT_LOCKED":
			return "Essa habilidade ainda esta bloqueada para seu nivel."
		"DUPLICATE_SPELL":
			return "A mesma habilidade nao pode ocupar dois espacos."
		"INVALID_DOCTRINE":
			return "Doutrina invalida para esta preparacao."
		"DOCTRINE_LOCKED":
			return "Essa Doutrina ainda esta bloqueada para seu nivel."
		"INVALID_FAMILIAR":
			return "Familiar invalido para esta preparacao."
		"FAMILIAR_LOCKED":
			return "Esse Familiar ainda esta bloqueado para seu nivel."
		"BEHAVIOR_UPDATE_FAILED", "POTION_EQUIP_FAILED", "BUILD_EQUIP_FAILED", "POWER_UPDATE_FAILED":
			return "Nao foi possivel salvar essa escolha agora. Tente novamente."
		"BUILD_NOT_FOUND", "INVALID_SLOT", "INVALID_SPELL_SLOT", "INVALID_BEHAVIOR", "INVALID_BEHAVIOR_PERCENT", "INVALID_REQUEST_ID", "INVALID_SAVE_TYPE":
			return "Preparacao indisponivel agora. Tente novamente em instantes."
		"NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED", "INVALID_JSON":
			return "Sem conexao para carregar a preparacao. Verifique a internet e tente de novo."
		_:
			return "Nao foi possivel atualizar a preparacao. Tente novamente."

static func is_network_error(code: String) -> bool:
	return bool(NETWORK_ERROR_CODES.get(code.strip_edges(), false))

static func default_potion_behavior(item_id: String = "pocao_vida") -> Dictionary:
	match item_id.strip_edges():
		"pocao_foco":
			return {
				"enabled": true,
				"hp": {"mode": "ignore", "percent": 0},
				"mana": {"mode": "below", "percent": 35},
			}
		"pocao_resguardo":
			return {
				"enabled": true,
				"hp": {"mode": "below", "percent": 55},
				"mana": {"mode": "ignore", "percent": 0},
			}
		_:
			return {
				"enabled": true,
				"hp": {"mode": "below", "percent": 40},
				"mana": {"mode": "ignore", "percent": 0},
			}

static func default_spell_behavior(enabled: bool) -> Dictionary:
	return {
		"enabled": enabled,
		"hp": {"mode": "ignore", "percent": 0},
		"mana": {"mode": "ignore", "percent": 0},
	}

static func as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
