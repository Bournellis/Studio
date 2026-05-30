class_name DraxosAppShellActionRouter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

const CATEGORY_UNKNOWN := "unknown"
const CATEGORY_SESSION := "session"
const CATEGORY_BATTLE := "battle"
const CATEGORY_BASE := "base"
const CATEGORY_PREPARATION := "preparation"
const CATEGORY_SOCIAL := "social"
const CATEGORY_COMPETITION := "competition"
const CATEGORY_SHOP := "shop"

static func normalize_action(action_id: String) -> String:
	return action_id.strip_edges()

static func can_route(action_id: String) -> bool:
	var action := normalize_action(action_id)
	return action != "" and category_for_action(action) != CATEGORY_UNKNOWN

static func route_action(action_id: String, context: Dictionary = {}) -> Dictionary:
	var action := normalize_action(action_id)
	return {
		"action_id": action,
		"category": category_for_action(action),
		"value": AppShellActionContractScript.action_value(action),
		"secondary_value": AppShellActionContractScript.action_value_at(action, 2),
		"payload": action_payload(action, context),
		"blocked_by_update": update_gate_blocks_action(action, context),
		"allowed_during_replay": AppShellActionContractScript.is_allowed_during_replay(action),
		"read_only_battle": _is_read_only_battle_action(action),
		"build_equip": AppShellActionContractScript.is_build_equip_action(action),
	}

static func action_payload(action_id: String, context: Dictionary = {}) -> Dictionary:
	return AppShellActionContractScript.action_payload(
		normalize_action(action_id),
		str(context.get("screen", "")),
		str(context.get("save_type", "")),
		bool(context.get("has_account", false)),
		bool(context.get("offline", false))
	)

static func update_gate_blocks_action(action_id: String, context: Dictionary = {}) -> bool:
	var update_gate := _dictionary_or_empty(context.get("update_gate", {}))
	return AppShellActionContractScript.update_gate_blocks_action(
		normalize_action(action_id),
		update_gate,
		bool(context.get("replay_running", false))
	)

static func category_for_action(action_id: String) -> String:
	var action := normalize_action(action_id)
	if action == "":
		return CATEGORY_UNKNOWN
	if _is_base_action(action):
		return CATEGORY_BASE
	if _is_preparation_action(action):
		return CATEGORY_PREPARATION
	if _is_shop_action(action):
		return CATEGORY_SHOP
	if _is_battle_action(action):
		return CATEGORY_BATTLE
	if _is_session_action(action):
		return CATEGORY_SESSION
	if _is_social_action(action):
		return CATEGORY_SOCIAL
	if _is_competition_action(action):
		return CATEGORY_COMPETITION
	return CATEGORY_UNKNOWN

static func _is_base_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_SHOW_BASE,
		AppShellActionContractScript.ACTION_COLLECT_BASE,
		AppShellActionContractScript.ACTION_BUY_ENERGY_PACK_ALPHA,
		AppShellActionContractScript.ACTION_UPGRADE_NUCLEO,
		AppShellActionContractScript.ACTION_SHOW_CRAFTING,
		AppShellActionContractScript.ACTION_CRUSH_BONES,
		AppShellActionContractScript.ACTION_CRAFT_HEALTH_POTION,
	] or AppShellActionContractScript.is_select_base_structure(action_id) \
		or AppShellActionContractScript.is_upgrade_base_structure(action_id)

static func _is_preparation_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_SHOW_PREPARATION,
		AppShellActionContractScript.ACTION_EQUIP_HEALTH_POTION,
		AppShellActionContractScript.ACTION_UNEQUIP_POTION,
		AppShellActionContractScript.ACTION_ENABLE_POTION_DEFAULT,
		AppShellActionContractScript.ACTION_DISABLE_POTION,
	] or AppShellActionContractScript.is_build_equip_action(action_id) \
		or AppShellActionContractScript.is_enable_spell_behavior(action_id) \
		or AppShellActionContractScript.is_disable_spell_behavior(action_id)

static func _is_shop_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_SHOW_SHOP,
		AppShellActionContractScript.ACTION_BUY_PREMIUM_ALPHA,
		AppShellActionContractScript.ACTION_GRANT_DIAMOND_ALPHA,
		AppShellActionContractScript.ACTION_CLAIM_DAILY_REWARD,
	] or AppShellActionContractScript.is_shop_purchase(action_id) \
		or AppShellActionContractScript.is_claim_reward(action_id)

static func _is_battle_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_REQUEST_BATTLE,
		AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE,
		AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY,
		AppShellActionContractScript.ACTION_SKIP_REPLAY,
		AppShellActionContractScript.ACTION_RETURN_REFUGE,
		AppShellActionContractScript.ACTION_REPLAY_LATEST,
		AppShellActionContractScript.ACTION_SHOW_CURRENT_BATTLE_LOGS,
		AppShellActionContractScript.ACTION_RETURN_BATTLE_SUMMARY,
	] or AppShellActionContractScript.is_battle_replay(action_id)

static func _is_session_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_ENTER_GUEST,
		AppShellActionContractScript.ACTION_ENTER_REFUGE,
		AppShellActionContractScript.ACTION_OPEN_CREATE_ACCOUNT,
		AppShellActionContractScript.ACTION_CHECK_UPDATE,
		AppShellActionContractScript.ACTION_EMAIL_SIGN_UP,
		AppShellActionContractScript.ACTION_EMAIL_SIGN_IN,
		AppShellActionContractScript.ACTION_REFRESH_SESSION,
		AppShellActionContractScript.ACTION_RESET_SESSION,
		AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE,
		AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL,
		AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB,
		AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB,
		AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB,
	]

static func _is_social_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_SHOW_SOCIAL,
		AppShellActionContractScript.ACTION_COPY_SOCIAL_USERNAME,
		AppShellActionContractScript.ACTION_ADD_FRIEND,
		AppShellActionContractScript.ACTION_CREATE_GUILD,
		AppShellActionContractScript.ACTION_JOIN_GUILD,
		AppShellActionContractScript.ACTION_SEND_GUILD_CHAT,
	]

static func _is_competition_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_SHOW_MATCHMAKING,
		AppShellActionContractScript.ACTION_SHOW_RANKING,
	]

static func _is_read_only_battle_action(action_id: String) -> bool:
	return action_id == AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY \
		or action_id == AppShellActionContractScript.ACTION_REPLAY_LATEST \
		or action_id == AppShellActionContractScript.ACTION_SHOW_CURRENT_BATTLE_LOGS \
		or action_id == AppShellActionContractScript.ACTION_RETURN_BATTLE_SUMMARY \
		or AppShellActionContractScript.is_battle_replay(action_id)

static func _dictionary_or_empty(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
