import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { grimoireCatalog } from "../_shared/grimoire_catalog.ts";
import { verifiedAuthContext } from "../_shared/auth_context.ts";

type Route = "grimoire";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

interface PlayerRow {
  id: string;
}

Deno.serve(async (request: Request) => {
  return withCorsResponse(request, await handleCorsRequest(request));
});

async function handleCorsRequest(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  const route = resolveRoute(new URL(request.url).pathname);
  if (route === null) {
    return errorResponse("NOT_FOUND", "Unknown content endpoint.", 404);
  }
  if (request.method !== "GET") {
    return errorResponse(
      "METHOD_NOT_ALLOWED",
      "Use GET for content endpoints.",
      405,
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

  const auth = await verifiedAuthContext(request, {
    supabaseUrl: config.value.supabaseUrl,
    serviceRoleKey: config.value.serviceRoleKey,
  }, {
    requireEmailAccount: true,
    emailAccountRequiredMessage: "The Grimorio requires an email/password alpha account.",
  });
  if (auth.error !== null) {
    return errorResponse(
      auth.error.code,
      auth.error.message,
      auth.error.status,
    );
  }
  const access = await assertAlphaAccess(auth.value.userId, config.value);
  if (access.error !== null) {
    return errorResponse(
      access.error.code,
      access.error.message,
      access.error.status,
    );
  }

  return jsonResponse({
    ok: true,
    ...grimoireCatalog(),
  });

}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/grimoire")) return "grimoire";
  return null;
}

function loadConfig(): { value: EdgeConfig; error: null } | {
  value: null;
  error: RestError;
} {
  const supabaseUrl = (Deno.env.get("SUPABASE_URL") ?? "").replace(/\/$/, "");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Content function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl, serviceRoleKey }, error: null };
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
        code: "ALPHA_ACCESS_READ_FAILED",
        message: "Unable to verify Internal Alpha access.",
        status: 500,
      },
    };
  }
  if ((result.value[0] ?? null) === null) {
    return {
      error: {
        code: "ALPHA_ACCESS_REQUIRED",
        message: "Create an Internal Alpha save before opening the Grimorio.",
        status: 403,
      },
    };
  }
  return { error: null };
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
  const payload = text === "" ? null : parseJson(text);
  if (!response.ok) {
    const body = isObject(payload) ? payload : {};
    return {
      value: null,
      error: {
        code: stringValue(body.code, "REST_ERROR"),
        message: stringValue(body.message, response.statusText),
        status: response.status,
      },
    };
  }
  return { value: payload as T, error: null };
}

function serviceHeaders(config: EdgeConfig, hasBody: boolean): Headers {
  const headers = new Headers();
  headers.set("accept", "application/json");
  headers.set("apikey", config.serviceRoleKey);
  headers.set("authorization", `Bearer ${config.serviceRoleKey}`);
  if (hasBody) headers.set("content-type", "application/json");
  return headers;
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function errorResponse(
  code: string,
  message: string,
  status: number,
): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" ? value : fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
