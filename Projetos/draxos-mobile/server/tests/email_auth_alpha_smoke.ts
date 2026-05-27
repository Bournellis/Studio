const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

interface JsonObject {
  [key: string]: unknown;
}

const runId = crypto.randomUUID().replaceAll("-", "").slice(0, 12);
const email = `draxosalpha${runId}@gmail.com`;
const password = `alpha-${runId}`;
const username = `alpha_${runId.slice(0, 10)}`;

const signup = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  { email, password },
  baseHeaders(),
);
const signupToken = stringField(signup, "access_token");
assert(signupToken !== "", "email signup should return access token");
assertEq(
  Boolean(objectField(signup, "user").is_anonymous),
  false,
  "email signup should create a registered auth user",
);

const normalHeaders = authHeaders(signupToken);
const normalBootstrap = await postJson(
  `${SUPABASE_URL}/functions/v1/account/bootstrap`,
  {
    invite_code: Deno.env.get("DRAXOS_ALPHA_INVITE_CODE") ?? "ALPHA-TEST",
    username,
    device_label: "deno-email-alpha-smoke",
    request_id: crypto.randomUUID(),
  },
  normalHeaders,
);
assertEq(
  stringField(objectField(normalBootstrap, "player"), "username"),
  username,
  "account/bootstrap should create normal save with requested username",
);
assertEq(
  stringField(objectField(normalBootstrap, "player"), "account_type"),
  "registered",
  "account/bootstrap should mark email accounts as registered",
);

const normalState = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  normalHeaders,
);
assertEq(
  stringField(objectField(normalState, "player"), "username"),
  username,
  "account/state should return normal save for default context",
);

const labHeaders = authHeaders(signupToken, "progression_lab");
const labBootstrap = await postJson(
  `${SUPABASE_URL}/functions/v1/account/bootstrap`,
  {
    invite_code: Deno.env.get("DRAXOS_ALPHA_INVITE_CODE") ?? "ALPHA-TEST",
    username,
    device_label: "deno-email-alpha-smoke",
    request_id: crypto.randomUUID(),
  },
  labHeaders,
);
assertEq(
  stringField(objectField(labBootstrap, "player"), "username"),
  `${username}_lab`,
  "account/bootstrap should create isolated progression lab save",
);
assertEq(
  stringField(objectField(labBootstrap, "player"), "save_type"),
  "progression_lab",
  "progression lab bootstrap should preserve save context",
);

const labState = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  labHeaders,
);
assertEq(
  stringField(objectField(labState, "player"), "username"),
  `${username}_lab`,
  "account/state should respect x-draxos-save-type",
);

const signin = await postJson(
  `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
  { email, password },
  baseHeaders(),
);
const signinToken = stringField(signin, "access_token");
assert(signinToken !== "", "email login should return access token");
const signinState = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  authHeaders(signinToken),
);
assertEq(
  stringField(objectField(signinState, "player"), "username"),
  username,
  "signed-in account should recover the same normal save",
);

const registeredBattle = await postJson(
  `${SUPABASE_URL}/functions/v1/battle/request`,
  {
    request_id: crypto.randomUUID(),
    mode: "FIRST_SLICE_SIM",
  },
  authHeaders(signinToken),
);
const battleLog = objectField(registeredBattle, "battle_log");
assertEq(
  stringField(battleLog, "schema_version"),
  "battle_log_v1",
  "signed-in account should be able to request a battle",
);

console.log("[email-auth-alpha-smoke] OK", {
  email,
  username,
  normal_player: stringField(objectField(normalState, "player"), "id"),
  lab_player: stringField(objectField(labState, "player"), "id"),
  battle_id: stringField(battleLog, "battle_id"),
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function authHeaders(
  accessToken: string,
  saveType = "normal",
): Record<string, string> {
  const headers: Record<string, string> = {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
  };
  if (saveType !== "normal") {
    headers["x-draxos-save-type"] = saveType;
  }
  return headers;
}

async function getJson(
  url: string,
  headers: Record<string, string>,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response, true);
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
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
