class_name DraxosAppShellActionContract
extends RefCounted

const RouteContract := preload("res://modes/boot/ui/app_shell_route_contract.gd")

const ACTION_ENTER_GUEST := "enter_guest"
const ACTION_ENTER_REFUGE := "enter_refuge"
const ACTION_OPEN_CREATE_ACCOUNT := "open_create_account"
const ACTION_CHECK_UPDATE := "check_update"
const ACTION_EMAIL_SIGN_UP := "email_sign_up"
const ACTION_EMAIL_SIGN_IN := "email_sign_in"
const ACTION_REFRESH_SESSION := "refresh_session"
const ACTION_RESET_SESSION := "reset_session"
const ACTION_RESET_ACTIVE_SAVE := "reset_active_save"
const ACTION_SELECT_SAVE_NORMAL := "select_save_normal"
const ACTION_SELECT_SAVE_PROGRESSION_LAB := "select_save_progression_lab"
const ACTION_OPEN_BATTLE_LAB := "open_battle_lab"
const ACTION_OPEN_PROGRESSION_LAB := "open_progression_lab"
const ACTION_OPEN_ARENA := "open_arena"
const ACTION_ARENA_START_TUTORIAL := "arena_start_tutorial"
const ACTION_ARENA_START_EARLY := "arena_start_early"
const ACTION_ARENA_LOCK_LOADOUT := "arena_lock_loadout"
const ACTION_ARENA_RESUME_ATTEMPT := "arena_resume_attempt"
const ACTION_ARENA_RESOLVE_DUEL := "arena_resolve_duel"
const ACTION_ARENA_ABANDON_ATTEMPT := "arena_abandon_attempt"
const ACTION_ARENA_CLAIM_SUMMARY := "arena_claim_summary"
const ACTION_REQUEST_BATTLE := RouteContract.ACTION_REQUEST_BATTLE
const ACTION_SHOW_LATEST_BATTLE := "show_latest_battle"
const ACTION_SHOW_BATTLE_HISTORY := RouteContract.ACTION_SHOW_BATTLE_HISTORY
const ACTION_SKIP_REPLAY := RouteContract.ACTION_SKIP_REPLAY
const ACTION_RETURN_REFUGE := "return_refuge"
const ACTION_REPLAY_LATEST := RouteContract.ACTION_REPLAY_LATEST
const ACTION_SHOW_CURRENT_BATTLE_LOGS := RouteContract.ACTION_SHOW_CURRENT_BATTLE_LOGS
const ACTION_RETURN_BATTLE_SUMMARY := RouteContract.ACTION_RETURN_BATTLE_SUMMARY
const ACTION_SHOW_BASE := "show_base"
const ACTION_UPGRADE_NUCLEO := "upgrade_nucleo"
const ACTION_SHOW_CRAFTING := "show_crafting"
const ACTION_CRUSH_BONES := "crush_bones"
const ACTION_CRAFT_HEALTH_POTION := "craft_health_potion"
const ACTION_SHOW_PREPARATION := "show_preparation"
const ACTION_EQUIP_HEALTH_POTION := "equip_health_potion"
const ACTION_UNEQUIP_POTION := "unequip_potion"
const ACTION_ENABLE_POTION_DEFAULT := "enable_potion_default"
const ACTION_DISABLE_POTION := "disable_potion"
const ACTION_SHOW_SOCIAL := "show_social"
const ACTION_COPY_SOCIAL_USERNAME := "copy_social_username"
const ACTION_ADD_FRIEND := "add_friend"
const ACTION_CREATE_GUILD := "create_guild"
const ACTION_JOIN_GUILD := "join_guild"
const ACTION_SEND_GUILD_CHAT := "send_guild_chat"
const ACTION_SHOW_MATCHMAKING := "show_matchmaking"
const ACTION_SHOW_RANKING := "show_ranking"
const ACTION_SHOW_SHOP := "show_shop"
const ACTION_BUY_PREMIUM_ALPHA := "buy_premium_alpha"
const ACTION_GRANT_DIAMOND_ALPHA := "grant_diamond_alpha"
const ACTION_CLAIM_DAILY_REWARD := "claim_daily_reward"
const ACTION_OPEN_MODE_SHELL := "open_mode_shell"

const PREFIX_SELECT_BASE_STRUCTURE := "select_base_structure:"
const PREFIX_UPGRADE_BASE_STRUCTURE := "upgrade_base_structure:"
const PREFIX_SHOP_PURCHASE := "shop_purchase:"
const PREFIX_CLAIM_REWARD := "claim_reward:"
const PREFIX_EQUIP_INSTRUMENT := "equip_instrument:"
const PREFIX_EQUIP_SPELL_POSITION := "equip_spell_position:"
const PREFIX_REMOVE_SPELL_POSITION := "remove_spell_position:"
const PREFIX_EQUIP_DOCTRINE := "equip_doctrine:"
const PREFIX_REMOVE_DOCTRINE := "remove_doctrine:"
const PREFIX_EQUIP_FAMILIAR := "equip_familiar:"
const PREFIX_REMOVE_FAMILIAR := "remove_familiar:"
const PREFIX_ENABLE_SPELL_BEHAVIOR := "enable_spell_behavior:"
const PREFIX_DISABLE_SPELL_BEHAVIOR := "disable_spell_behavior:"
const PREFIX_ARENA_START := "arena_start:"
const PREFIX_ARENA_CHOOSE_BUFF := "arena_choose_buff:"
const PREFIX_BATTLE_REPLAY := RouteContract.ACTION_BATTLE_REPLAY_PREFIX
const PREFIX_OPEN_MODE_SHELL := "open_mode_shell:"
const PREFIX_MODE_DISABLED := "mode_disabled:"

const PRODUCT_ALPHA_ENERGY_PACK := "alpha_energy_pack_small"
const PRODUCT_ALPHA_BATTLE_PASS_PREMIUM := "alpha_battle_pass_premium"
const PRODUCT_ALPHA_REDEEM_MEDIUM := "alpha_redeem_medium"
const REWARD_DAILY_COLLECT_BASE := "daily_collect_base"
const STRUCTURE_NUCLEO_ENERGIA := "nucleo_energia"
const RECIPE_HEALTH_POTION := "craft_pocao_vida"
const ITEM_HEALTH_POTION := "pocao_vida"

const _UPDATE_GATE_ALLOWED_ACTIONS := {
	ACTION_CHECK_UPDATE: true,
	ACTION_RESET_SESSION: true,
	ACTION_SELECT_SAVE_NORMAL: true,
	ACTION_SELECT_SAVE_PROGRESSION_LAB: true,
	ACTION_OPEN_BATTLE_LAB: true,
	ACTION_OPEN_PROGRESSION_LAB: true,
	ACTION_SKIP_REPLAY: true,
	ACTION_RETURN_REFUGE: true,
	ACTION_REPLAY_LATEST: true,
}

static func action_payload(
	action_id: String,
	screen: String,
	save_type: String,
	has_account: bool,
	offline: bool
) -> Dictionary:
	return {
		"action_id": action_id,
		"screen": screen,
		"save_type": save_type,
		"has_account": has_account,
		"offline": offline,
	}

static func update_gate_blocks_action(action_id: String, update_gate: Dictionary, replay_running: bool) -> bool:
	if not bool(update_gate.get("block_online", false)):
		return false
	if replay_running and is_allowed_during_replay(action_id):
		return false
	if bool(_UPDATE_GATE_ALLOWED_ACTIONS.get(action_id.strip_edges(), false)):
		return false
	if is_open_mode_shell(action_id):
		return false
	if is_select_base_structure(action_id):
		return false
	return true

static func is_allowed_during_replay(action_id: String) -> bool:
	return RouteContract.is_safe_replay_action(action_id)

static func is_select_base_structure(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_SELECT_BASE_STRUCTURE)

static func is_upgrade_base_structure(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_UPGRADE_BASE_STRUCTURE)

static func is_shop_purchase(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_SHOP_PURCHASE)

static func is_claim_reward(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_CLAIM_REWARD)

static func is_equip_instrument(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_EQUIP_INSTRUMENT)

static func is_equip_spell_position(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_EQUIP_SPELL_POSITION)

static func is_remove_spell_position(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_REMOVE_SPELL_POSITION)

static func is_equip_doctrine(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_EQUIP_DOCTRINE)

static func is_remove_doctrine(action_id: String) -> bool:
	return action_id.strip_edges() == PREFIX_REMOVE_DOCTRINE

static func is_equip_familiar(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_EQUIP_FAMILIAR)

static func is_remove_familiar(action_id: String) -> bool:
	return action_id.strip_edges() == PREFIX_REMOVE_FAMILIAR

static func is_build_equip_action(action_id: String) -> bool:
	return (
		is_equip_instrument(action_id)
		or is_equip_spell_position(action_id)
		or is_remove_spell_position(action_id)
		or is_equip_doctrine(action_id)
		or is_remove_doctrine(action_id)
		or is_equip_familiar(action_id)
		or is_remove_familiar(action_id)
	)

static func is_enable_spell_behavior(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_ENABLE_SPELL_BEHAVIOR)

static func is_disable_spell_behavior(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_DISABLE_SPELL_BEHAVIOR)

static func is_arena_start(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_ARENA_START)

static func is_battle_replay(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_BATTLE_REPLAY)

static func is_arena_choose_buff(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_ARENA_CHOOSE_BUFF)

static func is_open_mode_shell(action_id: String) -> bool:
	var candidate := action_id.strip_edges()
	return candidate == ACTION_OPEN_MODE_SHELL or candidate.begins_with(PREFIX_OPEN_MODE_SHELL)

static func is_mode_disabled(action_id: String) -> bool:
	return action_id.strip_edges().begins_with(PREFIX_MODE_DISABLED)

static func select_base_structure_action(structure_id: String) -> String:
	return "%s%s" % [PREFIX_SELECT_BASE_STRUCTURE, structure_id.strip_edges()]

static func upgrade_base_structure_action(structure_id: String) -> String:
	return "%s%s" % [PREFIX_UPGRADE_BASE_STRUCTURE, structure_id.strip_edges()]

static func shop_purchase_action(product_id: String) -> String:
	return "%s%s" % [PREFIX_SHOP_PURCHASE, product_id.strip_edges()]

static func claim_reward_action(reward_id: String) -> String:
	return "%s%s" % [PREFIX_CLAIM_REWARD, reward_id.strip_edges()]

static func equip_instrument_action(instrument_id: String) -> String:
	return "%s%s" % [PREFIX_EQUIP_INSTRUMENT, instrument_id.strip_edges()]

static func equip_spell_position_action(position: int, spell_id: String) -> String:
	return "%s%d:%s" % [PREFIX_EQUIP_SPELL_POSITION, maxi(1, position), spell_id.strip_edges()]

static func remove_spell_position_action(position: int) -> String:
	return "%s%d" % [PREFIX_REMOVE_SPELL_POSITION, maxi(1, position)]

static func equip_doctrine_action(doctrine_id: String) -> String:
	return "%s%s" % [PREFIX_EQUIP_DOCTRINE, doctrine_id.strip_edges()]

static func remove_doctrine_action() -> String:
	return PREFIX_REMOVE_DOCTRINE

static func equip_familiar_action(familiar_id: String) -> String:
	return "%s%s" % [PREFIX_EQUIP_FAMILIAR, familiar_id.strip_edges()]

static func remove_familiar_action() -> String:
	return PREFIX_REMOVE_FAMILIAR

static func enable_spell_behavior_action(spell_id: String) -> String:
	return "%s%s" % [PREFIX_ENABLE_SPELL_BEHAVIOR, spell_id.strip_edges()]

static func disable_spell_behavior_action(spell_id: String) -> String:
	return "%s%s" % [PREFIX_DISABLE_SPELL_BEHAVIOR, spell_id.strip_edges()]

static func arena_start_action(arena_id: String, difficulty_id: String = "") -> String:
	var normalized_arena := arena_id.strip_edges()
	var normalized_difficulty := difficulty_id.strip_edges()
	if normalized_difficulty == "":
		return "%s%s" % [PREFIX_ARENA_START, normalized_arena]
	return "%s%s:%s" % [PREFIX_ARENA_START, normalized_arena, normalized_difficulty]

static func battle_replay_action(battle_id: String) -> String:
	return "%s%s" % [PREFIX_BATTLE_REPLAY, battle_id.strip_edges()]

static func arena_choose_buff_action(buff_id: String) -> String:
	return "%s%s" % [PREFIX_ARENA_CHOOSE_BUFF, buff_id.strip_edges()]

static func open_mode_shell_action(mode_id: String) -> String:
	return "%s%s" % [PREFIX_OPEN_MODE_SHELL, mode_id.strip_edges()]

static func mode_disabled_action(mode_id: String) -> String:
	return "%s%s" % [PREFIX_MODE_DISABLED, mode_id.strip_edges()]

static func action_value(action_id: String) -> String:
	var candidate := action_id.strip_edges()
	if not candidate.contains(":"):
		return ""
	return candidate.get_slice(":", 1).strip_edges()

static func action_value_at(action_id: String, index: int) -> String:
	var candidate := action_id.strip_edges()
	if index < 1 or not candidate.contains(":"):
		return ""
	if candidate.get_slice_count(":") <= index:
		return ""
	return candidate.get_slice(":", index).strip_edges()
