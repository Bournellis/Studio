import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

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
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const EVENT_TYPE_PATTERN = /^[a-z0-9_.:/-]{3,80}$/;
const SCHEMA_VERSION = "telemetry_client_v1";

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    if (!new URL(request.url).pathname.endsWith("/client-event")) {
      return errorResponse("NOT_FOUND", "Unknown telemetry endpoint.", 404);
    }
    if (request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /telemetry/client-event.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    return await handleClientEvent(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected telemetry service error.", 500);
  }
});

async function handleClientEvent(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }

  const schemaVersion = stringField(body, "schema_version");
  const eventType = stringField(body, "event_type");
  const sessionId = stringField(body, "session_id");
  const payload = objectField(body, "payload") ?? {};

  if (schemaVersion !== SCHEMA_VERSION) {
    return errorResponse("UNSUPPORTED_SCHEMA", "Use telemetry_client_v1.", 400);
  }
  if (!EVENT_TYPE_PATTERN.test(eventType)) {
    return errorResponse("INVALID_EVENT_TYPE", "event_type is invalid.", 400);
  }
  if (!UUID_PATTERN.test(sessionId)) {
    return errorResponse("INVALID_SESSION_ID", "session_id must be a UUID.", 400);
  }

  const playerId = await loadPlayerId(auth, config);
  if (playerId.error !== null) {
    return errorResponse(playerId.error.code, playerId.error.message, playerId.error.status);
  }

  const insert = await restRequest<unknown>(config, "telemetry_events", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId.value,
      session_id: sessionId,
      event_type: eventType,
      schema_version: schemaVersion,
      source: "client",
      payload,
    }),
  });

  if (insert.error !== null) {
    return errorResponse("TELEMETRY_WRITE_FAILED", "Unable to record client event.", 500);
  }

  return jsonResponse({
    ok: true,
    accepted: true,
    event_type: eventType,
    session_id: sessionId,
  });
}

async function loadPlayerId(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: string | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return {
      value: null,
      error: {
        code: "STATE_READ_FAILED",
        message: "Unable to resolve telemetry player context.",
        status: 500,
      },
    };
  }
  return { value: result.value[0]?.id ?? null, error: null };
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
        message: "Telemetry function is missing Supabase runtime configuration.",
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

function objectField(
  payload: Record<string, unknown>,
  key: string,
): Record<string, unknown> | null {
  const value = payload[key];
  return isObject(value) ? value : null;
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
