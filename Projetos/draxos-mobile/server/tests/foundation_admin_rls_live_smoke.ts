import postgres from "npm:postgres@3.4.5";

const SUPABASE_URL = (Deno.env.get("SUPABASE_URL") ??
  "http://127.0.0.1:54321").replace(/\/+$/, "");
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";
const LOCAL_SERVICE_ROLE_KEY =
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU";
const SERVICE_ROLE_KEY = serviceRoleKeyForTarget();
const DATABASE_URL = Deno.env.get("DRAXOS_LOCAL_DB_URL") ??
  "postgres://postgres:postgres@127.0.0.1:54322/postgres";

interface JsonObject {
  [key: string]: unknown;
}

interface TestAccount {
  authUserId: string;
  accountProfileId: string;
  gameSaveId: string;
  playerId: string;
  username: string;
  headers: Record<string, string>;
}

const ADMIN_RPCS = [
  "resource_reconciliation_report_v1",
  "admin_adjust_resource_balance_v1",
  "admin_lookup_account_v1",
  "admin_battle_diagnostics_v1",
  "admin_flag_account_v1",
  "admin_set_mode_status_v1",
  "admin_expire_mode_session_v1",
  "admin_invalidate_mode_session_v1",
];

const sql = postgres(DATABASE_URL, {
  max: 1,
  connect_timeout: 5,
  idle_timeout: 1,
});

try {
  assertLocalOnly();
  await assertLocalEdgeIsReachable();
  await assertLocalDatabaseIsCurrent();

  const primary = await createTestAccount("admin-rls-primary");
  const secondary = await createTestAccount("admin-rls-secondary");

  await proveOwnReadIsolation(primary, secondary);
  await proveRulesetRegistryRls(primary);
  await proveAdminAuditHiddenFromClient(primary);
  await proveAdminRpcDeniedToClient();
  await proveServiceRoleAdminOps(primary);

  console.log("[foundation-admin-rls-live-smoke] OK", {
    supabase_url: SUPABASE_URL,
    account_profile_id: primary.accountProfileId,
    game_save_id: primary.gameSaveId,
    player_id: primary.playerId,
  });
} finally {
  await sql.end();
}

function assertLocalOnly(): void {
  assert(
    isLocalSupabaseUrl(SUPABASE_URL),
    "foundation_admin_rls_live_smoke refuses remote Supabase URLs. Start local Supabase/Edge or set SUPABASE_URL=http://127.0.0.1:54321.",
  );
}

function serviceRoleKeyForTarget(): string {
  const configured = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim() ?? "";
  if (configured !== "") {
    return configured;
  }
  assert(
    isLocalSupabaseUrl(SUPABASE_URL),
    "SUPABASE_SERVICE_ROLE_KEY is required for non-local targets; the bundled local service role fallback is limited to localhost, 127.0.0.1 or ::1.",
  );
  return LOCAL_SERVICE_ROLE_KEY;
}

function isLocalSupabaseUrl(value: string): boolean {
  try {
    const url = new URL(value);
    const host = url.hostname.toLowerCase();
    return url.protocol === "http:" &&
      (host === "localhost" || host === "127.0.0.1" || host === "0.0.0.0" ||
        host === "::1" || host === "[::1]");
  } catch {
    return false;
  }
}

async function assertLocalEdgeIsReachable(): Promise<void> {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/healthcheck`, {
    method: "GET",
    headers: baseHeaders(),
  });
  const text = await response.text();
  assert(
    response.ok,
    `local Edge Runtime should serve healthcheck at ${SUPABASE_URL}. Start it with "supabase functions serve". Response: ${text}`,
  );
}

async function assertLocalDatabaseIsCurrent(): Promise<void> {
  const rlsRows = await sql<{ relname: string; relrowsecurity: boolean }[]>`
    select c.relname, c.relrowsecurity
    from pg_class as c
    join pg_namespace as n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname in (
        'account_profiles',
        'game_saves',
        'ruleset_registry',
        'admin_audit_log'
      )
  `;
  const rlsEnabled = new Map(
    rlsRows.map((row) => [row.relname, row.relrowsecurity]),
  );
  for (
    const table of [
      "account_profiles",
      "game_saves",
      "ruleset_registry",
      "admin_audit_log",
    ]
  ) {
    assert(
      rlsEnabled.get(table) === true,
      `${table} must have RLS enabled in the local database`,
    );
  }

  const policyRows = await sql<{ tablename: string; policyname: string }[]>`
    select tablename, policyname
    from pg_policies
    where schemaname = 'public'
      and tablename in (
        'account_profiles',
        'game_saves',
        'ruleset_registry',
        'admin_audit_log'
      )
  `;
  const policies = new Set(
    policyRows.map((row) => `${row.tablename}:${row.policyname}`),
  );
  for (
    const expected of [
      "account_profiles:account_profiles_select_own",
      "game_saves:game_saves_select_own",
      "ruleset_registry:ruleset_registry_select_active",
    ]
  ) {
    assert(policies.has(expected), `missing RLS policy ${expected}`);
  }
  assert(
    !Array.from(policies).some((policy) =>
      policy.startsWith("admin_audit_log:")
    ),
    "admin_audit_log should have no client-readable RLS policy",
  );

  const grantRows = await sql<{
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
      and p.proname = any(${ADMIN_RPCS})
  `;
  const grants = new Map(grantRows.map((row) => [row.proname, row]));
  for (const rpc of ADMIN_RPCS) {
    const grant = grants.get(rpc);
    assert(grant !== undefined, `missing admin RPC ${rpc}`);
    assert(
      grant?.anon_execute === false,
      `${rpc} must not be executable by anon`,
    );
    assert(
      grant?.authenticated_execute === false,
      `${rpc} must not be executable by authenticated`,
    );
    assert(
      grant?.service_role_execute === true,
      `${rpc} must be executable by service_role`,
    );
  }
}

async function createTestAccount(label: string): Promise<TestAccount> {
  const auth = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { data: { provider: "guest" } },
    baseHeaders(),
    false,
  );
  const accessToken = stringField(auth, "access_token");
  const user = objectField(auth, "user");
  const authUserId = stringField(user, "id");
  assert(accessToken !== "", "anonymous auth should return access_token");
  assert(authUserId !== "", "anonymous auth should return user.id");

  const headers = {
    ...baseHeaders(),
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
  const username = stringField(player, "username");
  assert(playerId !== "", "account/guest should return player.id");
  assert(username !== "", "account/guest should return player.username");

  const [foundation] = await sql<{
    account_profile_id: string;
    game_save_id: string;
  }[]>`
    select
      ap.id::text as account_profile_id,
      gs.id::text as game_save_id
    from public.account_profiles as ap
    join public.game_saves as gs on gs.account_profile_id = ap.id
    where ap.auth_user_id = ${authUserId}::uuid
      and gs.legacy_player_id = ${playerId}::uuid
      and gs.save_type = 'normal'
      and gs.lifecycle_status = 'active'
    limit 1
  `;
  assert(
    foundation?.account_profile_id !== undefined,
    "account/guest must bootstrap account_profiles",
  );
  assert(
    foundation?.game_save_id !== undefined,
    "account/guest must bootstrap game_saves",
  );

  return {
    authUserId,
    accountProfileId: foundation.account_profile_id,
    gameSaveId: foundation.game_save_id,
    playerId,
    username,
    headers,
  };
}

async function proveOwnReadIsolation(
  primary: TestAccount,
  secondary: TestAccount,
): Promise<void> {
  const profiles = await getRestArray(
    "account_profiles?select=id,auth_user_id,username&order=created_at.asc",
    primary.headers,
  );
  assert(
    profiles.some((row) => stringField(row, "id") === primary.accountProfileId),
    "authenticated client should read its own account_profile",
  );
  assert(
    !profiles.some((row) =>
      stringField(row, "id") === secondary.accountProfileId
    ),
    "authenticated client must not read another account_profile",
  );

  const saves = await getRestArray(
    "game_saves?select=id,account_profile_id,save_type&order=created_at.asc",
    primary.headers,
  );
  assert(
    saves.some((row) => stringField(row, "id") === primary.gameSaveId),
    "authenticated client should read its own game_save",
  );
  assert(
    !saves.some((row) => stringField(row, "id") === secondary.gameSaveId),
    "authenticated client must not read another game_save",
  );
}

async function proveRulesetRegistryRls(account: TestAccount): Promise<void> {
  const draftRulesetId = `admin_rls_draft_${crypto.randomUUID()}`;
  await sql`
    insert into public.ruleset_registry (
      ruleset_id,
      ruleset_version,
      content_hash,
      simulator_hash,
      schema_version,
      active_from,
      channel,
      cohort,
      status,
      publication_payload
    )
    values (
      ${draftRulesetId},
      1,
      'admin-rls-draft-content',
      'admin-rls-draft-simulator',
      'foundation_ruleset_manifest_v1',
      now(),
      'internal_alpha',
      'admin_rls_smoke',
      'draft',
      '{}'::jsonb
    )
  `;
  try {
    const rulesets = await getRestArray(
      "ruleset_registry?select=ruleset_id,status&order=created_at.asc",
      account.headers,
    );
    assert(
      rulesets.some((row) =>
        stringField(row, "ruleset_id") === "foundation_ruleset_v0"
      ),
      "authenticated client should read active ruleset publications",
    );
    assert(
      !rulesets.some((row) =>
        stringField(row, "ruleset_id") === draftRulesetId
      ),
      "authenticated client must not read draft ruleset publications",
    );
  } finally {
    await sql`
      delete from public.ruleset_registry
      where ruleset_id = ${draftRulesetId}
    `;
  }
}

async function proveAdminAuditHiddenFromClient(
  account: TestAccount,
): Promise<void> {
  const response = await getRest(
    "admin_audit_log?select=id,action&limit=1",
    account.headers,
  );
  assert(
    response.status === 401 || response.status === 403 ||
      (response.ok && Array.isArray(response.payload) &&
        response.payload.length === 0),
    `authenticated client must not read admin_audit_log. Status: ${response.status}; payload: ${response.text}`,
  );
}

async function proveAdminRpcDeniedToClient(): Promise<void> {
  // Local PostgREST/PG17 can terminate the database process when probing a
  // revoked RPC directly, so this live smoke proves the same boundary through
  // the authoritative grant matrix instead of exercising that destructive path.
  const grantRows = await sql<{
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
      and p.proname = any(${ADMIN_RPCS})
  `;
  const grants = new Map(grantRows.map((row) => [row.proname, row]));

  for (const rpc of ADMIN_RPCS) {
    const grant = grants.get(rpc);
    assert(grant !== undefined, `missing admin RPC ${rpc}`);
    assert(
      grant.anon_execute === false,
      `${rpc} must not be executable by anon`,
    );
    assert(
      grant.authenticated_execute === false,
      `${rpc} must not be executable by authenticated`,
    );
    assert(
      grant.service_role_execute === true,
      `${rpc} must be executable by service_role`,
    );
  }
}

async function proveServiceRoleAdminOps(account: TestAccount): Promise<void> {
  const lookup = await postRpc(
    "admin_lookup_account_v1",
    {
      p_auth_user_id: account.authUserId,
      p_username: null,
      p_player_id: null,
      p_game_save_id: null,
    },
    serviceHeaders(),
  );
  const lookupAccount = objectField(lookup, "account");
  assertEq(
    stringField(lookupAccount, "account_profile_id"),
    account.accountProfileId,
    "service role lookup should find the test account",
  );

  const beforeReconciliation = await postRpc(
    "resource_reconciliation_report_v1",
    { p_game_save_id: account.gameSaveId },
    serviceHeaders(),
  );
  assertEq(
    stringField(beforeReconciliation, "schema_version"),
    "resource_reconciliation_report_v1",
    "service role reconciliation should return the v1 schema",
  );

  const adjustRequestId = crypto.randomUUID();
  const adjustBody = {
    p_game_save_id: account.gameSaveId,
    p_delta: { almas: 3, energia: 2 },
    p_reason: "foundation admin RLS live smoke resource adjustment",
    p_request_id: adjustRequestId,
  };
  const adjusted = await postRpc(
    "admin_adjust_resource_balance_v1",
    adjustBody,
    serviceHeaders(),
  );
  const adjustedAgain = await postRpc(
    "admin_adjust_resource_balance_v1",
    adjustBody,
    serviceHeaders(),
  );
  assertEq(
    stableStringify(adjusted),
    stableStringify(adjustedAgain),
    "admin resource adjustment should be idempotent by request_id",
  );
  assertEq(
    stringField(adjusted, "schema_version"),
    "admin_adjust_resource_balance_v1",
    "service role resource adjustment should return the v1 schema",
  );

  const flagRequestId = crypto.randomUUID();
  const flagBody = {
    p_account_profile_id: account.accountProfileId,
    p_status: "active",
    p_reason: "foundation admin RLS live smoke account flag probe",
    p_request_id: flagRequestId,
  };
  const flagged = await postRpc(
    "admin_flag_account_v1",
    flagBody,
    serviceHeaders(),
  );
  const flaggedAgain = await postRpc(
    "admin_flag_account_v1",
    flagBody,
    serviceHeaders(),
  );
  assertEq(
    stableStringify(flagged),
    stableStringify(flaggedAgain),
    "admin account flag should be idempotent by request_id",
  );
  assertEq(
    stringField(flagged, "schema_version"),
    "admin_flag_account_v1",
    "service role account flag should return the v1 schema",
  );

  const diagnostics = await postRpc(
    "admin_battle_diagnostics_v1",
    { p_battle_id: crypto.randomUUID() },
    serviceHeaders(),
    false,
  );
  assert(
    !diagnostics.ok && diagnostics.text.includes("BATTLE_NOT_FOUND"),
    `service role battle diagnostics should execute and report BATTLE_NOT_FOUND for a missing battle. Payload: ${diagnostics.text}`,
  );

  const auditRows = await getRestArray(
    `admin_audit_log?select=action,request_id&request_id=in.(${adjustRequestId},${flagRequestId})&order=created_at.asc`,
    serviceHeaders(),
  );
  const auditActions = auditRows.map((row) => stringField(row, "action"));
  assert(
    auditActions.includes("admin_adjust_resource_balance_v1"),
    "admin resource adjustment should write admin_audit_log",
  );
  assert(
    auditActions.includes("admin_flag_account_v1"),
    "admin account flag should write admin_audit_log",
  );
}

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
    "x-draxos-api-version": "1",
  };
}

function serviceHeaders(): Record<string, string> {
  return {
    apikey: SERVICE_ROLE_KEY,
    authorization: `Bearer ${SERVICE_ROLE_KEY}`,
    "content-type": "application/json",
    "x-draxos-api-version": "1",
  };
}

async function postRpc(
  rpcName: string,
  body: JsonObject,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject & { ok: boolean; status: number; text: string }> {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/rpc/${rpcName}`, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });
  const text = await response.text();
  let payload: unknown = {};
  if (text.trim() !== "") {
    try {
      payload = JSON.parse(text);
    } catch {
      payload = { raw: text };
    }
  }
  if (requireOk) {
    assert(
      response.ok,
      `POST /rest/v1/rpc/${rpcName} failed with ${response.status}: ${text}`,
    );
  }
  const objectPayload = isRecord(payload) ? payload : { value: payload };
  return {
    ...objectPayload,
    ok: response.ok,
    status: response.status,
    text,
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
  const text = await response.text();
  let payload: unknown = {};
  if (text.trim() !== "") {
    payload = JSON.parse(text) as unknown;
  }
  if (requireOk) {
    assert(response.ok, `POST ${url} failed with ${response.status}: ${text}`);
  }
  return objectField({ payload }, "payload");
}

async function getRestArray(
  path: string,
  headers: Record<string, string>,
): Promise<JsonObject[]> {
  const response = await getRest(path, headers);
  assert(
    response.ok,
    `GET /rest/v1/${path} failed with ${response.status}: ${response.text}`,
  );
  assert(
    Array.isArray(response.payload),
    `GET /rest/v1/${path} must return array`,
  );
  return response.payload.filter(isRecord);
}

async function getRest(
  path: string,
  headers: Record<string, string>,
): Promise<{
  ok: boolean;
  status: number;
  text: string;
  payload: unknown;
}> {
  const response = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    method: "GET",
    headers,
  });
  const text = await response.text();
  let payload: unknown = {};
  if (text.trim() !== "") {
    try {
      payload = JSON.parse(text) as unknown;
    } catch {
      payload = { raw: text };
    }
  }
  return { ok: response.ok, status: response.status, text, payload };
}

function objectField(value: unknown, field: string): JsonObject {
  assert(isRecord(value), `expected object before reading ${field}`);
  const fieldValue = value[field];
  assert(isRecord(fieldValue), `expected ${field} to be object`);
  return fieldValue;
}

function stringField(value: unknown, field: string): string {
  assert(isRecord(value), `expected object before reading ${field}`);
  const fieldValue = value[field];
  assert(
    typeof fieldValue === "string",
    `expected ${field} to be string, got ${typeof fieldValue}`,
  );
  return fieldValue;
}

function isRecord(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function stableStringify(value: unknown): string {
  if (value === null || typeof value !== "object") {
    return JSON.stringify(value);
  }
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  const record = value as JsonObject;
  return `{${
    Object.keys(record).sort().map((key) =>
      `${JSON.stringify(key)}:${stableStringify(record[key])}`
    ).join(",")
  }}`;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Expected ${expected}, got ${actual}`);
  }
}
