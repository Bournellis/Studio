const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH =
  "supabase/migrations/202605300003_remaining_transactional_domain_enforcement.sql";
const SERVER_MIRROR_PATH =
  "server/schema/migrations/202605300003_remaining_transactional_domain_enforcement.sql";
const SHARED_HELPER_PATH = "server/functions/_shared/transactional_mutation.ts";
const SUPABASE_SHARED_HELPER_PATH = "supabase/functions/_shared/transactional_mutation.ts";

const ADAPTERS = [
  {
    label: "battle",
    server: "server/functions/battle/index.ts",
    supabase: "supabase/functions/battle/index.ts",
    rpcs: ["rpc/request_battle_v1"],
  },
  {
    label: "build",
    server: "server/functions/build/index.ts",
    supabase: "supabase/functions/build/index.ts",
    rpcs: ["rpc/equip_build_v1"],
  },
  {
    label: "crafting",
    server: "server/functions/crafting/index.ts",
    supabase: "supabase/functions/crafting/index.ts",
    rpcs: ["rpc/crush_bones_v1", "rpc/craft_item_v1"],
  },
  {
    label: "monetization",
    server: "server/functions/monetization/index.ts",
    supabase: "supabase/functions/monetization/index.ts",
    rpcs: ["rpc/claim_reward_v1", "rpc/alpha_purchase_v1"],
  },
  {
    label: "social",
    server: "server/functions/social/index.ts",
    supabase: "supabase/functions/social/index.ts",
    rpcs: ["rpc/guild_create_v1", "rpc/guild_join_v1"],
  },
];

Deno.test("remaining transactional domain migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("remaining transactional domain RPC dispatcher applies real atomic effects", async () => {
  const migration = await migrationText();
  const dispatcher = functionBlock(migration, "apply_foundation_mutation_v1");

  for (
    const required of [
      "from public.game_saves",
      "for update",
      "from public.ruleset_registry",
      "public.reserve_idempotency",
      "public.complete_idempotency",
      "'battle/request'",
      "'monetization/rewards/claim'",
      "'monetization/alpha-purchase'",
      "'build/equip'",
      "'crafting/craft'",
      "'crafting/crush-bones'",
      "'guild/create'",
      "'guild/join'",
      "insert into public.battles",
      "update public.players",
      "update public.resources",
      "insert into public.resource_transactions",
      "insert into public.item_transactions",
      "insert into public.reward_claims",
      "insert into public.alpha_purchases",
      "insert into public.guilds",
      "insert into public.guild_members",
      "update public.ranking",
      "'ruleset_id'",
      "'ruleset_version'",
      "'content_hash'",
      "'simulator_hash'",
    ]
  ) {
    assertIncludes(
      dispatcher,
      required,
      `dispatcher should include ${required}`,
    );
  }

  assertNotIncludes(
    dispatcher,
    "foundation_command_v1",
    "remaining transactional dispatcher should not delegate to reserved scaffolds",
  );
  assertNotIncludes(
    dispatcher,
    "reserved_for_domain_service",
    "remaining transactional dispatcher should be a real domain mutation",
  );
});

Deno.test("remaining v1 RPC wrappers preserve public endpoint identities", async () => {
  const migration = await migrationText();
  const wrappers = new Map([
    ["request_battle_v1", "battle/request"],
    ["equip_build_v1", "build/equip"],
    ["crush_bones_v1", "crafting/crush-bones"],
    ["craft_item_v1", "crafting/craft"],
    ["claim_reward_v1", "monetization/rewards/claim"],
    ["alpha_purchase_v1", "monetization/alpha-purchase"],
    ["guild_create_v1", "guild/create"],
    ["guild_join_v1", "guild/join"],
  ]);

  for (const [functionName, endpoint] of wrappers) {
    const block = functionBlock(migration, functionName);
    assertIncludes(
      block,
      "apply_foundation_mutation_v1",
      `${functionName} should route through the transactional dispatcher`,
    );
    assertIncludes(
      block,
      `'${endpoint}'`,
      `${functionName} should preserve endpoint ${endpoint}`,
    );
    assertNotIncludes(
      block,
      "foundation_command_v1",
      `${functionName} should not call the reserved scaffold`,
    );
  }
});

Deno.test("remaining transactional RPCs are service-role only", async () => {
  const migration = await migrationText();

  for (
    const signature of [
      "public.foundation_jsonb_numeric_v1(jsonb, text)",
      "public.foundation_jsonb_integer_v1(jsonb, text)",
      "public.apply_foundation_mutation_v1(uuid, text, uuid, text, jsonb)",
      "public.request_battle_v1(uuid, uuid, text, jsonb)",
      "public.equip_build_v1(uuid, uuid, text, jsonb)",
      "public.crush_bones_v1(uuid, uuid, text, jsonb)",
      "public.craft_item_v1(uuid, uuid, text, jsonb)",
      "public.claim_reward_v1(uuid, uuid, text, jsonb)",
      "public.alpha_purchase_v1(uuid, uuid, text, jsonb)",
      "public.guild_create_v1(uuid, uuid, text, jsonb)",
      "public.guild_join_v1(uuid, uuid, text, jsonb)",
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
        `grant execute on function ${escapeRegex(signature)} to (anon|authenticated);`,
      ),
      `${signature} should not be executable by anon/authenticated roles`,
    );
  }
});

Deno.test("transactional mutation helper and adapters are mirrored", async () => {
  const serverHelper = await readProjectText(SHARED_HELPER_PATH);
  const supabaseHelper = await readProjectText(SUPABASE_SHARED_HELPER_PATH);
  assertEq(
    normalizeNewlines(serverHelper),
    normalizeNewlines(supabaseHelper),
    "transactional mutation helper should be mirrored",
  );

  const helper = normalizeCode(serverHelper);
  for (
    const required of [
      "loadfoundationgamesave",
      "mutationrequesthash",
      "mapfoundationdatabaseerror",
      "ensure_foundation_profile_and_saves",
      "request_hash",
    ]
  ) {
    assertIncludes(helper, required, `helper should include ${required}`);
  }

  for (const adapter of ADAPTERS) {
    const serverAdapter = await readProjectText(adapter.server);
    const supabaseAdapter = await readProjectText(adapter.supabase);
    assertEq(
      normalizeNewlines(serverAdapter),
      normalizeNewlines(supabaseAdapter),
      `${adapter.label} adapter should be mirrored`,
    );

    const code = normalizeCode(serverAdapter);
    for (const rpc of adapter.rpcs) {
      assertIncludes(code, rpc, `${adapter.label} adapter should call ${rpc}`);
    }
    for (const required of ["mutationrequesthash", "request_hash"]) {
      assertIncludes(code, required, `${adapter.label} adapter should include ${required}`);
    }
    if (!code.includes("gamesave.id") && !code.includes("gamesave.value.id")) {
      throw new Error(`${adapter.label} adapter should pass a game save id to its RPC`);
    }
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
    throw new Error(message);
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
