import { simulateFirstSliceBattle } from "../../server/functions/_shared/battle_simulator.ts";
import {
  allowedSpellIds,
  analyzeBattleLog,
  buildBridgeReplayResponse,
  buildReplaySamples,
  calculatePower,
  classifyPowerBand,
  compareBattleLabResults,
  createBuilds,
  historyIndexDocument,
  markHistoryCompatibility,
  nearPowerMatchup,
  parseOptions,
  runBattleLab,
  upsertHistory,
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
    weaponId: "varinha_cinzas",
    weaponLevel: 8,
    weaponQualityTier: 2,
    spellIds: ["sussurro_medo", "descarga_nervosa"],
    spellLevels: { sussurro_medo: 7, descarga_nervosa: 6 },
    passiveId: "anatomista_profano",
    passiveLevel: 5,
    petId: undefined,
    petLevel: undefined,
  };
  const power = calculatePower(build);
  assertEquals(
    power,
    1334,
    "power formula should match the documented contract",
  );
  assertEquals(
    classifyPowerBand(power, testModel().power_bands),
    "band_004",
    "power band should match",
  );
});

Deno.test("battle lab parses combat log metrics", () => {
  const model = testModel();
  const builds = createBuilds(model).filter((build) => build.level === 25);
  const player = builds.find((build) => build.archetype_id === "dot_pressure")!;
  const opponent = builds.find((build) =>
    build.archetype_id === "defensive_occultist"
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
    metrics.damage_by_type.arcano >= 0,
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

Deno.test("battle lab replay samples include a spell-active representative", () => {
  const model = testModel();
  const result = runBattleLab(model);
  const samples = buildReplaySamples(model, result);
  const representative = samples.find((sample) =>
    sample.tag.includes("representative") &&
    sample.player_archetype_id !== "starter_instrument" &&
    sample.opponent_archetype_id !== "starter_instrument"
  );
  const spellCasts =
    representative?.battle_log.events.filter((event) =>
      event.type === "spell_cast"
    ).length ?? 0;

  assert(
    representative !== undefined,
    "samples should include non-starter representative",
  );
  assert(spellCasts > 0, "representative replay should visibly cast spells");
  assert(samples.length <= 24, "samples should respect max sample count");
});

Deno.test("battle lab Track 16 scenarios cover potion and spell behavior", () => {
  const result = runBattleLab(testModel());
  const potionCheck = result.checks.find((check) =>
    check.id === "track16_potion_event_coverage"
  );
  const behaviorCheck = result.checks.find((check) =>
    check.id === "track16_spell_behavior_coverage"
  );
  const potionReplay = buildReplaySamples(testModel(), result).find((sample) =>
    sample.tag === "track16_potion_behavior"
  );
  const potionEvents =
    potionReplay?.battle_log.events.filter((event) =>
      event.type === "consumable_use" || event.type === "heal"
    ) ?? [];

  assertEquals(potionCheck?.status, "PASS", "potion events should be covered");
  assertEquals(
    behaviorCheck?.status,
    "PASS",
    "spell behavior scenarios should be covered",
  );
  assert(
    result.summary.potion_enabled_matchups > 0,
    "summary should count potion-enabled matchups",
  );
  assert(
    result.summary.behavior_matchups > 0,
    "summary should count behavior matchups",
  );
  assert(
    potionEvents.length > 0,
    "Track 16 replay sample should include consumable/heal events",
  );
});

Deno.test("battle lab parses archive and compare options", () => {
  const options = parseOptions([
    "--archive-run",
    "run_a",
    "--compare-with",
    "run_b",
    "--request",
    "request.json",
    "--response",
    "response.json",
  ]);
  assertEquals(options.archiveRunId, "run_a", "archive run id should parse");
  assertEquals(
    options.compareWithRunId,
    "run_b",
    "compare run id should parse",
  );
  assertEquals(
    options.requestPath,
    "request.json",
    "request path should parse",
  );
  assertEquals(
    options.responsePath,
    "response.json",
    "response path should parse",
  );
  const scratchOptions = parseOptions(["--scratch-run", "scratch_a"]);
  assertEquals(
    scratchOptions.scratchRunId,
    "scratch_a",
    "scratch run id should parse",
  );
});

Deno.test("battle lab classifies near-power matchups", () => {
  assert(
    nearPowerMatchup({ player_power: 1000, opponent_power: 820 }, 20),
    "20% near-power should include 1000 vs 820",
  );
  assert(
    !nearPowerMatchup({ player_power: 1000, opponent_power: 790 }, 20),
    "20% near-power should exclude 1000 vs 790",
  );
});

Deno.test("battle lab excludes same-archetype mirrors from near-power dominance", () => {
  const result = runBattleLab(singleArchetypeModel());
  assertEquals(
    result.near_power_archetypes[0].total,
    0,
    "same-archetype mirrors should not feed near-power dominance",
  );
  const dominance = result.checks.find((check) =>
    check.id === "near_power_dominance"
  );
  assertEquals(
    dominance?.status,
    "PASS",
    "self mirrors should not fail dominance",
  );
});

Deno.test("battle lab separates damage by side before aggregating sources", () => {
  const model = testModel();
  const builds = createBuilds(model).filter((build) => build.level === 25);
  const player = builds.find((build) => build.archetype_id === "dot_pressure")!;
  const opponent = builds.find((build) =>
    build.archetype_id === "defensive_occultist"
  )!;
  const simulation = simulateFirstSliceBattle({
    battleId: "side_damage_test",
    seed: "side_damage_test_seed",
    player: player.build,
    opponent: opponent.build,
  });
  const metrics = analyzeBattleLog(
    model,
    player,
    opponent,
    "side_damage_test",
    "side_damage_test_seed",
    simulation,
  );

  for (const source of ["weapon", "spell", "dot", "pet", "summon", "system"]) {
    assertEquals(
      metrics.player_damage_by_source[source] +
        metrics.opponent_damage_by_source[source],
      metrics.damage_by_source[source],
      `${source} damage should equal player + opponent damage`,
    );
  }
});

Deno.test("battle lab compares current result against an archived baseline", () => {
  const baseline = runBattleLab(minimalModel());
  const current = structuredClone(baseline);
  current.summary.avg_duration = baseline.summary.avg_duration + 2;
  const rows = compareBattleLabResults("baseline_run", baseline, current);
  const avgDuration = rows.find((row) => row.metric === "avg_duration");
  assertEquals(
    avgDuration?.delta,
    "+2s",
    "comparison should show numeric delta",
  );
});

Deno.test("battle lab builds a run manifest entry and history index document", () => {
  const manifest = testRunManifest("test_run");
  const history = upsertHistory([], manifest);
  const indexDocument = historyIndexDocument(history);

  assert(
    indexDocument.includes('"run_id": "test_run"'),
    "history should keep run id",
  );
  assert(
    indexDocument.includes('"schema_version": 1'),
    "history should include schema version",
  );
  assertEquals(history.length, 1, "history index should include one run");
  assertEquals(
    history[0].run_id,
    "test_run",
    "history index should keep run id",
  );
});

Deno.test("battle lab marks old runs stale when compatibility hashes differ", () => {
  const manifest = {
    ...testRunManifest("old_run"),
    compatibility: {
      simulator_hash: "old",
      content_hash: "old",
      model_hash: "old",
      battle_log_schema: "battle_log_v1",
      compatibility_status: "current",
    },
  } as const;
  const history = markHistoryCompatibility([manifest], {
    simulator_hash: "new",
    content_hash: "new",
    model_hash: "new",
    battle_log_schema: "battle_log_v1",
    compatibility_status: "current",
  });
  assertEquals(
    history[0].compatibility?.compatibility_status,
    "stale",
    "hash mismatch should mark old runs stale",
  );
});

Deno.test("battle lab bridge generates deterministic custom replay logs", () => {
  const model = testModel();
  const player = createBuilds(model).find((build) =>
    build.level === 25 && build.archetype_id === "dot_pressure"
  )!;
  const opponent = createBuilds(model).find((build) =>
    build.level === 25 && build.archetype_id === "defensive_occultist"
  )!;
  const first = buildBridgeReplayResponse(model, {
    schema_version: "battle_lab_request_v1",
    mode: "replay",
    battle_id: "bridge_test",
    seed: "bridge_seed",
    player_build: player.build,
    opponent_build: opponent.build,
  });
  const second = buildBridgeReplayResponse(model, {
    schema_version: "battle_lab_request_v1",
    mode: "replay",
    battle_id: "bridge_test",
    seed: "bridge_seed",
    player_build: player.build,
    opponent_build: opponent.build,
  });
  assertEquals(first.ok, true, "bridge replay should succeed");
  assertEquals(
    JSON.stringify(first.replay?.battle_log),
    JSON.stringify(second.replay?.battle_log),
    "same seed/builds should produce same battle log",
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
    track16_scenarios: [
      {
        id: "potion_default",
        display_name: "Pocao default hp<40",
        levels: [25],
        archetypes: ["dot_pressure", "defensive_occultist"],
        potion: {
          item_id: "pocao_vida",
          quantity: 1,
          behavior: {
            enabled: true,
            hp: { mode: "below", percent: 40 },
            mana: { mode: "ignore", percent: 0 },
          },
        },
      },
      {
        id: "spell_behavior_disabled",
        display_name: "Primeira spell desativada",
        levels: [25],
        archetypes: ["dot_pressure", "defensive_occultist"],
        spell_behavior: {
          target: "first_spell",
          behavior: {
            enabled: false,
            hp: { mode: "ignore", percent: 0 },
            mana: { mode: "ignore", percent: 0 },
          },
        },
      },
    ],
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
        id: "starter_instrument",
        display_name: "Starter Instrument",
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
        spell_preferences: [
          "toxina_palida",
          "marca_brasa",
          "hemorragia_induzida",
          "geada_ossos",
        ],
        passive_preferences: ["alquimia_toxica", "cinza_viva"],
        pet_preferences: ["serpente_toxina", "cao_cinzas"],
        weapon_level_ratio: 0.75,
        spell_level_ratio: 0.95,
        passive_level_ratio: 0.75,
        pet_level_ratio: 0.75,
        quality_bias: 0,
      },
      {
        id: "defensive_occultist",
        display_name: "Defensive Occultist",
        role: "Test defensive",
        spell_preferences: [
          "coagulo_negro",
          "toxina_palida",
          "geada_ossos",
          "sussurro_medo",
        ],
        passive_preferences: [
          "pedra_interna",
          "mente_fria",
          "sangue_obediente",
        ],
        pet_preferences: ["medusa_mare_fria", "corvo_pressagio"],
        weapon_level_ratio: 0.7,
        spell_level_ratio: 0.75,
        passive_level_ratio: 0.95,
        pet_level_ratio: 0.7,
        quality_bias: 0,
      },
    ],
  };
}

function singleArchetypeModel(): BattleLabModel {
  const model = testModel();
  return {
    ...model,
    levels: [1],
    random_builds_per_archetype_per_level: 1,
    archetypes: model.archetypes.slice(0, 1),
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

function testRunManifest(runId: string) {
  return {
    run_id: runId,
    archived_at: "2026-05-21T00:00:00.000Z",
    base_sha: "test",
    model_id: "battle_lab_test",
    seed: "test_seed",
    hypothesis: "test",
    overall_status: "PASS" as const,
    avg_duration: 20,
    median_duration: 20,
    short_rate_percent: 0,
    long_rate_percent: 0,
    anti_stall_rate_percent: 0,
    raw_stress_dominance_max_percent: 50,
    near_power_dominance_max_percent: 50,
    critical_archetypes: [],
    files: ["battle_lab_summary.json"],
  };
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
