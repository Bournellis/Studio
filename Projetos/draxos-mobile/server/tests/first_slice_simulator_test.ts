import { simulateFirstSliceBattle } from "../functions/_shared/battle_simulator.ts";

Deno.test("first-slice battle simulator is deterministic and emits the v1 combat log", () => {
  const input = {
    battleId: "00000000-0000-4000-8000-000000000001",
    seed: "first_slice:test-player:00000000-0000-4000-8000-000000000002",
    player: {
      id: "player-test",
      displayName: "Draxos",
      level: 10,
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: ["raio_cosmico", "invocar_demonio"],
      spellLevels: { raio_cosmico: 1, invocar_demonio: 1 },
      passiveId: "foco_astral",
      passiveLevel: 1,
      petId: "familiar_cinzento",
      petLevel: 10,
    },
    opponent: {
      id: "bot_summoner_01",
      displayName: "Invocador Abissal",
      level: 10,
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: ["raio_cosmico", "animar_morto"],
      spellLevels: { raio_cosmico: 1, animar_morto: 1 },
      passiveId: "foco_astral",
      passiveLevel: 1,
      petId: "brasido",
      petLevel: 10,
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
    hasEvent(first.battleLog.events, "spell_cast"),
    "battle should include spell casts",
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
