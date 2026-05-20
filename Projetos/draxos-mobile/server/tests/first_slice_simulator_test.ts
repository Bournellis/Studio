import { simulateFirstSliceBattle } from "../functions/_shared/battle_simulator.ts";

Deno.test("first-slice battle simulator is deterministic and emits rich v1 combat events", () => {
  const input = {
    battleId: "00000000-0000-4000-8000-000000000001",
    seed: "first_slice:test-player:00000000-0000-4000-8000-000000000002",
    player: {
      id: "player-test",
      displayName: "Draxos",
      level: 28,
      weaponLevel: 8,
      weaponQualityTier: 1,
      spellIds: ["raio", "acender", "fortificar"],
      spellLevels: { raio: 20, acender: 20, fortificar: 20 },
      passiveId: "vampirismo",
      passiveLevel: 20,
      petId: "gelum",
      petLevel: 20,
    },
    opponent: {
      id: "bot-summoner-test",
      displayName: "Invocador Abissal",
      level: 28,
      weaponLevel: 8,
      weaponQualityTier: 1,
      spellIds: ["congelar", "envenenar", "animar_morto"],
      spellLevels: { congelar: 20, envenenar: 20, animar_morto: 20 },
      passiveId: "escudo",
      passiveLevel: 20,
      petId: "brasido",
      petLevel: 20,
    },
  };

  const first = simulateFirstSliceBattle(input);
  const second = simulateFirstSliceBattle(input);

  assertEq(
    JSON.stringify(first),
    JSON.stringify(second),
    "simulation should be deterministic",
  );
  assertEq(
    first.battleLog.schema_version,
    "battle_log_v1",
    "schema version should match",
  );
  assertEq(first.battleLog.mode, "FIRST_SLICE_SIM", "mode should match");
  assert(
    first.battleLog.events.length >= 10,
    "battle should produce a useful event log",
  );
  assert(
    hasEvent(first.battleLog.events, "passive_apply"),
    "battle should apply passives",
  );
  assert(
    hasEvent(first.battleLog.events, "spell_cast"),
    "battle should include spell casts",
  );
  assert(
    hasEvent(first.battleLog.events, "dot_apply"),
    "battle should apply DoTs",
  );
  assert(
    hasEvent(first.battleLog.events, "dot_tick"),
    "battle should tick DoTs",
  );
  assert(
    hasEvent(first.battleLog.events, "status_apply"),
    "battle should apply statuses",
  );
  assert(
    hasEvent(first.battleLog.events, "barrier_gain"),
    "battle should gain barriers",
  );
  assert(
    hasEvent(first.battleLog.events, "barrier_absorb"),
    "battle should absorb with barriers",
  );
  assert(
    hasEvent(first.battleLog.events, "resistance_apply"),
    "battle should apply resistances",
  );
  assert(
    hasEvent(first.battleLog.events, "summon_spawn"),
    "battle should include summon spawns",
  );
  assert(
    hasEvent(first.battleLog.events, "summon_attack"),
    "battle should include summon attacks",
  );
  assert(
    hasEvent(first.battleLog.events, "pet_attack"),
    "battle should include pet attacks",
  );
  assert(
    hasEvent(first.battleLog.events, "heal"),
    "battle should include lifesteal healing",
  );
  assert(
    hasEvent(first.battleLog.events, "cooldown_start"),
    "battle should expose cooldown starts",
  );
  assert(
    hasEvent(first.battleLog.events, "reward_preview"),
    "battle should preview rewards",
  );
  assert(
    hasEvent(first.battleLog.events, "battle_result"),
    "battle should include result event",
  );
  assert(first.reward.resources.xp > 0, "reward should include XP");
  assert(first.reward.resources.almas > 0, "reward should include Almas");
});

Deno.test("first-slice simulator supports long defensive status expiry and cooldown readiness", () => {
  const result = simulateFirstSliceBattle({
    battleId: "00000000-0000-4000-8000-000000000003",
    seed: "first_slice:defensive:00000000-0000-4000-8000-000000000004",
    player: {
      id: "player-defensive",
      displayName: "Draxos",
      level: 40,
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: ["fortificar", "envenenar"],
      spellLevels: { fortificar: 1, envenenar: 1 },
      passiveId: "resistencia",
      passiveLevel: 40,
    },
    opponent: {
      id: "bot-defensive",
      displayName: "Defensor de Cinzas",
      level: 40,
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: ["fortificar", "envenenar"],
      spellLevels: { fortificar: 1, envenenar: 1 },
      passiveId: "resistencia",
      passiveLevel: 40,
    },
  });

  assert(
    hasEvent(result.battleLog.events, "status_expire"),
    "battle should expire statuses",
  );
  assert(
    hasEvent(result.battleLog.events, "cooldown_ready"),
    "battle should expose cooldown ready events",
  );
  assert(
    result.battleLog.duration > 8,
    "defensive simulation should last long enough to validate time-based effects",
  );
});

function hasEvent(events: Array<{ type: string }>, type: string): boolean {
  return events.some((event) => event.type === type);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
