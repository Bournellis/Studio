const SERVER_MIGRATION =
  "server/schema/migrations/202606030001_progression_lab_apply_request_hash.sql";
const SUPABASE_MIGRATION =
  "supabase/migrations/202606030001_progression_lab_apply_request_hash.sql";
const SERVER_FUNCTION = "server/functions/progression-lab/index.ts";
const SUPABASE_FUNCTION = "supabase/functions/progression-lab/index.ts";

Deno.test("Progression Lab apply requires request_hash and seeds Track 16 state inside RPC", async () => {
  const serverMigration = await Deno.readTextFile(SERVER_MIGRATION);
  const supabaseMigration = await Deno.readTextFile(SUPABASE_MIGRATION);
  assertEq(
    normalize(serverMigration),
    normalize(supabaseMigration),
    "Progression Lab apply request_hash migration should be mirrored",
  );
  for (const needle of [
    "p_request_hash text",
    "INVALID_REQUEST_HASH",
    "IDEMPOTENCY_HASH_MISMATCH",
    "player_consumables",
    "player_spell_behaviors",
    "player_potion_slots",
    "item_transactions",
    "request_hash = normalized_request_hash",
  ]) {
    assertIncludes(serverMigration, needle, `${SERVER_MIGRATION} should contain ${needle}`);
  }
  assertIncludes(
    serverMigration,
    "revoke all on function public.apply_progression_lab_save(uuid, uuid, text, text, jsonb) from service_role",
    "old no-hash RPC signature should not stay executable by service_role",
  );
});

Deno.test("Progression Lab Edge adapter passes request_hash and has no post-RPC Track 16 REST cleanup", async () => {
  const serverFunction = await Deno.readTextFile(SERVER_FUNCTION);
  const supabaseFunction = await Deno.readTextFile(SUPABASE_FUNCTION);
  assertEq(
    normalize(serverFunction),
    normalize(supabaseFunction),
    "Progression Lab Edge Function should be mirrored",
  );
  for (const needle of [
    'const requestHash = stringField(body, "request_hash").trim();',
    "p_request_hash: requestHash",
    "INVALID_REQUEST_HASH",
    "IDEMPOTENCY_HASH_MISMATCH",
  ]) {
    assertIncludes(serverFunction, needle, `${SERVER_FUNCTION} should contain ${needle}`);
  }
  for (const forbidden of [
    "resetConsumableAndBehaviorState",
    "player_consumables?on_conflict",
    "player_potion_slots?on_conflict",
    "player_spell_behaviors?on_conflict",
    "item_transactions?player_id",
  ]) {
    assertNotIncludes(
      serverFunction,
      forbidden,
      `${SERVER_FUNCTION} should not perform post-RPC Track 16 REST cleanup`,
    );
  }
});

function normalize(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assertNotIncludes(haystack: string, needle: string, message: string): void {
  if (haystack.includes(needle)) {
    throw new Error(`${message}. Forbidden: ${needle}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
