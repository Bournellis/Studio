import { jsonResponse } from "../_shared/http.ts";
import {
  type ModeProgressRow,
  type ModeRegistryRow,
  type ModeResourcesRow,
  type ModeRewardClaimRow,
  type ModeRulesetRow,
  type ModeSessionRow,
} from "../_shared/mode_domain.ts";
import {
  type FoundationGameSaveRow,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
} from "../_shared/transactional_mutation.ts";
import {
  SAVE_TYPE_HEADER,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";

export type Route =
  | "registry"
  | "state"
  | "session_start"
  | "session_event"
  | "session_complete"
  | "session_abandon"
  | "analytics_summary"
  | "admin_me"
  | "admin_disable"
  | "admin_enable"
  | "admin_session_expire"
  | "admin_session_invalidate"
  | "admin_reconcile"
  | "admin_compensate";

export interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

export interface AuthContext {
  userId: string;
  saveType: SaveType;
}

export interface RestError {
  code: string;
  message: string;
  status: number;
}

interface JwtPayload {
  sub?: unknown;
}

interface PlayerRow {
  id: string;
  username: string | null;
  save_type: SaveType;
}

export interface ModeState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  registry: ModeRegistryRow[];
  rulesets: ModeRulesetRow[];
  progress: ModeProgressRow | null;
  sessions: ModeSessionRow[];
  claims: ModeRewardClaimRow[];
  resources: ModeResourcesRow | null;
}

export interface AdminRoleRow {
  auth_user_id: string;
  role: string;
  active: boolean;
}

export const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/registry")) return "registry";
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/session/start")) return "session_start";
  if (pathname.endsWith("/session/event")) return "session_event";
  if (pathname.endsWith("/session/complete")) return "session_complete";
  if (pathname.endsWith("/session/abandon")) return "session_abandon";
  if (pathname.endsWith("/analytics/summary")) return "analytics_summary";
  if (pathname.endsWith("/admin/me")) return "admin_me";
  if (pathname.endsWith("/admin/disable")) return "admin_disable";
  if (pathname.endsWith("/admin/enable")) return "admin_enable";
  if (pathname.endsWith("/admin/session/expire")) return "admin_session_expire";
  if (pathname.endsWith("/admin/session/invalidate")) return "admin_session_invalidate";
  if (pathname.endsWith("/admin/reconcile")) return "admin_reconcile";
  if (pathname.endsWith("/admin/compensate")) return "admin_compensate";
  return null;
}

export async function loadModeState(
  auth: AuthContext,
  config: EdgeConfig,
  modeId: string,
): Promise<{ value: ModeState; error: null } | { value: null; error: RestError }> {
  const player = await loadPlayer(auth, config);
  if (player.error !== null) return { value: null, error: player.error };
  const gameSave = await loadFoundationGameSave(
    config,
    restRequest,
    auth.userId,
    auth.saveType,
    player.value.id,
  );
  if (gameSave.error !== null) return { value: null, error: gameSave.error };
  const registry = await loadRegistry(config, modeId);
  if (registry.error !== null) return { value: null, error: registry.error };
  if (registry.value.length <= 0) {
    return {
      value: null,
      error: {
        code: "INVALID_MODE",
        message: "Mode is not registered in Mode Platform V1.",
        status: 404,
      },
    };
  }
  const rulesets = await loadRulesets(config, modeId);
  if (rulesets.error !== null) return { value: null, error: rulesets.error };
  const progress = await loadProgress(config, gameSave.value.id, modeId);
  if (progress.error !== null) return { value: null, error: progress.error };
  const sessions = await loadSessions(config, gameSave.value.id, modeId);
  if (sessions.error !== null) return { value: null, error: sessions.error };
  const claims = await loadClaims(config, gameSave.value.id, modeId);
  if (claims.error !== null) return { value: null, error: claims.error };
  const resources = await loadResources(config, player.value.id);
  if (resources.error !== null) return { value: null, error: resources.error };
  return {
    value: {
      player: player.value,
      gameSave: gameSave.value,
      registry: registry.value,
      rulesets: rulesets.value,
      progress: progress.value,
      sessions: sessions.value,
      claims: claims.value,
      resources: resources.value,
    },
    error: null,
  };
}

async function loadPlayer(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,username,save_type&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const player = result.value[0] ?? null;
  if (player === null) {
    return {
      value: null,
      error: {
        code: "PLAYER_NOT_FOUND",
        message: "Guest account was not created yet.",
        status: 404,
      },
    };
  }
  return { value: player, error: null };
}

export async function loadRegistry(
  config: EdgeConfig,
  modeId: string,
): Promise<{ value: ModeRegistryRow[]; error: null } | { value: null; error: RestError }> {
  const filter = modeId === "" ? "" : `mode_id=eq.${encodeURIComponent(modeId)}&`;
  const result = await restRequest<ModeRegistryRow[]>(
    config,
    `mode_registry?${filter}select=mode_id,display_name,status,release_channel,default_slice_id,active_ruleset_id,active_ruleset_version,metadata,updated_at&order=mode_id.asc`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

export async function loadRulesets(
  config: EdgeConfig,
  modeId: string,
): Promise<{ value: ModeRulesetRow[]; error: null } | { value: null; error: RestError }> {
  const filter = modeId === "" ? "" : `mode_id=eq.${encodeURIComponent(modeId)}&`;
  const result = await restRequest<ModeRulesetRow[]>(
    config,
    `mode_ruleset_registry?${filter}select=ruleset_id,ruleset_version,mode_id,slice_id,status,release_channel,reward_limits,result_limits,ruleset_payload,updated_at&order=ruleset_id.asc`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

async function loadProgress(
  config: EdgeConfig,
  gameSaveId: string,
  modeId: string,
): Promise<{ value: ModeProgressRow | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<ModeProgressRow[]>(
    config,
    `mode_progress?game_save_id=eq.${encodeURIComponent(gameSaveId)}&mode_id=eq.${
      encodeURIComponent(modeId)
    }&select=game_save_id,mode_id,local_schema_version,progress_payload,totals_payload,last_session_id,updated_at&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0] ?? null, error: null };
}

export async function loadSessions(
  config: EdgeConfig,
  gameSaveId: string,
  modeId: string,
): Promise<{ value: ModeSessionRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<ModeSessionRow[]>(
    config,
    `mode_sessions?game_save_id=eq.${encodeURIComponent(gameSaveId)}&mode_id=eq.${
      encodeURIComponent(modeId)
    }&select=id,game_save_id,mode_id,slice_id,ruleset_id,ruleset_version,status,server_seed,session_seconds,activity_score,deposited_items,result_payload,reward_payload,snapshot_payload,snapshot_revision,last_event_at,started_at,completed_at,expires_at,abandoned_at,invalidated_at,invalidated_reason&order=started_at.desc&limit=20`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

export async function loadClaims(
  config: EdgeConfig,
  gameSaveId: string,
  modeId: string,
): Promise<{ value: ModeRewardClaimRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<ModeRewardClaimRow[]>(
    config,
    `mode_reward_claims?game_save_id=eq.${encodeURIComponent(gameSaveId)}&mode_id=eq.${
      encodeURIComponent(modeId)
    }&select=id,game_save_id,player_id,mode_id,session_id,period_key,reward_payload,resource_delta,xp_delta,created_at&order=created_at.desc&limit=20`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

async function loadResources(
  config: EdgeConfig,
  playerId: string,
): Promise<
  { value: ModeResourcesRow | null; error: null } | { value: null; error: RestError }
> {
  const result = await restRequest<ModeResourcesRow[]>(
    config,
    `resources?player_id=eq.${
      encodeURIComponent(playerId)
    }&select=almas,energia,sangue,cristais,ossos,po_osso,diamante&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0] ?? null, error: null };
}

export async function loadAdminRole(
  config: EdgeConfig,
  authUserId: string,
): Promise<{ value: AdminRoleRow | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<AdminRoleRow[]>(
    config,
    `admin_roles?auth_user_id=eq.${
      encodeURIComponent(authUserId)
    }&active=eq.true&select=auth_user_id,role,active&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null || (result.value[0] ?? null) === null) {
    return {
      value: null,
      error: {
        code: "ADMIN_FORBIDDEN",
        message: "Mode admin role is required.",
        status: 403,
      },
    };
  }
  return { value: result.value[0], error: null };
}

export function decodeAuthContext(request: Request): { value: AuthContext; error: null } | {
  value: null;
  error: RestError;
} {
  const header = request.headers.get("authorization") ?? "";
  if (!header.startsWith("Bearer ")) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Bearer token is required.", status: 401 },
    };
  }
  const token = header.slice("Bearer ".length);
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Invalid bearer token.", status: 401 },
    };
  }
  const payload = decodeJwtPayload(parts[1]);
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Token subject is invalid.", status: 401 },
    };
  }
  const saveTypeHeader = request.headers.get(SAVE_TYPE_HEADER);
  if (saveTypeHeader === null || saveTypeHeader.trim() === "") {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: "x-draxos-save-type is required for mode endpoints.",
        status: 400,
      },
    };
  }
  const saveType = saveTypeFromRequest(request);
  if (saveType === null) {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: "Save type must be normal or progression_lab.",
        status: 400,
      },
    };
  }
  return { value: { userId: payload.sub, saveType }, error: null };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const payload: unknown = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
}

export function loadConfig(): { value: EdgeConfig; error: null } | {
  value: null;
  error: RestError;
} {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Modes function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

export async function readJsonObject(
  request: Request,
): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

export async function restRequest<T>(
  config: EdgeConfig,
  path: string,
  init: RequestInit,
): Promise<{ value: T; error: null } | { value: null; error: RestError }> {
  const headers = new Headers(init.headers);
  headers.set("accept", "application/json");
  headers.set("apikey", config.serviceRoleKey);
  headers.set("authorization", `Bearer ${config.serviceRoleKey}`);
  if (init.body !== undefined) {
    headers.set("content-type", "application/json");
  }
  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, { ...init, headers });
  const text = await response.text();
  const data = text === "" ? null : parseJson(text);
  if (!response.ok) {
    const body = isObject(data) ? data : {};
    return {
      value: null,
      error: {
        code: stringValue(body.code, "REST_ERROR"),
        message: stringValue(body.message, response.statusText),
        status: response.status,
      },
    };
  }
  return { value: data as T, error: null };
}

export function mapModeDatabaseError(error: RestError, fallbackCode: string): RestError {
  const message = error.message.toUpperCase();
  const codes = [
    "INVALID_MODE_EVENT",
    "INVALID_MODE_STATUS",
    "INVALID_RULESET",
    "INVALID_SESSION",
    "INVALID_RESULT",
    "INVALID_MODE",
    "MODE_SESSION_NOT_FOUND",
    "MODE_SESSION_ALREADY_COMPLETED",
    "MODE_RESULT_REJECTED",
    "MODE_REWARD_BLOCKED_FOR_LAB",
    "MODE_REWARD_APPLY_FAILED",
    "MODE_DISABLED",
    "MODE_SESSION_UNSUPPORTED",
    "MODE_SESSION_NOT_ACTIVE",
    "MODE_SESSION_ALREADY_ACTIVE",
    "MODE_SESSION_START_COOLDOWN",
    "MODE_SESSION_DAILY_LIMIT",
    "MODE_SESSION_REVISION_STALE",
    "OPENWORLD_NODE_ALREADY_COLLECTED",
    "MODE_ADMIN_AUDIT_FAILED",
    "MODE_ADMIN_STATUS_FAILED",
    "MODE_ADMIN_SESSION_FAILED",
    "IDEMPOTENCY_HASH_MISMATCH",
  ];
  for (const code of codes) {
    if (message.includes(code)) {
      return {
        code,
        message: modeErrorMessage(code),
        status: modeStatus(code, error.status),
      };
    }
  }
  return mapFoundationDatabaseError(error, fallbackCode);
}

function modeStatus(code: string, fallback: number): number {
  if (code === "MODE_SESSION_NOT_FOUND") return 404;
  if (code === "MODE_DISABLED") return 409;
  if (
    code === "MODE_SESSION_ALREADY_COMPLETED" ||
    code === "MODE_REWARD_BLOCKED_FOR_LAB" ||
    code === "MODE_SESSION_NOT_ACTIVE" ||
    code === "MODE_SESSION_ALREADY_ACTIVE" ||
    code === "MODE_SESSION_START_COOLDOWN" ||
    code === "MODE_SESSION_DAILY_LIMIT" ||
    code === "MODE_SESSION_REVISION_STALE" ||
    code === "OPENWORLD_NODE_ALREADY_COLLECTED" ||
    code === "IDEMPOTENCY_HASH_MISMATCH"
  ) return 409;
  if (
    code === "INVALID_MODE" ||
    code === "INVALID_RULESET" ||
    code === "INVALID_SESSION" ||
    code === "INVALID_MODE_STATUS" ||
    code === "INVALID_RESULT" ||
    code === "MODE_RESULT_REJECTED" ||
    code === "INVALID_MODE_EVENT" ||
    code === "MODE_SESSION_UNSUPPORTED"
  ) return 400;
  return fallback >= 400 ? fallback : 500;
}

function modeErrorMessage(code: string): string {
  switch (code) {
    case "IDEMPOTENCY_HASH_MISMATCH":
      return "request_id was already used with a different request_hash.";
    case "INVALID_MODE":
      return "Mode is not available for this Mode Platform endpoint.";
    case "INVALID_RULESET":
      return "Openworld ruleset does not match the active server ruleset.";
    case "INVALID_SESSION":
      return "Mode session is invalid for this save.";
    case "MODE_SESSION_NOT_FOUND":
      return "Mode session was not found.";
    case "MODE_SESSION_ALREADY_COMPLETED":
      return "Mode session was already completed.";
    case "MODE_RESULT_REJECTED":
      return "Mode result failed server validation.";
    case "INVALID_MODE_EVENT":
      return "Mode event failed server validation.";
    case "MODE_SESSION_ALREADY_ACTIVE":
      return "Mode already has an active session for this save.";
    case "MODE_SESSION_START_COOLDOWN":
      return "Mode session start cooldown is still active.";
    case "MODE_SESSION_DAILY_LIMIT":
      return "Mode daily session start limit was reached.";
    case "MODE_SESSION_REVISION_STALE":
      return "Mode session revision is stale and must be refreshed.";
    case "OPENWORLD_NODE_ALREADY_COLLECTED":
      return "Openworld resource node was already collected in this session.";
    case "MODE_REWARD_BLOCKED_FOR_LAB":
      return "Progression Lab saves cannot receive account/base rewards.";
    case "MODE_REWARD_APPLY_FAILED":
      return "Unable to apply mode reward.";
    case "MODE_DISABLED":
      return "Mode is disabled or staged.";
    case "MODE_SESSION_UNSUPPORTED":
      return "Mode does not use generic sessions in V1.";
    case "MODE_SESSION_NOT_ACTIVE":
      return "Mode session is not active.";
    case "INVALID_MODE_STATUS":
      return "Mode status is invalid for admin mutation.";
    case "MODE_ADMIN_AUDIT_FAILED":
      return "Mode admin audit log could not be written.";
    case "MODE_ADMIN_STATUS_FAILED":
      return "Mode status could not be updated.";
    case "MODE_ADMIN_SESSION_FAILED":
      return "Mode session admin mutation could not be completed.";
    default:
      return "Mode mutation could not be completed.";
  }
}

function stateReadError(): RestError {
  return { code: "STATE_READ_FAILED", message: "Unable to load mode state.", status: 500 };
}

export function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

export function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

export function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
