import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  AUTOBATTLER_MODE_ID,
  BASEBUILDER_MODE_ID,
  canonicalCompletionPayload,
  CARDGAME_MODE_ID,
  completionResultFromBody,
  MODE_ENDPOINT_SESSION_ABANDON,
  MODE_ENDPOINT_SESSION_COMPLETE,
  MODE_ENDPOINT_SESSION_EVENT,
  MODE_ENDPOINT_SESSION_START,
  modeRegistryPayload,
  modeStatePayload,
  OPENWORLD_MODE_ID,
  OPENWORLD_RELEASE_CHANNEL,
  OPENWORLD_RULESET_ID,
  OPENWORLD_RULESET_VERSION,
  OPENWORLD_SLICE_ID,
  sessionEventFromBody,
  TOWERDEFENSE_MODE_ID,
} from "../_shared/mode_domain.ts";
import {
  foundationRpcPayload,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";
import {
  type AuthContext,
  type EdgeConfig,
  type Route,
  UUID_PATTERN,
  decodeAuthContext,
  errorResponse,
  isObject,
  loadAdminRole,
  loadClaims,
  loadConfig,
  loadModeState,
  loadRegistry,
  loadRulesets,
  loadSessions,
  mapModeDatabaseError,
  readJsonObject,
  resolveRoute,
  restRequest,
  stringField,
} from "./mode_support.ts";

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
      if (route === "session_event") {
        return await handleSessionEvent(request, auth.value, config.value);
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
  return internalModeHandler.handle(request).then((response) => withCorsResponse(request, response));
}

async function handleRegistry(config: EdgeConfig): Promise<Response> {
  const startedAtMs = performance.now();
  const registry = await loadRegistry(config, "");
  if (registry.error !== null) {
    return errorResponse(registry.error.code, registry.error.message, registry.error.status);
  }
  const rulesets = await loadRulesets(config, "");
  if (rulesets.error !== null) {
    return errorResponse(rulesets.error.code, rulesets.error.message, rulesets.error.status);
  }
  return jsonResponse(stateEnvelope(modeRegistryPayload(registry.value, rulesets.value, new Date()), {
    surface: "mode",
    schemaVersion: "mode_registry_v1",
    startedAtMs,
  }));
}

async function handleState(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const startedAtMs = performance.now();
  const modeId = new URL(request.url).searchParams.get("mode_id")?.trim() ?? OPENWORLD_MODE_ID;
  if (modeId === "") {
    return errorResponse("INVALID_MODE", "mode_id is not part of Mode Platform V1.", 400);
  }
  const state = await loadModeState(auth, config, modeId);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(stateEnvelope(modeStatePayload({ ...state.value, serverTime: new Date() }), {
    surface: "mode",
    saveType: auth.saveType,
    startedAtMs,
  }));
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
  return jsonResponse(stateEnvelope(foundationRpcPayload(rpc.value), {
    surface: "mode",
    saveType: auth.saveType,
  }));
}

async function handleSessionEvent(
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
  const event = sessionEventFromBody(body);
  if (event === null || !UUID_PATTERN.test(event.session_id)) {
    return errorResponse("INVALID_MODE_EVENT", "Openworld session event is invalid.", 400);
  }

  const state = await loadModeState(auth, config, OPENWORLD_MODE_ID);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const canonicalEvent = {
    request_id: requestId,
    save_type: auth.saveType,
    session_id: event.session_id,
    mode_id: event.mode_id,
    slice_id: event.slice_id,
    event_type: event.event_type,
    expected_revision: event.expected_revision,
    event_payload: event.event_payload,
  };
  const requestHash = await mutationRequestHash(MODE_ENDPOINT_SESSION_EVENT, body, canonicalEvent);
  const rpc = await restRequest<unknown>(config, "rpc/mode_session_event_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: canonicalEvent,
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapModeDatabaseError(rpc.error, "MODE_SESSION_EVENT_FAILED");
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
  return jsonResponse(stateEnvelope(foundationRpcPayload(rpc.value), {
    surface: "mode",
    saveType: auth.saveType,
  }));
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
  const canonicalAbandon = {
    request_id: requestId,
    save_type: auth.saveType,
    mode_id: modeId,
    slice_id: OPENWORLD_SLICE_ID,
    session_id: sessionId,
    reason: stringField(body, "reason"),
  };
  const requestHash = await mutationRequestHash(MODE_ENDPOINT_SESSION_ABANDON, body, canonicalAbandon);
  const rpc = await restRequest<unknown>(config, "rpc/mode_session_abandon_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: canonicalAbandon,
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapModeDatabaseError(rpc.error, "MODE_SESSION_ABANDON_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(stateEnvelope(foundationRpcPayload(rpc.value), {
    surface: "mode",
    saveType: auth.saveType,
  }));
}

async function handleAnalyticsSummary(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const startedAtMs = performance.now();
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
  return jsonResponse(stateEnvelope({
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
  }, {
    surface: "mode",
    saveType: auth.saveType,
    schemaVersion: "mode_analytics_v1",
    startedAtMs,
  }));
}

async function handleAdminRoute(
  route: Route,
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const admin = await loadAdminRole(config, auth.userId);
  if (route === "admin_me") {
    return jsonResponse(stateEnvelope({
      ok: true,
      schema_version: "mode_admin_v1",
      admin: admin.value,
      server_time: new Date().toISOString(),
    }, {
      surface: "mode",
      saveType: auth.saveType,
      schemaVersion: "mode_admin_v1",
    }), admin.error === null ? 200 : 403);
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
  return jsonResponse(stateEnvelope(foundationRpcPayload(rpc.value), {
    surface: "mode",
  }));
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
  return jsonResponse(stateEnvelope(foundationRpcPayload(rpc.value), {
    surface: "mode",
  }));
}

async function handleAdminReconcile(
  config: EdgeConfig,
  body: Record<string, unknown>,
  requestId: string,
): Promise<Response> {
  const modeId = stringField(body, "mode_id") || OPENWORLD_MODE_ID;
  const sessions = await loadSessions(config, stringField(body, "game_save_id"), modeId);
  const claims = await loadClaims(config, stringField(body, "game_save_id"), modeId);
  return jsonResponse(stateEnvelope({
    ok: true,
    schema_version: "mode_admin_v1",
    request_id: requestId,
    mode_id: modeId,
    sessions: sessions.error === null ? sessions.value : [],
    claims: claims.error === null ? claims.value : [],
    server_time: new Date().toISOString(),
  }, {
    surface: "mode",
    schemaVersion: "mode_admin_v1",
  }));
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
  return jsonResponse(stateEnvelope(foundationRpcPayload(rpc.value), {
    surface: "mode",
  }));
}
