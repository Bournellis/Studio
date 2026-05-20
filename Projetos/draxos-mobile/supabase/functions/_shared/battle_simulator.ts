export type BattleSideId = "player" | "opponent";

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

type BattleEvent = Record<string, unknown> & {
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
  mana: number;
  maxMana: number;
  manaRegen: number;
  weaponDamage: number;
  nextWeaponAt: number;
  attackCount: number;
  spellCooldowns: Record<string, number>;
  petCooldown: number;
  summons: RuntimeSummon[];
}

interface RuntimeSummon {
  id: string;
  owner: BattleSideId;
  hp: number;
  dps: number;
  damageType: string;
  expiresAt: number;
  nextAttackAt: number;
}

interface SpellDefinition {
  id: string;
  damageType: string;
  manaCost: number;
  cooldown: number;
  target: "direct" | "area" | "player" | "self";
  baseDamage: number;
  damagePerLevel: number;
  summonId?: string;
  barrierBase?: number;
}

const MAX_DURATION = 36;
const TICK_SECONDS = 0.5;

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
  },
  acender: {
    id: "acender",
    damageType: "fogo",
    manaCost: 14,
    cooldown: 7,
    target: "area",
    baseDamage: 12,
    damagePerLevel: 1.7,
  },
  congelar: {
    id: "congelar",
    damageType: "gelo",
    manaCost: 13,
    cooldown: 7.5,
    target: "area",
    baseDamage: 11,
    damagePerLevel: 1.6,
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

const SUMMONS: Record<string, { hp: number; dps: number; damageType: string }> = {
  esqueleto: { hp: 60, dps: 6, damageType: "morte" },
  morto_vivo: { hp: 40, dps: 5, damageType: "morte" },
  demonio: { hp: 50, dps: 7, damageType: "fogo" },
};

export function simulateFirstSliceBattle(input: BattleSimulationInput): BattleSimulationResult {
  const events: BattleEvent[] = [];
  let seq = 1;
  const player = createCombatant("player", input.player);
  const opponent = createCombatant("opponent", input.opponent);

  events.push(baseEvent(0, seq++, "battle_start", "system", "none"));

  for (let time = TICK_SECONDS; time <= MAX_DURATION; time += TICK_SECONDS) {
    regenerate(player);
    regenerate(opponent);
    processSummons(time, player, opponent, events, () => seq++);
    processSummons(time, opponent, player, events, () => seq++);
    processWeapon(time, player, opponent, events, () => seq++);
    processWeapon(time, opponent, player, events, () => seq++);
    processSpell(time, player, opponent, events, () => seq++);
    processSpell(time, opponent, player, events, () => seq++);

    if (player.hp <= 0 || opponent.hp <= 0) {
      break;
    }

    if (time >= 30) {
      const antiStallDamage = antiStallPercent(time);
      if (antiStallDamage > 0) {
        applyDirectDamage(player, Math.ceil(player.maxHp * antiStallDamage), "system");
        applyDirectDamage(opponent, Math.ceil(opponent.maxHp * antiStallDamage), "system");
        events.push({
          ...baseEvent(time, seq++, "anti_stall", "system", "none"),
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
    ...baseEvent(duration + 0.1, seq++, "reward_preview", "system", "player"),
    reward_type: reward.type,
    reward_id: reward.reward_id,
  });
  events.push({
    ...baseEvent(duration + 0.2, seq++, "battle_result", "system", "none"),
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
  const maxHp = Math.round(100 + 8 * (level - 1));
  const maxMana = Math.round(20 + 1.5 * (level - 1));
  return {
    side,
    build,
    hp: maxHp,
    maxHp,
    mana: maxMana,
    maxMana,
    manaRegen: 2 + 0.05 * (level - 1),
    weaponDamage: weaponDamage(build),
    nextWeaponAt: 0.5,
    attackCount: 0,
    spellCooldowns: {},
    petCooldown: 3,
    summons: [],
  };
}

function regenerate(combatant: RuntimeCombatant): void {
  combatant.mana = Math.min(combatant.maxMana, combatant.mana + combatant.manaRegen * TICK_SECONDS);
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
  const damage = Math.ceil(actor.weaponDamage * multiplier);
  applyDirectDamage(target, damage, actor.side);
  events.push({
    ...baseEvent(time, nextSeq(), "weapon_attack", actor.side, target.side),
    damage,
    damage_type: "magico",
    hp_after: Math.max(0, target.hp),
    special: multiplier > 1,
  });
  actor.nextWeaponAt = time + 1;
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
    processPet(time, actor, target, events, nextSeq);
    return;
  }
  const spell = SPELLS[spellId];
  const spellLevel = clamp(actor.build.spellLevels[spellId] ?? actor.build.level, 1, 40);
  actor.mana -= spell.manaCost;
  actor.spellCooldowns[spellId] = time + spell.cooldown;
  events.push({
    ...baseEvent(time, nextSeq(), "mana_change", actor.side, actor.side),
    mana_after: Math.round(actor.mana),
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
    });
    return;
  }

  if (spell.barrierBase !== undefined) {
    const amount = Math.round(spell.barrierBase + spellLevel * 3);
    actor.hp = Math.min(actor.maxHp, actor.hp + amount);
    events.push({
      ...baseEvent(time, nextSeq(), "barrier_gain", actor.side, actor.side),
      spell_id: spellId,
      amount,
      hp_after: actor.hp,
    });
    return;
  }

  const damage = Math.ceil(spell.baseDamage + spell.damagePerLevel * Math.max(0, spellLevel - 1));
  applyDirectDamage(target, damage, actor.side);
  events.push({
    ...baseEvent(time, nextSeq(), "spell_cast", actor.side, target.side),
    spell_id: spellId,
    damage,
    damage_type: spell.damageType,
    hp_after: Math.max(0, target.hp),
  });
}

function processPet(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if ((actor.build.petId ?? "") === "" || actor.build.petLevel === undefined) {
    return;
  }
  if (time + 0.0001 < actor.petCooldown) {
    return;
  }
  const damage = Math.ceil(8 + actor.build.petLevel * 1.2);
  applyDirectDamage(target, damage, actor.side);
  events.push({
    ...baseEvent(time, nextSeq(), "pet_attack", actor.side, target.side),
    pet_id: actor.build.petId,
    damage,
    damage_type: "magico",
    hp_after: Math.max(0, target.hp),
  });
  actor.petCooldown = time + 4;
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
      const damage = Math.ceil(summon.dps);
      applyDirectDamage(target, damage, summon.id);
      summon.nextAttackAt = time + 1.5;
      events.push({
        ...baseEvent(time, nextSeq(), "summon_attack", summon.id, target.side),
        damage,
        damage_type: summon.damageType,
        hp_after: Math.max(0, target.hp),
      });
    }
    active.push(summon);
  }
  owner.summons = active;
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

function applyDirectDamage(target: RuntimeCombatant, damage: number, _source: string): void {
  target.hp = Math.max(0, target.hp - Math.max(0, damage));
}

function weaponDamage(build: CombatantBuild): number {
  const qualityMultipliers = [1, 1.08, 1.18, 1.3, 1.45];
  const tier = clamp(build.weaponQualityTier, 0, qualityMultipliers.length - 1);
  return (15 + 1.8 * Math.max(0, build.weaponLevel - 1)) * qualityMultipliers[tier];
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
