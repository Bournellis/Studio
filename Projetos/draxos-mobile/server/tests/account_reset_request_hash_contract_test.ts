const SERVER_MIGRATION =
  "server/schema/migrations/202606050002_account_reset_request_hash_v1.sql";
const SUPABASE_MIGRATION =
  "supabase/migrations/202606050002_account_reset_request_hash_v1.sql";
const SERVER_FUNCTION = "server/functions/account/index.ts";
const SUPABASE_FUNCTION = "supabase/functions/account/index.ts";

Deno.test("Account save reset v1 requires request_hash and keeps reset cleanup DB-side", async () => {
  const serverMigration = await Deno.readTextFile(SERVER_MIGRATION);
  const supabaseMigration = await Deno.readTextFile(SUPABASE_MIGRATION);
  assertEq(
    normalize(serverMigration),
    normalize(supabaseMigration),
    "Account reset request_hash migration should be mirrored",
  );

  for (const needle of [
    "create or replace function public.reset_player_save_v1",
    "p_game_save_id uuid",
    "p_request_hash text",
    "INVALID_REQUEST_HASH",
    "public.reserve_idempotency",
    "public.complete_idempotency",
    "request_hash', normalized_hash",
    "preserved_account_social', true",
    "revoke all on function public.reset_player_save(uuid, uuid, text) from service_role",
  ]) {
    assertIncludes(serverMigration, needle, `${SERVER_MIGRATION} should contain ${needle}`);
  }

  for (const table of [
    "arena_attempt_steps",
    "arena_attempts",
    "arena_first_clears",
    "arena_progress",
    "mode_reward_claims",
    "mode_sessions",
    "mode_progress",
    "player_consumables",
    "player_spell_behaviors",
    "player_potion_slots",
    "item_transactions",
  ]) {
    assertIncludes(serverMigration, table, `${SERVER_MIGRATION} should reset ${table}`);
  }

  for (const forbidden of [
    "delete from public.guilds",
    "delete from public.guild_members",
    "delete from public.friendships",
    "delete from public.chat_messages",
    "delete from public.guild_contributions",
    "delete from public.construction_helps",
  ]) {
    assertNotIncludes(
      serverMigration,
      forbidden,
      `${SERVER_MIGRATION} should preserve account-social state`,
    );
  }
});

Deno.test("Account Edge adapter calls reset v1 with save-scoped request_hash", async () => {
  const serverFunction = await Deno.readTextFile(SERVER_FUNCTION);
  const supabaseFunction = await Deno.readTextFile(SUPABASE_FUNCTION);
  assertEq(
    normalize(serverFunction),
    normalize(supabaseFunction),
    "Account Edge Function should be mirrored",
  );

  for (const needle of [
    "loadFoundationGameSave",
    'const requestHash = stringField(body, "request_hash");',
    "request_hash is required for account save reset.",
    '"rpc/reset_player_save_v1"',
    "p_game_save_id: gameSave.value.id",
    "p_request_hash: requestHash",
    "IDEMPOTENCY_HASH_MISMATCH",
  ]) {
    assertIncludes(serverFunction, needle, `${SERVER_FUNCTION} should contain ${needle}`);
  }

  for (const forbidden of [
    '"rpc/reset_player_save"',
    "resetConsumableAndBehaviorState",
    "RESET_TRACK16_STATE_FAILED",
    "player_consumables?on_conflict",
    "player_potion_slots?on_conflict",
    "player_spell_behaviors?on_conflict",
    "item_transactions?player_id",
  ]) {
    assertNotIncludes(
      serverFunction,
      forbidden,
      `${SERVER_FUNCTION} should not use legacy reset or post-RPC cleanup`,
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
