class_name DraxosAppShellRouteContract
extends RefCounted

const ROUTE_REFUGE_HOME := "refuge_home"
const ROUTE_ACCOUNT := "account"
const ROUTE_BASE := "base"
const ROUTE_SOCIAL := "social"
const ROUTE_COMPETITION := "competition"
const ROUTE_SHOP := "shop"
const ROUTE_BATTLE_ENTRY := "battle_entry"
const ROUTE_BATTLE_RUNNING := "battle_running"
const ROUTE_BATTLE_SUMMARY := "battle_summary"

const _ALIASES := {
	"hub": ROUTE_REFUGE_HOME,
	"refugio": ROUTE_REFUGE_HOME,
	"refuge": ROUTE_REFUGE_HOME,
	"conta": ROUTE_ACCOUNT,
	"perfil": ROUTE_ACCOUNT,
	"profile": ROUTE_ACCOUNT,
	"battle": ROUTE_BATTLE_ENTRY,
	"monetization": ROUTE_SHOP,
}

const _TITLES := {
	ROUTE_REFUGE_HOME: "Refugio",
	ROUTE_ACCOUNT: "Conta",
	ROUTE_BASE: "Base",
	ROUTE_SOCIAL: "Social",
	ROUTE_COMPETITION: "Competicao",
	ROUTE_SHOP: "Loja",
	ROUTE_BATTLE_ENTRY: "Batalha",
	ROUTE_BATTLE_RUNNING: "Batalha",
	ROUTE_BATTLE_SUMMARY: "Resumo",
}

static func normalize(route_id: String) -> String:
	var candidate := route_id.strip_edges()
	if candidate == "":
		return ROUTE_REFUGE_HOME
	if _ALIASES.has(candidate):
		return str(_ALIASES[candidate])
	return candidate

static func supports_back(route_id: String) -> bool:
	return normalize(route_id) != ROUTE_REFUGE_HOME

static func prefers_landscape(route_id: String) -> bool:
	return normalize(route_id) == ROUTE_BATTLE_RUNNING

static func title_for(route_id: String) -> String:
	return str(_TITLES.get(normalize(route_id), "Refugio"))

static func push_route(history: Array[String], current_route: String, route_id: String, push_history: bool) -> String:
	var current := normalize(current_route)
	var target := normalize(route_id)
	if push_history and target != current:
		history.append(current)
	return target

static func pop_back_or_root(history: Array[String]) -> String:
	if history.is_empty():
		return ROUTE_REFUGE_HOME
	return normalize(str(history.pop_back()))

static func clear_for_root_return(history: Array[String]) -> String:
	history.clear()
	return ROUTE_REFUGE_HOME
