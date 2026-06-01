import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  canonicalCompletionPayload,
  completionResultFromBody,
  MINIGAME_ENDPOINT_SESSION_COMPLETE,
  MINIGAME_ENDPOINT_SESSION_START,
  type MinigameProgressRow,
  minigameRegistryPayload,
  type MinigameRegistryRow,
  type MinigameResourcesRow,
  type MinigameRewardClaimRow,
  type MinigameRulesetRow,
  type MinigameSessionRow,
  minigameStatePayload,
  RPGSUAVE_MODE_ID,
  RPGSUAVE_RELEASE_CHANNEL,
  RPGSUAVE_RULESET_ID,
  RPGSUAVE_RULESET_VERSION,
  RPGSUAVE_SLICE_ID,
} from "../_shared/minigame_domain.ts";
import {
  type FoundationGameSaveRow,
  foundationRpcPayload,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import {
  SAVE_TYPE_HEADER,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";

type Route = "registry" | "state" | "session_start" | "session_complete";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
  saveType: SaveType;
}

interface RestError {
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

interface MinigameState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  registry: MinigameRegistryRow[];
  rulesets: MinigameRulesetRow[];
  progress: MinigameProgressRow | null;
  sessions: MinigameSessionRow[];
  claims: MinigameRewardClaimRow[];
  resources: MinigameResourcesRow | null;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  const apiVersionError = validateApiVersion(request);
  if (apiVersionError !== null) {
    return apiVersionError;
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown minigames endpoint.", 404);
    }
    if ((route === "registry" || route === "state") && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET for minigame reads.", 405);
    }
    if (
      (route === "session_start" || route === "session_complete") &&
      request.method !== "POST"
    ) {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST for minigame sessions.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }
    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "registry") {
      return await handleRegistry(config.value);
    }
    if (route === "state") {
      return await handleState(request, auth.value, config.value);
    }
    if (route === "session_start") {
      return await handleSessionStart(request, auth.value, config.value);
    }
    return await handleSessionComplete(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected minigames service error.", 500);
  }
});

async function handleRegistry(config: EdgeConfig): Promise<Response> {
  const registry = await loadRegistry(config, "");
  if (registry.error !== null) {
    return errorResponse(registry.error.code, registry.error.message, registry.error.status);
  }
  const rulesets = await loadRulesets(config, "");
  if (rulesets.error !== null) {
    return errorResponse(rulesets.error.code, rulesets.error.message, rulesets.error.status);
  }
  return jsonResponse(minigameRegistryPayload(registry.value, rulesets.value, new Date()));
}

async function handleState(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const modeId = new URL(request.url).searchParams.get("mode_id")?.trim() ?? RPGSUAVE_MODE_ID;
  if (modeId !== RPGSUAVE_MODE_ID) {
    return errorResponse("INVALID_MODE", "mode_id is not part of Minigame Platform v0.", 400);
  }
  const state = await loadMinigameState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(minigameStatePayload({ ...state.value, serverTime: new Date() }));
}

async function handleSessionStart(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const modeId = stringField(body, "mode_id");
  const sliceId = stringField(body, "slice_id") || RPGSUAVE_SLICE_ID;
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (modeId !== RPGSUAVE_MODE_ID || sliceId !== RPGSUAVE_SLICE_ID) {
    return errorResponse("INVALID_MODE", "Only rpgsuave/forest is available in v0.", 400);
  }

  const state = await loadMinigameState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const requestHash = await mutationRequestHash(MINIGAME_ENDPOINT_SESSION_START, body, {
    request_id: requestId,
    save_type: auth.saveType,
    mode_id: modeId,
    slice_id: sliceId,
    ruleset_id: RPGSUAVE_RULESET_ID,
    ruleset_version: RPGSUAVE_RULESET_VERSION,
  });
  const rpc = await restRequest<unknown>(config, "rpc/minigame_session_start_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        mode_id: modeId,
        slice_id: sliceId,
        ruleset_id: RPGSUAVE_RULESET_ID,
        ruleset_version: RPGSUAVE_RULESET_VERSION,
        release_channel: RPGSUAVE_RELEASE_CHANNEL,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapMinigameDatabaseError(rpc.error, "MINIGAME_SESSION_START_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(foundationRpcPayload(rpc.value));
}

async function handleSessionComplete(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  const result = completionResultFromBody(body);
  if (result === null || !UUID_PATTERN.test(result.session_id)) {
    return errorResponse("INVALID_RESULT", "Rpgsuave completion result is invalid.", 400);
  }

  const state = await loadMinigameState(auth, config, RPGSUAVE_MODE_ID);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const canonicalResult = canonicalCompletionPayload(result);
  const requestHash = await mutationRequestHash(MINIGAME_ENDPOINT_SESSION_COMPLETE, body, {
    request_id: requestId,
    save_type: auth.saveType,
    ...canonicalResult,
  });
  const rpc = await restRequest<unknown>(config, "rpc/minigame_session_complete_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        ...canonicalResult,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapMinigameDatabaseError(rpc.error, "MINIGAME_SESSION_COMPLETE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(foundationRpcPayload(rpc.value));
}

async function loadMinigameState(
  auth: AuthContext,
  config: EdgeConfig,
  modeId: string,
): Promise<{ value: MinigameState; error: null } | { value: null; error: RestError }> {
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

async function loadRegistry(
  config: EdgeConfig,
  modeId: string,
): Promise<{ value: MinigameRegistryRow[]; error: null } | { value: null; error: RestError }> {
  const filter = modeId === "" ? "" : `mode_id=eq.${encodeURIComponent(modeId)}&`;
  const result = await restRequest<MinigameRegistryRow[]>(
    config,
    `mode_registry?${filter}select=mode_id,display_name,status,release_channel,default_slice_id,active_ruleset_id,active_ruleset_version,metadata,updated_at&order=mode_id.asc`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

async function loadRulesets(
  config: EdgeConfig,
  modeId: string,
): Promise<{ value: MinigameRulesetRow[]; error: null } | { value: null; error: RestError }> {
  const filter = modeId === "" ? "" : `mode_id=eq.${encodeURIComponent(modeId)}&`;
  const result = await restRequest<MinigameRulesetRow[]>(
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
): Promise<{ value: MinigameProgressRow | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<MinigameProgressRow[]>(
    config,
    `mode_progress?game_save_id=eq.${encodeURIComponent(gameSaveId)}&mode_id=eq.${
      encodeURIComponent(modeId)
    }&select=game_save_id,mode_id,local_schema_version,progress_payload,totals_payload,last_session_id,updated_at&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0] ?? null, error: null };
}

async function loadSessions(
  config: EdgeConfig,
  gameSaveId: string,
  modeId: string,
): Promise<{ value: MinigameSessionRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<MinigameSessionRow[]>(
    config,
    `mode_sessions?game_save_id=eq.${encodeURIComponent(gameSaveId)}&mode_id=eq.${
      encodeURIComponent(modeId)
    }&select=id,game_save_id,mode_id,slice_id,ruleset_id,ruleset_version,status,server_seed,session_seconds,activity_score,deposited_items,result_payload,reward_payload,started_at,completed_at&order=started_at.desc&limit=10`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

async function loadClaims(
  config: EdgeConfig,
  gameSaveId: string,
  modeId: string,
): Promise<{ value: MinigameRewardClaimRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<MinigameRewardClaimRow[]>(
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
  { value: MinigameResourcesRow | null; error: null } | { value: null; error: RestError }
> {
  const result = await restRequest<MinigameResourcesRow[]>(
    config,
    `resources?player_id=eq.${
      encodeURIComponent(playerId)
    }&select=almas,energia,sangue,cristais,ossos,po_osso,diamante&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0] ?? null, error: null };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/registry")) return "registry";
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/session/start")) return "session_start";
  if (pathname.endsWith("/session/complete")) return "session_complete";
  return null;
}

function decodeAuthContext(request: Request): { value: AuthContext; error: null } | {
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
        message: "x-draxos-save-type is required for minigame endpoints.",
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

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Minigames function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

async function restRequest<T>(
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

function mapMinigameDatabaseError(error: RestError, fallbackCode: string): RestError {
  const message = error.message.toUpperCase();
  const codes = [
    "INVALID_MODE",
    "INVALID_RULESET",
    "INVALID_SESSION",
    "INVALID_RESULT",
    "MINIGAME_SESSION_NOT_FOUND",
    "MINIGAME_SESSION_ALREADY_COMPLETED",
    "MINIGAME_RESULT_REJECTED",
    "MINIGAME_REWARD_BLOCKED_FOR_LAB",
    "MINIGAME_REWARD_APPLY_FAILED",
    "IDEMPOTENCY_HASH_MISMATCH",
  ];
  for (const code of codes) {
    if (message.includes(code)) {
      return {
        code,
        message: minigameErrorMessage(code),
        status: minigameStatus(code, error.status),
      };
    }
  }
  return mapFoundationDatabaseError(error, fallbackCode);
}

function minigameStatus(code: string, fallback: number): number {
  if (code === "MINIGAME_SESSION_NOT_FOUND") return 404;
  if (
    code === "MINIGAME_SESSION_ALREADY_COMPLETED" ||
    code === "MINIGAME_REWARD_BLOCKED_FOR_LAB" ||
    code === "IDEMPOTENCY_HASH_MISMATCH"
  ) return 409;
  if (
    code === "INVALID_MODE" ||
    code === "INVALID_RULESET" ||
    code === "INVALID_SESSION" ||
    code === "INVALID_RESULT" ||
    code === "MINIGAME_RESULT_REJECTED"
  ) return 400;
  return fallback >= 400 ? fallback : 500;
}

function minigameErrorMessage(code: string): string {
  switch (code) {
    case "IDEMPOTENCY_HASH_MISMATCH":
      return "request_id was already used with a different request_hash.";
    case "INVALID_MODE":
      return "Only rpgsuave/forest is available in Minigame Platform v0.";
    case "INVALID_RULESET":
      return "Rpgsuave ruleset does not match the active server ruleset.";
    case "INVALID_SESSION":
      return "Minigame session is invalid for this save.";
    case "MINIGAME_SESSION_NOT_FOUND":
      return "Minigame session was not found.";
    case "MINIGAME_SESSION_ALREADY_COMPLETED":
      return "Minigame session was already completed.";
    case "MINIGAME_RESULT_REJECTED":
      return "Minigame result failed server validation.";
    case "MINIGAME_REWARD_BLOCKED_FOR_LAB":
      return "Progression Lab saves cannot receive account/base rewards.";
    case "MINIGAME_REWARD_APPLY_FAILED":
      return "Unable to apply minigame reward.";
    default:
      return "Minigame mutation could not be completed.";
  }
}

function stateReadError(): RestError {
  return { code: "STATE_READ_FAILED", message: "Unable to load minigame state.", status: 500 };
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
