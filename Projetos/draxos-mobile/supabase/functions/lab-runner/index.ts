import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import battleModelDocument from "../../../tools/battle_lab/model.v1.json" with {
  type: "json",
};
import {
  buildBridgeReplayResponse,
  buildReplaySamples,
  runBattleLab,
} from "../../../tools/battle_lab/generate.ts";
import progressionModelDocument from "../../../tools/progression_lab/model.v1.json" with {
  type: "json",
};
import {
  buildProgressionData,
} from "../../../tools/progression_lab/generate.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "battle" | "progression";
type JsonObject = Record<string, unknown>;

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
  email: string;
  isAnonymous: boolean;
}

interface JwtPayload {
  sub?: unknown;
  email?: unknown;
  is_anonymous?: unknown;
}

interface PlayerRow {
  id: string;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export async function handleLabRunnerRequest(request: Request): Promise<Response> {
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
      return errorResponse("NOT_FOUND", "Unknown Lab Runner endpoint.", 404);
    }

    if (request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST for Lab Runner endpoints.", 405);
    }

    const auth = decodeAuth(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }
    if (auth.value.isAnonymous || auth.value.email === "") {
      return errorResponse(
        "AUTH_REQUIRES_EMAIL",
        "Lab Runner requires the same Supabase email/password Internal Alpha account used by the game.",
        403,
      );
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    const access = await assertAlphaAccess(auth.value.userId, config.value);
    if (access.error !== null) {
      return errorResponse(access.error.code, access.error.message, access.error.status);
    }

    const body = await readJsonObject(request);
    if (body === null) {
      return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
    }

    if (route === "battle") {
      return jsonResponse(stateEnvelope(await runBattleLabRemote(body), {
        surface: "battle_lab",
      }));
    }

    return jsonResponse(stateEnvelope(runProgressionLabRemote(), {
      surface: "progression_lab",
    }));
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected Lab Runner service error.", 500);
  }
}

if (import.meta.main) {
  Deno.serve(async (request: Request) => {
    return withCorsResponse(request, await handleLabRunnerRequest(request));
  });
}

async function runBattleLabRemote(body: JsonObject): Promise<JsonObject> {
  const model = cloneBattleModel();
  const request = isObject(body.request) ? body.request as JsonObject : body;
  const mode = stringValue(request.mode, "run");
  if (mode === "replay") {
    return {
      ...await Promise.resolve(buildBridgeReplayResponse(model, request)),
      runner: "remote",
      mutates_files: false,
    } as JsonObject;
  }

  if (request.seed !== undefined && typeof request.seed === "string" && request.seed.trim() !== "") {
    (model as { seed?: string }).seed = request.seed.trim();
  }

  const result = runBattleLab(model);
  const runId = stringValue(
    request.archive_run_id,
    stringValue(request.scratch_run_id, stringValue(request.run_id, "remote")),
  );
  const replays = buildReplaySamples(model, result).slice(0, 8);
  return {
    schema_version: "battle_lab_response_v1",
    ok: true,
    mode: "run",
    runner: "remote",
    mutates_files: false,
    status: result.overall_status,
    run_id: runId,
    output_dir: "remote://battle-lab",
    report_path: "remote://battle-lab/summary",
    summary: result.summary,
    checks: result.checks,
    outliers: result.outliers.slice(0, 20),
    arena_sequences: result.arena_sequences,
    compare: [],
    replays,
  };
}

function runProgressionLabRemote(): JsonObject {
  const model = cloneProgressionModel();
  const data = buildProgressionData(model);
  const reviewCount = [
    ...data.saves,
    ...data.reward_checks,
    ...data.arena_checks,
    ...data.consumable_checks,
    ...data.premium_gap,
    ...data.power_recommendations,
  ].filter((item) => item.status !== "PASS").length;
  return {
    schema_version: "progression_lab_remote_response_v1",
    ok: true,
    runner: "remote",
    mutates_files: false,
    status: data.status,
    model_id: data.model_id,
    summary: {
      saves: data.saves.length,
      bot_pool: data.bot_pool.length,
      review_items: reviewCount,
    },
    data,
  };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/battle")) return "battle";
  if (pathname.endsWith("/progression")) return "progression";
  return null;
}

function decodeAuth(
  request: Request,
): { value: AuthContext; error: null } | { value: null; error: RestError } {
  const header = request.headers.get("authorization") ?? "";
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Bearer token is required.", status: 401 },
    };
  }

  const parts = header.slice(prefix.length).split(".");
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

  return {
    value: {
      userId: payload.sub,
      email: typeof payload.email === "string" ? payload.email.trim().toLowerCase() : "",
      isAnonymous: payload.is_anonymous === true,
    },
    error: null,
  };
}

async function assertAlphaAccess(
  userId: string,
  config: EdgeConfig,
): Promise<{ error: null } | { error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${
      encodeURIComponent(userId)
    }&save_type=eq.normal&account_type=eq.registered&select=id&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return {
      error: {
        code: "LAB_RUNNER_ALPHA_ACCESS_READ_FAILED",
        message: "Unable to verify Internal Alpha Lab access.",
        status: 500,
      },
    };
  }
  if ((result.value[0] ?? null) === null) {
    return {
      error: {
        code: "LAB_RUNNER_ALPHA_ACCESS_REQUIRED",
        message: "Use a Supabase email/password account with Internal Alpha access before running Labs remotely.",
        status: 403,
      },
    };
  }
  return { error: null };
}

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = (Deno.env.get("SUPABASE_URL") ?? "").replace(/\/$/, "");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Lab Runner function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl, serviceRoleKey }, error: null };
}

async function restRequest<T>(
  config: EdgeConfig,
  path: string,
  init: RequestInit,
): Promise<{ value: T; error: null } | { value: null; error: RestError }> {
  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, {
    ...init,
    headers: serviceHeaders(config, init.body !== undefined),
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

function serviceHeaders(config: EdgeConfig, hasBody: boolean): Headers {
  const headers = new Headers({ accept: "application/json" });
  headers.set("apikey", config.serviceRoleKey);
  headers.set("authorization", `Bearer ${config.serviceRoleKey}`);
  if (hasBody) headers.set("content-type", "application/json");
  return headers;
}

async function readJsonObject(request: Request): Promise<JsonObject | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

function cloneBattleModel(): Parameters<typeof runBattleLab>[0] {
  return structuredClone(battleModelDocument) as Parameters<typeof runBattleLab>[0];
}

function cloneProgressionModel(): Parameters<typeof buildProgressionData>[0] {
  return structuredClone(progressionModelDocument) as Parameters<typeof buildProgressionData>[0];
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

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}
