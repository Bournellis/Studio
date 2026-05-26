const SUPABASE_URL = requiredEnv("SUPABASE_URL").replace(/\/+$/, "");
const PUBLISHABLE_KEY = requiredEnv("SUPABASE_PUBLISHABLE_KEY");
const RUN_ANON_AUTH = Deno.env.get("DRAXOS_REMOTE_ANON_AUTH_SMOKE") === "1";
const RUN_ACCOUNT_STATE = Deno.env.get("DRAXOS_REMOTE_ACCOUNT_SMOKE") === "1";

assertRemoteUrl(SUPABASE_URL);
assertClientKey(PUBLISHABLE_KEY);

interface JsonObject {
  [key: string]: unknown;
}

const healthcheck = await getJson(
  `${SUPABASE_URL}/functions/v1/healthcheck`,
  baseHeaders(),
);
assertEq(healthcheck.ok, true, "remote healthcheck should return ok");

let authUser = "";
let playerId = "";
if (RUN_ANON_AUTH || RUN_ACCOUNT_STATE) {
  const auth = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { data: { provider: "guest" } },
    baseHeaders(),
    false,
  );
  authUser = stringField(objectField(auth, "user"), "id");
  assert(stringField(auth, "access_token") !== "", "auth should return token");
  assert(authUser !== "", "auth should return user id");

  if (RUN_ACCOUNT_STATE) {
    const headers = {
      ...baseHeaders(),
      authorization: `Bearer ${stringField(auth, "access_token")}`,
    };
    const account = await postJson(
      `${SUPABASE_URL}/functions/v1/account/guest`,
      {
        invite_code: Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ??
          "ALPHA-TEST",
        device_label: "deno-internal-alpha-remote-smoke",
        request_id: crypto.randomUUID(),
      },
      headers,
    );
    playerId = stringField(objectField(account, "player"), "id");
    assert(playerId !== "", "account/guest should return player id");

    const state = await getJson(
      `${SUPABASE_URL}/functions/v1/account/state`,
      headers,
    );
    assertEq(
      stringField(objectField(state, "player"), "id"),
      playerId,
      "account/state should return the same player",
    );
  }
}

console.log("[internal-alpha-remote-smoke] OK", {
  url: SUPABASE_URL,
  healthcheck: healthcheck.ok,
  anon_auth: RUN_ANON_AUTH || RUN_ACCOUNT_STATE ? "checked" : "skipped",
  account_state: RUN_ACCOUNT_STATE ? "checked" : "skipped",
  auth_user: authUser,
  player_id: playerId,
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
    assert(payload.ok === true, `response ok should be true: ${text}`);
  }
  return payload;
}

function requiredEnv(key: string): string {
  const value = Deno.env.get(key)?.trim() ?? "";
  if (value === "") {
    throw new Error(`${key} is required for remote smoke`);
  }
  return value;
}

function assertRemoteUrl(url: string): void {
  assert(
    url.startsWith("https://"),
    "remote smoke requires an https Supabase project URL",
  );
  assert(
    !url.includes("localhost") && !url.includes("127.0.0.1"),
    "remote smoke refuses local Supabase URLs",
  );
}

function assertClientKey(key: string): void {
  const normalized = key.toLowerCase();
  assert(
    !normalized.includes("service_role") &&
      !normalized.includes("secret") &&
      !normalized.startsWith("sb_secret_") &&
      !normalized.startsWith("sb_service_"),
    "remote smoke must use a publishable/client key, never service role",
  );
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
