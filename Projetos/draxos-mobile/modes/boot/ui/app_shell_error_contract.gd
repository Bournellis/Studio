class_name DraxosAppShellErrorContract
extends RefCounted

const NETWORK_ERROR_CODES := {
	"NETWORK_UNAVAILABLE": true,
	"REQUEST_NOT_STARTED": true,
	"CLIENT_MISCONFIGURED": true,
	"INVALID_JSON": true,
}

const FRIENDLY_MESSAGES := {
	"PROGRESSION_LAB_SAVE_PENDING": "Save Progression Lab selecionado. Acoes online serao ligadas ao Supabase local na proxima subetapa.",
	"PROGRESSION_LAB_LOCAL_ONLY": "Save local-only do Progression Lab. Use o seeder com Supabase local para testar acoes online.",
	"PROGRESSION_LAB_SAVE_REQUIRED": "Selecione o save Progression Lab antes de aplicar um perfil do laboratorio.",
	"PROGRESSION_LAB_SAVE_NOT_FOUND": "Perfil/milestone do Progression Lab nao encontrado no catalogo do servidor.",
	"INVALID_PROGRESSION_LAB_SAVE": "O servidor recusou o estado gerado do Progression Lab.",
	"NETWORK_UNAVAILABLE": "Supabase local indisponivel. Confirme Docker/Supabase local em http://127.0.0.1:54321 e tente sincronizar.",
	"REQUEST_NOT_STARTED": "Requisicao nao iniciou. Verifique URL/chave local do Supabase nas Project Settings.",
	"CLIENT_MISCONFIGURED": "Cliente Supabase sem chave publishable configurada.",
	"AUTH_REQUIRES_EMAIL": "Esta acao exige conta por email/senha. Use Criar conta alpha ou Entrar com email.",
	"AUTH_NOT_ANONYMOUS": "Esta rota e apenas para guest dev. Use o fluxo de email/senha para a conta alpha.",
	"INVALID_LOGIN_CREDENTIALS": "Email ou senha invalidos. Confira os dados e tente novamente.",
	"INVALID_USERNAME": "Username invalido. Use 3 a 24 caracteres: letras minusculas, numeros ou underscore.",
	"USERNAME_TAKEN": "Este username ja esta em uso. Escolha outro para a conta alpha.",
	"ACCOUNT_ALREADY_CREATED": "Esta conta ja possui save criado. Sincronize a sessao para carregar o estado.",
	"INSUFFICIENT_RESOURCES": "Recursos insuficientes para esta acao. No Refugio, confira Energia, custo e loja alpha.",
	"CONSTRUCTION_QUEUE_FULL": "Fila de construcao cheia. Aguarde o upgrade ativo terminar antes de iniciar outro.",
	"STRUCTURE_ALREADY_UPGRADING": "Este predio ja esta em upgrade.",
	"LEVEL_CAP_REACHED": "O level do jogador limita o proximo upgrade deste predio.",
	"INVALID_STRUCTURE": "Predio do Refugio nao encontrado no contrato atual.",
	"USER_NOT_FOUND": "Usuario nao encontrado. Confirme o username do outro jogador.",
	"INVALID_FRIEND": "Voce nao pode adicionar a propria conta como amigo.",
	"INVALID_GUILD_NAME": "Nome de guilda invalido. Use de 3 a 32 caracteres.",
	"GUILD_NOT_FOUND": "Guilda nao encontrada. Confira o nome exato com o outro jogador.",
	"GUILD_REQUIRED": "Entre em uma guilda antes de enviar mensagem no chat.",
	"GUILD_ALREADY_JOINED": "Esta conta ja participa de uma guilda.",
	"GUILD_FULL": "Esta guilda esta cheia.",
	"EMPTY_MESSAGE": "Digite uma mensagem antes de enviar.",
	"CHAT_RATE_LIMITED": "Aguarde alguns segundos antes de enviar outra mensagem.",
	"PRODUCT_NOT_FOUND": "Produto alpha nao encontrado no servidor.",
	"INVALID_PRODUCT": "Produto alpha nao encontrado no catalogo atual.",
	"DAILY_REDEEM_ALREADY_CLAIMED": "Este redeem diario ja foi resgatado hoje neste save.",
	"ALREADY_OWNED": "Este produto ja esta ativo neste save.",
	"REWARD_NOT_FOUND": "Recompensa alpha nao encontrada no servidor.",
	"UNAUTHENTICATED": "Sessao expirada. Entre com email novamente ou use guest dev.",
}

static func extract_error(result: Dictionary) -> Dictionary:
	var error_payload := _as_dictionary(result.get("error", {}))
	if error_payload.is_empty():
		var body := _as_dictionary(result.get("body", {}))
		error_payload = _as_dictionary(body.get("error", {}))
	if error_payload.is_empty():
		error_payload = {
			"code": "REQUEST_FAILED",
			"message": "Acao nao concluida.",
		}
	return error_payload

static func friendly_message(code: String, message: String) -> String:
	var normalized_code := code.strip_edges()
	if FRIENDLY_MESSAGES.has(normalized_code):
		return str(FRIENDLY_MESSAGES[normalized_code])
	return "%s: %s" % [normalized_code, message]

static func is_network_error(code: String) -> bool:
	return bool(NETWORK_ERROR_CODES.get(code.strip_edges(), false))

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
