const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH =
  "supabase/migrations/202605300002_transactional_domain_enforcement.sql";
const SERVER_MIRROR_PATH =
  "server/schema/migrations/202605300002_transactional_domain_enforcement.sql";
const SERVER_BASE_FUNCTION_PATH = "server/functions/base/index.ts";
const SUPABASE_BASE_FUNCTION_PATH = "supabase/functions/base/index.ts";

Deno.test("transactional domain enforcement migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("base collect v1 is an atomic save-scoped economy mutation", async () => {
  const migration = await migrationText();
  const collectRpc = functionBlock(migration, "collect_base_v1");

  for (
    const required of [
      "p_game_save_id uuid",
      "p_request_id uuid",
      "p_request_hash text",
      "from public.game_saves",
      "for update",
      "from public.ruleset_registry",
      "public.reserve_idempotency",
      "'base/collect'",
      "public.complete_due_base_jobs_v1",
      "update public.resources",
      "insert into public.resource_transactions",
      "update public.base_structures",
      "collectable.amount > 0",
      "public.complete_idempotency",
      "'foundation_base_collect_response_v1'",
      "'game_save_id'",
      "'ruleset_id'",
      "'ruleset_version'",
      "'content_hash'",
      "'simulator_hash'",
    ]
  ) {
    assertIncludes(
      collectRpc,
      required,
      `collect_base_v1 should include ${required}`,
    );
  }

  assertNotIncludes(
    collectRpc,
    "foundation_command_v1",
    "collect_base_v1 should not delegate to the reserved scaffold",
  );
  assertNotIncludes(
    collectRpc,
    "reserved_for_domain_service",
    "collect_base_v1 should be a real domain mutation",
  );
});

Deno.test("base upgrade v1 is an atomic save-scoped economy mutation", async () => {
  const migration = await migrationText();
  const upgradeRpc = functionBlock(migration, "start_base_upgrade_v1");

  for (
    const required of [
      "p_game_save_id uuid",
      "p_request_id uuid",
      "p_request_hash text",
      "p_request_payload jsonb",
      "requested_structure_id",
      "from public.game_saves",
      "for update",
      "from public.ruleset_registry",
      "public.reserve_idempotency",
      "'base/upgrade'",
      "public.complete_due_base_jobs_v1",
      "alpha_double_construction_queue",
      "update public.resources",
      "insert into public.construction_jobs",
      "insert into public.resource_transactions",
      "public.complete_idempotency",
      "'foundation_base_upgrade_response_v1'",
      "'game_save_id'",
      "'ruleset_id'",
      "'ruleset_version'",
      "'content_hash'",
      "'simulator_hash'",
      "construction_queue_full",
      "insufficient_resources",
      "level_cap_reached",
    ]
  ) {
    assertIncludes(
      upgradeRpc,
      required,
      `start_base_upgrade_v1 should include ${required}`,
    );
  }

  assertNotIncludes(
    upgradeRpc,
    "foundation_command_v1",
    "start_base_upgrade_v1 should not delegate to the reserved scaffold",
  );
  assertNotIncludes(
    upgradeRpc,
    "reserved_for_domain_service",
    "start_base_upgrade_v1 should be a real domain mutation",
  );
  assertNotIncludes(
    upgradeRpc,
    "'base/start_upgrade'",
    "start_base_upgrade_v1 should preserve the existing /base/upgrade idempotency endpoint",
  );
});

Deno.test("base edge adapter calls transactional RPCs instead of direct multi-step writes", async () => {
  const serverBase = await readProjectText(SERVER_BASE_FUNCTION_PATH);
  const supabaseBase = await readProjectText(SUPABASE_BASE_FUNCTION_PATH);

  assertEq(
    normalizeNewlines(serverBase),
    normalizeNewlines(supabaseBase),
    "server and supabase base edge adapters should match exactly",
  );

  const baseFunction = normalizeCode(serverBase);
  for (
    const required of [
      "rpc/complete_due_base_jobs_v1",
      "rpc/collect_base_v1",
      "rpc/start_base_upgrade_v1",
      "rpc/ensure_foundation_profile_and_saves",
      "mutationrequesthash",
      "request_hash",
      "gamesave.id",
    ]
  ) {
    assertIncludes(
      baseFunction,
      required,
      `base adapter should include ${required}`,
    );
  }

  for (
    const forbidden of [
      "idempotency_keys",
      "resource_transactions",
      "construction_jobs?select=*",
      'method: "PATCH"',
      'headers: { prefer: "return=representation" }',
    ]
  ) {
    assertNotIncludes(
      baseFunction,
      forbidden,
      `base adapter should not perform direct mutation write ${forbidden}`,
    );
  }
});

Deno.test("transactional base RPCs are service-role only", async () => {
  const migration = await migrationText();

  for (
    const signature of [
      "public.complete_due_base_jobs_v1(uuid, timestamptz)",
      "public.collect_base_v1(uuid, uuid, text, jsonb)",
      "public.start_base_upgrade_v1(uuid, uuid, text, jsonb)",
    ]
  ) {
    assertIncludes(
      migration,
      `revoke all on function ${signature} from public;`,
      `${signature} should revoke public execute`,
    );
    assertIncludes(
      migration,
      `grant execute on function ${signature} to service_role;`,
      `${signature} should grant execute to service_role`,
    );
    assertNotRegex(
      migration,
      new RegExp(
        `grant execute on function ${
          escapeRegex(signature)
        } to (anon|authenticated);`,
      ),
      `${signature} should not be executable by anon/authenticated roles`,
    );
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

function functionBlock(migration: string, functionName: string): string {
  const pattern = new RegExp(
    `create or replace function public\\.${functionName}\\([\\s\\S]*?\\n\\$\\$;`,
  );
  const match = migration.match(pattern);
  assert(match !== null, `missing function block for ${functionName}`);
  return match[0];
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

function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
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

function assertNotRegex(
  haystack: string,
  pattern: RegExp,
  message: string,
): void {
  if (pattern.test(haystack)) {
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
