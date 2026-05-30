import { calculatePower } from "../../tools/battle_lab/generate.ts";

const PROJECT_ROOT = new URL("../../", import.meta.url);

Deno.test("lab heuristics contract records current lab model authority", async () => {
  const contract = await readText("docs/contracts/lab-heuristics.md");
  const battleModel = await readJson("tools/battle_lab/model.v1.json");
  const progressionModel = await readJson(
    "tools/progression_lab/model.v1.json",
  );

  assertContains(contract, "LAB_HEURISTICS_CONTRACT_V1");
  assertContains(contract, "lab-only");
  assertContains(contract, "foundation_ruleset_v0");
  assertContains(contract, "blocked until explicit package decision");
  assertContains(contract, battleModel.model_id);
  assertContains(contract, battleModel.status);
  assertContains(contract, progressionModel.model_id);
  assertContains(contract, progressionModel.status);
  assertContains(contract, "bot_power_offsets_percent");
  assertContains(contract, "Track 16");
  assertContains(contract, "potion");
  assertContains(contract, "crafting");
});

Deno.test("battle lab screen power display follows battle lab runner weights", async () => {
  const screen = await readText("dev/battle_lab/battle_lab_screen.gd");
  const clientTest = await readText("tests/client/test_battle_lab_dev.gd");
  const build = {
    id: "test",
    displayName: "Test",
    level: 10,
    weaponId: "varinha_cinzas",
    weaponLevel: 8,
    weaponQualityTier: 2,
    spellIds: ["sussurro_medo", "descarga_nervosa"],
    spellLevels: { sussurro_medo: 7, descarga_nervosa: 6 },
    passiveId: "anatomista_profano",
    passiveLevel: 5,
  };
  const expectedPower = calculatePower(build);

  assertEquals(
    expectedPower,
    1334,
    "battle lab runner fixture should stay stable",
  );
  for (
    const [key, value] of Object.entries({
      level: 42,
      weaponLevel: 28,
      spellLevelsTotal: 40,
      petLevel: 34,
      passiveLevel: 22,
      weaponQualityTier: 30,
    })
  ) {
    assertContains(screen, `"${key}": ${value}`);
  }
  assertContains(clientTest, "1334");
});

Deno.test("progression lab screen profile and milestone selectors match model ids", async () => {
  const screen = await readText(
    "dev/progression_lab/progression_lab_screen.gd",
  );
  const clientTest = await readText("tests/client/test_progression_lab_dev.gd");
  const model = await readJson("tools/progression_lab/model.v1.json");
  const profileIds = model.profiles.map((profile: { id: string }) =>
    profile.id
  );
  const milestoneIds = model.milestones.map((milestone: { id: string }) =>
    milestone.id
  );

  assertEquals(
    extractConstStringArray(screen, "PROFILE_IDS"),
    profileIds,
    "Progression Lab screen profiles must mirror model profiles",
  );
  assertEquals(
    extractConstStringArray(screen, "MILESTONE_IDS"),
    milestoneIds,
    "Progression Lab screen milestones must mirror model milestones",
  );
  assertContains(
    clientTest,
    "test_progression_lab_screen_profiles_and_milestones_match_model",
  );
});

Deno.test("foundation ruleset hashes the lab models that own offline heuristics", async () => {
  const ruleset = await readJson("data/rulesets/foundation_ruleset_v0.json");
  const sources = ruleset.sources as Array<{ path: string; kind: string }>;
  const sourcePaths = new Set(sources.map((source) => source.path));

  assert(
    sourcePaths.has("tools/battle_lab/model.v1.json"),
    "battle lab model should be hashed",
  );
  assert(
    sourcePaths.has("tools/progression_lab/model.v1.json"),
    "progression lab model should be hashed",
  );
  assertEquals(
    ruleset.counts.tool_models,
    3,
    "ruleset should count lab/economy tool models",
  );
  assertEquals(
    ruleset.runtime.server_authoritative,
    true,
    "ruleset runtime authority must remain server-side",
  );
  assertEquals(
    sources.find((source) => source.path === "tools/battle_lab/model.v1.json")
      ?.kind,
    "tool_model",
    "battle lab model is a tool model, not runtime authority",
  );
  assertEquals(
    sources.find((source) =>
      source.path === "tools/progression_lab/model.v1.json"
    )?.kind,
    "tool_model",
    "progression lab model is a tool model, not runtime authority",
  );
});

Deno.test("dev lab generators remain offline and adapter-free", async () => {
  for (
    const relativePath of [
      "tools/battle_lab/generate.ts",
      "tools/progression_lab/generate.ts",
    ]
  ) {
    const source = await readText(relativePath);
    assertNotMatches(source, /\bfetch\s*\(/, `${relativePath} must not fetch`);
    assertNotContains(source, "Deno.serve");
    assertNotContains(source, "rpc/");
    assertNotContains(source, "rest/v1");
    assertNotContains(source, "SUPABASE_SERVICE_ROLE_KEY");
    assertNotContains(source, "SUPABASE_URL");
  }
});

Deno.test("lab models declare Track 16 consumable and behavior coverage", async () => {
  const battleModel = await readJson("tools/battle_lab/model.v1.json");
  const progressionModel = await readJson(
    "tools/progression_lab/model.v1.json",
  );
  const scenarios = battleModel.track16_scenarios as Array<
    Record<string, unknown>
  >;

  assert(
    scenarios.some((scenario) => scenario.potion !== undefined),
    "Battle Lab model should include potion scenarios",
  );
  assert(
    scenarios.some((scenario) => scenario.spell_behavior !== undefined),
    "Battle Lab model should include spell behavior scenarios",
  );
  assertEquals(
    progressionModel.track16_consumables.life_potion_item_id,
    "pocao_vida",
    "Progression Lab should model the Track 16 life potion",
  );
  assertEquals(
    progressionModel.track16_consumables.life_potion_recipe_id,
    "craft_pocao_vida",
    "Progression Lab should model the Track 16 potion recipe",
  );
});

Deno.test("Progression Lab generated saves expose Track 16 preparation state", async () => {
  const generated = await readJson(
    "docs/progression-lab/generated/healthy_saves.json",
  );
  const save = generated.saves.find((item: { id: string }) =>
    item.id === "free_100_rewards_10h"
  );

  assert(save !== undefined, "generated 10h save should exist");
  assert(
    save.consumables?.crafted_life_potions > 0,
    "generated 10h save should include life potions",
  );
  assert(
    Array.isArray(save.consumables?.potion_slots),
    "generated saves should include potion slots",
  );
  assert(
    save.combat_build?.potionSlot?.itemId === "pocao_vida",
    "generated combat build should include potion slot",
  );
});

Deno.test("progression lab seeder remains local-only and explicit", async () => {
  const seeder = await readText("tools/progression_lab/seed_supabase.ts");

  assertContains(seeder, "assertLocalSupabase");
  assertContains(seeder, "Refusing to seed non-local Supabase URL");
  assertContains(seeder, "--dry-run");
  assertContains(seeder, "SUPABASE_SERVICE_ROLE_KEY");
});

Deno.test("server runtime does not import dev lab generators", async () => {
  for (
    const root of [
      "server/functions",
      "supabase/functions",
    ]
  ) {
    for await (const file of walkTextFiles(root)) {
      const source = await readText(file);
      assertNotMatches(
        source,
        /(?:from\s+["'][^"']*|import\s*\(\s*["'][^"']*)(?:tools|dev)\/(?:battle_lab|progression_lab)/,
        `${file} must not import dev lab generators or screens`,
      );
    }
  }
});

async function readText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(new URL(relativePath, PROJECT_ROOT));
}

async function readJson(relativePath: string): Promise<any> {
  return JSON.parse(await readText(relativePath));
}

function extractConstStringArray(source: string, constName: string): string[] {
  const match = source.match(
    new RegExp(`const ${constName} := \\[([\\s\\S]*?)\\]`),
  );
  if (match === null) {
    throw new Error(`missing const array ${constName}`);
  }
  return [...match[1].matchAll(/"([^"]+)"/g)].map((item) => item[1]);
}

function assertContains(haystack: string, needle: string): void {
  if (!haystack.includes(needle)) {
    throw new Error(`expected text to contain ${needle}`);
  }
}

function assertNotContains(haystack: string, needle: string): void {
  if (haystack.includes(needle)) {
    throw new Error(`expected text not to contain ${needle}`);
  }
}

function assertNotMatches(
  haystack: string,
  pattern: RegExp,
  message: string,
): void {
  if (pattern.test(haystack)) {
    throw new Error(message);
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEquals(
  actual: unknown,
  expected: unknown,
  message: string,
): void {
  if (JSON.stringify(actual) !== JSON.stringify(expected)) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}

async function* walkTextFiles(relativeRoot: string): AsyncGenerator<string> {
  const absoluteRoot = new URL(relativeRoot + "/", PROJECT_ROOT);
  for await (const entry of Deno.readDir(absoluteRoot)) {
    const relativePath = `${relativeRoot}/${entry.name}`;
    if (entry.isDirectory) {
      yield* walkTextFiles(relativePath);
    } else if (entry.isFile && relativePath.endsWith(".ts")) {
      yield relativePath;
    }
  }
}
