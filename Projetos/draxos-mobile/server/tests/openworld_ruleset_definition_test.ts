const PROJECT_PREFIX = "Projetos/draxos-mobile";
const RULESET_PATH = "data/definitions/openworld/forest_ruleset_v1.json";
const MIGRATION_PATH = "supabase/migrations/202606020001_openworld_bosque_hardening_v1.sql";
const MODE_DOMAIN_PATH = "server/functions/_shared/mode_domain.ts";

Deno.test("openworld forest ruleset v1 is active internal alpha and keeps v0 historical", async () => {
  const ruleset = await rulesetDefinition();
  assertEq(stringField(ruleset, "schema_version"), "openworld_forest_ruleset_v1", "schema should be v1");
  assertEq(stringField(ruleset, "ruleset_id"), "openworld_forest_ruleset_v1", "ruleset id should be v1");
  assertEq(numberField(ruleset, "ruleset_version"), 1, "ruleset version should be 1");
  assertEq(stringField(ruleset, "status"), "active", "bosque should be active");
  assertEq(stringField(ruleset, "release_channel"), "internal_alpha", "release channel remains internal alpha");
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
  const itemIds = new Set(arrayField(ruleset, "items").map((item) => stringField(objectField(item), "item_id")));

  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    assert(itemIds.has(stringField(node, "item_id")), `node ${stringField(node, "node_id")} should reference a known item`);
  }

  for (const recipe of arrayField(ruleset, "recipes").map(objectField)) {
    for (const itemId of Object.keys(objectField(recipe["cost"]))) {
      assert(itemIds.has(itemId), `recipe ${stringField(recipe, "recipe_id")} cost should reference ${itemId}`);
    }
    for (const itemId of Object.keys(objectField(recipe["output"]))) {
      assert(itemIds.has(itemId), `recipe ${stringField(recipe, "recipe_id")} output should reference ${itemId}`);
    }
  }
});

Deno.test("openworld forest ruleset is referenced by TS domain and SQL snapshot logic", async () => {
  const ruleset = await rulesetDefinition();
  const migration = await projectText(MIGRATION_PATH);
  const modeDomain = await projectText(MODE_DOMAIN_PATH);

  assertIncludes(modeDomain, RULESET_PATH, "mode domain should import the shared ruleset definition");
  assertIncludes(migration, stringField(ruleset, "ruleset_id"), "migration should seed ruleset v1");
  for (const node of arrayField(ruleset, "resource_nodes").map(objectField)) {
    assertIncludes(migration, stringField(node, "node_id"), `migration should know node ${stringField(node, "node_id")}`);
  }
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
  return value !== null && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};
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
  if (actual !== expected) throw new Error(`${message}. Actual=${String(actual)} Expected=${String(expected)}`);
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) throw new Error(`${message}. Missing=${needle}`);
}
