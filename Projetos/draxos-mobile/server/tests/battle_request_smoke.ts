const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

interface JsonObject {
  [key: string]: unknown;
}

const auth = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  {
    data: { provider: "guest" },
  },
  baseHeaders(),
  false,
);
const accessToken = stringField(auth, "access_token");
assert(accessToken !== "", "anonymous auth should return access_token");

const headers = {
  ...baseHeaders(),
  authorization: `Bearer ${accessToken}`,
};

const unauthenticated = await postJson(
  `${SUPABASE_URL}/functions/v1/battle/request`,
  { request_id: crypto.randomUUID(), mode: "MVP_ONLY" },
  baseHeaders(),
  false,
);
assertEq(
  errorCode(unauthenticated),
  "UNAUTHENTICATED",
  "battle/request should require auth",
);

await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-battle-smoke",
  request_id: crypto.randomUUID(),
}, headers);

const requestId = crypto.randomUUID();
const firstBattle = await postJson(
  `${SUPABASE_URL}/functions/v1/battle/request`,
  {
    request_id: requestId,
    mode: "MVP_ONLY",
  },
  headers,
);
const secondBattle = await postJson(
  `${SUPABASE_URL}/functions/v1/battle/request`,
  {
    request_id: requestId,
    mode: "MVP_ONLY",
  },
  headers,
);
const latest = await getJson(
  `${SUPABASE_URL}/functions/v1/battle/latest`,
  headers,
);
const state = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  headers,
);

const firstLog = objectField(firstBattle, "battle_log");
const secondLog = objectField(secondBattle, "battle_log");
const latestLog = objectField(latest, "battle_log");
const rewardResources = objectField(
  objectField(firstBattle, "rewards"),
  "resources",
);
assertEq(
  stringField(firstLog, "schema_version"),
  "battle_log_v1",
  "battle schema should match",
);
assertEq(
  stringField(firstLog, "battle_id"),
  stringField(secondLog, "battle_id"),
  "idempotent request should return the same battle",
);
assertEq(
  stringField(firstLog, "battle_id"),
  stringField(latestLog, "battle_id"),
  "latest battle should match request result",
);
assertEq(
  objectField(firstLog, "result").winner,
  "player",
  "MVP result should be player victory",
);
assert(
  Array.isArray(firstLog.events) && firstLog.events.length >= 5,
  "battle log should include MVP events",
);
assertEq(
  objectField(firstBattle, "rewards").type,
  "MVP_ONLY",
  "reward type should be MVP_ONLY",
);
assertEq(
  objectField(state, "player").xp,
  rewardResources.xp,
  "repeated request_id should not duplicate XP",
);
assertEq(
  objectField(state, "resources").ossos,
  rewardResources.ossos,
  "repeated request_id should not duplicate Ossos",
);

console.log("[battle-smoke] OK", {
  battle_id: stringField(firstLog, "battle_id"),
  events: (firstLog.events as unknown[]).length,
  xp: objectField(state, "player").xp,
  ossos: objectField(state, "resources").ossos,
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
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "GET",
    headers,
  });
  return await parseResponse(response, true);
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

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function errorCode(payload: JsonObject): string {
  const gatewayMessage = stringField(payload, "message");
  if (gatewayMessage.toLowerCase().includes("authorization")) {
    return "UNAUTHENTICATED";
  }
  return stringField(objectField(payload, "error"), "code");
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
