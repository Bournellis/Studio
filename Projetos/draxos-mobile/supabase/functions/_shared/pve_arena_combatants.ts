import {
  type BattleBotBuildRow,
  botCombatantFromRow,
  type CombatantBuild,
} from "./battle_combatants.ts";
import {
  type PveArenaDifficultyTier,
  type PveArenaEnemyDefinition,
  pveEnemyDefinition,
} from "./pve_arena_catalog.ts";

const INTRO_RUNWAY_ARENA_ID = "arena_cinzas_curta";
const INTRO_RUNWAY_DIFFICULTY_ID = "s1_d00_intro";
const INTRO_RUNWAY_TARGET_MAX = 220;

export function arenaOpponentCombatantFromBot(
  bot: BattleBotBuildRow,
  enemyId: string,
  tier: PveArenaDifficultyTier | null,
  duelPowerTarget: number | null,
): CombatantBuild {
  const enemy = pveEnemyDefinition(enemyId);
  const combatant = botCombatantFromRow(bot);
  const namedCombatant = {
    ...combatant,
    displayName: enemy?.display_name ?? combatant.displayName,
  };
  const legalCombatant = applyEnemyLegalUnlocks(namedCombatant, enemy);
  if (isIntroRunwayTier(tier, duelPowerTarget)) {
    return applyIntroRunwayTuning(legalCombatant, enemy);
  }
  return legalCombatant;
}

function applyEnemyLegalUnlocks(
  combatant: CombatantBuild,
  enemy: PveArenaEnemyDefinition | null,
): CombatantBuild {
  const legal = enemy?.legal_unlocks;
  const spellLimit = spellSlotLimit(enemy);
  const spellIds = spellLimit === null
    ? [...combatant.spellIds]
    : combatant.spellIds.slice(0, spellLimit);
  const spellLevels = spellLevelsFor(spellIds, combatant.spellLevels);
  const passiveId = legal?.requires_doutrina === false ? undefined : combatant.passiveId;
  const petId = legal?.requires_familiar === false ? undefined : combatant.petId;
  return {
    ...combatant,
    spellIds,
    spellLevels,
    passiveId,
    passiveLevel: passiveId === undefined ? undefined : combatant.passiveLevel,
    petId,
    petLevel: petId === undefined ? undefined : combatant.petLevel,
  };
}

function applyIntroRunwayTuning(
  combatant: CombatantBuild,
  enemy: PveArenaEnemyDefinition | null,
): CombatantBuild {
  const spellLimit = spellSlotLimit(enemy);
  const introSpellLimit = Math.min(spellLimit ?? combatant.spellIds.length, 1);
  const spellIds = combatant.spellIds.slice(0, introSpellLimit);
  return {
    ...combatant,
    level: Math.min(combatant.level, 2),
    weaponLevel: 1,
    weaponQualityTier: 0,
    spellIds,
    spellLevels: spellLevelsFor(spellIds, combatant.spellLevels, 1),
    passiveId: undefined,
    passiveLevel: undefined,
    petId: undefined,
    petLevel: undefined,
  };
}

function isIntroRunwayTier(
  tier: PveArenaDifficultyTier | null,
  duelPowerTarget: number | null,
): boolean {
  return tier?.arena_id === INTRO_RUNWAY_ARENA_ID &&
    tier.difficulty_id === INTRO_RUNWAY_DIFFICULTY_ID &&
    typeof duelPowerTarget === "number" &&
    duelPowerTarget <= INTRO_RUNWAY_TARGET_MAX;
}

function spellSlotLimit(enemy: PveArenaEnemyDefinition | null): number | null {
  const slots = enemy?.legal_unlocks.spell_slots;
  if (typeof slots !== "number" || !Number.isFinite(slots)) {
    return null;
  }
  return Math.max(0, Math.trunc(slots));
}

function spellLevelsFor(
  spellIds: string[],
  current: Record<string, number>,
  cap?: number,
): Record<string, number> {
  const output: Record<string, number> = {};
  for (const spellId of spellIds) {
    const level = current[spellId] ?? 1;
    output[spellId] = cap === undefined ? level : Math.min(level, cap);
  }
  return output;
}
