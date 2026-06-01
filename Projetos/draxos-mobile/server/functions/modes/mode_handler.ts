import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  AUTOBATTLER_MODE_ID,
  BASEBUILDER_MODE_ID,
  canonicalCompletionPayload,
  CARDGAME_MODE_ID,
  completionResultFromBody,
  MODE_ENDPOINT_SESSION_COMPLETE,
  MODE_ENDPOINT_SESSION_START,
  type ModeProgressRow,
  modeRegistryPayload,
  type ModeRegistryRow,
  type ModeResourcesRow,
  type ModeRewardClaimRow,
  type ModeRulesetRow,
  type ModeSessionRow,
  modeStatePayload,
  OPENWORLD_MODE_ID,
  OPENWORLD_RELEASE_CHANNEL,
  OPENWORLD_RULESET_ID,
  OPENWORLD_RULESET_VERSION,
  OPENWORLD_SLICE_ID,
  TOWERDEFENSE_MODE_ID,
} from "../_shared/mode_domain.ts";
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

type Route =
  | "registry"
  | "state"
  | "session_start"
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

interface ModeState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  registry: ModeRegistryRow[];
  rulesets: ModeRulesetRow[];
  progress: ModeProgressRow | null;
  sessions: ModeSessionRow[];
  claims: ModeRewardClaimRow[];
  resources: ModeResourcesRow | null;
}

interface AdminRoleRow {
  auth_user_id: string;
  role: string;
  active: boolean;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export class ModeHandler {
  async handle(request: Request): Promise<Response> {
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
        return errorResponse("NOT_FOUND", "Unknown modes endpoint.", 404);
      }
      if (
        (route === "registry" || route === "state" || route === "analytics_summary" ||
          route === "admin_me") && request.method !== "GET"
      ) {
        return errorResponse("METHOD_NOT_ALLOWED", "Use GET for mode reads.", 405);
      }
      if (
        route !== "registry" &&
        route !== "state" &&
        route !== "analytics_summary" &&
        route !== "admin_me" &&
        request.method !== "POST"
      ) {
        return errorResponse("METHOD_NOT_ALLOWED", "Use POST for mode sessions.", 405);
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
      if (route === "session_complete") {
        return await handleSessionComplete(request, auth.value, config.value);
      }
      if (route === "session_abandon") {
        return await handleSessionAbandon(request, auth.value, config.value);
      }
      if (route === "analytics_summary") {
        return await handleAnalyticsSummary(request, auth.value, config.value);
      }
      return await handleAdminRoute(route, request, auth.value, config.value);
    } catch (error) {
      console.error(error);
      return errorResponse("INTERNAL_ERROR", "Unexpected modes service error.", 500);
    }
  }
}

const internalModeHandler = new ModeHandler();

export function modeHandler(request: Request): Promise<Response> {
  return internalModeHandler.handle(request);
}

async function handleRegistry(config: EdgeConfig): Promise<Response> {
  const registry = await loadRegistry(config, "");
  if (registry.error !== null) {
    return errorResponse(registry.error.code, registry.error.message, registry.error.status);
  }
  const rulesets = await loadRulesets(config, "");
  if (rulesets.error !== null) {
    return errorResponse(rulesets.error.code, rulesets.error.message, rulesets.error.status);
  }
  return jsonResponse(modeRegistryPayload(registry.value, rulesets.value, new Date()));
}

async function handleState(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const modeId = new URL(request.url).searchParams.get("mode_id")?.trim() ?? OPENWORLD_MODE_ID;
  if (modeId === "") {
    return errorResponse("INVALID_MODE", "mode_id is not part of Mode Platform V1.", 400);
  }
  const state = await loadModeState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(modeStatePayload({ ...state.value, serverTime: new Date() }));
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
  const sliceId = stringField(body, "slice_id") || OPENWORLD_SLICE_ID;
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (modeId === TOWERDEFENSE_MODE_ID || modeId === CARDGAME_MODE_ID) {
    return errorResponse(
      "MODE_DISABLED",
      "Mode is staged/disabled and cannot start sessions yet.",
      409,
    );
  }
  if (modeId === BASEBUILDER_MODE_ID || modeId === AUTOBATTLER_MODE_ID) {
    return errorResponse(
      "MODE_SESSION_UNSUPPORTED",
      "This mode uses its own core endpoints in V1.",
      400,
    );
  }
  if (modeId !== OPENWORLD_MODE_ID || sliceId !== OPENWORLD_SLICE_ID) {
    return errorResponse("INVALID_MODE", "Only openworld/forest uses Mode sessions in V1.", 400);
  }

  const state = await loadModeState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const requestHash = await mutationRequestHash(MODE_ENDPOINT_SESSION_START, body, {
    request_id: requestId,
    save_type: auth.saveType,
    mode_id: modeId,
    slice_id: sliceId,
    ruleset_id: OPENWORLD_RULESET_ID,
    ruleset_version: OPENWORLD_RULESET_VERSION,
  });
  const rpc = await restRequest<unknown>(config, "rpc/mode_session_start_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        mode_id: modeId,
        slice_id: sliceId,
        ruleset_id: OPENWORLD_RULESET_ID,
        ruleset_version: OPENWORLD_RULESET_VERSION,
        release_channel: OPENWORLD_RELEASE_CHANNEL,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapModeDatabaseError(rpc.error, "MODE_SESSION_START_FAILED");
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
    return errorResponse("INVALID_RESULT", "Openworld completion result is invalid.", 400);
  }

  const state = await loadModeState(auth, config, OPENWORLD_MODE_ID);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const canonicalResult = canonicalCompletionPayload(result);
  const requestHash = await mutationRequestHash(MODE_ENDPOINT_SESSION_COMPLETE, body, {
    request_id: requestId,
    save_type: auth.saveType,
    ...canonicalResult,
  });
  const rpc = await restRequest<unknown>(config, "rpc/mode_session_complete_v1", {
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
    const mapped = mapModeDatabaseError(rpc.error, "MODE_SESSION_COMPLETE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(foundationRpcPayload(rpc.value));
}

async function handleSessionAbandon(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const sessionId = stringField(body, "session_id");
  const modeId = stringField(body, "mode_id") || OPENWORLD_MODE_ID;
  if (!UUID_PATTERN.test(requestId) || !UUID_PATTERN.test(sessionId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id and session_id must be UUIDs.", 400);
  }
  if (modeId !== OPENWORLD_MODE_ID) {
    return errorResponse("INVALID_MODE", "Only openworld sessions can be abandoned in V1.", 400);
  }
  const state = await loadModeState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const patch = await restRequest<ModeSessionRow[]>(
    config,
    `mode_sessions?id=eq.${encodeURIComponent(sessionId)}&game_save_id=eq.${
      encodeURIComponent(state.value.gameSave.id)
    }&mode_id=eq.${
      encodeURIComponent(modeId)
    }&status=eq.started&select=id,game_save_id,mode_id,slice_id,ruleset_id,ruleset_version,status,server_seed,session_seconds,activity_score,deposited_items,result_payload,reward_payload,started_at,completed_at,expires_at,abandoned_at,invalidated_at,invalidated_reason`,
    {
      method: "PATCH",
      headers: { "prefer": "return=representation" },
      body: JSON.stringify({
        status: "abandoned",
        abandoned_at: new Date().toISOString(),
        result_payload: { request_id: requestId, abandon_reason: stringField(body, "reason") },
      }),
    },
  );
  if (patch.error !== null) {
    return errorResponse("MODE_SESSION_ABANDON_FAILED", "Unable to abandon mode session.", 500);
  }
  const session = patch.value[0] ?? null;
  if (session === null) {
    return errorResponse("MODE_SESSION_NOT_FOUND", "Started mode session was not found.", 404);
  }
  return jsonResponse({
    ok: true,
    schema_version: "mode_platform_v1",
    request_id: requestId,
    mode: { mode_id: modeId, slice_id: OPENWORLD_SLICE_ID },
    session: sessionPayloadPublic(session),
    server_time: new Date().toISOString(),
  });
}

async function handleAnalyticsSummary(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const modeId = new URL(request.url).searchParams.get("mode_id")?.trim() || OPENWORLD_MODE_ID;
  const state = await loadModeState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const counts: Record<string, number> = {};
  let durationTotal = 0;
  let durationCount = 0;
  for (const session of state.value.sessions) {
    const status = String(session.status || "unknown");
    counts[status] = (counts[status] ?? 0) + 1;
    const seconds = Number(session.session_seconds ?? 0);
    if (Number.isFinite(seconds) && seconds > 0) {
      durationTotal += seconds;
      durationCount += 1;
    }
  }
  return jsonResponse({
    ok: true,
    schema_version: "mode_analytics_v1",
    mode_id: modeId,
    funnel: {
      sessions: state.value.sessions.length,
      started: counts.started ?? 0,
      completed: counts.completed ?? 0,
      abandoned: counts.abandoned ?? 0,
      expired: counts.expired ?? 0,
      invalidated: counts.invalidated ?? 0,
      reward_claims: state.value.claims.length,
      average_session_seconds: durationCount > 0 ? Math.round(durationTotal / durationCount) : 0,
    },
    resources: state.value.claims.map((claim) => claim.resource_delta),
    server_time: new Date().toISOString(),
  });
}

async function handleAdminRoute(
  route: Route,
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const admin = await loadAdminRole(config, auth.userId);
  if (route === "admin_me") {
    return jsonResponse({
      ok: true,
      schema_version: "mode_admin_v1",
      admin: admin.value,
      server_time: new Date().toISOString(),
    }, admin.error === null ? 200 : 403);
  }
  if (admin.error !== null) {
    return errorResponse(admin.error.code, admin.error.message, admin.error.status);
  }
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const reason = stringField(body, "reason");
  if (!UUID_PATTERN.test(requestId) || reason === "") {
    return errorResponse("INVALID_ADMIN_MUTATION", "request_id UUID and reason are required.", 400);
  }
  switch (route) {
    case "admin_disable": {
      const targetStatus = "paused";
      const requestHash = await mutationRequestHash("modes/admin/disable", body, {
        request_id: requestId,
        mode_id: stringField(body, "mode_id"),
        reason,
        target_status: targetStatus,
      });
      return await handleAdminModeStatus(
        config,
        auth.userId,
        body,
        requestId,
        requestHash,
        reason,
        targetStatus,
      );
    }
    case "admin_enable": {
      const targetStatus = stringField(body, "target_status") || "internal_alpha";
      const requestHash = await mutationRequestHash("modes/admin/enable", body, {
        request_id: requestId,
        mode_id: stringField(body, "mode_id"),
        reason,
        target_status: targetStatus,
      });
      return await handleAdminModeStatus(
        config,
        auth.userId,
        body,
        requestId,
        requestHash,
        reason,
        targetStatus,
      );
    }
    case "admin_session_expire":
      return await handleAdminSessionRpc(config, auth.userId, body, requestId, reason, "expired");
    case "admin_session_invalidate":
      return await handleAdminSessionRpc(
        config,
        auth.userId,
        body,
        requestId,
        reason,
        "invalidated",
      );
    case "admin_reconcile":
      return await handleAdminReconcile(config, body, requestId);
    case "admin_compensate":
      return await handleAdminCompensate(config, auth.userId, body, requestId, reason);
    default:
      return errorResponse("NOT_FOUND", "Unknown admin route.", 404);
  }
}

async function handleAdminModeStatus(
  config: EdgeConfig,
  actorAuthUserId: string,
  body: Record<string, unknown>,
  requestId: string,
  requestHash: string,
  reason: string,
  status: string,
): Promise<Response> {
  const modeId = stringField(body, "mode_id");
  if (modeId === "") return errorResponse("INVALID_MODE", "mode_id is required.", 400);
  const rpc = await restRequest<unknown>(config, "rpc/admin_set_mode_status_v1", {
    method: "POST",
    body: JSON.stringify({
      p_mode_id: modeId,
      p_status: status,
      p_reason: reason,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_actor_auth_user_id: actorAuthUserId,
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapModeDatabaseError(rpc.error, "MODE_ADMIN_STATUS_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(foundationRpcPayload(rpc.value));
}

async function handleAdminSessionRpc(
  config: EdgeConfig,
  actorAuthUserId: string,
  body: Record<string, unknown>,
  requestId: string,
  reason: string,
  status: string,
): Promise<Response> {
  const sessionId = stringField(body, "session_id");
  if (!UUID_PATTERN.test(sessionId)) {
    return errorResponse("INVALID_SESSION", "session_id must be a UUID.", 400);
  }
  const endpoint = status === "expired"
    ? "modes/admin/session/expire"
    : "modes/admin/session/invalidate";
  const requestHash = await mutationRequestHash(endpoint, body, {
    request_id: requestId,
    session_id: sessionId,
    reason,
    status,
  });
  const rpcName = status === "expired"
    ? "rpc/admin_expire_mode_session_v1"
    : "rpc/admin_invalidate_mode_session_v1";
  const rpc = await restRequest<unknown>(config, rpcName, {
    method: "POST",
    body: JSON.stringify({
      p_session_id: sessionId,
      p_reason: reason,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_actor_auth_user_id: actorAuthUserId,
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapModeDatabaseError(rpc.error, "MODE_ADMIN_SESSION_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(foundationRpcPayload(rpc.value));
}

async function handleAdminReconcile(
  config: EdgeConfig,
  body: Record<string, unknown>,
  requestId: string,
): Promise<Response> {
  const modeId = stringField(body, "mode_id") || OPENWORLD_MODE_ID;
  const sessions = await loadSessions(config, stringField(body, "game_save_id"), modeId);
  const claims = await loadClaims(config, stringField(body, "game_save_id"), modeId);
  return jsonResponse({
    ok: true,
    schema_version: "mode_admin_v1",
    request_id: requestId,
    mode_id: modeId,
    sessions: sessions.error === null ? sessions.value : [],
    claims: claims.error === null ? claims.value : [],
    server_time: new Date().toISOString(),
  });
}

async function handleAdminCompensate(
  config: EdgeConfig,
  actorAuthUserId: string,
  body: Record<string, unknown>,
  requestId: string,
  reason: string,
): Promise<Response> {
  const gameSaveId = stringField(body, "game_save_id");
  if (!UUID_PATTERN.test(gameSaveId)) {
    return errorResponse("INVALID_GAME_SAVE_ID", "game_save_id must be a UUID.", 400);
  }
  const rpc = await restRequest<unknown>(config, "rpc/admin_adjust_resource_balance_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: gameSaveId,
      p_delta: isObject(body.delta) ? body.delta : {},
      p_reason: reason,
      p_request_id: requestId,
      p_actor_auth_user_id: actorAuthUserId,
    }),
  });
  if (rpc.error !== null) {
    return errorResponse("MODE_ADMIN_COMPENSATE_FAILED", rpc.error.message, 500);
  }
  return jsonResponse(foundationRpcPayload(rpc.value));
}

async function loadModeState(
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

async function loadRegistry(
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

async function loadRulesets(
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

async function loadSessions(
  config: EdgeConfig,
  gameSaveId: string,
  modeId: string,
): Promise<{ value: ModeSessionRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<ModeSessionRow[]>(
    config,
    `mode_sessions?game_save_id=eq.${encodeURIComponent(gameSaveId)}&mode_id=eq.${
      encodeURIComponent(modeId)
    }&select=id,game_save_id,mode_id,slice_id,ruleset_id,ruleset_version,status,server_seed,session_seconds,activity_score,deposited_items,result_payload,reward_payload,started_at,completed_at,expires_at,abandoned_at,invalidated_at,invalidated_reason&order=started_at.desc&limit=20`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

async function loadClaims(
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

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/registry")) return "registry";
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/session/start")) return "session_start";
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

async function loadAdminRole(
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

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
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

function mapModeDatabaseError(error: RestError, fallbackCode: string): RestError {
  const message = error.message.toUpperCase();
  const codes = [
    "INVALID_MODE",
    "INVALID_RULESET",
    "INVALID_SESSION",
    "INVALID_RESULT",
    "MODE_SESSION_NOT_FOUND",
    "MODE_SESSION_ALREADY_COMPLETED",
    "MODE_RESULT_REJECTED",
    "MODE_REWARD_BLOCKED_FOR_LAB",
    "MODE_REWARD_APPLY_FAILED",
    "MODE_DISABLED",
    "MODE_SESSION_UNSUPPORTED",
    "MODE_SESSION_NOT_ACTIVE",
    "INVALID_MODE_STATUS",
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
    code === "IDEMPOTENCY_HASH_MISMATCH"
  ) return 409;
  if (
    code === "INVALID_MODE" ||
    code === "INVALID_RULESET" ||
    code === "INVALID_SESSION" ||
    code === "INVALID_MODE_STATUS" ||
    code === "INVALID_RESULT" ||
    code === "MODE_RESULT_REJECTED" ||
    code === "MODE_SESSION_UNSUPPORTED"
  ) return 400;
  return fallback >= 400 ? fallback : 500;
}

function modeErrorMessage(code: string): string {
  switch (code) {
    case "IDEMPOTENCY_HASH_MISMATCH":
      return "request_id was already used with a different request_hash.";
    case "INVALID_MODE":
      return "Only openworld/forest is available in Mode Platform v0.";
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

function sessionPayloadPublic(row: ModeSessionRow): Record<string, unknown> {
  return {
    id: row.id,
    mode_id: row.mode_id,
    slice_id: row.slice_id,
    ruleset_id: row.ruleset_id,
    ruleset_version: Number(row.ruleset_version || 1),
    status: row.status,
    session_seconds: row.session_seconds ?? null,
    activity_score: row.activity_score ?? null,
    deposited_items: isObject(row.deposited_items) ? row.deposited_items : {},
    result_payload: isObject(row.result_payload) ? row.result_payload : {},
    reward_payload: isObject(row.reward_payload) ? row.reward_payload : {},
    started_at: row.started_at ?? null,
    completed_at: row.completed_at ?? null,
    expires_at: row.expires_at ?? null,
    abandoned_at: row.abandoned_at ?? null,
    invalidated_at: row.invalidated_at ?? null,
    invalidated_reason: row.invalidated_reason ?? "",
  };
}

function stateReadError(): RestError {
  return { code: "STATE_READ_FAILED", message: "Unable to load mode state.", status: 500 };
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
