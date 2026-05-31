const MIGRATION_PATH =
  "supabase/migrations/202605310002_arena_consistency_pass.sql";
const SERVER_MIRROR_PATH =
  "server/schema/migrations/202605310002_arena_consistency_pass.sql";
const SERVER_ARENA_FUNCTION = "server/functions/arena/index.ts";
const SUPABASE_ARENA_FUNCTION = "supabase/functions/arena/index.ts";

Deno.test("arena consistency migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("arena edge function is mirrored between server and supabase", async () => {
  const serverFunction = await readProjectText(SERVER_ARENA_FUNCTION);
  const supabaseFunction = await readProjectText(SUPABASE_ARENA_FUNCTION);

  assertEq(
    normalizeNewlines(serverFunction),
    normalizeNewlines(supabaseFunction),
    "server and supabase arena functions should stay mirrored",
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
      "public.complete_idempotency",
    ]
  ) {
    assertIncludes(duelRpc, required, `duel RPC should include ${required}`);
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
});

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(new URL(`../../${relativePath}`, import.meta.url));
}

function functionBlock(source: string, functionName: string): string {
  const start = source.indexOf(`function public.${functionName}`);
  if (start < 0) {
    throw new Error(`Function ${functionName} not found`);
  }
  const next = source.indexOf("\ncreate or replace function public.", start + 1);
  return source.slice(start, next < 0 ? source.length : next);
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
