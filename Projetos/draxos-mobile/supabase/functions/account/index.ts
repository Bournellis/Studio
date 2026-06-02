import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  normalizeSaveType,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";

type Route = "bootstrap" | "guest" | "state" | "save_reset";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
  isAnonymous: boolean;
  saveType: SaveType;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

interface PlayerRow {
  id: string;
  username: string | null;
  account_type: string;
  save_type: SaveType;
  level: number;
  xp: number;
  power: number;
  created_at: string;
  updated_at: string;
}

interface ResourceRow {
  player_id: string;
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  po_osso: string | number;
  diamante: number;
  updated_at: string;
}

interface BuildRow {
  player_id: string;
  weapon_type: string;
  weapon_quality: string;
  weapon_level: number;
  spell_slots: unknown[];
  spells_unlocked: unknown[];
  pet_id: string | null;
  pet_level: number;
  passive_id: string | null;
  passive_level: number;
  updated_at: string;
}

interface BattleRow {
  id: string;
}

interface FoundationContext {
  account?: unknown;
  save?: unknown;
  ruleset?: unknown;
}

interface JwtPayload {
  sub?: unknown;
  is_anonymous?: unknown;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const DEFAULT_POTION_BEHAVIOR = {
  enabled: true,
  hp: { mode: "below", percent: 40 },
  mana: { mode: "ignore", percent: 0 },
};

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
      return errorResponse("NOT_FOUND", "Unknown account endpoint.", 404);
    }

    if (route === "guest" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /account/guest.", 405);
    }

    if (route === "bootstrap" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /account/bootstrap.", 405);
    }

    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /account/state.", 405);
    }

    if (route === "save_reset" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /account/saves/reset.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "guest") {
      return await handleGuest(request, auth.value, config.value);
    }
    if (route === "bootstrap") {
      return await handleBootstrap(request, auth.value, config.value);
    }
    if (route === "save_reset") {
      return await handleSaveReset(request, auth.value, config.value);
    }

    return await handleState(auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected account service error.", 500);
  }

}

async function handleGuest(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  if (!auth.isAnonymous) {
    return errorResponse(
      "AUTH_NOT_ANONYMOUS",
      "Use an anonymous Supabase Auth session for guest account creation.",
      403,
    );
  }

  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }

  const inviteCode = stringField(body, "invite_code");
  const requestId = stringField(body, "request_id");
  const deviceLabel = stringField(body, "device_label");

  if (inviteCode === "") {
    return errorResponse("INVALID_INVITE", "invite_code is required.", 400);
  }

  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const rpc = await restRequest<unknown>(config, "rpc/create_guest_account", {
    method: "POST",
    body: JSON.stringify({
      p_auth_user_id: auth.userId,
      p_invite_code: inviteCode,
      p_request_id: requestId,
      p_device_label: deviceLabel === "" ? null : deviceLabel,
      p_save_type: auth.saveType,
    }),
  });

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const payload = withResourceDefaults(rpc.value);
  const playerId = playerIdFromPayload(payload);
  const context = playerId === "" ? null : await loadFoundationContext(config, playerId);
  if (context !== null && context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }

  return jsonResponse(
    withFoundationContext(payload, context?.value ?? null, "account_guest_response_v1"),
  );
}

async function handleBootstrap(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  if (auth.isAnonymous) {
    return errorResponse(
      "AUTH_REQUIRES_EMAIL",
      "Use email/password Supabase Auth for Internal Alpha accounts.",
      403,
    );
  }

  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }

  const inviteCode = stringField(body, "invite_code");
  const requestId = stringField(body, "request_id");
  const deviceLabel = stringField(body, "device_label");
  const username = stringField(body, "username");

  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const rpc = await restRequest<unknown>(config, "rpc/create_alpha_account", {
    method: "POST",
    body: JSON.stringify({
      p_auth_user_id: auth.userId,
      p_invite_code: inviteCode,
      p_request_id: requestId,
      p_device_label: deviceLabel === "" ? null : deviceLabel,
      p_save_type: auth.saveType,
      p_username: username === "" ? null : username,
    }),
  });

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const payload = withResourceDefaults(rpc.value);
  const playerId = playerIdFromPayload(payload);
  const context = playerId === "" ? null : await loadFoundationContext(config, playerId);
  if (context !== null && context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }

  return jsonResponse(
    withFoundationContext(payload, context?.value ?? null, "account_bootstrap_response_v1"),
  );
}

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,username,account_type,save_type,level,xp,power,created_at,updated_at&limit=1`,
    { method: "GET" },
  );

  if (playerResult.error !== null) {
    return errorResponse("STATE_READ_FAILED", "Unable to load player state.", 500);
  }

  const player = playerResult.value[0] ?? null;
  if (player === null) {
    return errorResponse("PLAYER_NOT_FOUND", "Account save was not created yet.", 404);
  }

  const playerId = encodeURIComponent(player.id);
  const resourcesResult = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=player_id,almas,energia,sangue,cristais,ossos,po_osso,diamante,updated_at&limit=1`,
    { method: "GET" },
  );
  const buildResult = await restRequest<BuildRow[]>(
    config,
    `builds?player_id=eq.${playerId}&select=player_id,weapon_type,weapon_quality,weapon_level,spell_slots,spells_unlocked,pet_id,pet_level,passive_id,passive_level,updated_at&limit=1`,
    { method: "GET" },
  );
  const battlesResult = await restRequest<BattleRow[]>(
    config,
    `battles?attacker_id=eq.${playerId}&select=id&order=created_at.desc&limit=1`,
    { method: "GET" },
  );

  if (
    resourcesResult.error !== null ||
    buildResult.error !== null ||
    battlesResult.error !== null
  ) {
    return errorResponse("STATE_READ_FAILED", "Unable to load complete account state.", 500);
  }

  const resources = resourcesResult.value[0] ?? null;
  const build = buildResult.value[0] ?? null;
  if (resources === null || build === null) {
    return errorResponse("ACCOUNT_STATE_INCOMPLETE", "Account save state is incomplete.", 409);
  }

  const context = await loadFoundationContext(config, player.id);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }

  return jsonResponse(withFoundationContext(
    {
      ok: true,
      player,
      resources,
      build,
      last_battle_id: battlesResult.value[0]?.id ?? null,
    },
    context.value,
    "account_state_v1",
  ));
}

async function handleSaveReset(
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

  const bodySaveType = stringField(body, "save_type");
  if (bodySaveType !== "") {
    const normalizedBodySaveType = normalizeSaveType(bodySaveType);
    if (normalizedBodySaveType === null) {
      return errorResponse(
        "INVALID_SAVE_TYPE",
        "Save type must be normal or progression_lab.",
        400,
      );
    }
    if (normalizedBodySaveType !== auth.saveType) {
      return errorResponse(
        "SAVE_TYPE_MISMATCH",
        "Request save_type must match x-draxos-save-type.",
        409,
      );
    }
  }

  const rpc = await restRequest<unknown>(config, "rpc/reset_player_save", {
    method: "POST",
    body: JSON.stringify({
      p_auth_user_id: auth.userId,
      p_request_id: requestId,
      p_save_type: auth.saveType,
    }),
  });

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const playerId = playerIdFromPayload(rpc.value);
  if (playerId !== "") {
    const cleanup = await resetConsumableAndBehaviorState(config, playerId);
    if (cleanup !== null) {
      return errorResponse(cleanup.code, cleanup.message, cleanup.status);
    }
  }

  const payload = withResourceDefaults(rpc.value);
  const resetPayloadPlayerId = playerIdFromPayload(payload);
  const context = resetPayloadPlayerId === ""
    ? null
    : await loadFoundationContext(config, resetPayloadPlayerId);
  if (context !== null && context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }

  return jsonResponse(
    withFoundationContext(payload, context?.value ?? null, "account_save_reset_response_v1"),
  );
}

async function resetConsumableAndBehaviorState(
  config: EdgeConfig,
  playerId: string,
): Promise<RestError | null> {
  const tables = [
    "player_consumables",
    "player_spell_behaviors",
    "player_potion_slots",
    "item_transactions",
  ];

  for (const table of tables) {
    const result = await restRequest<unknown>(
      config,
      `${table}?player_id=eq.${encodeURIComponent(playerId)}`,
      { method: "DELETE" },
    );
    if (result.error !== null) {
      return {
        code: "RESET_TRACK16_STATE_FAILED",
        message: "Unable to reset consumables and behavior state.",
        status: 500,
      };
    }
  }

  const slotResult = await restRequest<unknown>(
    config,
    "player_potion_slots?on_conflict=player_id,slot_index",
    {
      method: "POST",
      headers: { prefer: "resolution=merge-duplicates" },
      body: JSON.stringify({
        player_id: playerId,
        slot_index: 1,
        potion_id: null,
        behavior: DEFAULT_POTION_BEHAVIOR,
      }),
    },
  );

  if (slotResult.error !== null) {
    return {
      code: "RESET_TRACK16_STATE_FAILED",
      message: "Unable to recreate default potion slot.",
      status: 500,
    };
  }

  return null;
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/saves/reset")) {
    return "save_reset";
  }

  if (pathname.endsWith("/bootstrap")) {
    return "bootstrap";
  }

  if (pathname.endsWith("/guest")) {
    return "guest";
  }

  if (pathname.endsWith("/state")) {
    return "state";
  }

  return null;
}

function decodeAuthContext(request: Request): { value: AuthContext; error: null } | {
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
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
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

  return {
    value: { userId: payload.sub, isAnonymous: payload.is_anonymous === true, saveType },
    error: null,
  };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const decoded = new TextDecoder().decode(bytes);
    const payload: unknown = JSON.parse(decoded);
    if (payload !== null && typeof payload === "object" && !Array.isArray(payload)) {
      return payload as JwtPayload;
    }
  } catch {
    return null;
  }

  return null;
}

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Account function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }

  return {
    value: {
      supabaseUrl: supabaseUrl.replace(/\/$/, ""),
      serviceRoleKey,
    },
    error: null,
  };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    if (payload !== null && typeof payload === "object" && !Array.isArray(payload)) {
      return payload as Record<string, unknown>;
    }
  } catch {
    return null;
  }

  return null;
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
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
    const body = data !== null && typeof data === "object" && !Array.isArray(data)
      ? data as Record<string, unknown>
      : {};

    return {
      value: null,
      error: {
        code: stringValue(body.code, "REST_ERROR"),
        message: stringValue(body.message, response.statusText),
        status: response.status,
      },
    };
  }

  return {
    value: data as T,
    error: null,
  };
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function playerIdFromPayload(payload: unknown): string {
  if (payload === null || typeof payload !== "object" || Array.isArray(payload)) {
    return "";
  }

  const root = payload as Record<string, unknown>;
  const player = root.player;
  if (player === null || typeof player !== "object" || Array.isArray(player)) {
    return "";
  }

  return stringValue((player as Record<string, unknown>).id, "");
}

function withResourceDefaults(payload: unknown): unknown {
  if (payload === null || typeof payload !== "object" || Array.isArray(payload)) {
    return payload;
  }

  const root = payload as Record<string, unknown>;
  const resources = root.resources;
  if (resources !== null && typeof resources === "object" && !Array.isArray(resources)) {
    const resourceMap = resources as Record<string, unknown>;
    if (resourceMap.po_osso === undefined) {
      resourceMap.po_osso = 0;
    }
  }

  return payload;
}

async function loadFoundationContext(
  config: EdgeConfig,
  playerId: string,
): Promise<
  { value: FoundationContext; error: null } | { value: null; error: RestError }
> {
  const contextResult = await restRequest<unknown>(
    config,
    "rpc/foundation_account_context_v1",
    {
      method: "POST",
      body: JSON.stringify({ p_player_id: playerId }),
    },
  );
  if (contextResult.error !== null) {
    const mapped = mapDatabaseError(contextResult.error);
    return {
      value: null,
      error: {
        code: mapped.code === "ACCOUNT_CREATE_FAILED"
          ? "FOUNDATION_CONTEXT_NOT_FOUND"
          : mapped.code,
        message: mapped.code === "ACCOUNT_CREATE_FAILED"
          ? "Account/save foundation context was not created yet."
          : mapped.message,
        status: mapped.code === "ACCOUNT_CREATE_FAILED" ? 500 : mapped.status,
      },
    };
  }
  const context = isObject(contextResult.value) ? contextResult.value : {};
  return {
    value: {
      account: context.account ?? null,
      save: context.save ?? null,
      ruleset: context.ruleset ?? null,
    },
    error: null,
  };
}

function withFoundationContext(
  payload: unknown,
  context: FoundationContext | null,
  schemaVersion: string,
): unknown {
  if (!isObject(payload)) {
    return payload;
  }
  return {
    schema_version: schemaVersion,
    api_version: 1,
    account: context?.account ?? null,
    save: context?.save ?? null,
    ruleset: context?.ruleset ?? null,
    ...payload,
  };
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function mapDatabaseError(error: RestError): RestError {
  const message = error.message.toUpperCase();

  if (message.includes("INVALID_INVITE")) {
    return {
      code: "INVALID_INVITE",
      message: "Invite code is invalid or expired.",
      status: 400,
    };
  }

  if (message.includes("INVITE_EXHAUSTED")) {
    return {
      code: "INVITE_EXHAUSTED",
      message: "Invite code has no remaining uses.",
      status: 409,
    };
  }

  if (message.includes("ACCOUNT_ALREADY_CREATED")) {
    return {
      code: "ACCOUNT_ALREADY_CREATED",
      message: "This auth session already has this save.",
      status: 409,
    };
  }

  if (message.includes("AUTH_REQUIRES_EMAIL")) {
    return {
      code: "AUTH_REQUIRES_EMAIL",
      message: "Email/password auth is required for this account action.",
      status: 403,
    };
  }

  if (message.includes("INVALID_USERNAME")) {
    return {
      code: "INVALID_USERNAME",
      message: "Username must use 3 to 24 lowercase letters, numbers or underscores.",
      status: 400,
    };
  }

  if (message.includes("USERNAME_TAKEN")) {
    return {
      code: "USERNAME_TAKEN",
      message: "Username is already in use.",
      status: 409,
    };
  }

  if (message.includes("INVALID_REQUEST_ID")) {
    return {
      code: "INVALID_REQUEST_ID",
      message: "request_id must be a UUID.",
      status: 400,
    };
  }

  if (message.includes("INVALID_SAVE_TYPE")) {
    return {
      code: "INVALID_SAVE_TYPE",
      message: "Save type must be normal or progression_lab.",
      status: 400,
    };
  }

  if (message.includes("PLAYER_NOT_FOUND")) {
    return {
      code: "PLAYER_NOT_FOUND",
      message: "Account save was not created yet.",
      status: 404,
    };
  }

  if (message.includes("GAME_SAVE_NOT_FOUND")) {
    return {
      code: "GAME_SAVE_NOT_FOUND",
      message: "Account save foundation row was not created yet.",
      status: 404,
    };
  }

  if (message.includes("ACCOUNT_PROFILE_NOT_FOUND")) {
    return {
      code: "ACCOUNT_PROFILE_NOT_FOUND",
      message: "Account profile foundation row was not created yet.",
      status: 404,
    };
  }

  if (message.includes("UNAUTHENTICATED")) {
    return {
      code: "UNAUTHENTICATED",
      message: "Authenticated Supabase session is required.",
      status: 401,
    };
  }

  return {
    code: "ACCOUNT_CREATE_FAILED",
    message: "Account save could not be created.",
    status: error.status >= 400 ? error.status : 500,
  };
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({
    ok: false,
    error: {
      code,
      message,
    },
  }, status);
}
