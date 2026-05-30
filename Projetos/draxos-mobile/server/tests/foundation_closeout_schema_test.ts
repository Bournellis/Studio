const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH = "supabase/migrations/202605300004_foundation_closeout.sql";
const SERVER_MIRROR_PATH = "server/schema/migrations/202605300004_foundation_closeout.sql";
const RULESET_PATH = "data/rulesets/foundation_ruleset_v0.json";

Deno.test("foundation closeout migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("foundation closeout makes ruleset registry publication immutable", async () => {
  const migration = await migrationText();

  assertIncludes(
    migration,
    "add column if not exists publication_id uuid default gen_random_uuid()",
    "ruleset registry should gain publication_id",
  );
  assertIncludes(
    migration,
    "drop constraint ruleset_registry_pkey",
    "legacy ruleset_id primary key should be removed",
  );
  assertIncludes(
    migration,
    "ruleset_registry_publication_pkey primary key (publication_id)",
    "publication_id should become the publication identity",
  );
  assertIncludes(
    migration,
    "create unique index if not exists ruleset_registry_publication_identity_idx",
    "publication identity should be unique by ruleset/version/channel/cohort",
  );
  assertIncludes(
    migration,
    "create unique index if not exists ruleset_registry_active_publication_idx",
    "active publication uniqueness should be enforced",
  );
  assertIncludes(
    migration,
    "where status = 'active'",
    "active publication uniqueness should be partial",
  );
});

Deno.test("foundation closeout seed hashes match generated foundation ruleset", async () => {
  const migration = await migrationText();
  const ruleset = JSON.parse(await readProjectText(RULESET_PATH)) as {
    content_hash: string;
    simulator_hash: string;
    schema_version: string;
  };

  assertIncludes(
    migration,
    `content_hash = '${ruleset.content_hash}'`,
    "active registry seed should carry the generated content hash",
  );
  assertIncludes(
    migration,
    `simulator_hash = '${ruleset.simulator_hash}'`,
    "active registry seed should carry the generated simulator hash",
  );
  assertIncludes(
    migration,
    `schema_version = '${ruleset.schema_version}'`,
    "active registry seed should carry the generated schema version",
  );
});

Deno.test("foundation closeout persists account save and history ruleset context", async () => {
  const migration = await migrationText();

  for (
    const tableName of [
      "game_saves",
      "battles",
      "construction_jobs",
      "reward_claims",
      "alpha_purchases",
    ]
  ) {
    for (
      const columnName of [
        "ruleset_publication_id",
        "ruleset_content_hash",
        "ruleset_simulator_hash",
        "ruleset_schema_version",
      ]
    ) {
      assertRegex(
        migration,
        new RegExp(
          `alter table public\\.${tableName}[\\s\\S]*?add column if not exists ${columnName}\\b`,
        ),
        `${tableName} should include ${columnName}`,
      );
    }
  }

  assertIncludes(
    migration,
    "add column if not exists state_version integer not null default 1",
    "game_saves should expose state_version",
  );
  assertIncludes(
    migration,
    'add column if not exists season_context jsonb not null default \'{"season_id":"alpha_0","channel":"internal_alpha"}\'::jsonb',
    "game_saves should expose season_context",
  );
  assertIncludes(
    migration,
    "create trigger game_saves_ruleset_context_v1",
    "game_saves should be normalized by ruleset trigger",
  );
  assertIncludes(
    migration,
    "create trigger battles_ruleset_context_v1",
    "battle rows should persist ruleset publication context",
  );
});

Deno.test("foundation closeout admin RPCs are service-role only", async () => {
  const migration = await migrationText();
  const adminFunctions = [
    "resource_reconciliation_report_v1",
    "admin_adjust_resource_balance_v1",
    "admin_lookup_account_v1",
    "admin_battle_diagnostics_v1",
    "admin_flag_account_v1",
  ];

  for (const functionName of adminFunctions) {
    assertIncludes(
      migration,
      `create or replace function public.${functionName}`,
      `migration should declare ${functionName}`,
    );
    assertRegex(
      migration,
      new RegExp(
        `revoke all on function public\\.${functionName}\\([^;]+\\) from public;`,
        "s",
      ),
      `${functionName} should be revoked from public`,
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

  assertNotRegex(
    migration,
    /grant execute on function public\.admin_[^;]+ to (anon|authenticated);/s,
    "admin functions must not be granted to player roles",
  );
});

Deno.test("foundation closeout promotes remaining build and social mutations", async () => {
  const migration = await migrationText();
  const serviceRoleFunctions = [
    "apply_build_preparation_mutation_v1",
    "build_spell_behavior_v1",
    "build_potion_equip_v1",
    "build_potion_behavior_v1",
    "apply_social_mutation_v1",
    "social_friend_add_v1",
    "social_chat_send_v1",
  ];

  for (const functionName of serviceRoleFunctions) {
    assertIncludes(
      migration,
      `create or replace function public.${functionName}`,
      `migration should declare ${functionName}`,
    );
    assertRegex(
      migration,
      new RegExp(
        `revoke all on function public\\.${functionName}\\([^;]+\\) from public;`,
        "s",
      ),
      `${functionName} should be revoked from public`,
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

  for (
    const endpoint of [
      "build/spell-behavior",
      "build/potion/equip",
      "build/potion-behavior",
      "social/friends/add",
      "social/chat/send",
    ]
  ) {
    assertIncludes(
      migration,
      endpoint,
      `${endpoint} should be reserved by the v1 idempotency layer`,
    );
  }

  assertNotRegex(
    migration,
    /grant execute on function public\.(build_|social_|apply_build|apply_social)[^;]+ to (anon|authenticated);/s,
    "remaining v1 mutation RPCs must not be granted to player roles",
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

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
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

function assertNotRegex(
  haystack: string,
  pattern: RegExp,
  message: string,
): void {
  if (pattern.test(haystack)) {
    throw new Error(`${message}. Pattern matched: ${pattern}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
