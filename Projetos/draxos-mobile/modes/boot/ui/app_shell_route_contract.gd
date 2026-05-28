class_name DraxosAppShellRouteContract
extends RefCounted

const ROUTE_ENTRY := "entry"
const ROUTE_REFUGE := "refuge"
const ROUTE_BASE_MANAGEMENT := "base_management"
const ROUTE_REFUGE_HOME := "refuge_home"
const ROUTE_ACCOUNT := "account"
const ROUTE_BASE := ROUTE_BASE_MANAGEMENT
const ROUTE_SOCIAL := "social"
const ROUTE_COMPETITION := "competition"
const ROUTE_SHOP := "shop"
const ROUTE_BATTLE_ENTRY := "battle_entry"
const ROUTE_BATTLE_RUNNING := "battle_running"
const ROUTE_BATTLE_SUMMARY := "battle_summary"

const ACTION_REQUEST_BATTLE := "request_battle"
const ACTION_SHOW_BATTLE_HISTORY := "show_battle_history"
const ACTION_BATTLE_REPLAY_PREFIX := "battle_replay:"
const ACTION_SKIP_REPLAY := "skip_battle_replay"
const ACTION_REPLAY_LATEST := "replay_latest_battle"

const _ALIASES := {
	"hub": ROUTE_ENTRY,
	"home": ROUTE_ENTRY,
	"refuge_home": ROUTE_ENTRY,
	"entrada": ROUTE_ENTRY,
	"login": ROUTE_ENTRY,
	"refugio": ROUTE_REFUGE,
	"refuge": ROUTE_REFUGE,
	"base": ROUTE_BASE_MANAGEMENT,
	"base_management": ROUTE_BASE_MANAGEMENT,
	"conta": ROUTE_ACCOUNT,
	"perfil": ROUTE_ACCOUNT,
	"profile": ROUTE_ACCOUNT,
	"battle": ROUTE_BATTLE_ENTRY,
	"monetization": ROUTE_SHOP,
}

const _TITLES := {
	ROUTE_ENTRY: "Entrada",
	ROUTE_REFUGE: "Refugio",
	ROUTE_REFUGE_HOME: "Entrada",
	ROUTE_ACCOUNT: "Conta",
	ROUTE_BASE_MANAGEMENT: "Base",
	ROUTE_SOCIAL: "Social",
	ROUTE_COMPETITION: "Competicao",
	ROUTE_SHOP: "Loja",
	ROUTE_BATTLE_ENTRY: "Batalha",
	ROUTE_BATTLE_RUNNING: "Batalha",
	ROUTE_BATTLE_SUMMARY: "Resumo",
}

const _BATTLE_MODE_ROUTES := {
	ROUTE_BATTLE_ENTRY: true,
	ROUTE_BATTLE_RUNNING: true,
	ROUTE_BATTLE_SUMMARY: true,
}

const _FULLSCREEN_GAMEPLAY_ROUTES := {
	ROUTE_BATTLE_RUNNING: true,
	ROUTE_BATTLE_SUMMARY: true,
}

const _IMMERSIVE_ROUTES := {
	ROUTE_ENTRY: true,
	ROUTE_REFUGE: true,
}

static func normalize(route_id: String) -> String:
	var candidate := route_id.strip_edges()
	if candidate == "":
		return ROUTE_ENTRY
	if _ALIASES.has(candidate):
		return str(_ALIASES[candidate])
	return candidate

static func supports_back(route_id: String) -> bool:
	return normalize(route_id) != ROUTE_ENTRY

static func is_first_screen(route_id: String) -> bool:
	return normalize(route_id) == ROUTE_ENTRY

static func is_refuge_home(route_id: String) -> bool:
	return normalize(route_id) == ROUTE_REFUGE

static func uses_immersive_layer(route_id: String) -> bool:
	return bool(_IMMERSIVE_ROUTES.get(normalize(route_id), false))

static func prefers_landscape(route_id: String) -> bool:
	return false

static func prefers_portrait(route_id: String = "") -> bool:
	return true

static func is_battle_mode(route_id: String) -> bool:
	return bool(_BATTLE_MODE_ROUTES.get(normalize(route_id), false))

static func is_fullscreen_gameplay(route_id: String) -> bool:
	return bool(_FULLSCREEN_GAMEPLAY_ROUTES.get(normalize(route_id), false))

static func shows_app_chrome(route_id: String) -> bool:
	return not uses_immersive_layer(route_id) and not is_fullscreen_gameplay(route_id)

static func summary_route_for(route_id: String) -> String:
	if is_battle_mode(route_id):
		return ROUTE_BATTLE_SUMMARY
	return normalize(route_id)

static func is_safe_replay_action(action_id: String) -> bool:
	return action_id.strip_edges() == ACTION_SKIP_REPLAY

static func is_read_only_battle_action(action_id: String) -> bool:
	var candidate := action_id.strip_edges()
	return candidate == ACTION_SHOW_BATTLE_HISTORY \
		or candidate == ACTION_REPLAY_LATEST \
		or candidate.begins_with(ACTION_BATTLE_REPLAY_PREFIX)

static func title_for(route_id: String) -> String:
	return str(_TITLES.get(normalize(route_id), "Entrada"))

static func push_route(history: Array[String], current_route: String, route_id: String, push_history: bool) -> String:
	var current := normalize(current_route)
	var target := normalize(route_id)
	if push_history and target != current:
		history.append(current)
	return target

static func pop_back_or_root(history: Array[String]) -> String:
	if history.is_empty():
		return ROUTE_ENTRY
	return normalize(str(history.pop_back()))

static func clear_for_root_return(history: Array[String]) -> String:
	history.clear()
	return ROUTE_ENTRY

static func clear_for_refuge_return(history: Array[String]) -> String:
	history.clear()
	return ROUTE_REFUGE
