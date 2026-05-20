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

const unauthenticated = await postJson(
  `${SUPABASE_URL}/functions/v1/telemetry/client-event`,
  {
    schema_version: "telemetry_client_v1",
    event_type: "screen_opened",
    session_id: crypto.randomUUID(),
    payload: { screen: "hub" },
  },
  baseHeaders(),
  false,
);
assertEq(
  errorCode(unauthenticated),
  "UNAUTHENTICATED",
  "telemetry/client-event should require auth",
);

const preAccountEvent = await postJson(
  `${SUPABASE_URL}/functions/v1/telemetry/client-event`,
  {
    schema_version: "telemetry_client_v1",
    event_type: "screen_opened",
    session_id: crypto.randomUUID(),
    payload: { screen: "hub", account_state: "anonymous_only" },
  },
  headers,
);
assertEq(
  preAccountEvent.accepted,
  true,
  "anonymous telemetry should be accepted",
);

const account = await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-telemetry-smoke",
  request_id: crypto.randomUUID(),
}, headers);
const player = objectField(account, "player");

const sessionId = crypto.randomUUID();
const actionEvent = await postJson(
  `${SUPABASE_URL}/functions/v1/telemetry/client-event`,
  {
    schema_version: "telemetry_client_v1",
    event_type: "action_success",
    session_id: sessionId,
    payload: {
      action_id: "enter_guest",
      surface: "pc_local_alpha",
    },
  },
  headers,
);
assertEq(
  actionEvent.accepted,
  true,
  "post-account telemetry should be accepted",
);
assertEq(
  actionEvent.session_id,
  sessionId,
  "telemetry response should echo session_id",
);

const invalidSchema = await postJson(
  `${SUPABASE_URL}/functions/v1/telemetry/client-event`,
  {
    schema_version: "unknown",
    event_type: "screen_opened",
    session_id: crypto.randomUUID(),
    payload: {},
  },
  headers,
  false,
);
assertEq(
  errorCode(invalidSchema),
  "UNSUPPORTED_SCHEMA",
  "telemetry should reject unknown schema versions",
);

const directInsert = await postJson(
  `${SUPABASE_URL}/rest/v1/telemetry_events`,
  {
    player_id: player.id,
    session_id: sessionId,
    event_type: "direct_forbidden",
    schema_version: "telemetry_client_v1",
    source: "client",
    payload: {},
  },
  headers,
  false,
);
assert(
  !Boolean(directInsert.ok),
  "direct anon insert into telemetry_events should be blocked by RLS",
);

console.log("[client-telemetry-smoke] OK", {
  player_id: player.id,
  session_id: sessionId,
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
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
