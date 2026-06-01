const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH = "supabase/migrations/202606010001_modes_platform_v1.sql";
const SERVER_MIRROR_PATH =
  "server/schema/migrations/202606010001_modes_platform_v1.sql";
const ADMIN_MIGRATION_PATH =
  "supabase/migrations/202606010002_modes_admin_audit_hardening.sql";
const ADMIN_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606010002_modes_admin_audit_hardening.sql";
const EDGE_PATH = "server/functions/modes/index.ts";
const SUPABASE_EDGE_PATH = "supabase/functions/modes/index.ts";
const HANDLER_PATH = "server/functions/modes/mode_handler.ts";
const SUPABASE_HANDLER_PATH = "supabase/functions/modes/mode_handler.ts";

Deno.test("mode platform migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("mode admin audit hardening migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(ADMIN_MIGRATION_PATH);
  const serverMirror = await readProjectText(ADMIN_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema admin hardening migration should mirror supabase migration exactly",
  );
});

Deno.test("mode platform declares registry, sessions, progress and reward claims", async () => {
  const migration = await migrationText();

  for (
    const tableName of [
      "mode_registry",
      "mode_ruleset_registry",
      "mode_progress",
      "mode_sessions",
      "mode_reward_claims",
    ]
  ) {
    assertIncludes(
      migration,
      `create table if not exists public.${tableName}`,
      `migration should create ${tableName}`,
    );
    assertIncludes(
      migration,
      `alter table public.${tableName} enable row level security`,
      `${tableName} should enable RLS`,
    );
  }

  assertIncludes(migration, "'openworld'", "registry should seed openworld");
  for (
    const modeId of [
      "'basebuilder'",
      "'autobattler'",
      "'towerdefense'",
      "'cardgame'",
      "'openworld'",
    ]
  ) {
    assertIncludes(migration, modeId, `registry should seed ${modeId}`);
  }
  assertIncludes(
    migration,
    "'openworld_forest_ruleset_v0'",
    "ruleset registry should seed the forest ruleset",
  );
  assertIncludes(
    migration,
    "open_mode_shell:openworld",
    "registry metadata should point to the mode shell action",
  );
  assertIncludes(
    migration,
    "create table if not exists public.mode_limit_policies",
    "migration should declare mode limit policies",
  );
  assertIncludes(
    migration,
    "create table if not exists public.admin_roles",
    "migration should declare admin roles for mode ops",
  );
});

Deno.test("mode reward bridge is service-role, idempotent and ledgers resources", async () => {
  const migration = await migrationText();

  for (
    const functionName of ["mode_session_start_v1", "mode_session_complete_v1"]
  ) {
    assertIncludes(
      migration,
      `create or replace function public.${functionName}`,
      `migration should declare ${functionName}`,
    );
    assertRegex(
      migration,
      new RegExp(
        `revoke all on function public\\.${functionName}\\([^;]+\\) from public, anon, authenticated;`,
        "s",
      ),
      `${functionName} should be revoked from public roles`,
    );
    assertRegex(
      migration,
      new RegExp(
        `grant execute on function public\\.${functionName}\\([^;]+\\) to service_role;`,
        "s",
      ),
      `${functionName} should be granted to service_role only`,
    );
  }

  for (const endpoint of ["modes/session/start", "modes/session/complete"]) {
    assertIncludes(
      migration,
      endpoint,
      `${endpoint} should reserve idempotency`,
    );
  }
  assertIncludes(
    migration,
    "insert into public.resource_transactions",
    "reward completion should write the economy ledger",
  );
  assertIncludes(
    migration,
    "mode_reward_blocked_for_lab",
    "progression lab saves should not receive Base/Account rewards",
  );
  assertIncludes(
    migration,
    "mode_result_rejected",
    "tampered or implausible results should be rejected",
  );
});

Deno.test("mode edge function mirror exposes all v1 routes", async () => {
  const edge = await readProjectText(EDGE_PATH);
  const supabaseEdge = await readProjectText(SUPABASE_EDGE_PATH);
  const handler = await readProjectText(HANDLER_PATH);
  const supabaseHandler = await readProjectText(SUPABASE_HANDLER_PATH);

  assertEq(
    normalizeNewlines(edge),
    normalizeNewlines(supabaseEdge),
    "server and supabase mode entrypoints should match exactly",
  );
  assertEq(
    normalizeNewlines(handler),
    normalizeNewlines(supabaseHandler),
    "server and supabase mode handlers should match exactly",
  );
  assertIncludes(
    edge,
    "mode_handler.ts",
    "edge entrypoint should delegate to ModeHandler",
  );
  assertIncludes(
    handler.toLowerCase(),
    "export class ModeHandler",
    "mode handler should be internally modularized",
  );
  for (
    const route of [
      "/registry",
      "/state",
      "/session/start",
      "/session/complete",
      "/session/abandon",
      "/analytics/summary",
      "/admin/disable",
      "/admin/enable",
      "/admin/session/expire",
      "/admin/session/invalidate",
      "/admin/reconcile",
      "/admin/compensate",
      "saveTypeFromRequest",
      "validateApiVersion",
      "request_hash",
    ]
  ) {
    assertIncludes(
      handler.toLowerCase(),
      route,
      `mode handler should include ${route}`,
    );
  }
});

Deno.test("mode admin RPCs are audited, service-role only and hash guarded", async () => {
  const migration = normalizeSql(await readProjectText(ADMIN_MIGRATION_PATH));
  const handler = normalizeCode(await readProjectText(HANDLER_PATH));
  const adminFunctions = [
    "admin_set_mode_status_v1",
    "admin_expire_mode_session_v1",
    "admin_invalidate_mode_session_v1",
  ];

  for (const functionName of adminFunctions) {
    assertIncludes(
      migration,
      `create or replace function public.${functionName}`,
      `migration should declare ${functionName}`,
    );
    assertIncludes(
      migration,
      `where action = '${functionName}'`,
      `${functionName} should dedupe by admin audit action/request_id`,
    );
    assertIncludes(
      migration,
      "metadata->>'request_hash'",
      `${functionName} should compare request hashes on retries`,
    );
    assertIncludes(
      migration,
      "'idempotency_hash_mismatch'",
      `${functionName} should reject reused request_id with a different hash`,
    );
    assertRegex(
      migration,
      new RegExp(
        `revoke all on function public\\.${functionName}\\([^;]+\\) from public, anon, authenticated;`,
        "s",
      ),
      `${functionName} should be revoked from public roles`,
    );
    assertRegex(
      migration,
      new RegExp(
        `grant execute on function public\\.${functionName}\\([^;]+\\) to service_role;`,
        "s",
      ),
      `${functionName} should be granted to service_role only`,
    );
    assertIncludes(
      handler,
      `rpc/${functionName}`,
      `/modes/admin/* should call audited RPC ${functionName}`,
    );
  }

  const adminMutationSection = codeSection(
    handler,
    "async function handleAdminModeStatus",
    "async function handleAdminReconcile",
  );
  assertNotIncludes(
    adminMutationSection,
    'method: "patch"',
    "admin mode/session handlers should not PATCH mode tables directly",
  );
});

async function migrationText(): Promise<string> {
  return normalizeSql(await readProjectText(MIGRATION_PATH));
}

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(projectFile(relativePath));
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `${PROJECT_PREFIX}/${relativePath}`;
}

function normalizeSql(value: string): string {
  return normalizeNewlines(value).toLowerCase();
}

function normalizeCode(value: string): string {
  return normalizeNewlines(value).toLowerCase();
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (!haystack.includes(needle.toLowerCase())) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assertNotIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (haystack.includes(needle.toLowerCase())) {
    throw new Error(`${message}. Unexpected: ${needle}`);
  }
}

function codeSection(haystack: string, start: string, end: string): string {
  const startIndex = haystack.indexOf(start.toLowerCase());
  const endIndex = haystack.indexOf(end.toLowerCase());
  if (startIndex < 0 || endIndex <= startIndex) {
    throw new Error(`missing code section ${start} -> ${end}`);
  }
  return haystack.slice(startIndex, endIndex);
}

function assertRegex(haystack: string, pattern: RegExp, message: string): void {
  if (!pattern.test(haystack)) {
    throw new Error(`${message}. Pattern: ${pattern}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(message);
  }
}
