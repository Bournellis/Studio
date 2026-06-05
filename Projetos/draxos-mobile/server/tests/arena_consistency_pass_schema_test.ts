const MIGRATION_PATH =
  "supabase/migrations/202605310003_s1_arena_calibration_runtime.sql";
const SERVER_MIRROR_PATH =
  "server/schema/migrations/202605310003_s1_arena_calibration_runtime.sql";
const INITIAL_ARENA_MIGRATION_PATH =
  "supabase/migrations/202605310001_arena_pve_initial.sql";
const INITIAL_ARENA_SERVER_MIRROR_PATH =
  "server/schema/migrations/202605310001_arena_pve_initial.sql";
const SERVER_ARENA_FUNCTION = "server/functions/arena/index.ts";
const SUPABASE_ARENA_FUNCTION = "supabase/functions/arena/index.ts";
const SERVER_ARENA_TYPES = "server/functions/arena/arena_types.ts";
const SUPABASE_ARENA_TYPES = "supabase/functions/arena/arena_types.ts";

Deno.test("arena consistency migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("arena initial migration keeps deploy-safe ruleset publication context", async () => {
  const supabaseMigration = await readProjectText(INITIAL_ARENA_MIGRATION_PATH);
  const serverMirror = await readProjectText(INITIAL_ARENA_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema initial arena migration should mirror supabase migration exactly",
  );
  assertIncludes(
    supabaseMigration,
    "ruleset_id text not null default 'foundation_ruleset_v0'",
    "arena attempts should keep legacy ruleset_id as a textual snapshot",
  );
  assertNotIncludes(
    supabaseMigration,
    "ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id)",
    "arena attempts should not reference the retired ruleset_id registry identity",
  );
  assertIncludes(
    supabaseMigration,
    "ruleset_publication_id uuid references public.ruleset_registry(publication_id)",
    "arena attempts should reference the immutable ruleset publication identity",
  );
});

Deno.test("arena edge function is mirrored between server and supabase", async () => {
  const serverFunction = await readProjectText(SERVER_ARENA_FUNCTION);
  const supabaseFunction = await readProjectText(SUPABASE_ARENA_FUNCTION);
  const serverTypes = await readProjectText(SERVER_ARENA_TYPES);
  const supabaseTypes = await readProjectText(SUPABASE_ARENA_TYPES);

  assertEq(
    normalizeNewlines(serverFunction),
    normalizeNewlines(supabaseFunction),
    "server and supabase arena functions should stay mirrored",
  );
  assertEq(
    normalizeNewlines(serverTypes),
    normalizeNewlines(supabaseTypes),
    "server and supabase arena type modules should stay mirrored",
  );
  assertIncludes(
    serverFunction,
    'from "./arena_types.ts";',
    "arena function should keep extracted types in the mirrored type module",
  );
  assertIncludes(
    serverTypes,
    "export interface ArenaAttemptRow",
    "arena type module should own Arena row contracts",
  );
});

Deno.test("arena duel RPC consumes live player potions idempotently", async () => {
  const migration = await readProjectText(MIGRATION_PATH);
  const duelRpc = functionBlock(migration, "arena_record_duel_v1");

  for (
    const required of [
      "consumables_used",
      "'arena/duel/request'",
      "from public.player_consumables",
      "for update",
      "current_quantity < consumable_quantity",
      "ARENA_CONSUMABLE_STOCK_CHANGED",
      "update public.player_consumables",
      "quantity = current_quantity - consumable_quantity",
      "insert into public.item_transactions",
      "'arena_pve_v1'",
      "completed_tier_key := attempt_row.arena_id || ':' || attempt_row.difficulty_id",
      "insert into public.arena_first_clears",
      "array['completed_tiers', completed_tier_key]",
      "array['completed_arenas', attempt_row.arena_id]",
      "public.complete_idempotency",
    ]
  ) {
    assertIncludes(duelRpc, required, `duel RPC should include ${required}`);
  }
});

Deno.test("arena runtime records first clears by arena difficulty tier", async () => {
  const migration = await readProjectText(MIGRATION_PATH);

  for (
    const required of [
      "create table if not exists public.arena_first_clears",
      "primary key (game_save_id, arena_id, difficulty_id)",
      "alter table public.arena_first_clears enable row level security",
      "completed_tier_key := attempt_row.arena_id || ':' || attempt_row.difficulty_id",
      "insert into public.arena_first_clears",
      "array['completed_tiers', completed_tier_key]",
      "array['completed_arenas', attempt_row.arena_id]",
      "'first_clear_inserted', first_clear_inserted",
    ]
  ) {
    assertIncludes(migration, required, `runtime migration should include ${required}`);
  }
});

Deno.test("arena runtime uses generated Season 1 catalog and tier difficulty ids", async () => {
  const edgeFunction = await readProjectText(SERVER_ARENA_FUNCTION);

  for (
    const required of [
      "../_shared/pve_arena_catalog.ts",
      "arenaDefinitions()",
      "arenaTierById",
      "arenaRewardProfile",
      "pveEnemyDefinition",
      "arenaTierUnlockState",
      "difficulty_id: tier.difficulty_id",
      "reward_profile_id",
      "duel_power_target",
      'mode: "PVE_ARENA_V1"',
    ]
  ) {
    assertIncludes(edgeFunction, required, `arena edge function should include ${required}`);
  }

  for (
    const obsolete of [
      "const ARENA_DEFINITIONS",
      "const BUFF_POOL",
      "const PVE_ENEMY_SOURCE_BOTS",
      "const ARENA_REWARD_PROFILES",
    ]
  ) {
    assertNotIncludes(edgeFunction, obsolete, `arena edge function should not keep ${obsolete}`);
  }

  const arenaMetadataBlock = objectLiteralBlock(edgeFunction, "metadata");
  for (
    const required of [
      'mode: "PVE_ARENA_V1"',
      "duel_index: nextStep",
      "duel_count: attempt.value.max_steps",
    ]
  ) {
    assertIncludes(
      arenaMetadataBlock,
      required,
      `arena battle log metadata should include ${required}`,
    );
  }
});

Deno.test("arena claim remains read-only ack and buff public endpoint is normalized", async () => {
  const edgeFunction = await readProjectText(SERVER_ARENA_FUNCTION);
  const migration = await readProjectText(MIGRATION_PATH);
  const buffRpc = functionBlock(migration, "arena_choose_buff_v1");

  for (
    const required of [
      'mutationRequestHash("arena/pve/claim"',
      'endpoint: "arena/pve/claim"',
      "mutates_economy: false",
      "ARENA_PVE_DOES_NOT_RANK",
      'mutationRequestHash("arena/pve/buff/select"',
      'pathname.endsWith("/buff/choose")',
      'pathname.endsWith("/pve/buff/select")',
    ]
  ) {
    assertIncludes(edgeFunction, required, `arena edge function should include ${required}`);
  }

  assertIncludes(
    buffRpc,
    "'arena/pve/buff/select'",
    "buff RPC should reserve idempotency under the public endpoint name",
  );
  assertNotIncludes(
    buffRpc,
    "'arena/buff/choose'",
    "buff RPC should not expose the old endpoint as a new idempotency source",
  );

  const claimHandler = functionBlock(edgeFunction, "handleClaim");
  for (
    const forbidden of [
      "rpc/",
      "reserve_idempotency",
      "complete_idempotency",
      "idempotency_keys",
      "p_request_hash",
    ]
  ) {
    assertNotIncludes(
      claimHandler,
      forbidden,
      `claim handler must remain read-only and avoid ${forbidden}`,
    );
  }
});

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(new URL(`../../${relativePath}`, import.meta.url));
}

function functionBlock(source: string, functionName: string): string {
  const start = source.indexOf(`function public.${functionName}`);
  if (start < 0) {
    return tsFunctionBlock(source, functionName);
  }
  const next = source.indexOf("\ncreate or replace function public.", start + 1);
  return source.slice(start, next < 0 ? source.length : next);
}

function tsFunctionBlock(source: string, functionName: string): string {
  const start = source.indexOf(`function ${functionName}`);
  if (start < 0) {
    throw new Error(`Function ${functionName} not found`);
  }
  const next = source.indexOf("\nasync function ", start + 1);
  return source.slice(start, next < 0 ? source.length : next);
}

function objectLiteralBlock(source: string, propertyName: string): string {
  const start = source.indexOf(`${propertyName}: {`);
  if (start < 0) {
    throw new Error(`Object literal ${propertyName} not found`);
  }
  const end = source.indexOf("\n    },", start + 1);
  if (end < 0) {
    throw new Error(`Object literal ${propertyName} end not found`);
  }
  return source.slice(start, end);
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertEq<T>(actual: T, expected: T, message?: string): void {
  if (actual !== expected) {
    throw new Error(message ?? `Expected ${String(expected)}, got ${String(actual)}`);
  }
}

function assertIncludes(source: string, expected: string, message?: string): void {
  if (!source.includes(expected)) {
    throw new Error(message ?? `Expected source to include ${expected}`);
  }
}

function assertNotIncludes(source: string, expected: string, message?: string): void {
  if (source.includes(expected)) {
    throw new Error(message ?? `Expected source not to include ${expected}`);
  }
}
