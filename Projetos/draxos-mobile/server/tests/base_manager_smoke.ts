const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

interface JsonObject {
  [key: string]: unknown;
}

const auth = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  { data: { provider: "guest" } },
  baseHeaders(),
  false,
);
const accessToken = stringField(auth, "access_token");
assert(accessToken !== "", "anonymous auth should return access_token");

const headers = {
  ...baseHeaders(),
  authorization: `Bearer ${accessToken}`,
};

const unauthenticated = await getJson(
  `${SUPABASE_URL}/functions/v1/base/state`,
  baseHeaders(),
  false,
);
assertEq(
  errorCode(unauthenticated),
  "UNAUTHENTICATED",
  "base/state should require auth",
);

await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-base-smoke",
  request_id: crypto.randomUUID(),
}, headers);

const baseState = await getJson(
  `${SUPABASE_URL}/functions/v1/base/state`,
  headers,
);
const base = objectField(baseState, "base");
const structures = arrayField(base, "structures");
assertEq(structures.length, 6, "base should initialize six structures");
assertEq(
  base.construction_slots,
  1,
  "base v0 starts with one construction slot",
);

const collectRequestId = crypto.randomUUID();
const firstCollect = await postJson(
  `${SUPABASE_URL}/functions/v1/base/collect`,
  { request_id: collectRequestId },
  headers,
);
const secondCollect = await postJson(
  `${SUPABASE_URL}/functions/v1/base/collect`,
  { request_id: collectRequestId },
  headers,
);
assertEq(
  resourceSummary(objectField(firstCollect, "collected")),
  resourceSummary(objectField(secondCollect, "collected")),
  "base/collect should be idempotent",
);

const upgradeWithoutEnergy = await postJson(
  `${SUPABASE_URL}/functions/v1/base/upgrade`,
  { request_id: crypto.randomUUID(), structure_id: "nucleo_energia" },
  headers,
  false,
);
assertEq(
  errorCode(upgradeWithoutEnergy),
  "INSUFFICIENT_RESOURCES",
  "base/upgrade should reject missing Energia",
);

console.log("[base-smoke] OK", {
  structures: structures.length,
  collected: objectField(firstCollect, "collected"),
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

async function postJson(
  url: string,
  body: JsonObject,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });
  return await parseResponse(response, requireOk);
}

async function getJson(
  url: string,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response, requireOk);
}

async function parseResponse(
  response: Response,
  requireOk: boolean,
): Promise<JsonObject> {
  const payload = await response.json() as unknown;
  assert(isObject(payload), "response should be a JSON object");
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${
        JSON.stringify(payload)
      }`,
    );
    assert(
      payload.ok === true,
      `response ok should be true: ${JSON.stringify(payload)}`,
    );
  }
  return payload;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function arrayField(payload: JsonObject, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function errorCode(payload: JsonObject): string {
  return stringField(objectField(payload, "error"), "code");
}

function resourceSummary(payload: JsonObject): string {
  return ["almas", "energia", "sangue", "cristais", "ossos"]
    .map((key) => `${key}:${String(payload[key] ?? 0)}`)
    .join("|");
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
