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
const initialNucleo = structureById(structures, "nucleo_energia");
assertEq(
  stringField(initialNucleo, "display_name"),
  "Nucleo de Energia",
  "base/state should expose structure display data",
);
assertEq(
  stringField(initialNucleo, "blocked_reason"),
  "INSUFFICIENT_RESOURCES",
  "base/state should explain why the first upgrade is blocked",
);
assertEq(
  numberField(objectField(initialNucleo, "upgrade_cost"), "energia"),
  20,
  "base/state should expose next upgrade cost",
);
assertEq(
  numberField(initialNucleo, "upgrade_duration_seconds"),
  360,
  "base/state should expose next upgrade duration",
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

await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_redeem_large" },
  headers,
);
await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_energy_pack_small" },
  headers,
);

const fundedBaseState = await getJson(
  `${SUPABASE_URL}/functions/v1/base/state`,
  headers,
);
const fundedNucleo = structureById(
  arrayField(objectField(fundedBaseState, "base"), "structures"),
  "nucleo_energia",
);
assertEq(
  fundedNucleo.can_upgrade,
  true,
  "base/state should mark upgrade available after buying Energia",
);

const upgradeRequestId = crypto.randomUUID();
const startedUpgrade = await postJson(
  `${SUPABASE_URL}/functions/v1/base/upgrade`,
  { request_id: upgradeRequestId, structure_id: "nucleo_energia" },
  headers,
);
const upgradeJob = objectField(startedUpgrade, "job");
assertEq(
  stringField(upgradeJob, "structure_id"),
  "nucleo_energia",
  "base/upgrade should start a job for selected structure",
);
assertEq(
  numberField(upgradeJob, "target_level"),
  1,
  "base/upgrade should target next level",
);

const queueFull = await postJson(
  `${SUPABASE_URL}/functions/v1/base/upgrade`,
  { request_id: crypto.randomUUID(), structure_id: "altar_das_almas" },
  headers,
  false,
);
assertEq(
  errorCode(queueFull),
  "CONSTRUCTION_QUEUE_FULL",
  "base/upgrade should reject a second active job",
);

await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_double_construction_queue" },
  headers,
);
const doubleQueueBaseState = await getJson(
  `${SUPABASE_URL}/functions/v1/base/state`,
  headers,
);
assertEq(
  objectField(doubleQueueBaseState, "base").construction_slots,
  2,
  "base/state should expose purchased double construction queue",
);
const secondUpgrade = await postJson(
  `${SUPABASE_URL}/functions/v1/base/upgrade`,
  { request_id: crypto.randomUUID(), structure_id: "altar_das_almas" },
  headers,
);
assertEq(
  numberField(objectField(secondUpgrade, "job"), "target_level"),
  1,
  "double construction queue should allow a second active upgrade",
);
const queueFullWithDouble = await postJson(
  `${SUPABASE_URL}/functions/v1/base/upgrade`,
  { request_id: crypto.randomUUID(), structure_id: "pocos_sangue" },
  headers,
  false,
);
assertEq(
  errorCode(queueFullWithDouble),
  "CONSTRUCTION_QUEUE_FULL",
  "double construction queue should still cap at two active jobs",
);

console.log("[base-smoke] OK", {
  structures: structures.length,
  collected: objectField(firstCollect, "collected"),
  upgrade_job: upgradeJob.id,
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
      `request failed with status ${response.status}: ${JSON.stringify(payload)}`,
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

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  if (typeof value === "number") return value;
  if (typeof value === "string") return Number(value);
  return 0;
}

function errorCode(payload: JsonObject): string {
  return stringField(objectField(payload, "error"), "code");
}

function structureById(items: unknown[], structureId: string): JsonObject {
  const structure = items.find((item) =>
    isObject(item) && stringField(item, "structure_id") === structureId
  );
  assert(isObject(structure), `structure ${structureId} should exist`);
  return structure;
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
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
