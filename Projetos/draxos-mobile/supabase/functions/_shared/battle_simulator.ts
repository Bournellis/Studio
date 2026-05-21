export type BattleSideId = "player" | "opponent";

type DamageType =
  | "magico"
  | "choque"
  | "fogo"
  | "veneno"
  | "gelo"
  | "morte"
  | "sangramento"
  | "none";

type DamageCategory = "weapon" | "spell" | "dot" | "pet" | "summon" | "system";

export interface CombatantBuild {
  id: string;
  displayName: string;
  level: number;
  weaponLevel: number;
  weaponQualityTier: number;
  spellIds: string[];
  spellLevels: Record<string, number>;
  passiveId?: string;
  passiveLevel?: number;
  petId?: string;
  petLevel?: number;
}

export interface BattleSimulationInput {
  battleId: string;
  seed: string;
  player: CombatantBuild;
  opponent: CombatantBuild;
}

export interface BattleSimulationResult {
  battleLog: {
    schema_version: "battle_log_v1";
    battle_id: string;
    seed: string;
    mode: "FIRST_SLICE_SIM";
    duration: number;
    participants: {
      player: { id: string; display_name: string };
      opponent: { id: string; display_name: string; is_bot: true };
    };
    result: {
      winner: BattleSideId;
      reason: string;
    };
    events: BattleEvent[];
  };
  reward: {
    type: "FIRST_SLICE_SIM";
    reward_id: "first_slice_battle_win" | "first_slice_battle_loss";
    resources: Record<string, number>;
  };
}

export type BattleEvent = Record<string, unknown> & {
  t: number;
  seq: number;
  type: string;
  source: string;
  target: string;
};

interface RuntimeCombatant {
  side: BattleSideId;
  build: CombatantBuild;
  hp: number;
  maxHp: number;
  hpRegen: number;
  barrier: number;
  mana: number;
  maxMana: number;
  manaRegen: number;
  damageBonus: number;
  damageReduction: number;
  lifesteal: number;
  cooldownMultiplier: number;
  weaponDamage: number;
  nextWeaponAt: number;
  attackCount: number;
  spellCooldowns: Record<string, number>;
  emittedCooldownReady: Record<string, boolean>;
  petCooldown: number;
  summons: RuntimeSummon[];
  dots: RuntimeDot[];
  statuses: RuntimeStatus[];
}

interface RuntimeSummon {
  id: string;
  owner: BattleSideId;
  hp: number;
  dps: number;
  damageType: DamageType;
  expiresAt: number;
  nextAttackAt: number;
}

interface RuntimeDot {
  id: string;
  source: string;
  damageType: DamageType;
  tickDamage: number;
  stacks: number;
  expiresAt: number;
  nextTickAt: number;
}

interface RuntimeStatus {
  id: string;
  source: string;
  stacks: number;
  expiresAt: number;
  vulnerabilityPerStack?: number;
  slowPerStack?: number;
  resistanceBonus?: number;
}

interface SpellDefinition {
  id: string;
  damageType: DamageType;
  manaCost: number;
  cooldown: number;
  target: "direct" | "area" | "player" | "self";
  baseDamage: number;
  damagePerLevel: number;
  summonId?: string;
  barrierBase?: number;
  barrierPerLevel?: number;
  resistance?: { amount: number; duration: number };
  dot?: { statusId: string; tickDamage: number; duration: number };
  status?: { statusId: string; stacks: number; duration: number };
}

interface DamageResult {
  rawDamage: number;
  mitigatedDamage: number;
  hpDamage: number;
  absorbed: number;
  resistancePercent: number;
}

interface PetDefinition {
  damageType: DamageType;
  baseDamage: number;
  damagePerLevel: number;
  cadence: number;
}

interface PassiveStats {
  manaRegenBonus: number;
  damageBonus: number;
  damageReduction: number;
  startingBarrier: number;
  lifesteal: number;
  cooldownReduction: number;
}

const MAX_DURATION = 36;
const TICK_SECONDS = 0.5;
const DOT_TICK_SECONDS = 1;
const COMBAT_PACE_HP_MULTIPLIER_BASE = 4.85;
const COMBAT_PACE_HP_MULTIPLIER_PER_LEVEL = 0.121;

const SPELLS: Record<string, SpellDefinition> = {
  raio_cosmico: {
    id: "raio_cosmico",
    damageType: "magico",
    manaCost: 8,
    cooldown: 4,
    target: "direct",
    baseDamage: 18,
    damagePerLevel: 2.4,
  },
  raio: {
    id: "raio",
    damageType: "choque",
    manaCost: 12,
    cooldown: 6,
    target: "player",
    baseDamage: 16,
    damagePerLevel: 2.1,
    status: { statusId: "choque_marcado", stacks: 1, duration: 6 },
  },
  acender: {
    id: "acender",
    damageType: "fogo",
    manaCost: 14,
    cooldown: 7,
    target: "area",
    baseDamage: 12,
    damagePerLevel: 1.7,
    dot: { statusId: "queimando", tickDamage: 3, duration: 5 },
  },
  envenenar: {
    id: "envenenar",
    damageType: "veneno",
    manaCost: 10,
    cooldown: 8,
    target: "player",
    baseDamage: 6,
    damagePerLevel: 0.8,
    dot: { statusId: "envenenado", tickDamage: 4, duration: 6 },
  },
  congelar: {
    id: "congelar",
    damageType: "gelo",
    manaCost: 13,
    cooldown: 7.5,
    target: "area",
    baseDamage: 11,
    damagePerLevel: 1.6,
    status: { statusId: "lento", stacks: 1, duration: 5 },
  },
  odio: {
    id: "odio",
    damageType: "morte",
    manaCost: 22,
    cooldown: 9,
    target: "player",
    baseDamage: 34,
    damagePerLevel: 3.2,
  },
  dilacerar: {
    id: "dilacerar",
    damageType: "sangramento",
    manaCost: 18,
    cooldown: 7.5,
    target: "direct",
    baseDamage: 20,
    damagePerLevel: 2.2,
    dot: { statusId: "sangrando", tickDamage: 5, duration: 5 },
  },
  fortificar: {
    id: "fortificar",
    damageType: "none",
    manaCost: 16,
    cooldown: 12,
    target: "self",
    baseDamage: 0,
    damagePerLevel: 0,
    barrierBase: 30,
    barrierPerLevel: 3,
    resistance: { amount: 0.08, duration: 8 },
  },
  invocar_demonio: {
    id: "invocar_demonio",
    damageType: "fogo",
    manaCost: 20,
    cooldown: 10,
    target: "self",
    baseDamage: 0,
    damagePerLevel: 0,
    summonId: "demonio",
  },
  animar_morto: {
    id: "animar_morto",
    damageType: "morte",
    manaCost: 20,
    cooldown: 10,
    target: "self",
    baseDamage: 0,
    damagePerLevel: 0,
    summonId: "esqueleto",
  },
};

const PETS: Record<string, PetDefinition> = {
  familiar_cinzento: {
    damageType: "magico",
    baseDamage: 8,
    damagePerLevel: 1.2,
    cadence: 4,
  },
  brasido: {
    damageType: "fogo",
    baseDamage: 7,
    damagePerLevel: 1.1,
    cadence: 3.5,
  },
  gelum: {
    damageType: "gelo",
    baseDamage: 10,
    damagePerLevel: 1.3,
    cadence: 4.8,
  },
};

const SUMMONS: Record<string, { hp: number; dps: number; damageType: DamageType }> = {
  esqueleto: { hp: 60, dps: 6, damageType: "morte" },
  morto_vivo: { hp: 40, dps: 5, damageType: "morte" },
  demonio: { hp: 50, dps: 7, damageType: "fogo" },
};

export function simulateFirstSliceBattle(input: BattleSimulationInput): BattleSimulationResult {
  const events: BattleEvent[] = [];
  let seq = 1;
  const player = createCombatant("player", input.player);
  const opponent = createCombatant("opponent", input.opponent);
  const nextSeq = () => seq++;

  events.push(baseEvent(0, nextSeq(), "battle_start", "system", "none"));
  emitPassiveStart(0, player, events, nextSeq);
  emitPassiveStart(0, opponent, events, nextSeq);

  for (let time = TICK_SECONDS; time <= MAX_DURATION; time += TICK_SECONDS) {
    expireStatuses(time, player, events, nextSeq);
    expireStatuses(time, opponent, events, nextSeq);
    processDots(time, player, events, nextSeq);
    processDots(time, opponent, events, nextSeq);
    regenerate(player);
    regenerate(opponent);
    processCooldownReady(time, player, events, nextSeq);
    processCooldownReady(time, opponent, events, nextSeq);
    processSummons(time, player, opponent, events, nextSeq);
    processSummons(time, opponent, player, events, nextSeq);
    processWeapon(time, player, opponent, events, nextSeq);
    processWeapon(time, opponent, player, events, nextSeq);
    processSpell(time, player, opponent, events, nextSeq);
    processSpell(time, opponent, player, events, nextSeq);
    processPet(time, player, opponent, events, nextSeq);
    processPet(time, opponent, player, events, nextSeq);

    if (player.hp <= 0 || opponent.hp <= 0) {
      break;
    }

    if (time >= 30) {
      const antiStallDamage = antiStallPercent(time);
      if (antiStallDamage > 0) {
        applyDamage(
          time,
          player,
          Math.ceil(player.maxHp * antiStallDamage),
          "none",
          "system",
          "system",
          events,
          nextSeq,
        );
        applyDamage(
          time,
          opponent,
          Math.ceil(opponent.maxHp * antiStallDamage),
          "none",
          "system",
          "system",
          events,
          nextSeq,
        );
        events.push({
          ...baseEvent(time, nextSeq(), "anti_stall", "system", "none"),
          player_hp_after: Math.max(0, player.hp),
          opponent_hp_after: Math.max(0, opponent.hp),
        });
      }
    }
  }

  const winner: BattleSideId = player.hp > opponent.hp ? "player" : "opponent";
  const reason = player.hp <= 0 || opponent.hp <= 0 ? "combatant_defeated" : "duration_limit";
  const reward = winner === "player" ? winReward() : lossReward();
  const duration = events.length > 0 ? Number(events[events.length - 1].t.toFixed(1)) : 0;

  events.push({
    ...baseEvent(duration + 0.1, nextSeq(), "reward_preview", "system", "player"),
    reward_type: reward.type,
    reward_id: reward.reward_id,
    resources: reward.resources,
  });
  events.push({
    ...baseEvent(duration + 0.2, nextSeq(), "battle_result", "system", "none"),
    winner,
    reason,
  });

  return {
    battleLog: {
      schema_version: "battle_log_v1",
      battle_id: input.battleId,
      seed: input.seed,
      mode: "FIRST_SLICE_SIM",
      duration: Number((duration + 0.2).toFixed(1)),
      participants: {
        player: { id: input.player.id, display_name: input.player.displayName },
        opponent: { id: input.opponent.id, display_name: input.opponent.displayName, is_bot: true },
      },
      result: { winner, reason },
      events,
    },
    reward,
  };
}

function createCombatant(side: BattleSideId, build: CombatantBuild): RuntimeCombatant {
  const level = clamp(build.level, 1, 40);
  const maxHp = maxHpForLevel(level);
  const maxMana = Math.round(20 + 1.5 * (level - 1));
  const passive = passiveStats(build.passiveId, build.passiveLevel);
  return {
    side,
    build,
    hp: maxHp,
    maxHp,
    hpRegen: hpRegenForLevel(level),
    barrier: passive.startingBarrier,
    mana: maxMana,
    maxMana,
    manaRegen: (2 + 0.05 * (level - 1)) * (1 + passive.manaRegenBonus),
    damageBonus: passive.damageBonus,
    damageReduction: passive.damageReduction,
    lifesteal: passive.lifesteal,
    cooldownMultiplier: 1 - passive.cooldownReduction,
    weaponDamage: weaponDamage(build),
    nextWeaponAt: 0.5,
    attackCount: 0,
    spellCooldowns: {},
    emittedCooldownReady: {},
    petCooldown: 3,
    summons: [],
    dots: [],
    statuses: [],
  };
}

function emitPassiveStart(
  time: number,
  combatant: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const passiveId = combatant.build.passiveId ?? "";
  if (passiveId === "") {
    return;
  }
  const passiveLevel = clamp(combatant.build.passiveLevel ?? 1, 1, 40);
  events.push({
    ...baseEvent(time, nextSeq(), "passive_apply", combatant.side, combatant.side),
    passive_id: passiveId,
    passive_level: passiveLevel,
  });
  if (combatant.barrier > 0) {
    events.push({
      ...baseEvent(time, nextSeq(), "barrier_gain", combatant.side, combatant.side),
      passive_id: passiveId,
      amount: combatant.barrier,
      barrier_after: combatant.barrier,
      hp_after: combatant.hp,
    });
  }
}

function regenerate(combatant: RuntimeCombatant): void {
  const slow = slowMultiplier(combatant);
  if (combatant.hp > 0) {
    combatant.hp = Math.min(
      combatant.maxHp,
      combatant.hp + combatant.hpRegen * slow * TICK_SECONDS,
    );
  }
  combatant.mana = Math.min(
    combatant.maxMana,
    combatant.mana + combatant.manaRegen * slow * TICK_SECONDS,
  );
}

function processCooldownReady(
  time: number,
  actor: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  for (const [spellId, readyAt] of Object.entries(actor.spellCooldowns)) {
    if (!actor.emittedCooldownReady[spellId] && time + 0.0001 >= readyAt) {
      actor.emittedCooldownReady[spellId] = true;
      events.push({
        ...baseEvent(time, nextSeq(), "cooldown_ready", actor.side, actor.side),
        spell_id: spellId,
      });
    }
  }
}

function processWeapon(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (time + 0.0001 < actor.nextWeaponAt || actor.hp <= 0 || target.hp <= 0) {
    return;
  }

  actor.attackCount += 1;
  const multiplier = actor.attackCount % 4 === 0 ? 3 : 1;
  const rawDamage = Math.ceil(actor.weaponDamage * multiplier * (1 + actor.damageBonus));
  const result = applyDamage(
    time,
    target,
    rawDamage,
    "magico",
    actor.side,
    "weapon",
    events,
    nextSeq,
  );
  events.push({
    ...baseEvent(time, nextSeq(), "weapon_attack", actor.side, target.side),
    raw_damage: result.rawDamage,
    damage: result.hpDamage,
    absorbed: result.absorbed,
    damage_type: "magico",
    resistance_percent: result.resistancePercent,
    hp_after: Math.max(0, target.hp),
    barrier_after: Math.max(0, target.barrier),
    special: multiplier > 1,
  });
  processLifesteal(time, actor, result.hpDamage, events, nextSeq);
  actor.nextWeaponAt = time + weaponInterval(actor);
}

function processSpell(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (actor.hp <= 0 || target.hp <= 0) {
    return;
  }
  const spellId = actor.build.spellIds.find((candidate) => {
    const spell = SPELLS[candidate];
    return spell !== undefined &&
      (actor.spellCooldowns[candidate] ?? 0) <= time &&
      actor.mana >= spell.manaCost;
  });
  if (spellId === undefined) {
    return;
  }
  const spell = SPELLS[spellId];
  const spellLevel = clamp(actor.build.spellLevels[spellId] ?? actor.build.level, 1, 40);
  actor.mana -= spell.manaCost;
  const readyAt = time + spell.cooldown * actor.cooldownMultiplier * cooldownSlowMultiplier(actor);
  actor.spellCooldowns[spellId] = readyAt;
  actor.emittedCooldownReady[spellId] = false;
  events.push({
    ...baseEvent(time, nextSeq(), "mana_change", actor.side, actor.side),
    mana_after: Math.round(actor.mana),
  });
  events.push({
    ...baseEvent(time, nextSeq(), "cooldown_start", actor.side, actor.side),
    spell_id: spellId,
    ready_at: Number(readyAt.toFixed(1)),
  });

  if (spell.summonId !== undefined) {
    const summon = createSummon(spell.summonId, actor.side, spellLevel, time);
    actor.summons = actor.summons.filter((existing) => existing.id !== summon.id);
    actor.summons.push(summon);
    events.push({
      ...baseEvent(time, nextSeq(), "summon_spawn", actor.side, summon.id),
      spell_id: spellId,
      hp: summon.hp,
      damage_type: summon.damageType,
      expires_at: Number(summon.expiresAt.toFixed(1)),
    });
    return;
  }

  if (spell.barrierBase !== undefined) {
    const amount = Math.round(spell.barrierBase + (spell.barrierPerLevel ?? 0) * spellLevel);
    actor.barrier += amount;
    events.push({
      ...baseEvent(time, nextSeq(), "barrier_gain", actor.side, actor.side),
      spell_id: spellId,
      amount,
      barrier_after: actor.barrier,
      hp_after: actor.hp,
    });
  }

  if (spell.resistance !== undefined) {
    applyResistance(time, actor, spell, spellLevel, events, nextSeq);
  }

  if (spell.baseDamage > 0) {
    const rawDamage = Math.ceil(
      (spell.baseDamage + spell.damagePerLevel * Math.max(0, spellLevel - 1)) *
        (1 + actor.damageBonus),
    );
    const result = applyDamage(
      time,
      target,
      rawDamage,
      spell.damageType,
      actor.side,
      "spell",
      events,
      nextSeq,
    );
    events.push({
      ...baseEvent(time, nextSeq(), "spell_cast", actor.side, target.side),
      spell_id: spellId,
      raw_damage: result.rawDamage,
      damage: result.hpDamage,
      absorbed: result.absorbed,
      damage_type: spell.damageType,
      resistance_percent: result.resistancePercent,
      hp_after: Math.max(0, target.hp),
      barrier_after: Math.max(0, target.barrier),
    });
    processLifesteal(time, actor, result.hpDamage, events, nextSeq);
  }

  if (spell.dot !== undefined && target.hp > 0) {
    applyDot(time, actor, target, spell, spellLevel, events, nextSeq);
  }

  if (spell.status !== undefined && target.hp > 0) {
    applyStatus(time, actor, target, spell, events, nextSeq);
  }
}

function processPet(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const petId = actor.build.petId ?? "";
  const pet = PETS[petId];
  if (pet === undefined || actor.build.petLevel === undefined || actor.hp <= 0 || target.hp <= 0) {
    return;
  }
  if (time + 0.0001 < actor.petCooldown) {
    return;
  }
  const petLevel = clamp(actor.build.petLevel, 1, 40);
  const rawDamage = Math.ceil(pet.baseDamage + pet.damagePerLevel * Math.max(0, petLevel - 1));
  const result = applyDamage(
    time,
    target,
    rawDamage,
    pet.damageType,
    actor.side,
    "pet",
    events,
    nextSeq,
  );
  events.push({
    ...baseEvent(time, nextSeq(), "pet_attack", actor.side, target.side),
    pet_id: petId,
    raw_damage: result.rawDamage,
    damage: result.hpDamage,
    absorbed: result.absorbed,
    damage_type: pet.damageType,
    resistance_percent: result.resistancePercent,
    hp_after: Math.max(0, target.hp),
    barrier_after: Math.max(0, target.barrier),
  });
  processLifesteal(time, actor, result.hpDamage, events, nextSeq);
  actor.petCooldown = time + pet.cadence;
}

function processSummons(
  time: number,
  owner: RuntimeCombatant,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const active: RuntimeSummon[] = [];
  for (const summon of owner.summons) {
    if (time >= summon.expiresAt || summon.hp <= 0) {
      events.push(baseEvent(time, nextSeq(), "summon_expire", summon.id, "none"));
      continue;
    }
    if (time + 0.0001 >= summon.nextAttackAt && target.hp > 0) {
      const rawDamage = Math.ceil(summon.dps);
      const result = applyDamage(
        time,
        target,
        rawDamage,
        summon.damageType,
        summon.id,
        "summon",
        events,
        nextSeq,
      );
      summon.nextAttackAt = time + 1.5;
      events.push({
        ...baseEvent(time, nextSeq(), "summon_attack", summon.id, target.side),
        raw_damage: result.rawDamage,
        damage: result.hpDamage,
        absorbed: result.absorbed,
        damage_type: summon.damageType,
        resistance_percent: result.resistancePercent,
        hp_after: Math.max(0, target.hp),
        barrier_after: Math.max(0, target.barrier),
      });
    }
    active.push(summon);
  }
  owner.summons = active;
}

function processDots(
  time: number,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const active: RuntimeDot[] = [];
  for (const dot of target.dots) {
    if (time > dot.expiresAt || target.hp <= 0) {
      events.push({
        ...baseEvent(time, nextSeq(), "status_expire", dot.source, target.side),
        status_id: dot.id,
      });
      continue;
    }

    if (time + 0.0001 >= dot.nextTickAt) {
      const rawDamage = Math.ceil(dot.tickDamage * dot.stacks);
      const result = applyDamage(
        time,
        target,
        rawDamage,
        dot.damageType,
        dot.source,
        "dot",
        events,
        nextSeq,
      );
      dot.nextTickAt += DOT_TICK_SECONDS;
      events.push({
        ...baseEvent(time, nextSeq(), "dot_tick", dot.source, target.side),
        status_id: dot.id,
        stacks: dot.stacks,
        raw_damage: result.rawDamage,
        damage: result.hpDamage,
        absorbed: result.absorbed,
        damage_type: dot.damageType,
        resistance_percent: result.resistancePercent,
        hp_after: Math.max(0, target.hp),
        barrier_after: Math.max(0, target.barrier),
      });
    }

    active.push(dot);
  }
  target.dots = active;
}

function expireStatuses(
  time: number,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const active: RuntimeStatus[] = [];
  for (const status of target.statuses) {
    if (time > status.expiresAt) {
      events.push({
        ...baseEvent(time, nextSeq(), "status_expire", status.source, target.side),
        status_id: status.id,
      });
      continue;
    }
    active.push(status);
  }
  target.statuses = active;
}

function applyDot(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  spell: SpellDefinition,
  spellLevel: number,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (spell.dot === undefined) {
    return;
  }

  const existing = target.dots.find((dot) =>
    dot.id === spell.dot?.statusId && dot.source === actor.side
  );
  const tickDamage = spell.dot.tickDamage + Math.max(0, spellLevel - 1) * 0.35;
  if (existing !== undefined) {
    existing.stacks = clamp(existing.stacks + 1, 1, 5);
    existing.tickDamage = Math.max(existing.tickDamage, tickDamage);
    existing.expiresAt = time + spell.dot.duration;
    existing.nextTickAt = Math.min(existing.nextTickAt, time + DOT_TICK_SECONDS);
    events.push({
      ...baseEvent(time, nextSeq(), "dot_apply", actor.side, target.side),
      spell_id: spell.id,
      status_id: existing.id,
      stacks: existing.stacks,
      tick_damage: Number(existing.tickDamage.toFixed(2)),
      duration: spell.dot.duration,
    });
    return;
  }

  target.dots.push({
    id: spell.dot.statusId,
    source: actor.side,
    damageType: spell.damageType,
    tickDamage,
    stacks: 1,
    expiresAt: time + spell.dot.duration,
    nextTickAt: time + DOT_TICK_SECONDS,
  });
  events.push({
    ...baseEvent(time, nextSeq(), "dot_apply", actor.side, target.side),
    spell_id: spell.id,
    status_id: spell.dot.statusId,
    stacks: 1,
    tick_damage: Number(tickDamage.toFixed(2)),
    duration: spell.dot.duration,
  });
}

function applyStatus(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  spell: SpellDefinition,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (spell.status === undefined) {
    return;
  }

  const status = createStatus(
    spell.status.statusId,
    actor.side,
    spell.status.stacks,
    time + spell.status.duration,
  );
  const existing = target.statuses.find((current) =>
    current.id === status.id && current.source === status.source
  );
  if (existing !== undefined) {
    existing.stacks = clamp(existing.stacks + status.stacks, 1, 5);
    existing.expiresAt = status.expiresAt;
    events.push({
      ...baseEvent(time, nextSeq(), "status_apply", actor.side, target.side),
      spell_id: spell.id,
      status_id: existing.id,
      stacks: existing.stacks,
      duration: spell.status.duration,
    });
    return;
  }

  target.statuses.push(status);
  events.push({
    ...baseEvent(time, nextSeq(), "status_apply", actor.side, target.side),
    spell_id: spell.id,
    status_id: status.id,
    stacks: status.stacks,
    duration: spell.status.duration,
  });
}

function applyResistance(
  time: number,
  actor: RuntimeCombatant,
  spell: SpellDefinition,
  spellLevel: number,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (spell.resistance === undefined) {
    return;
  }

  const amount = spell.resistance.amount + Math.max(0, spellLevel - 1) * 0.001;
  const status = createResistanceStatus(actor.side, amount, time + spell.resistance.duration);
  const existing = actor.statuses.find((current) =>
    current.id === status.id && current.source === status.source
  );
  if (existing !== undefined) {
    existing.resistanceBonus = Math.max(existing.resistanceBonus ?? 0, status.resistanceBonus ?? 0);
    existing.expiresAt = status.expiresAt;
  } else {
    actor.statuses.push(status);
  }

  events.push({
    ...baseEvent(time, nextSeq(), "resistance_apply", actor.side, actor.side),
    spell_id: spell.id,
    status_id: status.id,
    amount: Number(amount.toFixed(3)),
    duration: spell.resistance.duration,
  });
}

function applyDamage(
  time: number,
  target: RuntimeCombatant,
  rawDamage: number,
  damageType: DamageType,
  source: string,
  category: DamageCategory,
  events: BattleEvent[],
  nextSeq: () => number,
): DamageResult {
  const normalizedRaw = Math.max(0, Math.ceil(rawDamage));
  const vulnerability = targetVulnerability(target);
  const resistance = category === "system" ? 0 : totalDamageReduction(target, damageType);
  const mitigatedDamage = Math.max(
    0,
    Math.ceil(normalizedRaw * (1 + vulnerability) * (1 - resistance)),
  );
  const absorbed = Math.min(target.barrier, mitigatedDamage);
  if (absorbed > 0) {
    target.barrier -= absorbed;
    events.push({
      ...baseEvent(time, nextSeq(), "barrier_absorb", source, target.side),
      damage_type: damageType,
      amount: absorbed,
      barrier_after: Math.max(0, target.barrier),
    });
  }
  const hpDamage = Math.max(0, mitigatedDamage - absorbed);
  target.hp = Math.max(0, target.hp - hpDamage);
  return {
    rawDamage: normalizedRaw,
    mitigatedDamage,
    hpDamage,
    absorbed,
    resistancePercent: Number(resistance.toFixed(3)),
  };
}

function processLifesteal(
  time: number,
  actor: RuntimeCombatant,
  hpDamage: number,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (actor.lifesteal <= 0 || hpDamage <= 0 || actor.hp <= 0) {
    return;
  }

  const amount = Math.max(1, Math.floor(hpDamage * actor.lifesteal));
  const before = actor.hp;
  actor.hp = Math.min(actor.maxHp, actor.hp + amount);
  const healed = actor.hp - before;
  if (healed <= 0) {
    return;
  }

  events.push({
    ...baseEvent(time, nextSeq(), "heal", actor.side, actor.side),
    amount: healed,
    hp_after: actor.hp,
  });
}

function createSummon(
  id: string,
  owner: BattleSideId,
  spellLevel: number,
  time: number,
): RuntimeSummon {
  const definition = SUMMONS[id] ?? SUMMONS.esqueleto;
  return {
    id: `${owner}_${id}`,
    owner,
    hp: Math.round(definition.hp * (1 + 0.10 * (spellLevel - 1))),
    dps: definition.dps * (1 + 0.08 * (spellLevel - 1)),
    damageType: definition.damageType,
    expiresAt: time + 8,
    nextAttackAt: time + 0.5,
  };
}

function createStatus(
  id: string,
  source: string,
  stacks: number,
  expiresAt: number,
): RuntimeStatus {
  if (id === "choque_marcado") {
    return {
      id,
      source,
      stacks,
      expiresAt,
      vulnerabilityPerStack: 0.05,
    };
  }

  if (id === "lento") {
    return {
      id,
      source,
      stacks,
      expiresAt,
      slowPerStack: 0.15,
    };
  }

  return { id, source, stacks, expiresAt };
}

function createResistanceStatus(
  source: string,
  amount: number,
  expiresAt: number,
): RuntimeStatus {
  return {
    id: "fortificado",
    source,
    stacks: 1,
    expiresAt,
    resistanceBonus: amount,
  };
}

function passiveStats(passiveId: string | undefined, level: number | undefined): PassiveStats {
  const passiveLevel = clamp(level ?? 1, 1, 40);
  const scale = Math.max(0, passiveLevel - 1);
  const empty = {
    manaRegenBonus: 0,
    damageBonus: 0,
    damageReduction: 0,
    startingBarrier: 0,
    lifesteal: 0,
    cooldownReduction: 0,
  };

  switch (passiveId) {
    case "foco_astral":
      return { ...empty, manaRegenBonus: 0.04 + scale * 0.002 };
    case "forca":
      return { ...empty, damageBonus: 0.04 + scale * 0.002 };
    case "resistencia":
      return { ...empty, damageReduction: 0.03 + scale * 0.0015 };
    case "escudo":
      return { ...empty, startingBarrier: Math.round(12 + scale) };
    case "vampirismo":
      return { ...empty, lifesteal: 0.02 + scale * 0.001 };
    case "velocidade":
      return { ...empty, cooldownReduction: clampPercent(0.03 + scale * 0.001, 0, 0.25) };
    default:
      return empty;
  }
}

function totalDamageReduction(target: RuntimeCombatant, damageType: DamageType): number {
  const statusResistance = target.statuses.reduce(
    (total, status) => total + (status.resistanceBonus ?? 0),
    0,
  );
  const typeResistance = damageType === "none" ? 0 : target.damageReduction;
  return clampPercent(typeResistance + statusResistance, 0, 0.75);
}

function targetVulnerability(target: RuntimeCombatant): number {
  return clampPercent(
    target.statuses.reduce(
      (total, status) => total + (status.vulnerabilityPerStack ?? 0) * status.stacks,
      0,
    ),
    0,
    0.5,
  );
}

function slowMultiplier(target: RuntimeCombatant): number {
  const slow = target.statuses.reduce(
    (total, status) => total + (status.slowPerStack ?? 0) * status.stacks,
    0,
  );
  return 1 / (1 + clampPercent(slow, 0, 0.6));
}

function cooldownSlowMultiplier(target: RuntimeCombatant): number {
  const slow = target.statuses.reduce(
    (total, status) => total + (status.slowPerStack ?? 0) * status.stacks,
    0,
  );
  return 1 + clampPercent(slow, 0, 0.6);
}

function weaponInterval(actor: RuntimeCombatant): number {
  return 1 * cooldownSlowMultiplier(actor);
}

function weaponDamage(build: CombatantBuild): number {
  const qualityMultipliers = [1, 1.08, 1.18, 1.3, 1.45];
  const tier = clamp(build.weaponQualityTier, 0, qualityMultipliers.length - 1);
  return (15 + 1.8 * Math.max(0, build.weaponLevel - 1)) * qualityMultipliers[tier];
}

function maxHpForLevel(level: number): number {
  const normalizedLevel = clamp(level, 1, 40);
  const baseHp = 100 + 8 * (normalizedLevel - 1);
  const paceMultiplier = COMBAT_PACE_HP_MULTIPLIER_BASE +
    COMBAT_PACE_HP_MULTIPLIER_PER_LEVEL * (normalizedLevel - 1);
  return Math.round(baseHp * paceMultiplier);
}

function hpRegenForLevel(level: number): number {
  const normalizedLevel = clamp(level, 1, 40);
  return 1 + 0.08 * (normalizedLevel - 1);
}

function antiStallPercent(time: number): number {
  if (time >= 36) return 1;
  if (time >= 34) return 0.4;
  if (time >= 32) return 0.2;
  if (time >= 30) return 0.1;
  return 0;
}

function winReward(): BattleSimulationResult["reward"] {
  return {
    type: "FIRST_SLICE_SIM",
    reward_id: "first_slice_battle_win",
    resources: { xp: 50, almas: 4, energia: 2, sangue: 1, ossos: 0.2 },
  };
}

function lossReward(): BattleSimulationResult["reward"] {
  return {
    type: "FIRST_SLICE_SIM",
    reward_id: "first_slice_battle_loss",
    resources: { xp: 10, almas: 0.8, energia: 0.4, sangue: 0.2, ossos: 0.04 },
  };
}

function baseEvent(
  time: number,
  seq: number,
  type: string,
  source: string,
  target: string,
): BattleEvent {
  return { t: Number(time.toFixed(1)), seq, type, source, target };
}

function clamp(value: number, min: number, max: number): number {
  if (Number.isNaN(value)) return min;
  return Math.max(min, Math.min(max, Math.trunc(value)));
}

function clampPercent(value: number, min: number, max: number): number {
  if (Number.isNaN(value)) return min;
  return Math.max(min, Math.min(max, value));
}
