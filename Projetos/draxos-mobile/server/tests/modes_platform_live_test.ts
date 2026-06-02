import postgres from "npm:postgres@3.4.5";

const SUPABASE_URL = (Deno.env.get("SUPABASE_URL") ??
  "http://127.0.0.1:54321").replace(/\/+$/, "");
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";
const DATABASE_URL = Deno.env.get("DRAXOS_LOCAL_DB_URL") ??
  "postgres://postgres:postgres@127.0.0.1:54322/postgres";

type SaveType = "normal" | "progression_lab";

interface JsonObject {
  [key: string]: unknown;
}

interface TestAccount {
  authUserId: string;
  playerId: string;
  headers: Record<string, string>;
  saveType: SaveType;
}

const MODE_MODE_ID = "openworld";
const MODE_SLICE_ID = "forest";
const MODE_RULESET_ID = "openworld_forest_ruleset_v1";
const MODE_RULESET_VERSION = 1;

const sql = postgres(DATABASE_URL, {
  max: 1,
  connect_timeout: 5,
  idle_timeout: 1,
});

try {
  assertLocalOnly();
  await assertLocalEdgeIsReachable();
  await assertLocalDatabaseIsCurrent();

  const account = await createTestAccount("mode-live-normal", "normal");
  await proveSaveTypeHeaderIsRequired(account);
  await proveRegistryAndState(account);
  await proveDisabledModesDoNotStart(account);
  await proveSessionRewardAndIdempotency(account);

  const tamperAccount = await createTestAccount("mode-live-tamper", "normal");
  await proveTamperedResultIsRejected(tamperAccount);

  const labAccount = await createTestAccount(
    "mode-live-progression-lab",
    "progression_lab",
  );
  await proveProgressionLabCannotClaimReward(labAccount);

  console.log("[mode-platform-live-test] OK", {
    supabase_url: SUPABASE_URL,
    normal_player: account.playerId,
    progression_lab_player: labAccount.playerId,
  });
} finally {
  await sql.end();
}

function assertLocalOnly(): void {
  assert(
    /^http:\/\/(127\.0\.0\.1|localhost|0\.0\.0\.0)(:\d+)?$/.test(
      SUPABASE_URL,
    ),
    "modes_platform_live_test refuses remote Supabase URLs. Use local Supabase/Edge.",
  );
}

async function assertLocalEdgeIsReachable(): Promise<void> {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/healthcheck`, {
    method: "GET",
    headers: baseHeaders(),
  });
  const text = await response.text();
  assert(
    response.ok,
    `local Edge Runtime should serve healthcheck at ${SUPABASE_URL}: ${text}`,
  );
}

async function assertLocalDatabaseIsCurrent(): Promise<void> {
  const functionRows = await sql<{
    proname: string;
    anon_execute: boolean;
    authenticated_execute: boolean;
    service_role_execute: boolean;
  }[]>`
    select
      p.proname,
      has_function_privilege('anon', p.oid, 'EXECUTE') as anon_execute,
      has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_execute,
      has_function_privilege('service_role', p.oid, 'EXECUTE') as service_role_execute
    from pg_proc as p
    join pg_namespace as n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'mode_session_start_v1',
        'mode_session_event_v1',
        'mode_session_complete_v1'
      )
  `;
  const grants = new Map(functionRows.map((row) => [row.proname, row]));
  for (
    const rpc of [
      "mode_session_start_v1",
      "mode_session_event_v1",
      "mode_session_complete_v1",
    ]
  ) {
    const grant = grants.get(rpc);
    assert(grant !== undefined, `missing mode RPC ${rpc}`);
    assert(grant?.anon_execute === false, `${rpc} must not be anon executable`);
    assert(
      grant?.authenticated_execute === false,
      `${rpc} must not be authenticated executable`,
    );
    assert(
      grant?.service_role_execute === true,
      `${rpc} must be service_role executable`,
    );
  }

  const tableRows = await sql<{ relname: string; relrowsecurity: boolean }[]>`
    select c.relname, c.relrowsecurity
    from pg_class as c
    join pg_namespace as n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname in (
        'mode_registry',
        'mode_ruleset_registry',
        'mode_progress',
        'mode_sessions',
        'mode_reward_claims'
      )
  `;
  const rls = new Map(tableRows.map((row) => [row.relname, row.relrowsecurity]));
  for (
    const table of [
      "mode_registry",
      "mode_ruleset_registry",
      "mode_progress",
      "mode_sessions",
      "mode_reward_claims",
    ]
  ) {
    assert(rls.get(table) === true, `${table} must have RLS enabled`);
  }

  const registryRows = await sql<{ mode_id: string }[]>`
    select mode_id
    from public.mode_registry
    where mode_id = ${MODE_MODE_ID}
      and status = 'active'
      and release_channel = 'internal_alpha'
      and active_ruleset_id = ${MODE_RULESET_ID}
      and active_ruleset_version = ${MODE_RULESET_VERSION}
  `;
  assertEq(registryRows.length, 1, "openworld mode registry seed should match the active internal alpha contract");
}

async function createTestAccount(
  label: string,
  saveType: SaveType,
): Promise<TestAccount> {
  const auth = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { data: { provider: "guest" } },
    baseHeaders(saveType),
    false,
  );
  const accessToken = stringField(auth, "access_token");
  const user = objectField(auth, "user");
  const authUserId = stringField(user, "id");
  assert(accessToken !== "", "anonymous auth should return access_token");
  assert(authUserId !== "", "anonymous auth should return user.id");

  const headers = {
    ...baseHeaders(saveType),
    authorization: `Bearer ${accessToken}`,
  };
  const account = await postJson(
    `${SUPABASE_URL}/functions/v1/account/guest`,
    {
      invite_code: "ALPHA-TEST",
      device_label: label,
      request_id: crypto.randomUUID(),
    },
    headers,
  );
  const player = objectField(account, "player");
  const playerId = stringField(player, "id");
  assert(playerId !== "", "account/guest should return player.id");
  return { authUserId, playerId, headers, saveType };
}

async function proveSaveTypeHeaderIsRequired(
  account: TestAccount,
): Promise<void> {
  const headers = { ...account.headers };
  delete headers["x-draxos-save-type"];
  const response = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/registry`,
    headers,
    false,
  );
  assertEq(
    stringField(objectField(response, "error"), "code"),
    "INVALID_SAVE_TYPE",
    "modes should require x-draxos-save-type explicitly",
  );
}

async function proveRegistryAndState(account: TestAccount): Promise<void> {
  const registry = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/registry`,
    account.headers,
  );
  assertEq(
    stringField(findObjectByField(arrayField(registry, "modes"), "mode_id", MODE_MODE_ID), "mode_id"),
    MODE_MODE_ID,
    "registry should expose openworld",
  );
  assertEq(
    stringField(findObjectByField(arrayField(registry, "rulesets"), "ruleset_id", MODE_RULESET_ID), "ruleset_id"),
    MODE_RULESET_ID,
    "registry should expose openworld forest ruleset",
  );

  const state = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/state?mode_id=${MODE_MODE_ID}`,
    account.headers,
  );
  assertEq(
    stringField(findObjectByField(arrayField(state, "modes"), "mode_id", MODE_MODE_ID), "mode_id"),
    MODE_MODE_ID,
    "state should be scoped to openworld",
  );
  assertEq(
    arrayField(state, "sessions").length,
    0,
    "new test account should have no mode sessions yet",
  );
}

async function proveDisabledModesDoNotStart(account: TestAccount): Promise<void> {
  for (const modeId of ["towerdefense", "cardgame"]) {
    const response = await postJson(
      `${SUPABASE_URL}/functions/v1/modes/session/start`,
      {
        request_id: crypto.randomUUID(),
        mode_id: modeId,
        slice_id: "tbd",
      },
      account.headers,
      false,
    );
    assertEq(
      stringField(objectField(response, "error"), "code"),
      "MODE_DISABLED",
      `${modeId} should be staged/disabled`,
    );
  }
}

async function proveSessionRewardAndIdempotency(
  account: TestAccount,
): Promise<void> {
  const startRequestId = crypto.randomUUID();
  const startBody = {
    request_id: startRequestId,
    mode_id: MODE_MODE_ID,
    slice_id: MODE_SLICE_ID,
  };
  const firstStart = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    startBody,
    account.headers,
  );
  const repeatedStart = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    startBody,
    account.headers,
  );
  const sessionId = stringField(objectField(firstStart, "session"), "id");
  let revision = numberField(objectField(firstStart, "session"), "snapshot_revision");
  assert(sessionId !== "", "session/start should return session.id");
  assertEq(
    sessionId,
    stringField(objectField(repeatedStart, "session"), "id"),
    "session/start should be idempotent",
  );
  await assertCompletedIdempotency(
    "modes/session/start",
    startRequestId,
    "mode:openworld:normal",
  );

  for (
    const node of [
      { node_id: "node_madeira_01", item_id: "madeira" },
      { node_id: "node_pedra_01", item_id: "pedra" },
      { node_id: "node_pedra_pequena_01", item_id: "pedra_pequena" },
      { node_id: "node_ossos_preview_01", item_id: "ossos_preview" },
      { node_id: "node_po_osso_preview_01", item_id: "po_osso_preview" },
    ]
  ) {
    revision = await recordEvent(account, sessionId, revision, "collect_start", {
      node_id: node.node_id,
      item_id: node.item_id,
      session_seconds: 119,
    });
    revision = await recordEvent(account, sessionId, revision, "collect_complete", {
      ...node,
      session_seconds: 120,
    });
  }
  revision = await recordEvent(account, sessionId, revision, "deposit_all", {
    session_seconds: 120,
  });

  const completeRequestId = crypto.randomUUID();
  const completeBody = completionBody(completeRequestId, sessionId, revision);
  const firstComplete = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completeBody,
    account.headers,
  );
  const reward = objectField(firstComplete, "reward");
  const resourceDelta = objectField(reward, "resource_delta");
  assert(numberField(resourceDelta, "energia") >= 1, "reward energy should come from server snapshot");
  assert(numberField(resourceDelta, "ossos") >= 0, "reward bones should be server-derived");
  assert(numberField(resourceDelta, "xp") >= 0, "reward XP should be server-derived");

  const repeatedComplete = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completeBody,
    account.headers,
  );
  assertStableJson(
    firstComplete,
    repeatedComplete,
    "session/complete should return stored idempotent response",
  );
  await assertCompletedIdempotency(
    "modes/session/complete",
    completeRequestId,
    "mode:openworld:normal",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.mode_reward_claims where request_id = ${completeRequestId}::uuid`,
    ),
    1,
    "reward claim should persist once",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.resource_transactions where request_id = ${completeRequestId}::uuid`,
    ),
    1,
    "resource ledger should persist once",
  );

  const mismatch = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    { ...completeBody, request_hash: "sha256:changed" },
    account.headers,
    false,
  );
  assertEq(
    stringField(objectField(mismatch, "error"), "code"),
    "IDEMPOTENCY_HASH_MISMATCH",
    "same complete request_id with a different hash should be rejected",
  );

  const state = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/state?mode_id=${MODE_MODE_ID}`,
    account.headers,
  );
  assertEq(arrayField(state, "sessions").length, 1, "state should expose completed session");
  assertEq(arrayField(state, "rewards").length, 1, "state should expose reward claim");
}

async function proveTamperedResultIsRejected(
  account: TestAccount,
): Promise<void> {
  const sessionId = await startSession(account);
  const requestId = crypto.randomUUID();
  const response = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completionBody(requestId, sessionId, 999),
    account.headers,
    false,
  );
  assertEq(
    stringField(objectField(response, "error"), "code"),
    "MODE_SESSION_REVISION_STALE",
    "server should reject stale or forged completion revisions",
  );
}

async function proveProgressionLabCannotClaimReward(
  account: TestAccount,
): Promise<void> {
  const sessionId = await startSession(account);
  const requestId = crypto.randomUUID();
  const response = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completionBody(requestId, sessionId, 0),
    account.headers,
    false,
  );
  assertEq(
    stringField(objectField(response, "error"), "code"),
    "MODE_REWARD_BLOCKED_FOR_LAB",
    "progression_lab save must not receive real mode rewards",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.mode_reward_claims where request_id = ${requestId}::uuid`,
    ),
    0,
    "blocked lab completion should not create reward claims",
  );
}

async function startSession(account: TestAccount): Promise<string> {
  const start = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    {
      request_id: crypto.randomUUID(),
      mode_id: MODE_MODE_ID,
      slice_id: MODE_SLICE_ID,
    },
    account.headers,
  );
  return stringField(objectField(start, "session"), "id");
}

function completionBody(
  requestId: string,
  sessionId: string,
  expectedRevision: number,
): JsonObject {
  return {
    request_id: requestId,
    result: {
      session_id: sessionId,
      ruleset_id: MODE_RULESET_ID,
      ruleset_version: MODE_RULESET_VERSION,
      expected_revision: expectedRevision,
    },
  };
}

async function recordEvent(
  account: TestAccount,
  sessionId: string,
  expectedRevision: number,
  eventType: string,
  eventPayload: JsonObject,
): Promise<number> {
  const response = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/event`,
    {
      request_id: crypto.randomUUID(),
      session_id: sessionId,
      mode_id: MODE_MODE_ID,
      slice_id: MODE_SLICE_ID,
      event_type: eventType,
      expected_revision: expectedRevision,
      event_payload: eventPayload,
    },
    account.headers,
  );
  return numberField(objectField(response, "event"), "revision_after");
}

async function assertCompletedIdempotency(
  endpoint: string,
  requestId: string,
  scopeId: string,
): Promise<void> {
  const rows = await sql<{ status: string; scope_id: string | null }[]>`
    select status, scope_id
    from public.idempotency_keys
    where endpoint = ${endpoint}
      and request_id = ${requestId}::uuid
  `;
  assertEq(rows.length, 1, `${endpoint} should create one idempotency row`);
  assertEq(rows[0].status, "completed", `${endpoint} idempotency should complete`);
  assertEq(rows[0].scope_id, scopeId, `${endpoint} idempotency scope should match`);
}

function baseHeaders(saveType: SaveType = "normal"): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
    "x-draxos-api-version": "1",
    "x-draxos-save-type": saveType,
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
    assert(payload.ok === true, `response ok should be true: ${text}`);
  }
  return payload;
}

async function countRows(query: PromiseLike<{ length: number }>): Promise<number> {
  return (await query).length;
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function objectField(value: JsonObject, key: string): JsonObject {
  const field = value[key];
  assert(isObject(field), `${key} should be an object`);
  return field;
}

function arrayField(value: JsonObject, key: string): unknown[] {
  const field = value[key];
  assert(Array.isArray(field), `${key} should be an array`);
  return field;
}

function findObjectByField(items: unknown[], key: string, expected: string): JsonObject {
  for (const item of items) {
    if (isObject(item) && item[key] === expected) {
      return item;
    }
  }
  throw new Error(`Missing object with ${key}=${expected}`);
}

function stringField(value: JsonObject, key: string): string {
  const field = value[key];
  assert(typeof field === "string", `${key} should be a string`);
  return field;
}

function numberField(value: JsonObject, key: string): number {
  const field = value[key];
  assert(typeof field === "number", `${key} should be numeric`);
  return field;
}

function isObject(value: unknown): value is JsonObject {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function stableStringify(value: unknown, parentKey = ""): string {
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item, parentKey)).join(",")}]`;
  }
  if (isObject(value)) {
    const keys = Object.keys(value).filter((key) => !(parentKey === "cache" && key === "generated_at"));
    return `{${
      keys.sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key], key)}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function assertStableJson(
  actual: JsonObject,
  expected: JsonObject,
  message: string,
): void {
  assertEq(stableStringify(actual), stableStringify(expected), message);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq<T>(actual: T, expected: T, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
