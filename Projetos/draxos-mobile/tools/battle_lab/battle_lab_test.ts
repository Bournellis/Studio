import { simulateFirstSliceBattle } from "../../server/functions/_shared/battle_simulator.ts";
import {
  allowedSpellIds,
  analyzeBattleLog,
  calculatePower,
  classifyPowerBand,
  createBuilds,
  runBattleLab,
} from "./generate.ts";

type BattleLabModel = Parameters<typeof createBuilds>[0];

Deno.test("battle lab build generation is deterministic for the same seed", () => {
  const first = createBuilds(testModel());
  const second = createBuilds(testModel());
  assertEquals(
    JSON.stringify(first),
    JSON.stringify(second),
    "build generation should be deterministic",
  );
});

Deno.test("battle lab generated builds obey unlock rules by level", () => {
  const builds = createBuilds(testModel());
  for (const build of builds) {
    const allowed = allowedSpellIds(build.level);
    assert(
      build.build.spellIds.every((spellId) => allowed.includes(spellId)),
      `${build.id} should only equip unlocked spells`,
    );
    assert(
      build.build.spellIds.length <= maxSpellSlotsForTest(build.level),
      `${build.id} should not exceed spell slots`,
    );
    assert(
      build.build.weaponLevel <= build.level,
      `${build.id} weapon level should not exceed character level`,
    );
    assert(
      Object.values(build.build.spellLevels).every((level) =>
        level <= build.level
      ),
      `${build.id} spell levels should not exceed character level`,
    );
    if (build.level < 10) {
      assert(
        build.build.passiveId === undefined,
        `${build.id} should not equip a passive before level 10`,
      );
    }
    if (build.level < 15) {
      assert(
        build.build.petId === undefined,
        `${build.id} should not equip a pet before level 15`,
      );
    }
  }
});

Deno.test("battle lab calculates power and classifies power bands", () => {
  const build = {
    id: "test",
    displayName: "Test",
    level: 10,
    weaponLevel: 8,
    weaponQualityTier: 2,
    spellIds: ["raio_cosmico", "raio"],
    spellLevels: { raio_cosmico: 7, raio: 6 },
    passiveId: "forca",
    passiveLevel: 5,
    petId: undefined,
    petLevel: undefined,
  };
  const power = calculatePower(build);
  assertEquals(
    power,
    1100,
    "power formula should match the documented contract",
  );
  assertEquals(
    classifyPowerBand(power, testModel().power_bands),
    "band_003",
    "power band should match",
  );
});

Deno.test("battle lab parses combat log metrics", () => {
  const model = testModel();
  const builds = createBuilds(model).filter((build) => build.level === 25);
  const player = builds.find((build) => build.archetype_id === "dot_pressure")!;
  const opponent = builds.find((build) =>
    build.archetype_id === "defensive_caster"
  )!;
  const simulation = simulateFirstSliceBattle({
    battleId: "test_battle",
    seed: "battle_lab_test_seed",
    player: player.build,
    opponent: opponent.build,
  });
  const metrics = analyzeBattleLog(
    model,
    player,
    opponent,
    "test_battle",
    "battle_lab_test_seed",
    simulation,
  );

  assert(metrics.duration > 0, "duration should be parsed");
  assert(metrics.event_count > 0, "event count should be parsed");
  assert(
    typeof metrics.anti_stall === "boolean",
    "anti-stall flag should exist",
  );
  assert(
    metrics.damage_by_source.weapon >= 0,
    "weapon damage should be available",
  );
  assert(
    metrics.damage_by_type.magico >= 0,
    "damage type buckets should be available",
  );
});

Deno.test("battle lab can generate a minimal summary", () => {
  const result = runBattleLab(minimalModel());
  assert(result.summary.total_builds > 0, "summary should include builds");
  assert(result.summary.total_battles > 0, "summary should include battles");
  assert(result.checks.length > 0, "summary should include checks");
  assert(
    ["PASS", "REVIEW", "CRITICAL"].includes(result.overall_status),
    "status should be valid",
  );
});

function testModel(): BattleLabModel {
  return {
    schema_version: 1,
    model_id: "battle_lab_test",
    status: "TEST",
    notes: [],
    output_dir: "docs/battle-lab/generated",
    seed: "test_seed",
    levels: [1, 3, 7, 10, 15, 25],
    random_builds_per_archetype_per_level: 1,
    thresholds: {
      target_duration_min: 18,
      target_duration_max: 28,
      short_duration: 12,
      long_duration: 32,
      short_battle_rate_review_percent: 20,
      long_battle_rate_review_percent: 20,
      anti_stall_review_percent: 5,
      healthy_win_rate_min_percent: 45,
      healthy_win_rate_max_percent: 55,
      dominance_review_percent: 65,
      dominance_critical_percent: 75,
      stomp_winner_hp_percent: 65,
    },
    power_bands: [
      {
        id: "band_001",
        display_name: "Banda 001",
        min_power: 0,
        max_power: 250,
      },
      {
        id: "band_002",
        display_name: "Banda 002",
        min_power: 251,
        max_power: 600,
      },
      {
        id: "band_003",
        display_name: "Banda 003",
        min_power: 601,
        max_power: 1200,
      },
      {
        id: "band_004",
        display_name: "Banda 004",
        min_power: 1201,
        max_power: 2200,
      },
      {
        id: "band_005",
        display_name: "Banda 005",
        min_power: 2201,
        max_power: 999999,
      },
    ],
    archetypes: [
      {
        id: "starter_wand",
        display_name: "Starter Wand",
        role: "Test starter",
        spell_preferences: [],
        passive_preferences: [],
        pet_preferences: [],
        weapon_level_ratio: 0.8,
        spell_level_ratio: 0,
        passive_level_ratio: 0,
        pet_level_ratio: 0,
        quality_bias: -1,
      },
      {
        id: "dot_pressure",
        display_name: "DoT Pressure",
        role: "Test dot",
        spell_preferences: ["envenenar", "acender", "dilacerar", "congelar"],
        passive_preferences: ["velocidade", "foco_astral"],
        pet_preferences: ["brasido", "gelum"],
        weapon_level_ratio: 0.75,
        spell_level_ratio: 0.95,
        passive_level_ratio: 0.75,
        pet_level_ratio: 0.75,
        quality_bias: 0,
      },
      {
        id: "defensive_caster",
        display_name: "Defensive Caster",
        role: "Test defensive",
        spell_preferences: [
          "fortificar",
          "envenenar",
          "congelar",
          "raio_cosmico",
        ],
        passive_preferences: ["resistencia", "escudo", "vampirismo"],
        pet_preferences: ["gelum", "familiar_cinzento"],
        weapon_level_ratio: 0.7,
        spell_level_ratio: 0.75,
        passive_level_ratio: 0.95,
        pet_level_ratio: 0.7,
        quality_bias: 0,
      },
    ],
  };
}

function minimalModel(): BattleLabModel {
  const model = testModel();
  return {
    ...model,
    levels: [3],
    random_builds_per_archetype_per_level: 0,
    archetypes: model.archetypes.slice(0, 2),
  };
}

function maxSpellSlotsForTest(level: number): number {
  if (level >= 25) return 3;
  if (level >= 7) return 2;
  if (level >= 3) return 1;
  return 0;
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
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
