const PROJECT_PREFIX = "Projetos/draxos-mobile";
const RULESET_PATH = "data/definitions/openworld/forest_ruleset_v1.json";
const BASE_MIGRATION_PATH = "server/schema/migrations/202606020001_openworld_bosque_hardening_v1.sql";
const GUIDANCE_MIGRATION_PATH =
  "server/schema/migrations/202606040001_openworld_guidance_persistence_v1.sql";
const COLLECTION_SYNC_MIGRATION_PATH =
  "server/schema/migrations/202606040002_openworld_bosque_collection_sync_v1.sql";
const SUPABASE_COLLECTION_SYNC_MIGRATION_PATH =
  "supabase/migrations/202606040002_openworld_bosque_collection_sync_v1.sql";
const MODE_DOMAIN_PATH = "server/functions/_shared/mode_domain.ts";
const SUPABASE_MODE_DOMAIN_PATH = "supabase/functions/_shared/mode_domain.ts";

Deno.test("openworld forest ruleset v1 is active internal alpha and keeps v0 historical", async () => {
  const ruleset = await rulesetDefinition();
  assertEq(
    stringField(ruleset, "schema_version"),
    "openworld_forest_ruleset_v1",
    "schema should be v1",
  );
  assertEq(
    stringField(ruleset, "ruleset_id"),
    "openworld_forest_ruleset_v1",
    "ruleset id should be v1",
  );
  assertEq(numberField(ruleset, "ruleset_version"), 1, "ruleset version should be 1");
  assertEq(stringField(ruleset, "status"), "active", "bosque should be active");
  assertEq(
    stringField(ruleset, "release_channel"),
    "internal_alpha",
    "release channel remains internal alpha",
  );
  const historicalRulesets = arrayField(ruleset, "historical_rulesets");
  assert(
    historicalRulesets.some((entry) => {
      const historical = objectField(entry);
      return stringField(historical, "ruleset_id") === "openworld_forest_ruleset_v0" &&
        stringField(historical, "status") === "historical";
    }),
    "v0 should remain documented as historical",
  );
});

Deno.test("openworld forest ruleset cross-links resource nodes and recipe items", async () => {
  const ruleset = await rulesetDefinition();
  const itemIds = new Set(
    arrayField(ruleset, "items").map((item) => stringField(objectField(item), "item_id")),
  );

  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    assert(
      itemIds.has(stringField(node, "item_id")),
      `node ${stringField(node, "node_id")} should reference a known item`,
    );
  }

  for (const recipe of arrayField(ruleset, "recipes").map(objectField)) {
    for (const itemId of Object.keys(objectField(recipe["cost"]))) {
      assert(
        itemIds.has(itemId),
        `recipe ${stringField(recipe, "recipe_id")} cost should reference ${itemId}`,
      );
    }
    for (const itemId of Object.keys(objectField(recipe["output"]))) {
      assert(
        itemIds.has(itemId),
        `recipe ${stringField(recipe, "recipe_id")} output should reference ${itemId}`,
      );
    }
  }
});

Deno.test("openworld forest ruleset is referenced by TS domain and effective SQL logic", async () => {
  const ruleset = await rulesetDefinition();
  const baseMigration = await projectText(BASE_MIGRATION_PATH);
  const guidanceMigration = await projectText(GUIDANCE_MIGRATION_PATH);
  const collectionSyncMigration = await projectText(COLLECTION_SYNC_MIGRATION_PATH);
  const supabaseCollectionSyncMigration = await projectText(
    SUPABASE_COLLECTION_SYNC_MIGRATION_PATH,
  );
  const effectiveMigration =
    `${baseMigration}\n${guidanceMigration}\n${collectionSyncMigration}`;
  const modeDomain = await projectText(MODE_DOMAIN_PATH);
  const supabaseModeDomain = await projectText(SUPABASE_MODE_DOMAIN_PATH);

  assertEq(
    normalizeNewlines(modeDomain),
    normalizeNewlines(supabaseModeDomain),
    "mode domain should be mirrored between server and supabase",
  );
  assertIncludes(
    modeDomain,
    RULESET_PATH,
    "mode domain should import the shared ruleset definition",
  );
  assertIncludes(
    modeDomain,
    "guidance_update",
    "mode domain should accept Bosque guidance updates",
  );
  assertEq(
    normalizeNewlines(collectionSyncMigration),
    normalizeNewlines(supabaseCollectionSyncMigration),
    "collection sync migration should be mirrored between server and supabase",
  );
  assertIncludes(
    effectiveMigration,
    stringField(ruleset, "ruleset_id"),
    "effective migration chain should seed ruleset v1",
  );
  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    const nodeId = stringField(node, "node_id");
    const itemId = stringField(node, "item_id");
    assertIncludes(
      collectionSyncMigration,
      `when '${nodeId}' then '${itemId}'`,
      `collection sync migration should map node ${nodeId}`,
    );
  }
});

Deno.test("openworld forest event migration preserves position except move heartbeat", async () => {
  const migration = await projectText(COLLECTION_SYNC_MIGRATION_PATH);
  const applyEventFunction = sqlFunctionBody(migration, "openworld_forest_apply_event_v1");
  const moveBranchStart = applyEventFunction.indexOf("if p_event_type = 'move_heartbeat'");
  const collectBranchStart = applyEventFunction.indexOf("elsif p_event_type = 'collect_start'");

  assert(moveBranchStart >= 0, "apply event function should branch on move heartbeat");
  assert(collectBranchStart > moveBranchStart, "collect branch should follow move heartbeat branch");
  assertEq(
    applyEventFunction.slice(0, moveBranchStart).includes("'{player_position}'"),
    false,
    "apply event should not write player_position before event type dispatch",
  );
  assertIncludes(
    applyEventFunction.slice(moveBranchStart, collectBranchStart),
    "'{player_position}'",
    "move heartbeat branch should write player_position",
  );
  assertEq(
    applyEventFunction.slice(collectBranchStart).includes("'{player_position}'"),
    false,
    "collection/deposit/craft/guidance branches should preserve persisted player_position",
  );
});

async function rulesetDefinition(): Promise<Record<string, unknown>> {
  return objectField(JSON.parse(await projectText(RULESET_PATH)));
}

async function projectText(relativePath: string): Promise<string> {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  const path = cwd.endsWith("/draxos-mobile") ? relativePath : `${PROJECT_PREFIX}/${relativePath}`;
  return await Deno.readTextFile(path);
}

function objectField(value: unknown): Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function arrayField(record: Record<string, unknown>, key: string): unknown[] {
  return Array.isArray(record[key]) ? record[key] as unknown[] : [];
}

function stringField(record: Record<string, unknown>, key: string): string {
  return typeof record[key] === "string" ? record[key] as string : "";
}

function numberField(record: Record<string, unknown>, key: string): number {
  return typeof record[key] === "number" ? record[key] as number : Number.NaN;
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Actual=${String(actual)} Expected=${String(expected)}`);
  }
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(`${message}. Missing=${needle}`);
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function sqlFunctionBody(sql: string, functionName: string): string {
  const marker = `create or replace function public.${functionName}`;
  const start = sql.indexOf(marker);
  assert(start >= 0, `migration should define ${functionName}`);
  const end = sql.indexOf("\n$$;", start);
  assert(end > start, `migration should close ${functionName}`);
  return sql.slice(start, end);
}
