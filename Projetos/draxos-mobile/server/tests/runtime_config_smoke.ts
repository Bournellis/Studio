const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";

const FEATURE_FLAGS = [
  "profile_account_panel",
  "battle_history_replay",
  "base_routine_panel",
  "social_qol_readability",
  "asset_pack_01_safe",
];

const FORBIDDEN_STATE_KEYS = [
  "player",
  "player_id",
  "resources",
  "build",
  "battle_log",
  "battle_state",
  "save_state",
  "service_role",
  "service_role_key",
  "access_token",
  "refresh_token",
];

interface JsonObject {
  [key: string]: unknown;
}

const config = await getJson(
  `${SUPABASE_URL.replace(/\/+$/, "")}/functions/v1/release/config`,
  baseHeaders(),
);

assertEq(
  stringField(config, "schema_version"),
  "runtime_config_v1",
  "runtime config schema should match the Godot client contract",
);
assertEq(
  stringField(config, "channel"),
  "internal_alpha",
  "runtime config should serve the internal alpha channel",
);

const features = objectField(config, "features");
for (const flag of FEATURE_FLAGS) {
  assert(
    typeof features[flag] === "boolean",
    `runtime config should expose boolean feature flag ${flag}`,
  );
}

const client = objectField(config, "client");
assert(
  booleanField(client, "offline_fallback_allowed"),
  "runtime config should allow conservative offline fallback",
);
assert(
  numberField(client, "config_refresh_seconds") >= 60,
  "runtime config refresh interval should be bounded",
);

const guardrails = objectField(config, "guardrails");
assert(booleanField(guardrails, "release_scoped"), "runtime config should be release-scoped");
assert(
  !booleanField(guardrails, "read_only"),
  "published runtime config should allow online progression actions",
);
assert(booleanField(guardrails, "no_service_role"), "runtime config must not expose service role");
assert(booleanField(guardrails, "no_player_state"), "runtime config must not expose player state");
assert(booleanField(guardrails, "no_gameplay_tuning"), "runtime config must not expose gameplay tuning");
assert(
  booleanField(guardrails, "mutable_gameplay_state"),
  "published runtime config should allow server-authoritative gameplay mutations",
);

const forbidden = findForbiddenKeys(config);
assertEq(forbidden.length, 0, `runtime config should not contain forbidden keys: ${forbidden}`);

console.log("[runtime-config-smoke] OK", {
  url: SUPABASE_URL,
  schema_version: stringField(config, "schema_version"),
  config_version: stringField(config, "config_version"),
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

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  return typeof value === "number" ? value : 0;
}

function booleanField(payload: JsonObject, key: string): boolean {
  const value = payload[key];
  return typeof value === "boolean" ? value : false;
}

function findForbiddenKeys(payload: unknown, path = ""): string[] {
  if (!isObject(payload)) {
    return [];
  }
  const found: string[] = [];
  for (const [key, value] of Object.entries(payload)) {
    const currentPath = path === "" ? key : `${path}.${key}`;
    if (FORBIDDEN_STATE_KEYS.includes(key.toLowerCase())) {
      found.push(currentPath);
    }
    found.push(...findForbiddenKeys(value, currentPath));
  }
  return found;
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
