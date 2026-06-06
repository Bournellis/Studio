import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { verifiedAuthContext } from "../_shared/auth_context.ts";

const DEFAULT_MANIFEST: ReleaseManifest = {
  schema_version: "internal_alpha_manifest_v1",
  channel: "internal_alpha",
  latest_version: "0.0.4-alpha.0",
  latest_version_code: 4,
  minimum_supported_version: "0.0.4-alpha.0",
  minimum_supported_version_code: 4,
  released_at: "2026-06-06T01:59:20Z",
  requires_save_reset: false,
  portal_url: "https://draxos-mobile-internal-alpha.pages.dev/",
  notes: [
    "Bosque Offline-First Checkpoint v1 publicado na URL principal de Internal Alpha.",
    "APK Android, PC ZIP e Web compartilham o mesmo backend remoto publicado.",
    "Manifesto exige build minima 0.0.4-alpha.0 para evitar instalacao silenciosa de APK anterior.",
    "Bosque usa cache local/checkpoints para movimento, coleta, deposito e craft durante gameplay.",
    "Conclusao/reward do Bosque continuam server-authoritative via checkpoint aceito.",
    "Arena Preparacao, buff -> Resolver duelo e pacotes anteriores seguem preservados.",
    "Battle Lab e Progression Lab no Web usam lab-runner remoto com a mesma conta alpha Supabase do jogo.",
    "Progression Lab usa save separado e nao pontua ranking.",
  ],
  artifacts: {
    android: {
      label: "Android APK",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22/downloads/draxos-mobile-alpha.apk",
      sha256: "207c0eb79f36f3420ca539fbffaf7ce92150c38271df5f608916d4c12b0e8d5c",
      auth_required: "false",
    },
    pc_windows: {
      label: "PC Windows ZIP",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22/downloads/draxos-mobile-alpha.zip",
      sha256: "7c0206a3bc0e4b65a5f8a20524921820282904f69e9e8224aff4307bd5cfefa9",
      auth_required: "false",
    },
    web: {
      label: "Web",
      url: "https://draxos-mobile-internal-alpha.pages.dev/web/index.html",
    },
  },
  known_issues: [
    "Fallback estatico nao substitui o manifest remoto versionado para hashes exatos de artefatos.",
    "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
    "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
    "Web usa hospedagem hibrida Cloudflare Pages + Supabase Storage; validar / e /web/index.html apos cada deploy.",
    "Dominio production fixo do Cloudflare Pages e o link oficial de playtest; se Cloudflare Access estiver ativo, validar conteudo com sessao autenticada.",
  ],
};

const RUNTIME_FEATURE_FLAGS = [
  "profile_account_panel",
  "battle_history_replay",
  "base_routine_panel",
  "social_qol_readability",
  "asset_pack_01_safe",
] as const;

const DEFAULT_RUNTIME_CONFIG: RuntimeConfig = {
  schema_version: "runtime_config_v1",
  channel: "internal_alpha",
  config_version: "track23-online-actions-hotfix",
  generated_at: "2026-06-05T09:23:46Z",
  features: {
    profile_account_panel: false,
    battle_history_replay: false,
    base_routine_panel: false,
    social_qol_readability: false,
    asset_pack_01_safe: false,
  },
  client: {
    offline_fallback_allowed: true,
    config_refresh_seconds: 900,
  },
  guardrails: {
    release_scoped: true,
    read_only: false,
    no_service_role: true,
    no_secrets: true,
    no_player_state: true,
    no_gameplay_tuning: true,
    mutable_gameplay_state: true,
  },
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

type RuntimeFeatureFlag = typeof RUNTIME_FEATURE_FLAGS[number];

interface RuntimeConfig {
  schema_version: string;
  channel: string;
  config_version: string;
  generated_at: string;
  features: Record<RuntimeFeatureFlag, boolean>;
  client: {
    offline_fallback_allowed: boolean;
    config_refresh_seconds: number;
  };
  guardrails: {
    release_scoped: boolean;
    read_only: boolean;
    no_service_role: boolean;
    no_secrets: boolean;
    no_player_state: boolean;
    no_gameplay_tuning: boolean;
    mutable_gameplay_state: boolean;
  };
}

type Route = "manifest" | "config" | "download" | "unknown";

interface EdgeConfig {
  supabaseUrl: string;
  publishableKey: string;
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

interface PlayerRow {
  id: string;
}

const DEFAULT_RELEASE_ROOT = "internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a";

Deno.serve(async (request: Request) => {
  return withCorsResponse(request, await handleCorsRequest(request));
});

async function handleCorsRequest(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  if (request.method !== "GET") {
    return jsonResponse({
      ok: false,
      error: {
        code: "METHOD_NOT_ALLOWED",
        message: "Use GET /release/manifest, GET /release/config or GET /release/download.",
      },
    }, 405);
  }

  const route = releaseRoute(request);

  if (route === "unknown") {
    return errorResponse("NOT_FOUND", "Unknown release endpoint.", 404);
  }

  try {
    if (route === "download") {
      return await handleDownload(request);
    }
    if (route === "config") {
      return jsonResponse(buildRuntimeConfig());
    }
    return jsonResponse(buildManifest());
  } catch (error) {
    const routeLabel = route === "config"
      ? "runtime config"
      : route === "download"
      ? "release download"
      : "release manifest";
    return jsonResponse({
      ok: false,
      error: {
        code: route === "config"
          ? "INVALID_RUNTIME_CONFIG"
          : route === "download"
          ? "INVALID_RELEASE_DOWNLOAD"
          : "INVALID_RELEASE_MANIFEST",
        message: error instanceof Error ? error.message : `${routeLabel} override is invalid.`,
      },
    }, 500);
  }

}

function releaseRoute(request: Request): Route {
  const pathname = new URL(request.url).pathname.replace(/\/+$/, "");
  if (pathname.endsWith("/download")) {
    return "download";
  }
  if (pathname.endsWith("/config")) {
    return "config";
  }
  if (pathname.endsWith("/manifest") || pathname.endsWith("/release")) {
    return "manifest";
  }
  return "unknown";
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

  const overrideManifest = {
    schema_version: stringOverride(
      parsed,
      "schema_version",
      DEFAULT_MANIFEST.schema_version,
    ),
    channel: stringOverride(parsed, "channel", DEFAULT_MANIFEST.channel),
    latest_version: stringOverride(
      parsed,
      "latest_version",
      DEFAULT_MANIFEST.latest_version,
    ),
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
    released_at: stringOverride(
      parsed,
      "released_at",
      DEFAULT_MANIFEST.released_at,
    ),
    requires_save_reset: booleanOverride(
      parsed,
      "requires_save_reset",
      DEFAULT_MANIFEST.requires_save_reset,
    ),
    portal_url: stringOverride(
      parsed,
      "portal_url",
      DEFAULT_MANIFEST.portal_url,
    ),
    notes: stringArrayOverride(parsed, "notes", DEFAULT_MANIFEST.notes),
    artifacts: isObject(parsed.artifacts)
      ? asRecordOfRecord(parsed.artifacts)
      : DEFAULT_MANIFEST.artifacts,
    known_issues: stringArrayOverride(
      parsed,
      "known_issues",
      DEFAULT_MANIFEST.known_issues,
    ),
  };
  return manifestIsNewer(DEFAULT_MANIFEST, overrideManifest)
    ? DEFAULT_MANIFEST
    : overrideManifest;
}

function buildRuntimeConfig(): RuntimeConfig {
  const overrideText = runtimeConfigOverrideText();
  if (overrideText === "") {
    return DEFAULT_RUNTIME_CONFIG;
  }

  const parsed: unknown = JSON.parse(overrideText);
  if (!isObject(parsed)) {
    throw new Error("RELEASE_RUNTIME_CONFIG_JSON must be a JSON object.");
  }

  const client = isObject(parsed.client) ? parsed.client : {};
  const features = isObject(parsed.features) ? parsed.features : {};
  return {
    schema_version: DEFAULT_RUNTIME_CONFIG.schema_version,
    channel: stringOverride(parsed, "channel", DEFAULT_RUNTIME_CONFIG.channel),
    config_version: stringOverride(
      parsed,
      "config_version",
      DEFAULT_RUNTIME_CONFIG.config_version,
    ),
    generated_at: stringOverride(
      parsed,
      "generated_at",
      DEFAULT_RUNTIME_CONFIG.generated_at,
    ),
    features: featureFlagOverrides(features),
    client: {
      offline_fallback_allowed: booleanOverride(
        client,
        "offline_fallback_allowed",
        DEFAULT_RUNTIME_CONFIG.client.offline_fallback_allowed,
      ),
      config_refresh_seconds: boundedNumberOverride(
        client,
        "config_refresh_seconds",
        DEFAULT_RUNTIME_CONFIG.client.config_refresh_seconds,
        60,
        3600,
      ),
    },
    guardrails: DEFAULT_RUNTIME_CONFIG.guardrails,
  };
}

async function handleDownload(request: Request): Promise<Response> {
  const config = loadConfig();
  if (config.error !== null) {
    return errorResponse(config.error.code, config.error.message, config.error.status);
  }

  const auth = await verifiedAuthContext(request, {
    supabaseUrl: config.value.supabaseUrl,
    publishableKey: config.value.publishableKey,
    serviceRoleKey: config.value.serviceRoleKey,
  }, {
    requireEmailAccount: true,
    emailAccountRequiredMessage:
      "Internal Alpha downloads require an email/password alpha account.",
  });
  if (auth.error !== null) {
    return errorResponse(auth.error.code, auth.error.message, auth.error.status);
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

function manifestOverrideText(): string {
  if (
    (Deno.env.get("RELEASE_MANIFEST_OVERRIDE_ENABLED") ?? "").trim() !== "1"
  ) {
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

function runtimeConfigOverrideText(): string {
  if (
    (Deno.env.get("RELEASE_RUNTIME_CONFIG_OVERRIDE_ENABLED") ?? "").trim() !==
      "1"
  ) {
    return "";
  }
  const encoded = Deno.env.get("RELEASE_RUNTIME_CONFIG_JSON_BASE64")?.trim() ??
    "";
  if (encoded !== "") {
    return new TextDecoder().decode(
      Uint8Array.from(atob(encoded), (character) => character.charCodeAt(0)),
    );
  }
  return Deno.env.get("RELEASE_RUNTIME_CONFIG_JSON")?.trim() ?? "";
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

  const signedUrl = stringOverride(payload, "signedUrl", stringOverride(payload, "signedURL", ""));
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
        code: stringOverride(body, "code", "REST_ERROR"),
        message: stringOverride(body, "message", response.statusText),
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
  const publishableKey = firstEnv([
    "SUPABASE_PUBLISHABLE_KEY",
    "SUPABASE_ANON_KEY",
    "DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY",
  ]);
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || publishableKey === "" || serviceRoleKey === "") {
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
      publishableKey,
      serviceRoleKey,
      privateBucket: Deno.env.get("INTERNAL_ALPHA_PRIVATE_BUCKET")?.trim() ||
        "draxos-internal-alpha-private",
      releaseRoot: (Deno.env.get("INTERNAL_ALPHA_RELEASE_ROOT")?.trim() || DEFAULT_RELEASE_ROOT)
        .replace(/^\/+|\/+$/g, ""),
      signedUrlExpiresIn: positiveInteger(
        Deno.env.get("INTERNAL_ALPHA_SIGNED_URL_EXPIRES_IN"),
        300,
      ),
    },
    error: null,
  };
}

function firstEnv(keys: string[]): string {
  for (const key of keys) {
    const value = Deno.env.get(key)?.trim() ?? "";
    if (value !== "") return value;
  }
  return "";
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function manifestIsNewer(left: ReleaseManifest, right: ReleaseManifest): boolean {
  const leftTime = Date.parse(left.released_at);
  const rightTime = Date.parse(right.released_at);
  return Number.isFinite(leftTime) && (!Number.isFinite(rightTime) || leftTime >= rightTime);
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function asRecordOfRecord(
  value: Record<string, unknown>,
): Record<string, Record<string, string>> {
  const result: Record<string, Record<string, string>> = {};
  for (const [key, item] of Object.entries(value)) {
    if (!isObject(item)) {
      continue;
    }
    result[key] = Object.fromEntries(
      Object.entries(item).map((
        [itemKey, itemValue],
      ) => [itemKey, String(itemValue)]),
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

function numberOverride(
  value: Record<string, unknown>,
  key: string,
  fallback: number,
): number {
  return typeof value[key] === "number" ? value[key] : fallback;
}

function boundedNumberOverride(
  value: Record<string, unknown>,
  key: string,
  fallback: number,
  min: number,
  max: number,
): number {
  const next = numberOverride(value, key, fallback);
  if (!Number.isFinite(next)) {
    return fallback;
  }
  return Math.max(min, Math.min(max, Math.round(next)));
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

function featureFlagOverrides(
  value: Record<string, unknown>,
): Record<RuntimeFeatureFlag, boolean> {
  const features = { ...DEFAULT_RUNTIME_CONFIG.features };
  for (const flag of RUNTIME_FEATURE_FLAGS) {
    if (typeof value[flag] === "boolean") {
      features[flag] = value[flag];
    }
  }
  return features;
}

function positiveInteger(value: string | undefined, fallback: number): number {
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : fallback;
}
