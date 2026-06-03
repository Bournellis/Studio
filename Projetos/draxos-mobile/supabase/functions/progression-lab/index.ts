import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  SAVE_TYPE_PROGRESSION_LAB,
  type SaveType,
  saveTypeFromRequest,
} from "../_shared/save_context.ts";
import healthySavesDocument from "../_shared/progression_lab_saves.json" with {
  type: "json",
};
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "apply";

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

interface HealthySavesDocument {
  schema_version: number;
  model_id: string;
  saves: HealthySave[];
}

interface HealthySave {
  id: string;
  profile_id: string;
  milestone_id: string;
  [key: string]: unknown;
}

interface JwtPayload {
  sub?: unknown;
}

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const HEALTHY_SAVES = (healthySavesDocument as HealthySavesDocument).saves;

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
      return errorResponse(
        "NOT_FOUND",
        "Unknown Progression Lab endpoint.",
        404,
      );
    }

    if (route === "apply" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /progression-lab/apply.",
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

    if (auth.value.saveType !== SAVE_TYPE_PROGRESSION_LAB) {
      return errorResponse(
        "PROGRESSION_LAB_SAVE_REQUIRED",
        "Progression Lab apply can only target the progression_lab save.",
        409,
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

    return await handleApply(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse(
      "INTERNAL_ERROR",
      "Unexpected Progression Lab service error.",
      500,
    );
  }

}

async function handleApply(
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
  const requestHash = stringField(body, "request_hash").trim();
  if (requestHash === "") {
    return errorResponse(
      "INVALID_REQUEST_HASH",
      "request_hash must be a non-empty mutation hash.",
      400,
    );
  }

  const profileId = normalizeId(stringField(body, "profile_id"));
  const milestoneId = normalizeId(stringField(body, "milestone_id"));
  const saveId = stringField(body, "save_id");
  if (profileId === "" || milestoneId === "") {
    return errorResponse(
      "INVALID_PROGRESSION_LAB_SELECTION",
      "profile_id and milestone_id are required.",
      400,
    );
  }

  const healthySave = findHealthySave(profileId, milestoneId, saveId);
  if (healthySave === null) {
    return errorResponse(
      "PROGRESSION_LAB_SAVE_NOT_FOUND",
      "Selected profile/milestone is not available in the server Progression Lab catalog.",
      404,
    );
  }

  const rpc = await restRequest<unknown>(
    config,
    "rpc/apply_progression_lab_save",
    {
      method: "POST",
      body: JSON.stringify({
        p_auth_user_id: auth.userId,
        p_request_id: requestId,
        p_request_hash: requestHash,
        p_profile_id: profileId,
        p_milestone_id: milestoneId,
        p_save_payload: healthySave,
      }),
    },
  );

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  return jsonResponse(stateEnvelope(withResourceDefaults(rpc.value), {
    surface: "progression_lab",
    saveType: auth.saveType,
  }));
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/apply")) {
    return "apply";
  }

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

  return {
    value: { userId: payload.sub, saveType },
    error: null,
  };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(
      atob(padded),
      (character) => character.charCodeAt(0),
    );
    const decoded = new TextDecoder().decode(bytes);
    const payload: unknown = JSON.parse(decoded);
    if (
      payload !== null && typeof payload === "object" && !Array.isArray(payload)
    ) {
      return payload as JwtPayload;
    }
  } catch {
    return null;
  }

  return null;
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
        message:
          "Progression Lab function is missing Supabase runtime configuration.",
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

async function readJsonObject(
  request: Request,
): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    if (
      payload !== null && typeof payload === "object" && !Array.isArray(payload)
    ) {
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

function normalizeId(value: string): string {
  return value.trim().toLowerCase();
}

function findHealthySave(
  profileId: string,
  milestoneId: string,
  saveId: string,
): HealthySave | null {
  for (const save of HEALTHY_SAVES) {
    const profileMatches = normalizeId(save.profile_id) === profileId;
    const milestoneMatches = normalizeId(save.milestone_id) === milestoneId;
    const saveMatches = saveId === "" || save.id === saveId;
    if (profileMatches && milestoneMatches && saveMatches) {
      return save;
    }
  }

  return null;
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
    const responseBody =
      data !== null && typeof data === "object" && !Array.isArray(data)
        ? data as Record<string, unknown>
        : {};

    return {
      value: null,
      error: {
        code: stringValue(responseBody.code, "REST_ERROR"),
        message: stringValue(responseBody.message, response.statusText),
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

function withResourceDefaults(payload: unknown): Record<string, unknown> {
  if (
    payload === null || typeof payload !== "object" || Array.isArray(payload)
  ) {
    return {};
  }

  const root = payload as Record<string, unknown>;
  const resources = root.resources;
  if (
    resources !== null && typeof resources === "object" &&
    !Array.isArray(resources)
  ) {
    const resourceMap = resources as Record<string, unknown>;
    if (resourceMap.po_osso === undefined) {
      resourceMap.po_osso = 0;
    }
  }

  return root;
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function mapDatabaseError(error: RestError): RestError {
  const message = error.message.toUpperCase();

  if (message.includes("INVALID_REQUEST_ID")) {
    return {
      code: "INVALID_REQUEST_ID",
      message: "request_id must be a UUID.",
      status: 400,
    };
  }

  if (message.includes("INVALID_REQUEST_HASH")) {
    return {
      code: "INVALID_REQUEST_HASH",
      message: "request_hash must be a non-empty mutation hash.",
      status: 400,
    };
  }

  if (message.includes("IDEMPOTENCY_HASH_MISMATCH")) {
    return {
      code: "IDEMPOTENCY_HASH_MISMATCH",
      message: "request_id was already used with a different request_hash.",
      status: 409,
    };
  }

  if (message.includes("INVALID_PROGRESSION_LAB_SAVE")) {
    return {
      code: "INVALID_PROGRESSION_LAB_SAVE",
      message: "Progression Lab save payload failed server validation.",
      status: 400,
    };
  }

  if (message.includes("PLAYER_NOT_FOUND")) {
    return {
      code: "PLAYER_NOT_FOUND",
      message: "Create the progression_lab save before applying a lab profile.",
      status: 404,
    };
  }

  if (message.includes("UNAUTHENTICATED")) {
    return {
      code: "UNAUTHENTICATED",
      message: "Authenticated session is required.",
      status: 401,
    };
  }

  return {
    code: "PROGRESSION_LAB_APPLY_FAILED",
    message: "Progression Lab save could not be applied.",
    status: error.status >= 400 ? error.status : 500,
  };
}

function errorResponse(
  code: string,
  message: string,
  status: number,
): Response {
  return jsonResponse({
    ok: false,
    error: {
      code,
      message,
    },
  }, status);
}
