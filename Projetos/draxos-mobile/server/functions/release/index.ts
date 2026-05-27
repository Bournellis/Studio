import { emptyResponse, jsonResponse } from "../_shared/http.ts";

const DEFAULT_MANIFEST: ReleaseManifest = {
  schema_version: "internal_alpha_manifest_v1",
  channel: "internal_alpha",
  latest_version: "0.0.1-alpha.0",
  latest_version_code: 1,
  minimum_supported_version: "0.0.1-alpha.0",
  minimum_supported_version_code: 1,
  released_at: "2026-05-27T15:02:12Z",
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
        "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.apk",
      sha256: "6c39ce9a63eaf4796a67a9e5a29e9252f1f03266f713ffa58c5d2333c15102d6",
    },
    pc_windows: {
      label: "PC Windows ZIP",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.zip",
      sha256: "4b7dc516bc4c5c4895930f8732ad9e97733cca85ba7574c9a0308c705982d236",
    },
    web: {
      label: "Web",
      url: "https://draxos-mobile-internal-alpha.pages.dev/web/index.html",
    },
  },
  known_issues: [
    "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
    "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
    "Web usa hospedagem hibrida Cloudflare Pages + Supabase Storage; validar /portal/index.html e /web/index.html apos cada deploy.",
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
  config_version: "t06-c-safe-defaults",
  generated_at: "2026-05-27T00:00:00Z",
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
    read_only: true,
    no_service_role: true,
    no_secrets: true,
    no_player_state: true,
    no_gameplay_tuning: true,
    mutable_gameplay_state: false,
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

Deno.serve((request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  if (request.method !== "GET") {
    return jsonResponse({
      ok: false,
      error: {
        code: "METHOD_NOT_ALLOWED",
        message: "Use GET /release/manifest or GET /release/config.",
      },
    }, 405);
  }

  const route = releaseRoute(request);

  try {
    if (route === "config") {
      return jsonResponse(buildRuntimeConfig());
    }
    return jsonResponse(buildManifest());
  } catch (error) {
    const routeLabel = route === "config" ? "runtime config" : "release manifest";
    return jsonResponse({
      ok: false,
      error: {
        code: route === "config" ? "INVALID_RUNTIME_CONFIG" : "INVALID_RELEASE_MANIFEST",
        message: error instanceof Error ? error.message : `${routeLabel} override is invalid.`,
      },
    }, 500);
  }
});

function releaseRoute(request: Request): "manifest" | "config" {
  const pathname = new URL(request.url).pathname.replace(/\/+$/, "");
  if (pathname.endsWith("/config")) {
    return "config";
  }
  return "manifest";
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
    config_version: stringOverride(parsed, "config_version", DEFAULT_RUNTIME_CONFIG.config_version),
    generated_at: stringOverride(parsed, "generated_at", DEFAULT_RUNTIME_CONFIG.generated_at),
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

function runtimeConfigOverrideText(): string {
  if ((Deno.env.get("RELEASE_RUNTIME_CONFIG_OVERRIDE_ENABLED") ?? "").trim() !== "1") {
    return "";
  }
  const encoded = Deno.env.get("RELEASE_RUNTIME_CONFIG_JSON_BASE64")?.trim() ?? "";
  if (encoded !== "") {
    return new TextDecoder().decode(
      Uint8Array.from(atob(encoded), (character) => character.charCodeAt(0)),
    );
  }
  return Deno.env.get("RELEASE_RUNTIME_CONFIG_JSON")?.trim() ?? "";
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

function featureFlagOverrides(value: Record<string, unknown>): Record<RuntimeFeatureFlag, boolean> {
  const features = { ...DEFAULT_RUNTIME_CONFIG.features };
  for (const flag of RUNTIME_FEATURE_FLAGS) {
    if (typeof value[flag] === "boolean") {
      features[flag] = value[flag];
    }
  }
  return features;
}
