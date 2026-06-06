import type { SaveType } from "./save_context.ts";

export interface FoundationRestError {
  code: string;
  message: string;
  status: number;
}

export interface FoundationGameSaveRow {
  id: string;
  account_profile_id: string;
  legacy_player_id: string;
  save_type: SaveType;
  ruleset_id: string;
  ruleset_version: number;
  snapshot?: unknown;
}

interface FoundationRestConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

type FoundationRestRequest = <T>(
  config: FoundationRestConfig,
  path: string,
  init: RequestInit,
) => Promise<
  { value: T; error: null } | { value: null; error: FoundationRestError }
>;

const DOMAIN_CONFLICT_CODES = new Set([
  "IDEMPOTENCY_HASH_MISMATCH",
  "INSUFFICIENT_RESOURCES",
  "PREMIUM_REQUIRED",
  "GUILD_ALREADY_JOINED",
  "GUILD_FULL",
  "GUILD_REQUIRED",
  "CONSUMABLE_APPLY_FAILED",
  "STATION_REQUIRED",
  "STATION_NOT_BUILT",
  "MODE_CHECKPOINT_REQUIRED",
  "PROGRESS_REVISION_MISMATCH",
  "INSUFFICIENT_OPENWORLD_MATERIALS",
  "REWARD_ALREADY_CLAIMED",
  "ALPHA_DAILY_ALREADY_REDEEMED",
  "ALPHA_ALREADY_OWNED",
  "SPELL_NOT_EQUIPPED",
  "POTION_NOT_OWNED",
]);

const DOMAIN_NOT_FOUND_CODES = new Set([
  "GAME_SAVE_NOT_FOUND",
  "PLAYER_NOT_FOUND",
  "USER_NOT_FOUND",
  "RESOURCES_NOT_FOUND",
  "BUILD_NOT_FOUND",
  "MODE_SESSION_NOT_FOUND",
  "MODE_SESSION_NOT_ACTIVE",
  "GUILD_NOT_FOUND",
  "BATTLE_PASS_NOT_FOUND",
]);

const DOMAIN_INVALID_CODES = new Set([
  "INVALID_GAME_SAVE_ID",
  "INVALID_PLAYER_ID",
  "INVALID_REQUEST_ID",
  "INVALID_REQUEST_HASH",
  "INVALID_PAYLOAD",
  "INVALID_ENDPOINT",
  "INVALID_REWARD",
  "INVALID_PRODUCT",
  "INVALID_RECIPE",
  "INVALID_GUILD_NAME",
  "INVALID_USERNAME",
  "INVALID_FRIEND",
  "INVALID_SPELL",
  "INVALID_SLOT",
  "INVALID_POTION",
  "INVALID_STATION_CONTEXT",
  "INVALID_SESSION_ID",
  "INVALID_MODE",
  "INVALID_RULESET",
  "INVALID_PROGRESS_REVISION",
  "EMPTY_MESSAGE",
]);

export async function loadFoundationGameSave(
  config: FoundationRestConfig,
  restRequest: FoundationRestRequest,
  authUserId: string,
  saveType: SaveType,
  playerId: string,
): Promise<
  { value: FoundationGameSaveRow; error: null } | { value: null; error: FoundationRestError }
> {
  const query = `game_saves?legacy_player_id=eq.${encodeURIComponent(playerId)}&save_type=eq.${
    encodeURIComponent(saveType)
  }&lifecycle_status=eq.active&select=id,account_profile_id,legacy_player_id,save_type,ruleset_id,ruleset_version,snapshot&limit=1`;
  const existing = await restRequest<FoundationGameSaveRow[]>(config, query, { method: "GET" });
  if (existing.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const current = existing.value[0] ?? null;
  if (current !== null) {
    return { value: current, error: null };
  }

  const ensure = await restRequest<unknown>(
    config,
    "rpc/ensure_foundation_profile_and_saves",
    {
      method: "POST",
      body: JSON.stringify({
        p_auth_user_id: authUserId,
        p_ruleset_id: "foundation_ruleset_v0",
      }),
    },
  );
  if (ensure.error !== null) {
    return {
      value: null,
      error: mapFoundationDatabaseError(ensure.error, "GAME_SAVE_NOT_FOUND"),
    };
  }

  const created = await restRequest<FoundationGameSaveRow[]>(config, query, { method: "GET" });
  if (created.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const gameSave = created.value[0] ?? null;
  if (gameSave === null) {
    return {
      value: null,
      error: {
        code: "GAME_SAVE_NOT_FOUND",
        message: "Account save foundation row was not created yet.",
        status: 404,
      },
    };
  }
  return { value: gameSave, error: null };
}

export async function mutationRequestHash(
  endpoint: string,
  body: Record<string, unknown>,
  canonicalPayload: Record<string, unknown>,
): Promise<string> {
  const explicitHash = stringField(body, "request_hash");
  if (explicitHash !== "") {
    return explicitHash;
  }
  return `sha256:${await sha256Hex(stableStringify({ endpoint, payload: canonicalPayload }))}`;
}

export function foundationRpcPayload(value: unknown): Record<string, unknown> {
  return isObject(value) ? value : {};
}

export function mapFoundationDatabaseError(
  error: FoundationRestError,
  fallbackCode: string,
): FoundationRestError {
  const upperMessage = error.message.toUpperCase();
  const codes = [
    ...DOMAIN_CONFLICT_CODES,
    ...DOMAIN_NOT_FOUND_CODES,
    ...DOMAIN_INVALID_CODES,
    "GAME_SAVE_WITHOUT_LEGACY_PLAYER",
    "RULESET_NOT_FOUND",
    "BATTLE_INSERT_FAILED",
    "REWARD_APPLY_FAILED",
    "CRAFT_FAILED",
    "BUILD_EQUIP_FAILED",
    "BEHAVIOR_UPDATE_FAILED",
    "POTION_EQUIP_FAILED",
    "FRIEND_ADD_FAILED",
    "GUILD_CREATE_FAILED",
    "GUILD_JOIN_FAILED",
    "CHAT_SEND_FAILED",
    "CHAT_RATE_LIMITED",
    "RANKING_APPLY_FAILED",
    "STATION_CRAFT_FAILED",
    "MODE_SESSION_NOT_FOUND",
  ];
  for (const code of codes) {
    if (upperMessage.includes(code)) {
      return {
        code,
        message: foundationErrorMessage(code),
        status: statusFor(code, error.status),
      };
    }
  }
  return {
    code: fallbackCode,
    message: foundationErrorMessage(fallbackCode),
    status: error.status >= 400 ? error.status : 500,
  };
}

function statusFor(code: string, fallback: number): number {
  if (code === "CHAT_RATE_LIMITED") return 429;
  if (DOMAIN_CONFLICT_CODES.has(code)) return 409;
  if (DOMAIN_NOT_FOUND_CODES.has(code)) return 404;
  if (DOMAIN_INVALID_CODES.has(code)) return 400;
  return fallback >= 400 ? fallback : 500;
}

function foundationErrorMessage(code: string): string {
  switch (code) {
    case "IDEMPOTENCY_HASH_MISMATCH":
      return "request_id was already used with a different request_hash.";
    case "INSUFFICIENT_RESOURCES":
      return "Not enough resources for this mutation.";
    case "PREMIUM_REQUIRED":
      return "Premium Battle Pass is not unlocked.";
    case "GUILD_ALREADY_JOINED":
      return "Player already belongs to a guild.";
    case "GUILD_FULL":
      return "Guild member limit reached.";
    case "GUILD_NOT_FOUND":
      return "Guild name was not found.";
    case "GUILD_REQUIRED":
      return "Join a guild before using guild chat.";
    case "USER_NOT_FOUND":
      return "Friend username was not found.";
    case "INVALID_FRIEND":
      return "Cannot add yourself.";
    case "SPELL_NOT_EQUIPPED":
      return "Spell behavior can only be set for equipped spells.";
    case "POTION_NOT_OWNED":
      return "This potion is not in inventory.";
    case "STATION_REQUIRED":
      return "Prepare this recipe at the Bosque Fogueira.";
    case "STATION_NOT_BUILT":
      return "Build the Bosque Fogueira before preparing potions.";
    case "MODE_CHECKPOINT_REQUIRED":
      return "Save a Bosque checkpoint before preparing potions.";
    case "PROGRESS_REVISION_MISMATCH":
      return "Bosque progress changed before the station craft could be applied.";
    case "INSUFFICIENT_OPENWORLD_MATERIALS":
      return "The Bosque Bau does not have the required materials.";
    case "INVALID_USERNAME":
      return "username is required.";
    case "INVALID_SPELL":
      return "spell_id is invalid.";
    case "INVALID_SLOT":
      return "Only potion slot 1 is available.";
    case "INVALID_POTION":
      return "item_id is not an available potion.";
    case "INVALID_STATION_CONTEXT":
      return "station_context is invalid.";
    case "INVALID_SESSION_ID":
      return "session_id is invalid.";
    case "INVALID_MODE":
      return "mode_id is invalid for this mutation.";
    case "INVALID_RULESET":
      return "ruleset is invalid for this mutation.";
    case "INVALID_PROGRESS_REVISION":
      return "expected_progress_revision is invalid.";
    case "EMPTY_MESSAGE":
      return "Chat message cannot be empty.";
    case "CHAT_RATE_LIMITED":
      return "Wait a few seconds before sending another message.";
    case "CONSUMABLE_APPLY_FAILED":
      return "Potion stock changed before battle could be applied.";
    case "GAME_SAVE_NOT_FOUND":
      return "Account save foundation row was not created yet.";
    case "GAME_SAVE_WITHOUT_LEGACY_PLAYER":
      return "Account save is missing its compatibility player row.";
    case "RULESET_NOT_FOUND":
      return "Active ruleset publication was not found.";
    case "PLAYER_NOT_FOUND":
      return "Guest account was not created yet.";
    case "RESOURCES_NOT_FOUND":
      return "Resources row is missing.";
    case "BUILD_NOT_FOUND":
      return "Build row is missing.";
    case "BATTLE_PASS_NOT_FOUND":
      return "No active Battle Pass is configured.";
    case "INVALID_REWARD":
      return "reward_id is not part of Rewards v0.";
    case "INVALID_PRODUCT":
      return "product_id is not part of Alpha monetization.";
    case "INVALID_RECIPE":
      return "recipe_id is not part of Crafting v1.";
    case "INVALID_GUILD_NAME":
      return "Guild name must be 3-32 characters.";
    case "BATTLE_INSERT_FAILED":
      return "Unable to persist battle result.";
    case "REWARD_APPLY_FAILED":
      return "Unable to apply battle reward.";
    case "CRAFT_FAILED":
      return "Unable to craft item.";
    case "BUILD_EQUIP_FAILED":
      return "Unable to update battle preparation.";
    case "BEHAVIOR_UPDATE_FAILED":
      return "Unable to update behavior.";
    case "POTION_EQUIP_FAILED":
      return "Unable to update potion slot.";
    case "FRIEND_ADD_FAILED":
      return "Unable to add friend.";
    case "GUILD_CREATE_FAILED":
      return "Unable to create guild.";
    case "GUILD_JOIN_FAILED":
      return "Unable to join guild.";
    case "CHAT_SEND_FAILED":
      return "Unable to send chat message.";
    case "RANKING_APPLY_FAILED":
      return "Unable to update arena ranking.";
    case "STATION_CRAFT_FAILED":
      return "Unable to prepare potion at the Bosque station.";
    case "MODE_SESSION_NOT_FOUND":
      return "Active Bosque session was not found.";
    case "MODE_SESSION_NOT_ACTIVE":
      return "Bosque session is not active.";
    default:
      return "Foundation mutation could not be completed.";
  }
}

function stateReadError(): FoundationRestError {
  return {
    code: "STATE_READ_FAILED",
    message: "Unable to load account save foundation state.",
    status: 500,
  };
}

async function sha256Hex(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
