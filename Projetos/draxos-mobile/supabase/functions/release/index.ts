import { emptyResponse, jsonResponse } from "../_shared/http.ts";

type Route = "manifest" | "download";

const DEFAULT_MANIFEST: ReleaseManifest = {
  schema_version: "internal_alpha_manifest_v1",
  channel: "internal_alpha",
  latest_version: "0.0.1-alpha.0",
  latest_version_code: 1,
  minimum_supported_version: "0.0.1-alpha.0",
  minimum_supported_version_code: 1,
  released_at: "2026-05-27T00:00:00Z",
  requires_save_reset: false,
  portal_url: "https://draxos-mobile-internal-alpha.pages.dev/portal/index.html",
  notes: [
    "Primeira release candidate interna.",
    "APK Android e PC ZIP compartilham o mesmo backend remoto.",
    "Portal/Web rodam no Cloudflare Pages; downloads e assets grandes continuam no Supabase Storage.",
    "Progression Lab usa save separado e nao pontua ranking.",
  ],
  artifacts: {
    android: {
      label: "Android APK",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=android",
      sha256: "87533f150ffb773ef3bb7e41f6d69e98c7fdd4a85cbbf1e28544040aaade2448",
      auth_required: "true",
    },
    pc_windows: {
      label: "PC Windows ZIP",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/download?artifact=pc_windows",
      sha256: "e678fb7e2d2e984ad7356a47cbdcf4fdb12628ebe23636ab1a3b976365111082",
      auth_required: "true",
    },
    web: {
      label: "Web",
      url: "https://draxos-mobile-internal-alpha.pages.dev/web/index.html",
    },
  },
  known_issues: [
    "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
    "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
    "Web usa hospedagem hibrida Cloudflare Pages + Supabase Storage e deve ser validada no navegador desktop antes do signoff.",
  ],
};

interface ReleaseManifest {
  schema_version: string;
  channel: string;
  latest_version: string;
  latest_version_code: number;
  minimum_supported_version: string;
  minimum_supported_version_code: number;
  released_at: string;
  requires_save_reset: boolean;
  portal_url: string;
  notes: string[];
  artifacts: Record<string, Record<string, string>>;
  known_issues: string[];
}

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
  privateBucket: string;
  releaseRoot: string;
  signedUrlExpiresIn: number;
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

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  const route = resolveRoute(new URL(request.url).pathname);
  if (route === null) {
    return jsonResponse({
      ok: false,
      error: {
        code: "NOT_FOUND",
        message: "Unknown release endpoint.",
      },
    }, 404);
  }

  if (request.method !== "GET") {
    return jsonResponse({
      ok: false,
      error: {
        code: "METHOD_NOT_ALLOWED",
        message: "Use GET for release endpoints.",
      },
    }, 405);
  }

  try {
    if (route === "download") {
      return await handleDownload(request);
    }
    return jsonResponse(buildManifest());
  } catch (error) {
    return jsonResponse({
      ok: false,
      error: {
        code: "INVALID_RELEASE_MANIFEST",
        message: error instanceof Error ? error.message : "Release manifest override is invalid.",
      },
    }, 500);
  }
});

async function handleDownload(request: Request): Promise<Response> {
  const config = loadConfig();
  if (config.error !== null) {
    return errorResponse(config.error.code, config.error.message, config.error.status);
  }

  const auth = decodeAuth(request);
  if (auth.error !== null) {
    return errorResponse(auth.error.code, auth.error.message, auth.error.status);
  }
  if (auth.value.isAnonymous) {
    return errorResponse(
      "AUTH_REQUIRES_EMAIL",
      "Internal Alpha downloads require an email/password alpha account.",
      403,
    );
  }

  const url = new URL(request.url);
  const artifact = (url.searchParams.get("artifact") ?? "").trim();
  const artifactPath = artifactStoragePath(artifact, config.value.releaseRoot);
  if (artifactPath === null) {
    return errorResponse("INVALID_ARTIFACT", "Artifact must be android or pc_windows.", 400);
  }

  const access = await assertAlphaAccess(auth.value.userId, config.value);
  if (access.error !== null) {
    return errorResponse(access.error.code, access.error.message, access.error.status);
  }

  const signedUrl = await createSignedUrl(config.value, artifactPath);
  if (signedUrl.error !== null) {
    return errorResponse(signedUrl.error.code, signedUrl.error.message, signedUrl.error.status);
  }

  return jsonResponse({
    ok: true,
    artifact,
    url: signedUrl.value,
    expires_in: config.value.signedUrlExpiresIn,
  });
}

function buildManifest(): ReleaseManifest {
  const overrideText = manifestOverrideText();
  if (overrideText === "") {
    return DEFAULT_MANIFEST;
  }

  const parsed: unknown = JSON.parse(overrideText);
  if (!isObject(parsed)) {
    throw new Error("RELEASE_MANIFEST_JSON must be a JSON object.");
  }

  return {
    schema_version: stringOverride(parsed, "schema_version", DEFAULT_MANIFEST.schema_version),
    channel: stringOverride(parsed, "channel", DEFAULT_MANIFEST.channel),
    latest_version: stringOverride(parsed, "latest_version", DEFAULT_MANIFEST.latest_version),
    latest_version_code: numberOverride(
      parsed,
      "latest_version_code",
      DEFAULT_MANIFEST.latest_version_code,
    ),
    minimum_supported_version: stringOverride(
      parsed,
      "minimum_supported_version",
      DEFAULT_MANIFEST.minimum_supported_version,
    ),
    minimum_supported_version_code: numberOverride(
      parsed,
      "minimum_supported_version_code",
      DEFAULT_MANIFEST.minimum_supported_version_code,
    ),
    released_at: stringOverride(parsed, "released_at", DEFAULT_MANIFEST.released_at),
    requires_save_reset: booleanOverride(
      parsed,
      "requires_save_reset",
      DEFAULT_MANIFEST.requires_save_reset,
    ),
    portal_url: stringOverride(parsed, "portal_url", DEFAULT_MANIFEST.portal_url),
    notes: stringArrayOverride(parsed, "notes", DEFAULT_MANIFEST.notes),
    artifacts: isObject(parsed.artifacts)
      ? asRecordOfRecord(parsed.artifacts)
      : DEFAULT_MANIFEST.artifacts,
    known_issues: stringArrayOverride(parsed, "known_issues", DEFAULT_MANIFEST.known_issues),
  };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/download")) return "download";
  if (pathname.endsWith("/manifest")) return "manifest";
  return null;
}

function decodeAuth(
  request: Request,
): { value: { userId: string; isAnonymous: boolean }; error: null } | {
  value: null;
  error: RestError;
} {
  const header = request.headers.get("authorization") ?? "";
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Bearer token is required.", status: 401 },
    };
  }
  const token = header.slice(prefix.length);
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
  return {
    value: { userId: payload.sub, isAnonymous: payload.is_anonymous === true },
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
        message: "Create an Internal Alpha save before downloading builds.",
        status: 403,
      },
    };
  }
  return { error: null };
}

async function createSignedUrl(
  config: EdgeConfig,
  path: string,
): Promise<{ value: string; error: null } | { value: null; error: RestError }> {
  const requestUrl = `${config.supabaseUrl}/storage/v1/object/sign/${
    encodeURIComponent(config.privateBucket)
  }/${path.split("/").map(encodeURIComponent).join("/")}`;
  const response = await fetch(requestUrl, {
    method: "POST",
    headers: serviceHeaders(config, true),
    body: JSON.stringify({ expiresIn: config.signedUrlExpiresIn }),
  });
  const text = await response.text();
  const payload = text === "" ? null : parseJson(text);
  if (!response.ok || !isObject(payload)) {
    return {
      value: null,
      error: {
        code: "SIGNED_URL_FAILED",
        message: "Unable to create a signed download URL.",
        status: 500,
      },
    };
  }

  const signedUrl = stringValue(payload.signedUrl, stringValue(payload.signedURL, ""));
  if (signedUrl === "") {
    return {
      value: null,
      error: {
        code: "SIGNED_URL_INVALID",
        message: "Storage did not return a signed URL.",
        status: 500,
      },
    };
  }
  if (signedUrl.startsWith("http://") || signedUrl.startsWith("https://")) {
    return { value: signedUrl, error: null };
  }
  return { value: normalizeStorageSignedUrl(config.supabaseUrl, signedUrl), error: null };
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

function artifactStoragePath(artifact: string, releaseRoot: string): string | null {
  if (artifact === "android") return `${releaseRoot}/downloads/draxos-mobile-alpha.apk`;
  if (artifact === "pc_windows") return `${releaseRoot}/downloads/draxos-mobile-alpha.zip`;
  return null;
}

function normalizeStorageSignedUrl(supabaseUrl: string, signedUrl: string): string {
  if (signedUrl.startsWith("/storage/v1/")) {
    return `${supabaseUrl}${signedUrl}`;
  }
  if (signedUrl.startsWith("/object/")) {
    return `${supabaseUrl}/storage/v1${signedUrl}`;
  }
  if (signedUrl.startsWith("storage/v1/")) {
    return `${supabaseUrl}/${signedUrl}`;
  }
  if (signedUrl.startsWith("object/")) {
    return `${supabaseUrl}/storage/v1/${signedUrl}`;
  }
  return `${supabaseUrl}/storage/v1/${signedUrl.replace(/^\/+/, "")}`;
}

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = (Deno.env.get("SUPABASE_URL") ?? "").replace(/\/$/, "");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Release download function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return {
    value: {
      supabaseUrl,
      serviceRoleKey,
      privateBucket: Deno.env.get("INTERNAL_ALPHA_PRIVATE_BUCKET")?.trim() ||
        "draxos-internal-alpha-private",
      releaseRoot: (Deno.env.get("INTERNAL_ALPHA_RELEASE_ROOT")?.trim() || "internal-alpha/v0")
        .replace(/^\/+|\/+$/g, ""),
      signedUrlExpiresIn: positiveInteger(
        Deno.env.get("INTERNAL_ALPHA_SIGNED_URL_EXPIRES_IN"),
        300,
      ),
    },
    error: null,
  };
}

function manifestOverrideText(): string {
  if ((Deno.env.get("RELEASE_MANIFEST_OVERRIDE_ENABLED") ?? "").trim() !== "1") {
    return "";
  }
  const encoded = Deno.env.get("RELEASE_MANIFEST_JSON_BASE64")?.trim() ?? "";
  if (encoded !== "") {
    return new TextDecoder().decode(
      Uint8Array.from(atob(encoded), (character) => character.charCodeAt(0)),
    );
  }
  return Deno.env.get("RELEASE_MANIFEST_JSON")?.trim() ?? "";
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

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function asRecordOfRecord(value: Record<string, unknown>): Record<string, Record<string, string>> {
  const result: Record<string, Record<string, string>> = {};
  for (const [key, item] of Object.entries(value)) {
    if (!isObject(item)) {
      continue;
    }
    result[key] = Object.fromEntries(
      Object.entries(item).map(([itemKey, itemValue]) => [itemKey, String(itemValue)]),
    );
  }
  return result;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function stringOverride(
  value: Record<string, unknown>,
  key: string,
  fallback: string,
): string {
  return typeof value[key] === "string" ? value[key] : fallback;
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function numberOverride(
  value: Record<string, unknown>,
  key: string,
  fallback: number,
): number {
  return typeof value[key] === "number" ? value[key] : fallback;
}

function booleanOverride(
  value: Record<string, unknown>,
  key: string,
  fallback: boolean,
): boolean {
  return typeof value[key] === "boolean" ? value[key] : fallback;
}

function stringArrayOverride(
  value: Record<string, unknown>,
  key: string,
  fallback: string[],
): string[] {
  return Array.isArray(value[key]) ? value[key].map(String) : fallback;
}

function positiveInteger(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}
