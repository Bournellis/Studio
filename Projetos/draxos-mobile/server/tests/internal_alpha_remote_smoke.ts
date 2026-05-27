const SUPABASE_URL = requiredEnv("SUPABASE_URL").replace(/\/+$/, "");
const PUBLISHABLE_KEY = requiredEnv("SUPABASE_PUBLISHABLE_KEY");
const RUN_ANON_AUTH = Deno.env.get("DRAXOS_REMOTE_ANON_AUTH_SMOKE") === "1";
const RUN_ACCOUNT_STATE = Deno.env.get("DRAXOS_REMOTE_ACCOUNT_SMOKE") === "1";
const RUN_EMAIL_AUTH = Deno.env.get("DRAXOS_REMOTE_EMAIL_AUTH_SMOKE") === "1";
const RUN_RELEASE_MANIFEST = Deno.env.get("DRAXOS_REMOTE_RELEASE_SMOKE") === "1";

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

let releaseManifestChecked = false;
if (RUN_RELEASE_MANIFEST) {
  const manifest = await getJson(
    `${SUPABASE_URL}/functions/v1/release/manifest`,
    baseHeaders(),
    false,
  );
  assertEq(
    stringField(manifest, "schema_version"),
    "internal_alpha_manifest_v1",
    "release manifest schema should match the Godot contract",
  );
  assertEq(
    stringField(manifest, "channel"),
    "internal_alpha",
    "release manifest should use the internal alpha channel",
  );
  assertEq(
    manifest.latest_version_code,
    1,
    "release manifest should expose the current version code",
  );
  assert(
    isObject(manifest.artifacts),
    "release manifest should include artifacts",
  );
  releaseManifestChecked = true;
}

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

let emailUser = "";
let emailPlayerId = "";
let labPlayerId = "";
let emailBattleId = "";
if (RUN_EMAIL_AUTH) {
  const runId = crypto.randomUUID().replaceAll("-", "").slice(0, 12);
  const email = `draxosremotealpha${runId}@gmail.com`;
  const password = `alpha-${runId}`;
  const username = `remote_${runId.slice(0, 10)}`;
  const signup = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { email, password },
    baseHeaders(),
  );
  const signupToken = stringField(signup, "access_token");
  emailUser = stringField(objectField(signup, "user"), "id");
  assert(signupToken !== "", "email signup should return token");
  assert(emailUser !== "", "email signup should return user id");

  const headers = {
    ...baseHeaders(),
    authorization: `Bearer ${signupToken}`,
  };
  const account = await postJson(
    `${SUPABASE_URL}/functions/v1/account/bootstrap`,
    {
      invite_code: Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ?? "ALPHA-TEST",
      username,
      device_label: "deno-internal-alpha-email-smoke",
      request_id: crypto.randomUUID(),
    },
    headers,
  );
  emailPlayerId = stringField(objectField(account, "player"), "id");
  assert(
    emailPlayerId !== "",
    "account/bootstrap should return email player id",
  );
  assertEq(
    stringField(objectField(account, "player"), "account_type"),
    "registered",
    "email bootstrap should create registered player",
  );

  const labHeaders = {
    ...headers,
    "x-draxos-save-type": "progression_lab",
  };
  const lab = await postJson(
    `${SUPABASE_URL}/functions/v1/account/bootstrap`,
    {
      invite_code: Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ?? "ALPHA-TEST",
      username,
      device_label: "deno-internal-alpha-email-smoke",
      request_id: crypto.randomUUID(),
    },
    labHeaders,
  );
  labPlayerId = stringField(objectField(lab, "player"), "id");
  assert(labPlayerId !== "", "account/bootstrap should return lab player id");
  assertEq(
    stringField(objectField(lab, "player"), "username"),
    `${username}_lab`,
    "email bootstrap should create lab username suffix",
  );

  const signin = await postJson(
    `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
    { email, password },
    baseHeaders(),
  );
  const signinState = await getJson(
    `${SUPABASE_URL}/functions/v1/account/state`,
    {
      ...baseHeaders(),
      authorization: `Bearer ${stringField(signin, "access_token")}`,
    },
  );
  assertEq(
    stringField(objectField(signinState, "player"), "username"),
    username,
    "email signin should recover normal save",
  );

  const registeredBattle = await postJson(
    `${SUPABASE_URL}/functions/v1/battle/request`,
    {
      request_id: crypto.randomUUID(),
      mode: "FIRST_SLICE_SIM",
    },
    {
      ...baseHeaders(),
      authorization: `Bearer ${stringField(signin, "access_token")}`,
    },
  );
  const registeredBattleLog = objectField(registeredBattle, "battle_log");
  emailBattleId = stringField(registeredBattleLog, "battle_id");
  assert(emailBattleId !== "", "registered email account should be able to request battle");
  assertEq(
    stringField(registeredBattleLog, "schema_version"),
    "battle_log_v1",
    "registered email battle should return a battle log",
  );
}

console.log("[internal-alpha-remote-smoke] OK", {
  url: SUPABASE_URL,
  healthcheck: healthcheck.ok,
  anon_auth: RUN_ANON_AUTH || RUN_ACCOUNT_STATE ? "checked" : "skipped",
  account_state: RUN_ACCOUNT_STATE ? "checked" : "skipped",
  email_auth: RUN_EMAIL_AUTH ? "checked" : "skipped",
  release_manifest: releaseManifestChecked ? "checked" : "skipped",
  auth_user: authUser,
  player_id: playerId,
  email_user: emailUser,
  email_player_id: emailPlayerId,
  lab_player_id: labPlayerId,
  email_battle_id: emailBattleId,
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
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
