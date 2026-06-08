const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";
const EXPECTED_RELEASE_ROOT = requiredExpectedReleaseRoot();
const LEGACY_OPENWORLD_RELEASE_ROOTS = [
  "internal-alpha/v0-openworld-node2d-qol-20260601-5707167",
  "internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129",
];

interface JsonObject {
  [key: string]: unknown;
}

const manifest = await getJson(
  `${SUPABASE_URL.replace(/\/+$/, "")}/functions/v1/release/manifest`,
  baseHeaders(),
);

assertEq(
  stringField(manifest, "schema_version"),
  "internal_alpha_manifest_v1",
  "release manifest schema should match the Godot client contract",
);
assertEq(
  stringField(manifest, "channel"),
  "internal_alpha",
  "release manifest should serve the internal alpha channel",
);
assertEq(
  stringField(manifest, "latest_version"),
  "0.0.12-alpha.0",
  "release manifest should expose the current alpha version",
);
assertEq(
  numberField(manifest, "latest_version_code"),
  12,
  "release manifest should expose the current version code",
);
assertEq(
  numberField(manifest, "minimum_supported_version_code"),
  12,
  "release manifest should force-update builds before the Openworld operations v2 contract",
);

const artifacts = objectField(manifest, "artifacts");
assert(
  stringField(manifest, "portal_url").startsWith("https://"),
  "manifest should include the published portal URL",
);
assert(
  isObject(artifacts.android),
  "manifest should include Android artifact metadata",
);
assert(
  isObject(artifacts.pc_windows),
  "manifest should include PC artifact metadata",
);
assert(
  isObject(artifacts.web),
  "manifest should include Web artifact metadata",
);
const androidUrl = stringField(objectField(artifacts, "android"), "url");
const pcUrl = stringField(objectField(artifacts, "pc_windows"), "url");
const androidAuthRequired = booleanishField(
  objectField(artifacts, "android"),
  "auth_required",
);
const pcAuthRequired = booleanishField(
  objectField(artifacts, "pc_windows"),
  "auth_required",
);
assert(
  !includesLegacyReleaseRoot(androidUrl) &&
    !includesLegacyReleaseRoot(pcUrl),
  "manifest should not fall back to old Openworld package roots",
);
assertArtifactUrlMatchesContract(
  androidUrl,
  androidAuthRequired,
  "android",
  "Android",
);
assertArtifactUrlMatchesContract(pcUrl, pcAuthRequired, "pc_windows", "PC");
assert(
  stringField(objectField(artifacts, "web"), "url").startsWith("https://"),
  "manifest should include the published Web URL",
);

console.log("[release-manifest-smoke] OK", {
  url: SUPABASE_URL,
  version: stringField(manifest, "latest_version"),
  version_code: numberField(manifest, "latest_version_code"),
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

async function getJson(
  url: string,
  headers: Record<string, string>,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  const text = await response.text();
  const payload = parseJson(text);
  if (!isObject(payload)) {
    throw new Error(`response should be a JSON object: ${text}`);
  }
  assert(response.ok, `request failed with status ${response.status}: ${text}`);
  return payload;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  if (!isObject(value)) {
    throw new Error(`${key} should be an object`);
  }
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function booleanishField(payload: JsonObject, key: string): boolean {
  const value = payload[key];
  return value === true || value === "true";
}

function assertArtifactUrlMatchesContract(
  url: string,
  authRequired: boolean,
  artifact: string,
  label: string,
): void {
  if (authRequired) {
    assert(
      url.includes("/functions/v1/release/download") &&
        url.includes(`artifact=${artifact}`),
      `${label} protected URL should use release/download?artifact=${artifact}`,
    );
    return;
  }
  assert(
    url.includes(EXPECTED_RELEASE_ROOT),
    `${label} URL should include expected release root ${EXPECTED_RELEASE_ROOT}`,
  );
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  return typeof value === "number" ? value : 0;
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function includesLegacyReleaseRoot(url: string): boolean {
  return LEGACY_OPENWORLD_RELEASE_ROOTS.some((releaseRoot) => url.includes(releaseRoot));
}

function requiredExpectedReleaseRoot(): string {
  const releaseRoot = (Deno.env.get("DRAXOS_EXPECTED_RELEASE_ROOT") ?? "").trim();
  if (releaseRoot === "") {
    throw new Error("DRAXOS_EXPECTED_RELEASE_ROOT is required for release manifest smoke.");
  }
  return releaseRoot;
}

function assert(condition: boolean, message: string): void {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Expected ${expected}, got ${actual}.`);
  }
}
