import {
  type BattleSimulationInput,
  simulateFirstSliceBattle,
} from "../functions/_shared/battle_simulator.ts";

Deno.test("first-slice battle simulator is deterministic and emits rich v1 combat events", () => {
  const input = {
    battleId: "00000000-0000-4000-8000-000000000001",
    seed: "first_slice:test-player:00000000-0000-4000-8000-000000000002",
    player: {
      id: "player-test",
      displayName: "Draxos",
      level: 28,
      weaponId: "varinha_cinzas",
      weaponLevel: 8,
      weaponQualityTier: 1,
      spellIds: ["descarga_nervosa", "marca_brasa", "coagulo_negro"],
      spellLevels: { descarga_nervosa: 20, marca_brasa: 20, coagulo_negro: 20 },
      passiveId: "sangue_obediente",
      passiveLevel: 20,
      petId: "medusa_mare_fria",
      petLevel: 20,
    },
    opponent: {
      id: "bot-summoner-test",
      displayName: "Invocador Ossario",
      level: 28,
      weaponId: "cajado_ossario",
      weaponLevel: 8,
      weaponQualityTier: 1,
      spellIds: ["geada_ossos", "toxina_palida", "erguer_ossos"],
      spellLevels: { geada_ossos: 20, toxina_palida: 20, erguer_ossos: 20 },
      passiveId: "pedra_interna",
      passiveLevel: 20,
      petId: "cao_cinzas",
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
      weaponId: "idolo_pedra_viva",
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: ["coagulo_negro", "toxina_palida"],
      spellLevels: { coagulo_negro: 1, toxina_palida: 1 },
      passiveId: "mente_fria",
      passiveLevel: 40,
    },
    opponent: {
      id: "bot-defensive",
      displayName: "Defensor de Cinzas",
      level: 40,
      weaponId: "idolo_pedra_viva",
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: ["coagulo_negro", "toxina_palida"],
      spellLevels: { coagulo_negro: 1, toxina_palida: 1 },
      passiveId: "mente_fria",
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

Deno.test("first-slice simulator uses one health potion and emits five healing ticks", () => {
  const result = simulateFirstSliceBattle({
    battleId: "00000000-0000-4000-8000-000000000005",
    seed: "first_slice:potion:00000000-0000-4000-8000-000000000006",
    player: {
      id: "player-potion",
      displayName: "Draxos",
      level: 20,
      weaponId: "varinha_cinzas",
      weaponLevel: 3,
      weaponQualityTier: 0,
      spellIds: ["coagulo_negro"],
      spellLevels: { coagulo_negro: 8 },
      potionSlot: {
        slotIndex: 1,
        itemId: "pocao_vida",
        quantity: 2,
        behavior: {
          enabled: true,
          hp: { mode: "below", percent: 100 },
          mana: { mode: "ignore", percent: 0 },
        },
      },
    },
    opponent: {
      id: "bot-potion-test",
      displayName: "Atacante de Teste",
      level: 20,
      weaponId: "athame_hematico",
      weaponLevel: 10,
      weaponQualityTier: 1,
      spellIds: ["incisao_ritual"],
      spellLevels: { incisao_ritual: 10 },
    },
  });

  const consumableEvents = result.battleLog.events.filter((event) =>
    event.type === "consumable_use" && event.item_id === "pocao_vida"
  );
  const potionHeals = result.battleLog.events.filter((event) =>
    event.type === "heal" && event.item_id === "pocao_vida"
  );

  assertEq(consumableEvents.length, 1, "potion should be used once");
  assertEq(potionHeals.length, 5, "potion should heal in five ticks");
  assertEq(result.consumables.used.length, 1, "simulation should report one consumed item");
  assertEq(result.consumables.used[0].quantity, 1, "simulation should consume one potion");
  assert(
    potionHeals.every((event) => Number(event.hp_after) <= Number(event.max_hp)),
    "potion heal should not overheal beyond max HP",
  );
});

Deno.test("first-slice simulator supports focus potion mana restore", () => {
  const result = simulateFirstSliceBattle({
    battleId: "00000000-0000-4000-8000-000000000015",
    seed: "first_slice:focus_potion:00000000-0000-4000-8000-000000000016",
    player: {
      id: "player-focus-potion",
      displayName: "Draxos",
      level: 20,
      weaponId: "varinha_cinzas",
      weaponLevel: 3,
      weaponQualityTier: 0,
      spellIds: ["coagulo_negro"],
      spellLevels: { coagulo_negro: 8 },
      potionSlot: {
        slotIndex: 1,
        itemId: "pocao_foco",
        quantity: 2,
        behavior: {
          enabled: true,
          hp: { mode: "below", percent: 100 },
          mana: { mode: "ignore", percent: 0 },
        },
      },
    },
    opponent: {
      id: "bot-focus-potion-test",
      displayName: "Atacante de Teste",
      level: 20,
      weaponId: "athame_hematico",
      weaponLevel: 10,
      weaponQualityTier: 1,
      spellIds: ["incisao_ritual"],
      spellLevels: { incisao_ritual: 10 },
    },
  });

  assert(
    hasEvent(result.battleLog.events, "potion_mana_restore"),
    "focus potion should restore mana",
  );
  assertEq(result.consumables.used.length, 1, "simulation should report one consumed item");
  assertEq(result.consumables.used[0].item_id, "pocao_foco", "focus potion should be consumed");
});

Deno.test("first-slice simulator supports resguardo potion barrier", () => {
  const result = simulateFirstSliceBattle({
    battleId: "00000000-0000-4000-8000-000000000017",
    seed: "first_slice:resguardo_potion:00000000-0000-4000-8000-000000000018",
    player: {
      id: "player-resguardo-potion",
      displayName: "Draxos",
      level: 20,
      weaponId: "varinha_cinzas",
      weaponLevel: 3,
      weaponQualityTier: 0,
      spellIds: ["coagulo_negro"],
      spellLevels: { coagulo_negro: 8 },
      potionSlot: {
        slotIndex: 1,
        itemId: "pocao_resguardo",
        quantity: 2,
        behavior: {
          enabled: true,
          hp: { mode: "below", percent: 100 },
          mana: { mode: "ignore", percent: 0 },
        },
      },
    },
    opponent: {
      id: "bot-resguardo-potion-test",
      displayName: "Atacante de Teste",
      level: 20,
      weaponId: "athame_hematico",
      weaponLevel: 10,
      weaponQualityTier: 1,
      spellIds: ["incisao_ritual"],
      spellLevels: { incisao_ritual: 10 },
    },
  });

  assert(
    hasEvent(result.battleLog.events, "potion_barrier_gain"),
    "resguardo potion should grant barrier",
  );
  assertEq(result.consumables.used.length, 1, "simulation should report one consumed item");
  assertEq(result.consumables.used[0].item_id, "pocao_resguardo", "resguardo potion should be consumed");
});

Deno.test("spell behavior disables configured spell while missing behavior keeps baseline", () => {
  const baseInput: BattleSimulationInput = {
    battleId: "00000000-0000-4000-8000-000000000007",
    seed: "first_slice:spell_behavior:00000000-0000-4000-8000-000000000008",
    player: {
      id: "player-spell-behavior",
      displayName: "Draxos",
      level: 18,
      weaponId: "varinha_cinzas",
      weaponLevel: 2,
      weaponQualityTier: 0,
      spellIds: ["sussurro_medo"],
      spellLevels: { sussurro_medo: 12 },
    },
    opponent: {
      id: "bot-spell-behavior",
      displayName: "Alvo de Teste",
      level: 18,
      weaponId: "varinha_cinzas",
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: [],
      spellLevels: {},
    },
  };

  const baseline = simulateFirstSliceBattle(baseInput);
  const disabled = simulateFirstSliceBattle({
    ...baseInput,
    player: {
      ...baseInput.player,
      spellBehaviors: {
        sussurro_medo: {
          enabled: false,
          hp: { mode: "ignore", percent: 0 },
          mana: { mode: "ignore", percent: 0 },
        },
      },
    },
  });

  assert(
    baseline.battleLog.events.some((event) =>
      event.type === "spell_cast" && event.source === "player" &&
      event.spell_id === "sussurro_medo"
    ),
    "spell without behavior should keep baseline casting",
  );
  assert(
    !disabled.battleLog.events.some((event) =>
      event.type === "spell_cast" && event.source === "player" &&
      event.spell_id === "sussurro_medo"
    ),
    "disabled spell should not be cast",
  );
});

Deno.test("first-slice simulator applies Arena temporary stat modifiers directly", () => {
  const baseInput: BattleSimulationInput = {
    battleId: "00000000-0000-4000-8000-000000000019",
    seed: "first_slice:arena_buffs:00000000-0000-4000-8000-000000000020",
    player: {
      id: "player-arena-buffs",
      displayName: "Draxos",
      level: 18,
      weaponId: "varinha_cinzas",
      weaponLevel: 2,
      weaponQualityTier: 0,
      spellIds: ["descarga_nervosa"],
      spellLevels: { descarga_nervosa: 12 },
    },
    opponent: {
      id: "bot-arena-buffs",
      displayName: "Alvo de Teste",
      level: 18,
      weaponId: "varinha_cinzas",
      weaponLevel: 1,
      weaponQualityTier: 0,
      spellIds: [],
      spellLevels: {},
    },
  };

  const baseline = simulateFirstSliceBattle(baseInput);
  const boosted = simulateFirstSliceBattle({
    ...baseInput,
    player: {
      ...baseInput.player,
      statModifiers: {
        maxHpPercent: 4,
        maxManaPercent: 4,
        hpRegenPercent: 4,
        manaRegenPercent: 4,
        damageBonusPercent: 4,
        damageReductionPercent: 4,
        cooldownReductionPercent: 3,
        statusDurationPercent: 4,
      },
    },
  });

  const baselineStart = battleStartEvent(baseline.battleLog.events);
  const boostedStart = battleStartEvent(boosted.battleLog.events);
  assert(
    Number(boostedStart.player_max_hp) > Number(baselineStart.player_max_hp),
    "max HP buff should increase the next duel HP pool",
  );
  assert(
    Number(boostedStart.player_max_mana) >
      Number(baselineStart.player_max_mana),
    "max mana buff should increase the next duel mana pool",
  );
  assertEq(
    JSON.stringify(boostedStart.player_stat_modifiers),
    JSON.stringify({
      maxHpPercent: 4,
      maxManaPercent: 4,
      hpRegenPercent: 4,
      manaRegenPercent: 4,
      damageBonusPercent: 4,
      damageReductionPercent: 4,
      cooldownReductionPercent: 3,
      statusDurationPercent: 4,
    }),
    "battle_start should expose the applied temporary Arena modifiers",
  );

  const baselineParticipant = baseline.battleLog.participants.player;
  const boostedParticipant = boosted.battleLog.participants.player;
  assert(
    boostedParticipant.max_hp > baselineParticipant.max_hp,
    "participant max_hp should expose the buffed initial HP pool",
  );
  assertEq(
    boostedParticipant.hp,
    boostedParticipant.max_hp,
    "participant hp should start full after the Arena per-duel HP reset",
  );
  assertEq(
    boostedParticipant.max_hp,
    Number(boostedStart.player_max_hp),
    "participant max_hp should match battle_start player_max_hp",
  );
  assertEq(
    boostedParticipant.max_mana,
    Number(boostedStart.player_max_mana),
    "participant max_mana should match battle_start player_max_mana",
  );
  assertEq(
    JSON.stringify(boostedParticipant.stat_modifiers),
    JSON.stringify(boostedStart.player_stat_modifiers),
    "participant stat_modifiers should match battle_start player_stat_modifiers",
  );
});

function hasEvent(events: Array<{ type: string }>, type: string): boolean {
  return events.some((event) => event.type === type);
}

function battleStartEvent(
  events: Array<Record<string, unknown>>,
): Record<string, unknown> {
  const event = events.find((item) => item.type === "battle_start");
  if (event === undefined) {
    throw new Error("battle_start event should exist");
  }
  return event;
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
