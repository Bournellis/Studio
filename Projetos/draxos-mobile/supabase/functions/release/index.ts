import { emptyResponse, jsonResponse } from "../_shared/http.ts";

const DEFAULT_MANIFEST: ReleaseManifest = {
  schema_version: "internal_alpha_manifest_v1",
  channel: "internal_alpha",
  latest_version: "0.0.1-alpha.0",
  latest_version_code: 1,
  minimum_supported_version: "0.0.1-alpha.0",
  minimum_supported_version_code: 1,
  released_at: "2026-05-27T00:00:00Z",
  requires_save_reset: false,
  portal_url: "",
  notes: [
    "Primeira release candidate interna.",
    "APK Android e PC ZIP compartilham o mesmo backend remoto.",
    "Portal/Web precisam de host estatico externo; Supabase Storage/Edge Functions nao servem HTML como pagina.",
    "Progression Lab usa save separado e nao pontua ranking.",
  ],
  artifacts: {
    android: {
      label: "Android APK",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.apk",
      sha256: "87533f150ffb773ef3bb7e41f6d69e98c7fdd4a85cbbf1e28544040aaade2448",
    },
    pc_windows: {
      label: "PC Windows ZIP",
      url:
        "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/downloads/draxos-mobile-alpha.zip",
      sha256: "e678fb7e2d2e984ad7356a47cbdcf4fdb12628ebe23636ab1a3b976365111082",
    },
    web: {
      label: "Web",
      url: "",
    },
  },
  known_issues: [
    "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
    "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
    "Link Web/Portal aguarda publicacao em host estatico externo.",
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

Deno.serve((request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  if (request.method !== "GET") {
    return jsonResponse({
      ok: false,
      error: {
        code: "METHOD_NOT_ALLOWED",
        message: "Use GET /release/manifest.",
      },
    }, 405);
  }

  try {
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
