const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH =
  "supabase/migrations/202605300001_foundation_expansion_readiness.sql";
const SERVER_MIRROR_PATH =
  "server/schema/migrations/202605300001_foundation_expansion_readiness.sql";

Deno.test("foundation expansion migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("foundation expansion declares account save ruleset and audit tables", async () => {
  const migration = await migrationText();

  for (
    const tableName of [
      "account_profiles",
      "game_saves",
      "ruleset_registry",
      "admin_audit_log",
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

  assertIncludes(
    migration,
    "auth_user_id uuid not null unique references auth.users(id)",
    "account_profiles should bind one profile to one Supabase auth user",
  );
  assertIncludes(
    migration,
    "legacy_player_id uuid unique references public.players(id)",
    "game_saves should map back to the legacy player/save row",
  );
  assertIncludes(
    migration,
    "ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id)",
    "game_saves should carry the active ruleset",
  );
  assertIncludes(
    migration,
    "content_hash text not null",
    "ruleset registry should store the authored content hash",
  );
  assertIncludes(
    migration,
    "simulator_hash text not null",
    "ruleset registry should store the simulator hash",
  );
  for (const registryField of ["active_from", "channel", "cohort", "status"]) {
    assertRegex(
      migration,
      new RegExp(`\\b${registryField}\\b`),
      `ruleset registry should include ${registryField}`,
    );
  }
  assertIncludes(
    migration,
    "'foundation_ruleset_v0'",
    "migration should seed the generated foundation ruleset id",
  );
  assertIncludes(
    migration,
    "insert into public.ruleset_registry",
    "migration should seed the default foundation ruleset",
  );
});

Deno.test("foundation expansion extends idempotency lifecycle fields", async () => {
  const migration = await migrationText();

  assertIncludes(
    migration,
    "alter table public.idempotency_keys",
    "migration should alter idempotency_keys",
  );

  for (
    const columnName of [
      "request_hash",
      "scope_id",
      "status",
      "completed_at",
      "failed_at",
    ]
  ) {
    assertRegex(
      migration,
      new RegExp(`add column if not exists ${columnName}\\b`),
      `idempotency_keys should add ${columnName}`,
    );
  }

  assertIncludes(
    migration,
    "check (status in ('pending', 'completed', 'failed'))",
    "idempotency status should be lifecycle constrained",
  );
  assertIncludes(
    migration,
    "create trigger idempotency_keys_scope_defaults",
    "legacy inserts should receive scope/status defaults",
  );
});

Deno.test("foundation expansion adds ruleset columns to authoritative history tables", async () => {
  const migration = await migrationText();

  for (
    const tableName of [
      "battles",
      "construction_jobs",
      "reward_claims",
      "alpha_purchases",
    ]
  ) {
    const alterBlock = extractAlterTableBlock(migration, tableName);
    assertIncludes(
      alterBlock,
      "add column if not exists ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id)",
      `${tableName} should include ruleset_id`,
    );
    assertIncludes(
      alterBlock,
      "add column if not exists ruleset_version integer not null default 1",
      `${tableName} should include ruleset_version`,
    );
  }
});

Deno.test("foundation expansion declares RPC scaffolds with service-role grants", async () => {
  const migration = await migrationText();

  const functions = [
    "ensure_foundation_profile_and_saves",
    "reserve_idempotency",
    "complete_idempotency",
    "fail_idempotency",
    "reconcile_resource_balance",
    "foundation_command_v1",
    "request_battle_v1",
    "collect_base_v1",
    "start_base_upgrade_v1",
    "equip_build_v1",
    "craft_item_v1",
    "claim_reward_v1",
    "alpha_purchase_v1",
    "guild_create_v1",
    "guild_join_v1",
  ];

  for (const functionName of functions) {
    assertIncludes(
      migration,
      `create or replace function public.${functionName}`,
      `migration should declare RPC ${functionName}`,
    );
    assertRegex(
      migration,
      new RegExp(
        `grant execute on function public\\.${functionName}\\([^;]+\\) to service_role;`,
        "s",
      ),
      `${functionName} should grant execute only through the service role path`,
    );
  }

  assertIncludes(
    migration,
    "insert into public.admin_audit_log",
    "resource reconciliation should write admin audit entries",
  );
  assertIncludes(
    migration,
    "insert into public.resource_transactions",
    "resource reconciliation should preserve economy ledger entries",
  );
  assertIncludes(
    migration,
    "reserved_for_domain_service",
    "foundation command RPCs should reserve idempotent domain-service mutations",
  );
  assertIncludes(
    migration,
    "p_game_save_id uuid",
    "mutation RPCs should use game_saves rather than players.save_type as the public save scope",
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

function extractAlterTableBlock(migration: string, tableName: string): string {
  const pattern = new RegExp(
    `alter table public\\.${tableName}\\s+([\\s\\S]*?);`,
  );
  const match = migration.match(pattern);
  assert(match !== null, `missing alter table block for ${tableName}`);
  return match[0];
}

function normalizeSql(value: string): string {
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

function assertRegex(
  haystack: string,
  pattern: RegExp,
  message: string,
): void {
  if (!pattern.test(haystack)) {
    throw new Error(`${message}. Pattern: ${pattern}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(message);
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}
