class_name DraxosAppShellActionRouter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

const CATEGORY_UNKNOWN := "unknown"
const CATEGORY_SESSION := "session"
const CATEGORY_BATTLE := "battle"
const CATEGORY_ARENA := "arena"
const CATEGORY_BASE := "base"
const CATEGORY_PREPARATION := "preparation"
const CATEGORY_SOCIAL := "social"
const CATEGORY_COMPETITION := "competition"
const CATEGORY_SHOP := "shop"
const CATEGORY_MODE := "mode"

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
		"scope_id": scope_for_action(action, context),
		"mutation_endpoint": mutation_endpoint_for_action(action),
		"requires_idempotent_retry": mutation_endpoint_for_action(action) != "",
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
	if AppShellActionContractScript.is_open_mode_shell(action):
		return CATEGORY_MODE
	if _is_arena_action(action):
		return CATEGORY_ARENA
	if _is_battle_action(action):
		return CATEGORY_BATTLE
	if _is_session_action(action):
		return CATEGORY_SESSION
	if _is_social_action(action):
		return CATEGORY_SOCIAL
	if _is_competition_action(action):
		return CATEGORY_COMPETITION
	return CATEGORY_UNKNOWN

static func scope_for_action(action_id: String, context: Dictionary = {}) -> String:
	var action := normalize_action(action_id)
	var save_type := str(context.get("save_type", "normal")).strip_edges()
	if save_type == "":
		save_type = "normal"
	if AppShellActionContractScript.is_open_mode_shell(action):
		var mode_id := AppShellActionContractScript.action_value(action)
		if mode_id == "":
			mode_id = "placeholder"
		return "mode:%s:%s" % [mode_id, save_type]
	var category := category_for_action(action)
	match category:
		CATEGORY_ARENA:
			return "arena:%s" % save_type
		CATEGORY_BATTLE:
			return "battle:%s" % save_type
		CATEGORY_BASE:
			return "base:%s" % save_type
		CATEGORY_PREPARATION:
			return "build:%s" % save_type
		CATEGORY_SOCIAL:
			return "social:%s" % save_type
		CATEGORY_SHOP:
			return "monetization:%s" % save_type
		CATEGORY_COMPETITION:
			return "competition:%s" % save_type
		CATEGORY_SESSION:
			return "session:%s" % save_type
		_:
			return "app"

static func mutation_endpoint_for_action(action_id: String) -> String:
	var action := normalize_action(action_id)
	if action == AppShellActionContractScript.ACTION_REQUEST_BATTLE:
		return "battle/request"
	if action == AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL \
			or action == AppShellActionContractScript.ACTION_ARENA_START_EARLY \
			or AppShellActionContractScript.is_arena_start(action):
		return "arena/pve/start"
	if action == AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL:
		return "arena/pve/duel/request"
	if AppShellActionContractScript.is_arena_choose_buff(action):
		return "arena/pve/buff/select"
	if action == AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT:
		return "arena/pve/abandon"
	if action == AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY:
		return "arena/pve/claim"
	if action == AppShellActionContractScript.ACTION_UPGRADE_NUCLEO or AppShellActionContractScript.is_upgrade_base_structure(action):
		return "base/upgrade"
	if action == AppShellActionContractScript.ACTION_CRUSH_BONES:
		return "crafting/crush-bones"
	if action == AppShellActionContractScript.ACTION_CRAFT_HEALTH_POTION:
		return "crafting/craft"
	if AppShellActionContractScript.is_build_equip_action(action):
		return "build/equip"
	if AppShellActionContractScript.is_enable_spell_behavior(action) or AppShellActionContractScript.is_disable_spell_behavior(action):
		return "build/spell-behavior"
	if action == AppShellActionContractScript.ACTION_EQUIP_HEALTH_POTION or action == AppShellActionContractScript.ACTION_UNEQUIP_POTION or AppShellActionContractScript.is_equip_potion(action):
		return "build/potion/equip"
	if action == AppShellActionContractScript.ACTION_ENABLE_POTION_DEFAULT or action == AppShellActionContractScript.ACTION_DISABLE_POTION:
		return "build/potion-behavior"
	if action == AppShellActionContractScript.ACTION_ADD_FRIEND:
		return "social/friends/add"
	if action == AppShellActionContractScript.ACTION_CREATE_GUILD:
		return "social/guild/create"
	if action == AppShellActionContractScript.ACTION_JOIN_GUILD:
		return "social/guild/join"
	if action == AppShellActionContractScript.ACTION_SEND_GUILD_CHAT:
		return "social/chat/send"
	if AppShellActionContractScript.is_shop_purchase(action) or action == AppShellActionContractScript.ACTION_BUY_PREMIUM_ALPHA or action == AppShellActionContractScript.ACTION_GRANT_DIAMOND_ALPHA:
		return "monetization/alpha-purchase"
	if AppShellActionContractScript.is_claim_reward(action) or action == AppShellActionContractScript.ACTION_CLAIM_DAILY_REWARD:
		return "monetization/rewards/claim"
	if action == AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE:
		return "account/saves/reset"
	return ""

static func _is_base_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_SHOW_BASE,
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
		or AppShellActionContractScript.is_disable_spell_behavior(action_id) \
		or AppShellActionContractScript.is_equip_potion(action_id)

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

static func _is_arena_action(action_id: String) -> bool:
	return action_id in [
		AppShellActionContractScript.ACTION_OPEN_ARENA,
		AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL,
		AppShellActionContractScript.ACTION_ARENA_START_EARLY,
		AppShellActionContractScript.ACTION_ARENA_LOCK_LOADOUT,
		AppShellActionContractScript.ACTION_ARENA_RESUME_ATTEMPT,
		AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL,
		AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT,
		AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY,
	] or AppShellActionContractScript.is_arena_start(action_id) \
		or AppShellActionContractScript.is_arena_choose_buff(action_id)

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
