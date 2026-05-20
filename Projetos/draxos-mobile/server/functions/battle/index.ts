import { emptyResponse, jsonResponse } from "../_shared/http.ts";

type Route = "request" | "latest";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
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

interface BattleRow {
  id: string;
  schema_version: string;
  seed: string;
  defender_id: string;
  defender_is_bot: boolean;
  result: unknown;
  event_log: unknown;
  reward_payload: unknown;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown battle endpoint.", 404);
    }

    if (route === "request" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /battle/request.", 405);
    }

    if (route === "latest" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /battle/latest.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "request") {
      return await handleRequest(request, auth.value, config.value);
    }

    return await handleLatest(auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected battle service error.", 500);
  }
});

async function handleRequest(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }

  const requestId = stringField(body, "request_id");
  const mode = stringField(body, "mode") || "MVP_ONLY";

  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const rpc = await restRequest<unknown>(config, "rpc/request_mvp_battle", {
    method: "POST",
    body: JSON.stringify({
      p_auth_user_id: auth.userId,
      p_request_id: requestId,
      p_mode: mode,
    }),
  });

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  return jsonResponse(rpc.value);
}

async function handleLatest(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&select=id&limit=1`,
    { method: "GET" },
  );

  if (playerResult.error !== null) {
    return errorResponse("STATE_READ_FAILED", "Unable to load player state.", 500);
  }

  const player = playerResult.value[0] ?? null;
  if (player === null) {
    return errorResponse("PLAYER_NOT_FOUND", "Guest account was not created yet.", 404);
  }

  const battleResult = await restRequest<BattleRow[]>(
    config,
    `battles?attacker_id=eq.${
      encodeURIComponent(player.id)
    }&select=id,schema_version,seed,defender_id,defender_is_bot,result,event_log,reward_payload&order=created_at.desc&limit=1`,
    { method: "GET" },
  );

  if (battleResult.error !== null) {
    return errorResponse("BATTLE_READ_FAILED", "Unable to load latest battle.", 500);
  }

  const battle = battleResult.value[0] ?? null;
  if (battle === null) {
    return jsonResponse({
      ok: true,
      battle_log: null,
      rewards: null,
    });
  }

  return jsonResponse({
    ok: true,
    battle_log: {
      schema_version: battle.schema_version,
      battle_id: battle.id,
      seed: battle.seed,
      mode: "MVP_ONLY",
      duration: 4.2,
      participants: {
        player: { id: player.id, display_name: "Draxos" },
        opponent: {
          id: battle.defender_id,
          display_name: "Bot de Treino",
          is_bot: battle.defender_is_bot,
        },
      },
      result: battle.result,
      events: battle.event_log,
    },
    rewards: battle.reward_payload,
  });
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/request")) {
    return "request";
  }

  if (pathname.endsWith("/latest")) {
    return "latest";
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

  if (payload.is_anonymous === false) {
    return {
      value: null,
      error: {
        code: "AUTH_NOT_ANONYMOUS",
        message: "Use an anonymous Supabase Auth session for the MVP battle request.",
        status: 403,
      },
    };
  }

  return {
    value: { userId: payload.sub },
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
        message: "Battle function is missing Supabase runtime configuration.",
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

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function mapDatabaseError(error: RestError): RestError {
  const message = error.message.toUpperCase();

  if (message.includes("PLAYER_NOT_FOUND")) {
    return {
      code: "PLAYER_NOT_FOUND",
      message: "Guest account was not created yet.",
      status: 404,
    };
  }

  if (message.includes("UNSUPPORTED_MODE")) {
    return {
      code: "UNSUPPORTED_MODE",
      message: "Only MVP_ONLY battle mode is available in the technical MVP.",
      status: 400,
    };
  }

  if (message.includes("INVALID_REQUEST_ID")) {
    return {
      code: "INVALID_REQUEST_ID",
      message: "request_id must be a UUID.",
      status: 400,
    };
  }

  if (message.includes("UNAUTHENTICATED")) {
    return {
      code: "UNAUTHENTICATED",
      message: "Anonymous auth session is required.",
      status: 401,
    };
  }

  return {
    code: "SIMULATION_FAILED",
    message: "MVP battle simulation failed.",
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
