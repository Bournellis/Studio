const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH = "supabase/migrations/202606010001_modes_platform_v1.sql";
const SERVER_MIRROR_PATH = "server/schema/migrations/202606010001_modes_platform_v1.sql";
const EDGE_PATH = "server/functions/modes/index.ts";
const SUPABASE_EDGE_PATH = "supabase/functions/modes/index.ts";

Deno.test("mode platform migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
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

  for (const functionName of ["mode_session_start_v1", "mode_session_complete_v1"]) {
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
    assertIncludes(migration, endpoint, `${endpoint} should reserve idempotency`);
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

  assertEq(
    normalizeNewlines(edge),
    normalizeNewlines(supabaseEdge),
    "server and supabase mode functions should match exactly",
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
    assertIncludes(edge.toLowerCase(), route, `edge function should include ${route}`);
  }
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

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle.toLowerCase())) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
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
