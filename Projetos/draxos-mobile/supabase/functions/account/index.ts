import { emptyResponse, jsonResponse } from "../_shared/http.ts";

type Route = "guest" | "state";

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

interface PlayerRow {
  id: string;
  username: string | null;
  account_type: string;
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

interface JwtPayload {
  sub?: unknown;
  is_anonymous?: unknown;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown account endpoint.", 404);
    }

    if (route === "guest" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /account/guest.", 405);
    }

    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /account/state.", 405);
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

    return await handleState(auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected account service error.", 500);
  }
});

async function handleGuest(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
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
    }),
  });

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  return jsonResponse(rpc.value);
}

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${
      encodeURIComponent(auth.userId)
    }&select=id,username,account_type,level,xp,power,created_at,updated_at&limit=1`,
    { method: "GET" },
  );

  if (playerResult.error !== null) {
    return errorResponse("STATE_READ_FAILED", "Unable to load player state.", 500);
  }

  const player = playerResult.value[0] ?? null;
  if (player === null) {
    return errorResponse("PLAYER_NOT_FOUND", "Guest account was not created yet.", 404);
  }

  const playerId = encodeURIComponent(player.id);
  const resourcesResult = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=player_id,almas,energia,sangue,cristais,ossos,diamante,updated_at&limit=1`,
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
    return errorResponse("ACCOUNT_STATE_INCOMPLETE", "Guest account state is incomplete.", 409);
  }

  return jsonResponse({
    ok: true,
    player,
    resources,
    build,
    last_battle_id: battlesResult.value[0]?.id ?? null,
  });
}

function resolveRoute(pathname: string): Route | null {
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

  if (payload.is_anonymous === false) {
    return {
      value: null,
      error: {
        code: "AUTH_NOT_ANONYMOUS",
        message: "Use an anonymous Supabase Auth session for guest account creation.",
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
      message: "This auth session already has a guest account.",
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

  if (message.includes("UNAUTHENTICATED")) {
    return {
      code: "UNAUTHENTICATED",
      message: "Anonymous auth session is required.",
      status: 401,
    };
  }

  return {
    code: "ACCOUNT_CREATE_FAILED",
    message: "Guest account could not be created.",
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
