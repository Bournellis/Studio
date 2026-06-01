import {
  arenaBuffDefinitions,
  arenaDefinitions,
  arenaDifficultyTiers,
  arenaRewardProfile,
  arenaTierById,
  arenaTierUnlockState,
  pveEnemyDefinition,
  PVE_ARENA_CATALOG,
} from "../functions/_shared/pve_arena_catalog.ts";

Deno.test("generated PVE arena catalog mirrors definitions and helpers", async () => {
  assertEq(PVE_ARENA_CATALOG.schema_version, "pve_arena_catalog_v1");
  assertEq(PVE_ARENA_CATALOG.mode, "PVE_ARENA_V1");
  assertEq(PVE_ARENA_CATALOG.season_id, "season_001");
  assertEq(PVE_ARENA_CATALOG.target_power_model, "arena_tuning_power_v1");

  const arenas = arenaDefinitions();
  const tiers = arenaDifficultyTiers();
  const buffs = arenaBuffDefinitions();

  assertEq(arenas.length, 5);
  assertEq(tiers.length, 27);
  assertEq(buffs.length, 8);

  const tierKeys = new Set<string>();
  for (const tier of tiers) {
    const tierKey = `${tier.arena_id}:${tier.difficulty_id}`;
    assert(!tierKeys.has(tierKey), `duplicate tier key ${tierKey}`);
    tierKeys.add(tierKey);

    const roundTripTier = arenaTierById(tier.arena_id, tier.difficulty_id);
    assert(roundTripTier !== null, `missing helper tier ${tierKey}`);
    assertEq(roundTripTier.id, tier.id);

    const reward = arenaRewardProfile(tier.reward_profile_id);
    assert(reward !== null, `missing reward ${tier.reward_profile_id}`);
    assertEq(reward.ledger_source, "arena_pve_v1");

    for (const enemyId of tier.enemy_sequence) {
      const enemy = pveEnemyDefinition(enemyId);
      assert(enemy !== null, `missing enemy ${enemyId}`);
      assert(
        enemy.source_bot_build_id.length > 0,
        `${enemyId} should map to a source bot build`,
      );
    }
  }

  const initialUnlocks = arenaTierUnlockState(
    { best_completed_difficulty: -1, best_completed_length: 0, metadata: {} },
    { level: 1, power: 90 },
    "arena_tutorial_cinzas",
    "s1_d00_intro",
  );
  assertEq(initialUnlocks.length, 1);
  assertEq(initialUnlocks[0].unlocked, true);

  const lockedLongArena = arenaTierUnlockState(
    { best_completed_difficulty: 1, best_completed_length: 3, metadata: {} },
    { level: 8, power: 900 },
    "arena_abismo_longa",
    "s1_d05_arcano",
  );
  assertEq(lockedLongArena.length, 1);
  assertEq(lockedLongArena[0].unlocked, false);

  const serverCatalog = await Deno.readTextFile(
    projectFile("server/functions/_shared/pve_arena_catalog.ts"),
  );
  const supabaseCatalog = await Deno.readTextFile(
    projectFile("supabase/functions/_shared/pve_arena_catalog.ts"),
  );
  assertEq(serverCatalog, supabaseCatalog, "server/supabase catalog mirrors");
});

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `Projetos/draxos-mobile/${relativePath}`;
}

function assertEq(
  actual: unknown,
  expected: unknown,
  message = "values should match",
): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}
