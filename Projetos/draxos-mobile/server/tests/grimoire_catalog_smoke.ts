const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";
const INVITE_CODE = Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ?? "ALPHA-TEST";

interface JsonObject {
  [key: string]: unknown;
}

const endpoint = `${
  SUPABASE_URL.replace(/\/+$/, "")
}/functions/v1/content/grimoire`;

const unauthenticated = await getJson(endpoint, baseHeaders(), false);
assertEq(
  errorCode(unauthenticated),
  "UNAUTHENTICATED",
  "content/grimoire should require auth",
);

const methodRejected = await postJson(endpoint, {}, baseHeaders(), false);
assertEq(
  errorCode(methodRejected),
  "METHOD_NOT_ALLOWED",
  "content/grimoire should reject non-GET methods before auth",
);

const anonAuth = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  { data: { provider: "guest" } },
  baseHeaders(),
);
const anonDenied = await getJson(
  endpoint,
  authHeaders(stringField(anonAuth, "access_token")),
  false,
);
assertEq(
  errorCode(anonDenied),
  "AUTH_REQUIRES_EMAIL",
  "content/grimoire should reject anonymous dev sessions",
);

const runId = crypto.randomUUID().replaceAll("-", "").slice(0, 12);
const email = `draxosgrimoire${runId}@gmail.com`;
const password = `alpha-${runId}`;
const username = `grim_${runId.slice(0, 10)}`;
const signup = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  { email, password },
  baseHeaders(),
);
const signupToken = stringField(signup, "access_token");
assert(signupToken !== "", "email signup should return access token");

const notBootstrapped = await getJson(
  endpoint,
  authHeaders(signupToken),
  false,
);
assertEq(
  errorCode(notBootstrapped),
  "ALPHA_ACCESS_REQUIRED",
  "content/grimoire should require an Internal Alpha save",
);

await postJson(
  `${SUPABASE_URL}/functions/v1/account/bootstrap`,
  {
    invite_code: INVITE_CODE,
    username,
    device_label: "deno-grimoire-catalog-smoke",
    request_id: crypto.randomUUID(),
  },
  authHeaders(signupToken),
);

const catalog = await getJson(endpoint, authHeaders(signupToken));
assertEq(
  catalog.ok,
  true,
  "content/grimoire should return ok after alpha bootstrap",
);
assertEq(
  stringField(catalog, "schema_version"),
  "grimoire_catalog_v1",
  "grimoire schema should match the site contract",
);
assertEq(
  stringField(catalog, "catalog_version"),
  "internal_alpha_v0",
  "grimoire catalog version should match the alpha channel",
);

const collections = objectField(catalog, "collections");
const counts = objectField(catalog, "counts");
assertCollection(collections, counts, "weapons", 8);
assertCollection(collections, counts, "spells", 20);
assertCollection(collections, counts, "doutrines", 11);
assertCollection(collections, counts, "familiars", 9);
assertCollection(collections, counts, "base_structures", 6);
assertCollection(collections, counts, "rewards", 6);
assertCollection(collections, counts, "power_bands", 6);
assertCollection(collections, counts, "bot_archetypes", 8);

console.log("[grimoire-catalog-smoke] OK", {
  url: SUPABASE_URL,
  schema: stringField(catalog, "schema_version"),
  collections: Object.keys(collections).length,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function authHeaders(accessToken: string): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
  };
}

async function getJson(
  url: string,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response, requireOk);
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

async function parseResponse(
  response: Response,
  requireOk: boolean,
): Promise<JsonObject> {
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${text}`,
    );
    assert(
      payload.ok === true || stringField(payload, "access_token") !== "",
      `response should be ok/auth: ${text}`,
    );
  }
  return payload;
}

function assertCollection(
  collections: JsonObject,
  counts: JsonObject,
  key: string,
  expectedCount: number,
): void {
  const value = collections[key];
  assert(Array.isArray(value), `${key} should be an array`);
  assertEq(
    value.length,
    expectedCount,
    `${key} should expose the expected item count`,
  );
  assertEq(
    numberField(counts, key),
    expectedCount,
    `${key} count should match items`,
  );
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

function errorCode(payload: JsonObject): string {
  return stringField(objectField(payload, "error"), "code");
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

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Expected ${expected}, got ${actual}.`);
  }
}
