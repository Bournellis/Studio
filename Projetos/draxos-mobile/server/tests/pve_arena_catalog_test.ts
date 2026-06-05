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

  const mediumArenaUnlock = arenaTierUnlockState(
    {
      tutorial_completed: true,
      best_completed_difficulty: 3,
      best_completed_length: 4,
      metadata: {
        completed_arenas: {
          arena_tutorial_cinzas: true,
          arena_cinzas_curta: true,
          arena_veu_curta: true,
        },
        completed_tiers: {
          "arena_veu_curta:s1_d03_adepto": true,
        },
      },
    },
    { level: 15, power: 620 },
    "arena_ossos_media",
    "s1_d04_familiar",
  );
  assertEq(mediumArenaUnlock.length, 1);
  assertEq(mediumArenaUnlock[0].unlocked, true);

  const longArenaUnlock = arenaTierUnlockState(
    {
      tutorial_completed: true,
      best_completed_difficulty: 4,
      best_completed_length: 5,
      metadata: {
        completed_arenas: {
          arena_tutorial_cinzas: true,
          arena_cinzas_curta: true,
          arena_veu_curta: true,
          arena_ossos_media: true,
        },
        completed_tiers: {
          "arena_ossos_media:s1_d04_familiar": true,
        },
      },
    },
    { level: 20, power: 920 },
    "arena_abismo_longa",
    "s1_d05_arcano",
  );
  assertEq(longArenaUnlock.length, 1);
  assertEq(longArenaUnlock[0].unlocked, true);

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
