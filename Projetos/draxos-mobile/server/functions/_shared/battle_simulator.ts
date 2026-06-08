import type {
  BattleConsumableUse,
  BattlePotionSlot,
  BattleSideId,
  BehaviorCondition,
  BehaviorConfig,
  CombatantBuild,
  CombatantStatModifiers,
} from "./battle_combatants.ts";
import { potionDefinition } from "./economy_domain.ts";

export type {
  BattleConsumableUse,
  BattlePotionSlot,
  BattleSideId,
  BehaviorCondition,
  BehaviorConfig,
  CombatantBuild,
  CombatantStatModifiers,
} from "./battle_combatants.ts";

type DamageType =
  | "arcano"
  | "fisico"
  | "fogo"
  | "agua"
  | "terra"
  | "vento"
  | "raio"
  | "veneno"
  | "gelo"
  | "morte"
  | "sangue"
  | "none";

type DamageCategory = "weapon" | "spell" | "dot" | "pet" | "summon" | "system";

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
  consumables: {
    used: BattleConsumableUse[];
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
  weaponDamageType: DamageType;
  weaponCadence: number;
  weaponSpecialEvery: number;
  weaponSpecialMultiplier: number;
  nextWeaponAt: number;
  attackCount: number;
  spellCooldowns: Record<string, number>;
  emittedCooldownReady: Record<string, boolean>;
  petCooldown: number;
  summons: RuntimeSummon[];
  dots: RuntimeDot[];
  statuses: RuntimeStatus[];
  healingOverTime: RuntimeHealOverTime[];
  consumablesUsed: Record<number, boolean>;
}

interface RuntimeHealOverTime {
  id: string;
  itemId: string;
  source: BattleSideId;
  tickAmount: number;
  ticksRemaining: number;
  nextTickAt: number;
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
  damageTypeVulnerability?: Partial<Record<DamageType, number>>;
  slowPerStack?: number;
  cooldownSlowPerStack?: number;
  resistanceBonus?: number;
  regenPenaltyPerStack?: number;
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
  dot?: { statusId: string; tickDamage: number; duration: number };
  status?: { statusId: string; stacks: number; duration: number };
}

interface PassiveStats {
  manaRegenBonus: number;
  damageBonus: number;
  dotDamageBonus: number;
  damageReduction: number;
  startingBarrier: number;
  lifesteal: number;
  cooldownReduction: number;
  statusDurationBonus: number;
  petDamageBonus: number;
  summonDamageBonus: number;
}

const MAX_DURATION = 36;
const TICK_SECONDS = 0.5;
const DOT_TICK_SECONDS = 1;
const POTION_HEAL_TICK_SECONDS = 1;
const POTION_HEAL_TICKS = 5;
const POTION_HEAL_PERCENT_PER_TICK = 0.04;
const COMBAT_PACE_HP_MULTIPLIER_BASE = 3.25;
const COMBAT_PACE_HP_MULTIPLIER_PER_LEVEL = 0.085;

const WEAPONS: Record<
  string,
  {
    damageType: DamageType;
    baseDamage: number;
    damagePerLevel: number;
    cadence: number;
    specialEvery: number;
    specialMultiplier: number;
  }
> = {
  varinha_cinzas: {
    damageType: "arcano",
    baseDamage: 12,
    damagePerLevel: 1.35,
    cadence: 1.35,
    specialEvery: 4,
    specialMultiplier: 2.2,
  },
  grimorio_veu: {
    damageType: "arcano",
    baseDamage: 11,
    damagePerLevel: 1.3,
    cadence: 1.4,
    specialEvery: 4,
    specialMultiplier: 2,
  },
  athame_hematico: {
    damageType: "fisico",
    baseDamage: 13,
    damagePerLevel: 1.45,
    cadence: 1.25,
    specialEvery: 4,
    specialMultiplier: 2.1,
  },
  cajado_ossario: {
    damageType: "morte",
    baseDamage: 12,
    damagePerLevel: 1.35,
    cadence: 1.4,
    specialEvery: 4,
    specialMultiplier: 2.1,
  },
  orbe_tempestade: {
    damageType: "raio",
    baseDamage: 10,
    damagePerLevel: 1.15,
    cadence: 1.25,
    specialEvery: 4,
    specialMultiplier: 1.9,
  },
  selo_mare_fria: {
    damageType: "gelo",
    baseDamage: 10,
    damagePerLevel: 1.2,
    cadence: 1.35,
    specialEvery: 4,
    specialMultiplier: 2,
  },
  idolo_pedra_viva: {
    damageType: "terra",
    baseDamage: 13,
    damagePerLevel: 1.35,
    cadence: 1.55,
    specialEvery: 4,
    specialMultiplier: 2.1,
  },
  cetro_braseiro_negro: {
    damageType: "fogo",
    baseDamage: 12,
    damagePerLevel: 1.35,
    cadence: 1.35,
    specialEvery: 4,
    specialMultiplier: 2,
  },
};

const SPELLS: Record<string, SpellDefinition> = {
  sussurro_medo: {
    id: "sussurro_medo",
    damageType: "arcano",
    manaCost: 6,
    cooldown: 3.5,
    target: "player",
    baseDamage: 6,
    damagePerLevel: 0.8,
    status: { statusId: "inquietacao", stacks: 1, duration: 6 },
  },
  terror_primordial: {
    id: "terror_primordial",
    damageType: "arcano",
    manaCost: 9,
    cooldown: 5.5,
    target: "player",
    baseDamage: 13,
    damagePerLevel: 1.5,
    status: { statusId: "terror", stacks: 1, duration: 4 },
  },
  labirinto_razao: {
    id: "labirinto_razao",
    damageType: "arcano",
    manaCost: 8,
    cooldown: 5.5,
    target: "player",
    baseDamage: 11,
    damagePerLevel: 1.3,
    status: { statusId: "confusao", stacks: 1, duration: 5 },
  },
  mandato_oculto: {
    id: "mandato_oculto",
    damageType: "arcano",
    manaCost: 10,
    cooldown: 6.5,
    target: "player",
    baseDamage: 16,
    damagePerLevel: 1.8,
    status: { statusId: "compulsao", stacks: 1, duration: 5 },
  },
  incisao_ritual: {
    id: "incisao_ritual",
    damageType: "fisico",
    manaCost: 10,
    cooldown: 5,
    target: "direct",
    baseDamage: 18,
    damagePerLevel: 2.2,
    status: { statusId: "ferida", stacks: 1, duration: 6 },
  },
  hemorragia_induzida: {
    id: "hemorragia_induzida",
    damageType: "sangue",
    manaCost: 13,
    cooldown: 6.5,
    target: "direct",
    baseDamage: 10,
    damagePerLevel: 1.2,
    dot: { statusId: "hemorragia", tickDamage: 3.8, duration: 6 },
  },
  coagulo_negro: {
    id: "coagulo_negro",
    damageType: "none",
    manaCost: 14,
    cooldown: 9,
    target: "self",
    baseDamage: 0,
    damagePerLevel: 0,
    barrierBase: 28,
    barrierPerLevel: 2.6,
    resistance: { amount: 0.06, duration: 7 },
  },
  toxina_palida: {
    id: "toxina_palida",
    damageType: "veneno",
    manaCost: 8,
    cooldown: 6.5,
    target: "player",
    baseDamage: 8,
    damagePerLevel: 0.9,
    dot: { statusId: "envenenado", tickDamage: 3.5, duration: 6 },
  },
  marca_brasa: {
    id: "marca_brasa",
    damageType: "fogo",
    manaCost: 11,
    cooldown: 5.8,
    target: "area",
    baseDamage: 14,
    damagePerLevel: 1.7,
    dot: { statusId: "queimando", tickDamage: 3.2, duration: 5 },
  },
  coroa_cinzas: {
    id: "coroa_cinzas",
    damageType: "fogo",
    manaCost: 16,
    cooldown: 7,
    target: "player",
    baseDamage: 32,
    damagePerLevel: 3,
    status: { statusId: "cinzas_marcadas", stacks: 1, duration: 6 },
  },
  mare_escura: {
    id: "mare_escura",
    damageType: "agua",
    manaCost: 9,
    cooldown: 5.5,
    target: "area",
    baseDamage: 12,
    damagePerLevel: 1.7,
    status: { statusId: "molhado", stacks: 1, duration: 7 },
  },
  geada_ossos: {
    id: "geada_ossos",
    damageType: "gelo",
    manaCost: 10,
    cooldown: 6,
    target: "area",
    baseDamage: 15,
    damagePerLevel: 2,
    status: { statusId: "resfriado", stacks: 1, duration: 5 },
  },
  prisao_gelo: {
    id: "prisao_gelo",
    damageType: "gelo",
    manaCost: 16,
    cooldown: 8,
    target: "area",
    baseDamage: 18,
    damagePerLevel: 2.2,
    status: { statusId: "congelado", stacks: 1, duration: 3 },
  },
  raizes_pedra: {
    id: "raizes_pedra",
    damageType: "terra",
    manaCost: 14,
    cooldown: 8.5,
    target: "direct",
    baseDamage: 18,
    damagePerLevel: 2,
    barrierBase: 12,
    barrierPerLevel: 1.2,
    status: { statusId: "enraizado", stacks: 1, duration: 5 },
  },
  lamina_vento: {
    id: "lamina_vento",
    damageType: "vento",
    manaCost: 9,
    cooldown: 4.5,
    target: "direct",
    baseDamage: 20,
    damagePerLevel: 2.4,
    status: { statusId: "desequilibrado", stacks: 1, duration: 4 },
  },
  descarga_nervosa: {
    id: "descarga_nervosa",
    damageType: "raio",
    manaCost: 9,
    cooldown: 5,
    target: "player",
    baseDamage: 18,
    damagePerLevel: 2.3,
    status: { statusId: "condutor", stacks: 1, duration: 4.5 },
  },
  putrefacao: {
    id: "putrefacao",
    damageType: "morte",
    manaCost: 17,
    cooldown: 7.5,
    target: "player",
    baseDamage: 16,
    damagePerLevel: 2,
    dot: { statusId: "decaimento", tickDamage: 5.5, duration: 6 },
  },
  marca_sepulcral: {
    id: "marca_sepulcral",
    damageType: "morte",
    manaCost: 14,
    cooldown: 6.8,
    target: "player",
    baseDamage: 28,
    damagePerLevel: 2.8,
    status: { statusId: "marca_sepulcral", stacks: 1, duration: 7 },
  },
  erguer_ossos: {
    id: "erguer_ossos",
    damageType: "morte",
    manaCost: 16,
    cooldown: 8,
    target: "self",
    baseDamage: 0,
    damagePerLevel: 0,
    summonId: "guardiao_ossos",
  },
  invocar_brasa_faminta: {
    id: "invocar_brasa_faminta",
    damageType: "fogo",
    manaCost: 16,
    cooldown: 8,
    target: "self",
    baseDamage: 0,
    damagePerLevel: 0,
    summonId: "brasa_faminta",
  },
};

const PETS: Record<string, PetDefinition> = {
  corvo_pressagio: {
    damageType: "morte",
    baseDamage: 8,
    damagePerLevel: 1.05,
    cadence: 2.8,
    status: { statusId: "pressagio", stacks: 1, duration: 3 },
  },
  sanguessuga_sacramental: {
    damageType: "sangue",
    baseDamage: 8,
    damagePerLevel: 1.1,
    cadence: 3,
    dot: { statusId: "sangramento", tickDamage: 2.5, duration: 4 },
  },
  serpente_toxina: {
    damageType: "veneno",
    baseDamage: 8,
    damagePerLevel: 1.1,
    cadence: 3,
    dot: { statusId: "toxina", tickDamage: 2.5, duration: 4 },
  },
  cao_cinzas: {
    damageType: "fogo",
    baseDamage: 9,
    damagePerLevel: 1.2,
    cadence: 2.8,
  },
  medusa_mare_fria: {
    damageType: "gelo",
    baseDamage: 10,
    damagePerLevel: 1.25,
    cadence: 3.2,
    status: { statusId: "resfriado", stacks: 1, duration: 3.5 },
  },
  escaravelho_pedra: {
    damageType: "terra",
    baseDamage: 9,
    damagePerLevel: 1.15,
    cadence: 3.1,
    status: { statusId: "enraizado", stacks: 1, duration: 3.5 },
  },
  serpe_tempestade: {
    damageType: "raio",
    baseDamage: 8,
    damagePerLevel: 1.1,
    cadence: 2.7,
    status: { statusId: "condutor", stacks: 1, duration: 3 },
  },
  cranio_errante: {
    damageType: "morte",
    baseDamage: 9,
    damagePerLevel: 1.2,
    cadence: 3,
    status: { statusId: "decaimento", stacks: 1, duration: 3.5 },
  },
  olho_veu: {
    damageType: "arcano",
    baseDamage: 7,
    damagePerLevel: 1,
    cadence: 2.8,
    status: { statusId: "vulneravel", stacks: 1, duration: 3 },
  },
};

const SUMMONS: Record<
  string,
  { hp: number; dps: number; damageType: DamageType }
> = {
  guardiao_ossos: { hp: 70, dps: 10, damageType: "morte" },
  brasa_faminta: { hp: 60, dps: 12, damageType: "fogo" },
};

export function simulateFirstSliceBattle(
  input: BattleSimulationInput,
): BattleSimulationResult {
  const events: BattleEvent[] = [];
  const consumablesUsed: BattleConsumableUse[] = [];
  let seq = 1;
  const player = createCombatant("player", input.player);
  const opponent = createCombatant("opponent", input.opponent);
  const nextSeq = () => seq++;

  events.push({
    ...baseEvent(0, nextSeq(), "battle_start", "system", "none"),
    player_hp: player.hp,
    player_max_hp: player.maxHp,
    player_max_mana: player.maxMana,
    opponent_hp: opponent.hp,
    opponent_max_hp: opponent.maxHp,
    opponent_max_mana: opponent.maxMana,
    player_stat_modifiers: cleanStatModifiers(input.player.statModifiers),
    opponent_stat_modifiers: cleanStatModifiers(input.opponent.statModifiers),
  });
  emitPassiveStart(0, player, events, nextSeq);
  emitPassiveStart(0, opponent, events, nextSeq);

  for (let time = TICK_SECONDS; time <= MAX_DURATION; time += TICK_SECONDS) {
    expireStatuses(time, player, events, nextSeq);
    expireStatuses(time, opponent, events, nextSeq);
    processDots(time, player, events, nextSeq);
    processDots(time, opponent, events, nextSeq);
    processHealOverTime(time, player, events, nextSeq);
    processHealOverTime(time, opponent, events, nextSeq);
    regenerate(player);
    regenerate(opponent);
    processCooldownReady(time, player, events, nextSeq);
    processCooldownReady(time, opponent, events, nextSeq);
    processPotion(time, player, events, nextSeq, consumablesUsed);
    processPotion(time, opponent, events, nextSeq, consumablesUsed);
    processSpell(time, player, opponent, events, nextSeq);
    processSpell(time, opponent, player, events, nextSeq);
    processPet(time, player, opponent, events, nextSeq);
    processPet(time, opponent, player, events, nextSeq);
    processSummons(time, player, opponent, events, nextSeq);
    processSummons(time, opponent, player, events, nextSeq);
    processWeapon(time, player, opponent, events, nextSeq);
    processWeapon(time, opponent, player, events, nextSeq);

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
  const reason = player.hp <= 0 || opponent.hp <= 0
    ? "combatant_defeated"
    : "duration_limit";
  const reward = winner === "player" ? winReward() : lossReward();
  const duration = events.length > 0
    ? Number(events[events.length - 1].t.toFixed(1))
    : 0;

  events.push({
    ...baseEvent(
      duration + 0.1,
      nextSeq(),
      "reward_preview",
      "system",
      "player",
    ),
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
        opponent: {
          id: input.opponent.id,
          display_name: input.opponent.displayName,
          is_bot: true,
        },
      },
      result: { winner, reason },
      events,
    },
    reward,
    consumables: { used: consumablesUsed },
  };
}

function createCombatant(
  side: BattleSideId,
  build: CombatantBuild,
): RuntimeCombatant {
  const level = clamp(build.level, 1, 40);
  const modifiers = normalizedStatModifiers(build.statModifiers);
  const maxHp = roundedPercent(maxHpForLevel(level), modifiers.maxHpPercent);
  const maxMana = roundedPercent(
    Math.round(20 + 1.5 * (level - 1)),
    modifiers.maxManaPercent,
  );
  const passive = passiveStatsForBuild(build);
  const weapon = weaponDefinition(build.weaponId);
  const baseManaRegen = (2 + 0.05 * (level - 1)) * (1 + passive.manaRegenBonus);
  const cooldownReduction = clampPercent(
    passive.cooldownReduction + percentRatio(modifiers.cooldownReductionPercent),
    0,
    0.75,
  );
  return {
    side,
    build,
    hp: maxHp,
    maxHp,
    hpRegen: hpRegenForLevel(level) * percentMultiplier(modifiers.hpRegenPercent),
    barrier: passive.startingBarrier,
    mana: maxMana,
    maxMana,
    manaRegen: baseManaRegen * percentMultiplier(modifiers.manaRegenPercent),
    damageBonus: passive.damageBonus + percentRatio(modifiers.damageBonusPercent),
    damageReduction: passive.damageReduction +
      percentRatio(modifiers.damageReductionPercent),
    lifesteal: passive.lifesteal,
    cooldownMultiplier: 1 - cooldownReduction,
    weaponDamage: weaponDamage(build, weapon),
    weaponDamageType: weapon.damageType,
    weaponCadence: weapon.cadence,
    weaponSpecialEvery: weapon.specialEvery,
    weaponSpecialMultiplier: weapon.specialMultiplier,
    nextWeaponAt: 0.5,
    attackCount: 0,
    spellCooldowns: {},
    emittedCooldownReady: {},
    petCooldown: 3,
    summons: [],
    dots: [],
    statuses: [],
    healingOverTime: [],
    consumablesUsed: {},
  };
}

function normalizedStatModifiers(
  modifiers: CombatantStatModifiers | undefined,
): Required<CombatantStatModifiers> {
  return {
    maxHpPercent: safePercent(modifiers?.maxHpPercent),
    maxManaPercent: safePercent(modifiers?.maxManaPercent),
    hpRegenPercent: safePercent(modifiers?.hpRegenPercent),
    manaRegenPercent: safePercent(modifiers?.manaRegenPercent),
    damageBonusPercent: safePercent(modifiers?.damageBonusPercent),
    damageReductionPercent: safePercent(modifiers?.damageReductionPercent),
    cooldownReductionPercent: safePercent(modifiers?.cooldownReductionPercent),
    statusDurationPercent: safePercent(modifiers?.statusDurationPercent),
  };
}

function cleanStatModifiers(
  modifiers: CombatantStatModifiers | undefined,
): Record<string, number> {
  const normalized = normalizedStatModifiers(modifiers);
  const clean: Record<string, number> = {};
  for (const [key, value] of Object.entries(normalized)) {
    if (value !== 0) {
      clean[key] = value;
    }
  }
  return clean;
}

function roundedPercent(value: number, percent: number): number {
  return Math.max(1, Math.round(value * percentMultiplier(percent)));
}

function percentMultiplier(percent: number): number {
  return Math.max(0.05, 1 + percentRatio(percent));
}

function percentRatio(percent: number): number {
  return percent / 100;
}

function safePercent(value: number | undefined): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
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
    ...baseEvent(
      time,
      nextSeq(),
      "passive_apply",
      combatant.side,
      combatant.side,
    ),
    passive_id: passiveId,
    passive_level: passiveLevel,
  });
  if (combatant.barrier > 0) {
    events.push({
      ...baseEvent(
        time,
        nextSeq(),
        "barrier_gain",
        combatant.side,
        combatant.side,
      ),
      passive_id: passiveId,
      amount: combatant.barrier,
      barrier_after: combatant.barrier,
      hp_after: combatant.hp,
    });
  }
}

function regenerate(combatant: RuntimeCombatant): void {
  const slow = slowMultiplier(combatant);
  const regenPenalty = regenPenaltyMultiplier(combatant);
  if (combatant.hp > 0) {
    combatant.hp = Math.min(
      combatant.maxHp,
      combatant.hp + combatant.hpRegen * slow * regenPenalty * TICK_SECONDS,
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
  const multiplier = actor.attackCount % actor.weaponSpecialEvery === 0
    ? actor.weaponSpecialMultiplier
    : 1;
  const rawDamage = Math.ceil(
    actor.weaponDamage * multiplier * (1 + actor.damageBonus),
  );
  const result = applyDamage(
    time,
    target,
    rawDamage,
    actor.weaponDamageType,
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
    weapon_id: actor.build.weaponId ?? "varinha_cinzas",
    damage_type: actor.weaponDamageType,
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
      actor.mana >= spell.manaCost &&
      shouldUseSpell(actor, candidate);
  });
  if (spellId === undefined) {
    return;
  }
  const spell = SPELLS[spellId];
  const spellLevel = clamp(
    actor.build.spellLevels[spellId] ?? actor.build.level,
    1,
    40,
  );
  actor.mana -= spell.manaCost;
  const readyAt = time +
    spell.cooldown * actor.cooldownMultiplier * cooldownSlowMultiplier(actor);
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
    actor.summons = actor.summons.filter((existing) =>
      existing.id !== summon.id
    );
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
    const amount = Math.round(
      spell.barrierBase + (spell.barrierPerLevel ?? 0) * spellLevel,
    );
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
  } else {
    events.push({
      ...baseEvent(
        time,
        nextSeq(),
        "spell_cast",
        actor.side,
        spell.target === "self" ? actor.side : target.side,
      ),
      spell_id: spellId,
      raw_damage: 0,
      damage: 0,
      absorbed: 0,
      damage_type: spell.damageType,
      resistance_percent: 0,
      hp_after: Math.max(0, target.hp),
      barrier_after: Math.max(0, target.barrier),
    });
  }

  if (spell.dot !== undefined && target.hp > 0) {
    applyDot(time, actor, target, spell, spellLevel, events, nextSeq);
  }

  if (spell.status !== undefined && target.hp > 0) {
    applyStatus(time, actor, target, spell, events, nextSeq);
  }
}

function processPotion(
  time: number,
  actor: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
  consumablesUsed: BattleConsumableUse[],
): void {
  const slot = actor.build.potionSlot;
  if (
    slot === undefined || actor.hp <= 0 ||
    actor.consumablesUsed[slot.slotIndex] === true ||
    slot.quantity <= 0
  ) {
    return;
  }
  const potion = potionDefinition(slot.itemId);
  if (potion === undefined) {
    return;
  }
  if (!shouldUseBehavior(slot.behavior, actor, true)) {
    return;
  }

  actor.consumablesUsed[slot.slotIndex] = true;
  consumablesUsed.push({
    owner: actor.side,
    slot_index: slot.slotIndex,
    item_id: slot.itemId,
    quantity: 1,
  });
  const effectType = stringValue(potion.effect.type, "");
  if (effectType === "heal_over_time") {
    actor.healingOverTime.push({
      id: `${actor.side}:${slot.slotIndex}:${slot.itemId}`,
      itemId: slot.itemId,
      source: actor.side,
      tickAmount: Math.max(
        1,
        Math.round(actor.maxHp * POTION_HEAL_PERCENT_PER_TICK),
      ),
      ticksRemaining: POTION_HEAL_TICKS,
      nextTickAt: time + POTION_HEAL_TICK_SECONDS,
    });
  } else if (effectType === "mana_restore") {
    const percent = numberValue(potion.effect.percent_max_mana, 25);
    const before = actor.mana;
    actor.mana = Math.min(actor.maxMana, actor.mana + actor.maxMana * (percent / 100));
    events.push({
      ...baseEvent(time, nextSeq(), "potion_mana_restore", actor.side, actor.side),
      item_id: slot.itemId,
      amount: Math.max(0, Math.round(actor.mana - before)),
      mana_after: Math.round(actor.mana),
      max_mana: actor.maxMana,
    });
  } else if (effectType === "barrier_gain") {
    const percent = numberValue(potion.effect.percent_max_hp, 12);
    const amount = Math.max(1, Math.round(actor.maxHp * (percent / 100)));
    actor.barrier += amount;
    events.push({
      ...baseEvent(time, nextSeq(), "potion_barrier_gain", actor.side, actor.side),
      item_id: slot.itemId,
      amount,
      barrier_after: Math.round(actor.barrier),
      max_hp: actor.maxHp,
    });
  } else {
    return;
  }
  events.push({
    ...baseEvent(time, nextSeq(), "consumable_use", actor.side, actor.side),
    item_id: slot.itemId,
    slot_index: slot.slotIndex,
    effect: effectType,
    duration_seconds: POTION_HEAL_TICKS * POTION_HEAL_TICK_SECONDS,
    tick_percent_max_hp: POTION_HEAL_PERCENT_PER_TICK * 100,
    hp_after: Math.max(0, actor.hp),
    mana_after: Math.round(actor.mana),
    barrier_after: Math.round(actor.barrier),
  });
}

function processHealOverTime(
  time: number,
  actor: RuntimeCombatant,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  if (actor.healingOverTime.length === 0) {
    return;
  }
  const active: RuntimeHealOverTime[] = [];
  for (const healing of actor.healingOverTime) {
    if (actor.hp <= 0) {
      continue;
    }
    if (time + 0.0001 >= healing.nextTickAt && healing.ticksRemaining > 0) {
      const before = actor.hp;
      actor.hp = Math.min(actor.maxHp, actor.hp + healing.tickAmount);
      const healed = Math.max(0, Math.round(actor.hp - before));
      healing.ticksRemaining -= 1;
      healing.nextTickAt += POTION_HEAL_TICK_SECONDS;
      events.push({
        ...baseEvent(time, nextSeq(), "heal", healing.source, actor.side),
        item_id: healing.itemId,
        effect_id: healing.id,
        amount: healed,
        hp_after: Math.max(0, Math.round(actor.hp)),
        max_hp: actor.maxHp,
        ticks_remaining: healing.ticksRemaining,
      });
    }
    if (healing.ticksRemaining > 0) {
      active.push(healing);
    }
  }
  actor.healingOverTime = active;
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
  if (
    pet === undefined || actor.build.petLevel === undefined || actor.hp <= 0 ||
    target.hp <= 0
  ) {
    return;
  }
  if (time + 0.0001 < actor.petCooldown) {
    return;
  }
  const petLevel = clamp(actor.build.petLevel, 1, 40);
  const passive = passiveStatsForBuild(actor.build);
  const rawDamage = Math.ceil(
    (pet.baseDamage + pet.damagePerLevel * Math.max(0, petLevel - 1)) *
      (1 + passive.petDamageBonus),
  );
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
  if (pet.dot !== undefined && target.hp > 0) {
    applyDotDefinition(
      time,
      actor,
      target,
      pet.dot,
      pet.damageType,
      petId,
      events,
      nextSeq,
    );
  }
  if (pet.status !== undefined && target.hp > 0) {
    applyStatusDefinition(
      time,
      actor,
      target,
      pet.status,
      petId,
      events,
      nextSeq,
    );
  }
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
      events.push(
        baseEvent(time, nextSeq(), "summon_expire", summon.id, "none"),
      );
      continue;
    }
    if (time + 0.0001 >= summon.nextAttackAt && target.hp > 0) {
      const passive = passiveStatsForBuild(owner.build);
      const rawDamage = Math.ceil(summon.dps * (1 + passive.summonDamageBonus));
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
        ...baseEvent(
          time,
          nextSeq(),
          "status_expire",
          status.source,
          target.side,
        ),
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
  const passive = passiveStatsForBuild(actor.build);
  const tickDamage =
    (spell.dot.tickDamage + Math.max(0, spellLevel - 1) * 0.35) *
    (1 + passive.dotDamageBonus);
  if (existing !== undefined) {
    existing.stacks = clamp(existing.stacks + 1, 1, 5);
    existing.tickDamage = Math.max(existing.tickDamage, tickDamage);
    existing.expiresAt = time +
      spell.dot.duration * (1 + passive.statusDurationBonus);
    existing.nextTickAt = Math.min(
      existing.nextTickAt,
      time + DOT_TICK_SECONDS,
    );
    events.push({
      ...baseEvent(time, nextSeq(), "dot_apply", actor.side, target.side),
      spell_id: spell.id,
      status_id: existing.id,
      stacks: existing.stacks,
      tick_damage: Number(existing.tickDamage.toFixed(2)),
      duration: Number(
        (spell.dot.duration * (1 + passive.statusDurationBonus)).toFixed(1),
      ),
    });
    return;
  }

  target.dots.push({
    id: spell.dot.statusId,
    source: actor.side,
    damageType: spell.damageType,
    tickDamage,
    stacks: 1,
    expiresAt: time + spell.dot.duration * (1 + passive.statusDurationBonus),
    nextTickAt: time + DOT_TICK_SECONDS,
  });
  events.push({
    ...baseEvent(time, nextSeq(), "dot_apply", actor.side, target.side),
    spell_id: spell.id,
    status_id: spell.dot.statusId,
    stacks: 1,
    tick_damage: Number(tickDamage.toFixed(2)),
    duration: Number(
      (spell.dot.duration * (1 + passive.statusDurationBonus)).toFixed(1),
    ),
  });
}

function applyDotDefinition(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  dot: { statusId: string; tickDamage: number; duration: number },
  damageType: DamageType,
  sourceId: string,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const passive = passiveStatsForBuild(actor.build);
  const duration = dot.duration * (1 + passive.statusDurationBonus);
  const tickDamage = dot.tickDamage * (1 + passive.dotDamageBonus);
  const existing = target.dots.find((current) =>
    current.id === dot.statusId && current.source === actor.side
  );
  if (existing !== undefined) {
    existing.stacks = clamp(existing.stacks + 1, 1, 5);
    existing.tickDamage = Math.max(existing.tickDamage, tickDamage);
    existing.expiresAt = time + duration;
    existing.nextTickAt = Math.min(
      existing.nextTickAt,
      time + DOT_TICK_SECONDS,
    );
  } else {
    target.dots.push({
      id: dot.statusId,
      source: actor.side,
      damageType,
      tickDamage,
      stacks: 1,
      expiresAt: time + duration,
      nextTickAt: time + DOT_TICK_SECONDS,
    });
  }
  events.push({
    ...baseEvent(time, nextSeq(), "dot_apply", actor.side, target.side),
    pet_id: sourceId,
    status_id: dot.statusId,
    stacks: existing?.stacks ?? 1,
    tick_damage: Number(tickDamage.toFixed(2)),
    duration: Number(duration.toFixed(1)),
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

  const passive = passiveStatsForBuild(actor.build);
  const status = createStatus(
    spell.status.statusId,
    actor.side,
    spell.status.stacks,
    time + spell.status.duration * (1 + passive.statusDurationBonus),
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
      duration: Number(
        (spell.status.duration * (1 + passive.statusDurationBonus)).toFixed(1),
      ),
    });
    return;
  }

  target.statuses.push(status);
  events.push({
    ...baseEvent(time, nextSeq(), "status_apply", actor.side, target.side),
    spell_id: spell.id,
    status_id: status.id,
    stacks: status.stacks,
    duration: Number(
      (spell.status.duration * (1 + passive.statusDurationBonus)).toFixed(1),
    ),
  });
}

function applyStatusDefinition(
  time: number,
  actor: RuntimeCombatant,
  target: RuntimeCombatant,
  statusDefinition: { statusId: string; stacks: number; duration: number },
  sourceId: string,
  events: BattleEvent[],
  nextSeq: () => number,
): void {
  const passive = passiveStatsForBuild(actor.build);
  const duration = statusDefinition.duration *
    (1 + passive.statusDurationBonus);
  const status = createStatus(
    statusDefinition.statusId,
    actor.side,
    statusDefinition.stacks,
    time + duration,
  );
  const existing = target.statuses.find((current) =>
    current.id === status.id && current.source === status.source
  );
  if (existing !== undefined) {
    existing.stacks = clamp(existing.stacks + status.stacks, 1, 5);
    existing.expiresAt = status.expiresAt;
  } else {
    target.statuses.push(status);
  }
  events.push({
    ...baseEvent(time, nextSeq(), "status_apply", actor.side, target.side),
    pet_id: sourceId,
    status_id: status.id,
    stacks: existing?.stacks ?? status.stacks,
    duration: Number(duration.toFixed(1)),
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
  const status = createResistanceStatus(
    actor.side,
    amount,
    time + spell.resistance.duration,
  );
  const existing = actor.statuses.find((current) =>
    current.id === status.id && current.source === status.source
  );
  if (existing !== undefined) {
    existing.resistanceBonus = Math.max(
      existing.resistanceBonus ?? 0,
      status.resistanceBonus ?? 0,
    );
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
  const vulnerability = targetVulnerabilityFor(target, damageType);
  const resistance = category === "system"
    ? 0
    : totalDamageReduction(target, damageType);
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
  const base = { id, source, stacks, expiresAt };
  switch (id) {
    case "inquietacao":
      return {
        ...base,
        vulnerabilityPerStack: 0.045,
        cooldownSlowPerStack: 0.06,
      };
    case "medo":
      return {
        ...base,
        vulnerabilityPerStack: 0.04,
        cooldownSlowPerStack: 0.05,
      };
    case "pressagio":
      return {
        ...base,
        vulnerabilityPerStack: 0.025,
        damageTypeVulnerability: { morte: 0.03 },
      };
    case "terror":
      return {
        ...base,
        vulnerabilityPerStack: 0.13,
        cooldownSlowPerStack: 0.16,
      };
    case "confusao":
    case "compulsao":
      return { ...base, cooldownSlowPerStack: 0.18 };
    case "ferida":
      return {
        ...base,
        damageTypeVulnerability: { sangue: 0.05, fisico: 0.03 },
      };
    case "sangue_exposto":
    case "sangramento":
      return { ...base, damageTypeVulnerability: { sangue: 0.05 } };
    case "envenenado":
    case "toxina":
      return { ...base, regenPenaltyPerStack: 0.08 };
    case "queimando":
    case "cinzas_marcadas":
      return { ...base, damageTypeVulnerability: { fogo: 0.04, morte: 0.03 } };
    case "molhado":
      return { ...base, damageTypeVulnerability: { raio: 0.08, gelo: 0.04 } };
    case "resfriado":
    case "lento":
      return { ...base, slowPerStack: 0.15 };
    case "congelado":
      return {
        ...base,
        slowPerStack: 0.35,
        damageTypeVulnerability: { fisico: 0.08, terra: 0.05 },
      };
    case "enraizado":
      return { ...base, slowPerStack: 0.2 };
    case "desequilibrado":
    case "vulneravel":
      return { ...base, vulnerabilityPerStack: 0.04 };
    case "condutor":
    case "eletrificado":
      return {
        ...base,
        damageTypeVulnerability: { raio: 0.055 },
        cooldownSlowPerStack: 0.035,
      };
    case "decaimento":
    case "anti_regeneracao":
      return {
        ...base,
        damageTypeVulnerability: { morte: 0.05 },
        regenPenaltyPerStack: 0.12,
      };
    case "marca_sepulcral":
      return { ...base, damageTypeVulnerability: { morte: 0.08 } };
    default:
      return base;
  }
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

function passiveStats(
  passiveId: string | undefined,
  level: number | undefined,
): PassiveStats {
  const passiveLevel = clamp(level ?? 1, 1, 40);
  const scale = Math.max(0, passiveLevel - 1);
  const empty = {
    manaRegenBonus: 0,
    damageBonus: 0,
    dotDamageBonus: 0,
    damageReduction: 0,
    startingBarrier: 0,
    lifesteal: 0,
    cooldownReduction: 0,
    statusDurationBonus: 0,
    petDamageBonus: 0,
    summonDamageBonus: 0,
  };

  switch (passiveId) {
    case "doutrina_pavor":
      return { ...empty, statusDurationBonus: 0.08 + scale * 0.004 };
    case "mente_fria":
      return { ...empty, damageReduction: 0.03 + scale * 0.0015 };
    case "anatomista_profano":
      return { ...empty, damageBonus: 0.04 + scale * 0.002 };
    case "sangue_obediente":
      return { ...empty, lifesteal: 0.02 + scale * 0.001 };
    case "alquimia_toxica":
    case "cinza_viva":
      return { ...empty, dotDamageBonus: 0.035 + scale * 0.001 };
    case "mare_silenciosa":
      return { ...empty, statusDurationBonus: 0.03 + scale * 0.0015 };
    case "pedra_interna":
      return {
        ...empty,
        startingBarrier: Math.round(12 + scale),
        damageReduction: 0.015 + scale * 0.0008,
      };
    case "pulso_tempestade":
      return {
        ...empty,
        cooldownReduction: clampPercent(0.05 + scale * 0.0015, 0, 0.25),
      };
    case "ossuario_interior":
      return {
        ...empty,
        summonDamageBonus: 0.08 + scale * 0.003,
        dotDamageBonus: 0.04 + scale * 0.0015,
      };
    case "pacto_familiar":
      return { ...empty, petDamageBonus: 0.04 + scale * 0.0015 };
    default:
      return empty;
  }
}

function passiveStatsForBuild(build: CombatantBuild): PassiveStats {
  const passive = passiveStats(build.passiveId, build.passiveLevel);
  const modifiers = normalizedStatModifiers(build.statModifiers);
  return {
    ...passive,
    statusDurationBonus: passive.statusDurationBonus +
      percentRatio(modifiers.statusDurationPercent),
  };
}

function totalDamageReduction(
  target: RuntimeCombatant,
  damageType: DamageType,
): number {
  const statusResistance = target.statuses.reduce(
    (total, status) => total + (status.resistanceBonus ?? 0),
    0,
  );
  const typeResistance = damageType === "none" ? 0 : target.damageReduction;
  return clampPercent(typeResistance + statusResistance, 0, 0.75);
}

function targetVulnerabilityFor(
  target: RuntimeCombatant,
  damageType: DamageType,
): number {
  return clampPercent(
    target.statuses.reduce(
      (total, status) => {
        const generic = (status.vulnerabilityPerStack ?? 0) * status.stacks;
        const typed = damageType === "none"
          ? 0
          : ((status.damageTypeVulnerability?.[damageType] ?? 0) *
            status.stacks);
        return total + generic + typed;
      },
      0,
    ),
    0,
    0.65,
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
    (total, status) =>
      total +
      ((status.slowPerStack ?? 0) + (status.cooldownSlowPerStack ?? 0)) *
        status.stacks,
    0,
  );
  return 1 + clampPercent(slow, 0, 0.6);
}

function weaponInterval(actor: RuntimeCombatant): number {
  return actor.weaponCadence * cooldownSlowMultiplier(actor);
}

function regenPenaltyMultiplier(target: RuntimeCombatant): number {
  const penalty = target.statuses.reduce(
    (total, status) =>
      total + (status.regenPenaltyPerStack ?? 0) * status.stacks,
    0,
  );
  return 1 - clampPercent(penalty, 0, 0.8);
}

function shouldUseSpell(actor: RuntimeCombatant, spellId: string): boolean {
  const behavior = actor.build.spellBehaviors?.[spellId];
  if (behavior === undefined) {
    return true;
  }
  return shouldUseBehavior(behavior, actor, false);
}

function shouldUseBehavior(
  behavior: BehaviorConfig,
  actor: RuntimeCombatant,
  defaultEnabled: boolean,
): boolean {
  const enabled = typeof behavior.enabled === "boolean"
    ? behavior.enabled
    : defaultEnabled;
  if (!enabled) {
    return false;
  }
  return conditionMatches(behavior.hp, hpPercent(actor)) &&
    conditionMatches(behavior.mana, manaPercent(actor));
}

function conditionMatches(
  condition: BehaviorCondition | undefined,
  currentPercent: number,
): boolean {
  if (condition === undefined || condition.mode === "ignore") {
    return true;
  }
  const threshold = clampPercent(condition.percent, 0, 100);
  if (condition.mode === "below") {
    return currentPercent < threshold;
  }
  if (condition.mode === "above") {
    return currentPercent > threshold;
  }
  return true;
}

function hpPercent(actor: RuntimeCombatant): number {
  return actor.maxHp <= 0 ? 0 : actor.hp / actor.maxHp * 100;
}

function manaPercent(actor: RuntimeCombatant): number {
  return actor.maxMana <= 0 ? 0 : actor.mana / actor.maxMana * 100;
}

function weaponDefinition(
  weaponId: string | undefined,
): typeof WEAPONS[keyof typeof WEAPONS] {
  return WEAPONS[weaponId ?? ""] ?? WEAPONS.varinha_cinzas;
}

function weaponDamage(
  build: CombatantBuild,
  weapon: typeof WEAPONS[keyof typeof WEAPONS],
): number {
  const qualityMultipliers = [1, 1.08, 1.18, 1.3, 1.45];
  const tier = clamp(build.weaponQualityTier, 0, qualityMultipliers.length - 1);
  return (weapon.baseDamage +
    weapon.damagePerLevel * Math.max(0, build.weaponLevel - 1)) *
    qualityMultipliers[tier];
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
  return 0;
}

function winReward(): BattleSimulationResult["reward"] {
  return {
    type: "FIRST_SLICE_SIM",
    reward_id: "first_slice_battle_win",
    resources: { xp: 50, almas: 4, energia: 2, sangue: 1, ossos: 20 },
  };
}

function lossReward(): BattleSimulationResult["reward"] {
  return {
    type: "FIRST_SLICE_SIM",
    reward_id: "first_slice_battle_loss",
    resources: { xp: 10, almas: 0.8, energia: 0.4, sangue: 0.2, ossos: 4 },
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

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}
