import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";
import {
  BASE_STRUCTURES,
  type BaseConstructionJobRow as ConstructionJobRow,
  type BaseResourceKey as ResourceKey,
  type BaseResourceRow as ResourceRow,
  baseStatePayload,
  type BaseStructureRow,
  DEFAULT_CONSTRUCTION_SLOTS,
  definitionFor,
  DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID,
} from "../_shared/base_domain.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "state" | "collect" | "upgrade";

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
  is_anonymous?: unknown;
}

interface PlayerRow {
  id: string;
  save_type: SaveType;
  level: number;
}

interface GameSaveRow {
  id: string;
  account_profile_id: string;
  legacy_player_id: string;
  save_type: SaveType;
  ruleset_id: string;
  ruleset_version: number;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request: Request) => {
  return withCorsResponse(request, await handleCorsRequest(request));
});

async function handleCorsRequest(request: Request): Promise<Response> {
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
      return errorResponse("NOT_FOUND", "Unknown base endpoint.", 404);
    }

    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /base/state.", 405);
    }
    if (route === "collect" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /base/collect.",
        405,
      );
    }
    if (route === "upgrade" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /base/upgrade.",
        405,
      );
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(
        auth.error.code,
        auth.error.message,
        auth.error.status,
      );
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(
        config.error.code,
        config.error.message,
        config.error.status,
      );
    }

    if (route === "state") {
      return await handleState(auth.value, config.value);
    }
    if (route === "collect") {
      return await handleCollect(request, auth.value, config.value);
    }
    return await handleUpgrade(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse(
      "INTERNAL_ERROR",
      "Unexpected base service error.",
      500,
    );
  }

}

async function handleState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const startedAtMs = performance.now();
  const state = await loadBaseState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }
  const completion = await completeDueJobs(config, state.value.player.id);
  if (completion !== null) {
    return errorResponse(completion.code, completion.message, completion.status);
  }
  const refreshed = await loadBaseState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(
      refreshed.error.code,
      refreshed.error.message,
      refreshed.error.status,
    );
  }
  return jsonResponse(stateEnvelope(baseStatePayload(refreshed.value), {
    surface: "base",
    saveType: auth.saveType,
    startedAtMs,
  }));
}

async function handleCollect(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse(
      "INVALID_JSON",
      "Request body must be a JSON object.",
      400,
    );
  }
  const requestId = stringField(body, "request_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse(
      "INVALID_REQUEST_ID",
      "request_id must be a UUID.",
      400,
    );
  }

  const state = await loadBaseState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }
  const requestHash = await mutationRequestHash("base/collect", body, {
    request_id: requestId,
    save_type: auth.saveType,
  });
  const rpc = await restRequest<unknown>(config, "rpc/collect_base_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapBaseDatabaseError(rpc.error, "BASE_COLLECT_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = baseRpcPayload(rpc.value);

  const finalState = await loadBaseState(auth, config);
  if (finalState.error !== null) {
    return errorResponse(
      finalState.error.code,
      finalState.error.message,
      finalState.error.status,
    );
  }
  const responsePayload = {
    ...baseStatePayload(finalState.value),
    collected: rpcPayload.collected,
    mutation: rpcPayload.mutation,
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "base",
    saveType: auth.saveType,
  }));
}

async function handleUpgrade(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse(
      "INVALID_JSON",
      "Request body must be a JSON object.",
      400,
    );
  }
  const requestId = stringField(body, "request_id");
  const structureId = stringField(body, "structure_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse(
      "INVALID_REQUEST_ID",
      "request_id must be a UUID.",
      400,
    );
  }
  const definition = definitionFor(structureId);
  if (definition === undefined) {
    return errorResponse(
      "INVALID_STRUCTURE",
      "structure_id is not part of Base v0.",
      400,
    );
  }

  const state = await loadBaseState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }
  const requestHash = await mutationRequestHash("base/upgrade", body, {
    request_id: requestId,
    save_type: auth.saveType,
    structure_id: structureId,
  });
  const rpc = await restRequest<unknown>(config, "rpc/start_base_upgrade_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        structure_id: structureId,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapBaseDatabaseError(rpc.error, "BASE_UPGRADE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = baseRpcPayload(rpc.value);

  const finalState = await loadBaseState(auth, config);
  if (finalState.error !== null) {
    return errorResponse(
      finalState.error.code,
      finalState.error.message,
      finalState.error.status,
    );
  }
  const responsePayload = {
    ...baseStatePayload(finalState.value),
    job: rpcPayload.job,
    mutation: rpcPayload.mutation,
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "base",
    saveType: auth.saveType,
  }));
}

async function loadBaseState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<
  {
    value: {
      player: PlayerRow;
      gameSave: GameSaveRow;
      resources: ResourceRow;
      structures: BaseStructureRow[];
      jobs: ConstructionJobRow[];
      constructionSlots: number;
    };
    error: null;
  } | { value: null; error: RestError }
> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,save_type,level&limit=1`,
    { method: "GET" },
  );
  if (playerResult.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const player = playerResult.value[0] ?? null;
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

  const playerId = encodeURIComponent(player.id);
  const gameSavePromise = loadGameSave(config, auth, player.id);
  const constructionSlotsPromise = loadConstructionSlots(config, player.id);
  const resourcesPromise = restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=player_id,almas,energia,sangue,cristais,ossos,po_osso,diamante,updated_at&limit=1`,
    { method: "GET" },
  );
  const jobsPromise = restRequest<ConstructionJobRow[]>(
    config,
    `construction_jobs?player_id=eq.${playerId}&select=*&order=created_at.desc`,
    { method: "GET" },
  );

  await ensureBaseRows(config, player.id);
  const [gameSave, constructionSlots, resourcesResult, structuresResult, jobsResult] =
    await Promise.all([
      gameSavePromise,
      constructionSlotsPromise,
      resourcesPromise,
      restRequest<BaseStructureRow[]>(
        config,
        `base_structures?player_id=eq.${playerId}&select=player_id,structure_id,level,last_collected_at,updated_at&order=structure_id.asc`,
        { method: "GET" },
      ),
      jobsPromise,
    ]);
  if (gameSave.error !== null) {
    return { value: null, error: gameSave.error };
  }
  if (constructionSlots.error !== null) {
    return { value: null, error: constructionSlots.error };
  }
  if (
    resourcesResult.error !== null || structuresResult.error !== null ||
    jobsResult.error !== null
  ) {
    return { value: null, error: stateReadError() };
  }
  const resources = resourcesResult.value[0] ?? null;
  if (resources === null || structuresResult.value.length < BASE_STRUCTURES.length) {
    return {
      value: null,
      error: {
        code: "BASE_STATE_INCOMPLETE",
        message: "Base state is incomplete.",
        status: 409,
      },
    };
  }
  return {
    value: {
      player,
      gameSave: gameSave.value,
      resources,
      structures: structuresResult.value,
      jobs: jobsResult.value,
      constructionSlots: constructionSlots.value,
    },
    error: null,
  };
}

async function loadConstructionSlots(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: number; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<{ id: string }[]>(
    config,
    `alpha_purchases?player_id=eq.${encodeURIComponent(playerId)}&product_id=eq.${
      encodeURIComponent(DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID)
    }&select=id&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  return {
    value: result.value.length > 0 ? 2 : DEFAULT_CONSTRUCTION_SLOTS,
    error: null,
  };
}

async function loadGameSave(
  config: EdgeConfig,
  auth: AuthContext,
  playerId: string,
): Promise<
  { value: GameSaveRow; error: null } | { value: null; error: RestError }
> {
  const query = `game_saves?legacy_player_id=eq.${encodeURIComponent(playerId)}&save_type=eq.${
    encodeURIComponent(auth.saveType)
  }&lifecycle_status=eq.active&select=id,account_profile_id,legacy_player_id,save_type,ruleset_id,ruleset_version&limit=1`;
  const existing = await restRequest<GameSaveRow[]>(config, query, {
    method: "GET",
  });
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
        p_auth_user_id: auth.userId,
        p_ruleset_id: "foundation_ruleset_v0",
      }),
    },
  );
  if (ensure.error !== null) {
    const mapped = mapBaseDatabaseError(ensure.error, "GAME_SAVE_NOT_FOUND");
    return { value: null, error: mapped };
  }

  const created = await restRequest<GameSaveRow[]>(config, query, {
    method: "GET",
  });
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

async function ensureBaseRows(
  config: EdgeConfig,
  playerId: string,
): Promise<void> {
  await Promise.all(BASE_STRUCTURES.map((definition) =>
    restRequest<unknown>(config, "base_structures", {
      method: "POST",
      headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
      body: JSON.stringify({
        player_id: playerId,
        structure_id: definition.id,
      }),
    })
  ));
}

async function completeDueJobs(
  config: EdgeConfig,
  playerId: string,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(
    config,
    "rpc/complete_due_base_jobs_v1",
    {
      method: "POST",
      body: JSON.stringify({
        p_player_id: playerId,
      }),
    },
  );
  return result.error === null
    ? null
    : mapBaseDatabaseError(result.error, "BASE_JOB_COMPLETION_FAILED");
}

async function mutationRequestHash(
  endpoint: string,
  body: Record<string, unknown>,
  canonicalPayload: Record<string, unknown>,
): Promise<string> {
  const explicitHash = stringField(body, "request_hash");
  if (explicitHash !== "") {
    return explicitHash;
  }
  return `sha256:${await sha256Hex(stableStringify({
    endpoint,
    payload: canonicalPayload,
  }))}`;
}

function baseRpcPayload(value: unknown): {
  collected: Record<ResourceKey, number>;
  job: unknown | null;
  mutation: unknown;
} {
  const payload = isObject(value) ? value : {};
  const collected = isObject(payload.collected)
    ? {
      almas: numberValue(payload.collected.almas, 0),
      energia: numberValue(payload.collected.energia, 0),
      sangue: numberValue(payload.collected.sangue, 0),
      cristais: numberValue(payload.collected.cristais, 0),
      ossos: numberValue(payload.collected.ossos, 0),
    }
    : { almas: 0, energia: 0, sangue: 0, cristais: 0, ossos: 0 };
  return {
    collected,
    job: payload.job ?? null,
    mutation: payload,
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

function mapBaseDatabaseError(error: RestError, fallbackCode: string): RestError {
  const message = error.message.toUpperCase();
  const statusFor = (code: string): number => {
    if (
      code === "CONSTRUCTION_QUEUE_FULL" ||
      code === "STRUCTURE_ALREADY_UPGRADING" ||
      code === "LEVEL_CAP_REACHED" ||
      code === "MAX_LEVEL_REACHED" ||
      code === "INSUFFICIENT_RESOURCES" ||
      code === "IDEMPOTENCY_HASH_MISMATCH"
    ) {
      return 409;
    }
    if (
      code === "GAME_SAVE_NOT_FOUND" ||
      code === "PLAYER_NOT_FOUND" ||
      code === "RESOURCES_NOT_FOUND"
    ) {
      return 404;
    }
    if (
      code === "INVALID_GAME_SAVE_ID" ||
      code === "INVALID_PLAYER_ID" ||
      code === "INVALID_REQUEST_ID" ||
      code === "INVALID_REQUEST_HASH" ||
      code === "INVALID_STRUCTURE"
    ) {
      return 400;
    }
    return error.status >= 400 ? error.status : 500;
  };

  for (
    const code of [
      "IDEMPOTENCY_HASH_MISMATCH",
      "CONSTRUCTION_QUEUE_FULL",
      "STRUCTURE_ALREADY_UPGRADING",
      "LEVEL_CAP_REACHED",
      "MAX_LEVEL_REACHED",
      "INSUFFICIENT_RESOURCES",
      "INVALID_GAME_SAVE_ID",
      "INVALID_PLAYER_ID",
      "INVALID_REQUEST_ID",
      "INVALID_REQUEST_HASH",
      "INVALID_STRUCTURE",
      "GAME_SAVE_NOT_FOUND",
      "GAME_SAVE_WITHOUT_LEGACY_PLAYER",
      "PLAYER_NOT_FOUND",
      "RESOURCES_NOT_FOUND",
      "RULESET_NOT_FOUND",
      "BASE_STATE_INCOMPLETE",
    ]
  ) {
    if (message.includes(code)) {
      return {
        code,
        message: baseErrorMessage(code),
        status: statusFor(code),
      };
    }
  }

  return {
    code: fallbackCode,
    message: fallbackCode === "BASE_UPGRADE_FAILED"
      ? "Unable to start base upgrade."
      : "Unable to apply base mutation.",
    status: error.status >= 400 ? error.status : 500,
  };
}

function baseErrorMessage(code: string): string {
  switch (code) {
    case "IDEMPOTENCY_HASH_MISMATCH":
      return "request_id was already used with a different request_hash.";
    case "CONSTRUCTION_QUEUE_FULL":
      return "No construction slot is available.";
    case "STRUCTURE_ALREADY_UPGRADING":
      return "This structure already has an active upgrade.";
    case "LEVEL_CAP_REACHED":
      return "Structure upgrade is limited by player level.";
    case "MAX_LEVEL_REACHED":
      return "Structure is already at max level.";
    case "INSUFFICIENT_RESOURCES":
      return "Not enough Energia for this upgrade.";
    case "GAME_SAVE_NOT_FOUND":
      return "Account save foundation row was not created yet.";
    case "GAME_SAVE_WITHOUT_LEGACY_PLAYER":
      return "Account save is missing its compatibility player row.";
    case "PLAYER_NOT_FOUND":
      return "Guest account was not created yet.";
    case "RESOURCES_NOT_FOUND":
      return "Base resources were not created yet.";
    case "RULESET_NOT_FOUND":
      return "Active ruleset publication was not found.";
    case "BASE_STATE_INCOMPLETE":
      return "Base structure state is missing.";
    case "INVALID_REQUEST_HASH":
      return "request_hash must be a non-empty string.";
    case "INVALID_STRUCTURE":
      return "structure_id is not part of Base v0.";
    case "INVALID_GAME_SAVE_ID":
    case "INVALID_PLAYER_ID":
    case "INVALID_REQUEST_ID":
      return "Base mutation request is invalid.";
    default:
      return "Base mutation could not be completed.";
  }
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/collect")) return "collect";
  if (pathname.endsWith("/upgrade")) return "upgrade";
  return null;
}

function decodeAuthContext(
  request: Request,
): { value: AuthContext; error: null } | {
  value: null;
  error: RestError;
} {
  const header = request.headers.get("authorization") ?? "";
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Bearer token is required.",
        status: 401,
      },
    };
  }
  const token = header.slice(prefix.length);
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Invalid bearer token.",
        status: 401,
      },
    };
  }
  const payload = decodeJwtPayload(parts[1]);
  if (
    payload === null || typeof payload.sub !== "string" ||
    !UUID_PATTERN.test(payload.sub)
  ) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Token subject is invalid.",
        status: 401,
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
    const bytes = Uint8Array.from(
      atob(padded),
      (character) => character.charCodeAt(0),
    );
    const payload: unknown = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
}

function loadConfig(): { value: EdgeConfig; error: null } | {
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
        message: "Base function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return {
    value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey },
    error: null,
  };
}

async function readJsonObject(
  request: Request,
): Promise<Record<string, unknown> | null> {
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
  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, {
    ...init,
    headers,
  });
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

function stateReadError(): RestError {
  return {
    code: "STATE_READ_FAILED",
    message: "Unable to load base state.",
    status: 500,
  };
}

function errorResponse(
  code: string,
  message: string,
  status: number,
): Response {
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

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
