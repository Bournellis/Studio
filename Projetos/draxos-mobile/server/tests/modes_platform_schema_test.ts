const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH = "supabase/migrations/202605310001_minigame_platform_v0.sql";
const SERVER_MIRROR_PATH = "server/schema/migrations/202605310001_minigame_platform_v0.sql";
const EDGE_PATH = "server/functions/minigames/index.ts";
const SUPABASE_EDGE_PATH = "supabase/functions/minigames/index.ts";

Deno.test("minigame platform migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("minigame platform declares registry, sessions, progress and reward claims", async () => {
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

  assertIncludes(migration, "'rpgsuave'", "registry should seed rpgsuave");
  assertIncludes(
    migration,
    "'rpgsuave_forest_ruleset_v0'",
    "ruleset registry should seed the forest ruleset",
  );
  assertIncludes(
    migration,
    "open_minigame_shell:rpgsuave",
    "registry metadata should point to the dev shell action",
  );
});

Deno.test("minigame reward bridge is service-role, idempotent and ledgers resources", async () => {
  const migration = await migrationText();

  for (const functionName of ["minigame_session_start_v1", "minigame_session_complete_v1"]) {
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

  for (const endpoint of ["minigames/session/start", "minigames/session/complete"]) {
    assertIncludes(migration, endpoint, `${endpoint} should reserve idempotency`);
  }
  assertIncludes(
    migration,
    "insert into public.resource_transactions",
    "reward completion should write the economy ledger",
  );
  assertIncludes(
    migration,
    "minigame_reward_blocked_for_lab",
    "progression lab saves should not receive Base/Account rewards",
  );
  assertIncludes(
    migration,
    "minigame_result_rejected",
    "tampered or implausible results should be rejected",
  );
});

Deno.test("minigame edge function mirror exposes all v0 routes", async () => {
  const edge = await readProjectText(EDGE_PATH);
  const supabaseEdge = await readProjectText(SUPABASE_EDGE_PATH);

  assertEq(
    normalizeNewlines(edge),
    normalizeNewlines(supabaseEdge),
    "server and supabase minigame functions should match exactly",
  );
  for (
    const route of [
      "/registry",
      "/state",
      "/session/start",
      "/session/complete",
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
