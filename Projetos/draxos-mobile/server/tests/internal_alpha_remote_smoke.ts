const SUPABASE_URL = requiredEnv("SUPABASE_URL").replace(/\/+$/, "");
const PUBLISHABLE_KEY = requiredEnv("SUPABASE_PUBLISHABLE_KEY");
const RUN_ANON_AUTH = Deno.env.get("DRAXOS_REMOTE_ANON_AUTH_SMOKE") === "1";
const RUN_ACCOUNT_STATE = Deno.env.get("DRAXOS_REMOTE_ACCOUNT_SMOKE") === "1";
const RUN_EMAIL_AUTH = Deno.env.get("DRAXOS_REMOTE_EMAIL_AUTH_SMOKE") === "1";
const RUN_RELEASE_MANIFEST =
  Deno.env.get("DRAXOS_REMOTE_RELEASE_SMOKE") === "1";
const RUN_MODE = Deno.env.get("DRAXOS_REMOTE_MODE_SMOKE") === "1";
const CORS_ORIGIN = Deno.env.get("DRAXOS_REMOTE_CORS_ORIGIN") ??
  "https://68116729.draxos-mobile-internal-alpha.pages.dev";

const MODE_MODE_ID = "openworld";
const MODE_SLICE_ID = "forest";
const MODE_RULESET_ID = "openworld_forest_ruleset_v0";
const MODE_RULESET_VERSION = 1;

assertRemoteUrl(SUPABASE_URL);
assertClientKey(PUBLISHABLE_KEY);
assert(
  !RUN_MODE || RUN_EMAIL_AUTH,
  "DRAXOS_REMOTE_MODE_SMOKE requires DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1",
);

interface JsonObject {
  [key: string]: unknown;
}

const healthcheck = await getJson(
  `${SUPABASE_URL}/functions/v1/healthcheck`,
  baseHeaders(),
);
assertEq(healthcheck.ok, true, "remote healthcheck should return ok");

await assertCorsPreflights([
  { url: `${SUPABASE_URL}/auth/v1/token?grant_type=password`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/account/guest`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/account/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/base/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/battle/request`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/build/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/social/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/competition/ranking/current`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/monetization/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/telemetry/client-event`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/release/manifest`, method: "GET" },
]);

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
let modeSessionId = "";
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
  assert(
    emailBattleId !== "",
    "registered email account should be able to request battle",
  );
  assertEq(
    stringField(registeredBattleLog, "schema_version"),
    "battle_log_v1",
    "registered email battle should return a battle log",
  );

  if (RUN_MODE) {
    modeSessionId = await proveRemoteModeFlow(
      stringField(signin, "access_token"),
    );
  }
}

console.log("[internal-alpha-remote-smoke] OK", {
  url: SUPABASE_URL,
  healthcheck: healthcheck.ok,
  anon_auth: RUN_ANON_AUTH || RUN_ACCOUNT_STATE ? "checked" : "skipped",
  account_state: RUN_ACCOUNT_STATE ? "checked" : "skipped",
  email_auth: RUN_EMAIL_AUTH ? "checked" : "skipped",
  mode: RUN_MODE ? "checked" : "skipped",
  release_manifest: releaseManifestChecked ? "checked" : "skipped",
  auth_user: authUser,
  player_id: playerId,
  email_user: emailUser,
  email_player_id: emailPlayerId,
  lab_player_id: labPlayerId,
  email_battle_id: emailBattleId,
  mode_session_id: modeSessionId,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
    "x-draxos-api-version": "1",
  };
}

async function assertCorsPreflights(
  targets: Array<{ url: string; method: string }>,
): Promise<void> {
  for (const target of targets) {
    await assertCorsPreflight(target.url, target.method);
  }
}

async function assertCorsPreflight(url: string, method: string): Promise<void> {
  const response = await fetch(url, {
    method: "OPTIONS",
    headers: {
      apikey: PUBLISHABLE_KEY,
      origin: CORS_ORIGIN,
      "access-control-request-method": method,
      "access-control-request-headers":
        "authorization,apikey,content-type,x-draxos-api-version,x-draxos-save-type",
    },
  });
  assert(
    response.ok,
    `CORS preflight should pass for ${url}; status ${response.status}`,
  );
  const allowHeaders = response.headers.get("access-control-allow-headers") ??
    "";
  const allowOrigin = response.headers.get("access-control-allow-origin");
  if (url.includes("/auth/v1/")) {
    assert(
      allowOrigin === CORS_ORIGIN || allowOrigin === "*",
      `Auth CORS preflight should allow ${CORS_ORIGIN} or * for ${url}; got ${allowOrigin}`,
    );
  } else {
    assertEq(
      allowOrigin,
      CORS_ORIGIN,
      `CORS preflight should echo ${CORS_ORIGIN} for ${url}`,
    );
  }
  assertIncludes(
    allowHeaders.toLowerCase(),
    "x-draxos-api-version",
    `CORS preflight should allow x-draxos-api-version for ${url}`,
  );
}

function modeHeaders(
  accessToken: string,
  saveType: "normal" | "progression_lab" = "normal",
): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
    "x-draxos-api-version": "1",
    "x-draxos-save-type": saveType,
  };
}

async function proveRemoteModeFlow(accessToken: string): Promise<string> {
  const headers = modeHeaders(accessToken);
  const registry = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/registry`,
    headers,
  );
  assertEq(
    stringField(findObjectByField(arrayField(registry, "modes"), "mode_id", MODE_MODE_ID), "mode_id"),
    MODE_MODE_ID,
    "remote mode registry should expose openworld",
  );
  assertEq(
    stringField(
      findObjectByField(arrayField(registry, "rulesets"), "ruleset_id", MODE_RULESET_ID),
      "ruleset_id",
    ),
    MODE_RULESET_ID,
    "remote mode registry should expose the forest ruleset",
  );

  const state = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/state?mode_id=${MODE_MODE_ID}`,
    headers,
  );
  assertEq(
    stringField(findObjectByField(arrayField(state, "modes"), "mode_id", MODE_MODE_ID), "mode_id"),
    MODE_MODE_ID,
    "remote mode state should be scoped to openworld",
  );

  const startBody = {
    request_id: crypto.randomUUID(),
    mode_id: MODE_MODE_ID,
    slice_id: MODE_SLICE_ID,
  };
  const started = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    startBody,
    headers,
  );
  const repeatedStart = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    startBody,
    headers,
  );
  const sessionId = stringField(objectField(started, "session"), "id");
  assert(
    sessionId !== "",
    "remote mode session/start should return session.id",
  );
  assertEq(
    sessionId,
    stringField(objectField(repeatedStart, "session"), "id"),
    "remote mode session/start should be idempotent",
  );

  const completeBody = {
    request_id: crypto.randomUUID(),
    result: {
      session_id: sessionId,
      ruleset_id: MODE_RULESET_ID,
      ruleset_version: MODE_RULESET_VERSION,
      session_seconds: 120,
      activity_score: 500,
      deposited_items: {
        madeira: 20,
        folha: 7,
        ossos_preview: 6,
        po_osso_preview: 3,
      },
    },
  };
  const completed = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completeBody,
    headers,
  );
  const repeatedComplete = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completeBody,
    headers,
  );
  assertEq(
    stableStringify(completed),
    stableStringify(repeatedComplete),
    "remote mode session/complete should be idempotent",
  );
  const resourceDelta = objectField(
    objectField(completed, "reward"),
    "resource_delta",
  );
  assertEq(
    numberField(resourceDelta, "energia"),
    12,
    "remote mode energy reward should be capped",
  );
  assertEq(
    numberField(resourceDelta, "ossos"),
    2,
    "remote mode bones reward should be capped",
  );
  assertEq(
    numberField(resourceDelta, "xp"),
    8,
    "remote mode XP reward should be capped",
  );

  const labStarted = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    {
      request_id: crypto.randomUUID(),
      mode_id: MODE_MODE_ID,
      slice_id: MODE_SLICE_ID,
    },
    modeHeaders(accessToken, "progression_lab"),
  );
  const labBlocked = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    {
      request_id: crypto.randomUUID(),
      result: {
        session_id: stringField(objectField(labStarted, "session"), "id"),
        ruleset_id: MODE_RULESET_ID,
        ruleset_version: MODE_RULESET_VERSION,
        session_seconds: 60,
        activity_score: 120,
        deposited_items: { madeira: 2, ossos_preview: 3 },
      },
    },
    modeHeaders(accessToken, "progression_lab"),
    false,
  );
  assertEq(
    stringField(objectField(labBlocked, "error"), "code"),
    "MODE_REWARD_BLOCKED_FOR_LAB",
    "remote progression_lab mode completion should not award real resources",
  );

  return sessionId;
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

function arrayField(payload: JsonObject, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function findObjectByField(items: unknown[], key: string, expected: string): JsonObject {
  for (const item of items) {
    if (isObject(item) && item[key] === expected) {
      return item;
    }
  }
  throw new Error(`Missing object with ${key}=${expected}`);
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  assert(typeof value === "number", `${key} should be a number`);
  return value;
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

function assertIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}. Got: ${haystack}`);
  }
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item)).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}
