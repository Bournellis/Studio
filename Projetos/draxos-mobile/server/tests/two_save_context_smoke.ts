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

const normalHeaders = authHeaders(accessToken, "normal");
const labHeaders = authHeaders(accessToken, "progression_lab");
const invalidSaveState = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  authHeaders(accessToken, "invalid_save"),
  false,
);
assertEq(
  objectField(invalidSaveState, "error").code,
  "INVALID_SAVE_TYPE",
  "invalid save header should be rejected",
);

const normalAccount = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "two-save-normal-smoke",
    request_id: crypto.randomUUID(),
  },
  normalHeaders,
);
const normalPlayer = objectField(normalAccount, "player");
assertEq(
  normalPlayer.save_type,
  "normal",
  "normal account should use normal save",
);

const labAccount = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "two-save-lab-smoke",
    request_id: crypto.randomUUID(),
  },
  labHeaders,
);
const labPlayer = objectField(labAccount, "player");
assertEq(
  labPlayer.save_type,
  "progression_lab",
  "lab account should use progression_lab save",
);
assert(
  stringField(normalPlayer, "id") !== stringField(labPlayer, "id"),
  "normal and lab saves should use distinct player ids",
);

const normalState = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  normalHeaders,
);
const labState = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  labHeaders,
);
assertEq(
  objectField(normalState, "player").id,
  normalPlayer.id,
  "normal state should resolve normal player",
);
assertEq(
  objectField(labState, "player").id,
  labPlayer.id,
  "lab state should resolve lab player",
);

const labBattle = await postJson(
  `${SUPABASE_URL}/functions/v1/battle/request`,
  {
    request_id: crypto.randomUUID(),
    mode: "MVP_ONLY",
  },
  labHeaders,
);
assertEq(
  stringField(objectField(labBattle, "battle_log"), "schema_version"),
  "battle_log_v1",
  "lab battle should return battle log",
);

const labBase = await getJson(
  `${SUPABASE_URL}/functions/v1/base/state`,
  labHeaders,
);
assert(
  Array.isArray(objectField(labBase, "base").structures),
  "lab base state should include structures",
);

const labShop = await getJson(
  `${SUPABASE_URL}/functions/v1/monetization/state`,
  labHeaders,
);
assert(
  isObject(objectField(labShop, "monetization").battle_pass),
  "lab monetization state should include battle pass",
);

const labRanking = await getJson(
  `${SUPABASE_URL}/functions/v1/competition/ranking/current`,
  labHeaders,
);
assertEq(
  objectField(labRanking, "ranking").excluded_reason,
  "PROGRESSION_LAB_DOES_NOT_RANK",
  "lab save should be excluded from ranking",
);

console.log("[two-save-context-smoke] OK", {
  normal_player_id: normalPlayer.id,
  lab_player_id: labPlayer.id,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function authHeaders(
  accessToken: string,
  saveType: string,
): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
    "x-draxos-save-type": saveType,
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
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${text}`,
    );
    assert(payload.ok === true, `response ok should be true: ${text}`);
  }
  return payload;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
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
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
