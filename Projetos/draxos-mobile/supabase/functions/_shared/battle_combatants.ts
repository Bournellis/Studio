import {
  spellLevelMap,
  weaponQualityTierFromQualityId,
} from "./progression_domain.ts";
import { DEFAULT_POTION_BEHAVIOR, POTION_IDS, potionDefinition } from "./economy_domain.ts";

export type BattleSideId = "player" | "opponent";

export interface BehaviorConfig {
  enabled: boolean;
  hp: BehaviorCondition;
  mana: BehaviorCondition;
}

export interface BehaviorCondition {
  mode: "ignore" | "below" | "above";
  percent: number;
}

export interface BattlePotionSlot {
  slotIndex: number;
  itemId: string;
  quantity: number;
  behavior: BehaviorConfig;
}

export interface BattleConsumableUse {
  owner: BattleSideId;
  slot_index: number;
  item_id: string;
  quantity: number;
}

export interface CombatantBuild {
  id: string;
  displayName: string;
  level: number;
  weaponId?: string;
  weaponLevel: number;
  weaponQualityTier: number;
  spellIds: string[];
  spellLevels: Record<string, number>;
  passiveId?: string;
  passiveLevel?: number;
  petId?: string;
  petLevel?: number;
  spellBehaviors?: Record<string, BehaviorConfig>;
  potionSlot?: BattlePotionSlot;
}

export interface BattlePlayerRow {
  id: string;
  username?: string | null;
  level?: number;
}

export interface BattleBuildRow {
  weapon_type: string;
  weapon_quality: string;
  weapon_level: number;
  spell_slots: unknown;
  spells_unlocked: unknown;
  pet_id: string | null;
  pet_level: number;
  passive_id: string | null;
  passive_level: number;
}

export interface BattleBotBuildRow {
  id: string;
  build_data: unknown;
}

export interface BattleConsumableRow {
  item_id: string;
  quantity: number;
}

export interface BattlePotionSlotRow {
  slot_index: number;
  potion_id: string | null;
  behavior: unknown;
}

export interface BattleSpellBehaviorRow {
  spell_id: string;
  behavior: unknown;
}

export interface PlayerCombatantState {
  player: BattlePlayerRow;
  build: BattleBuildRow;
  inventory: BattleConsumableRow[];
  potionSlots: BattlePotionSlotRow[];
  spellBehaviors: BattleSpellBehaviorRow[];
}

const DEFAULT_SPELL_ID = "sussurro_medo";
const DEFAULT_PLAYER_NAME = "Draxos";
const DEFAULT_BOT_NAME = "Treinador da Primeira Ruina";
const DEFAULT_WEAPON_ID = "varinha_cinzas";
const DEFAULT_BOT_WEAPON_QUALITY = "reforcada";
export const DEFAULT_SPELL_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "ignore", percent: 0 },
  mana: { mode: "ignore", percent: 0 },
};

export function playerCombatantFromState(
  state: PlayerCombatantState,
): CombatantBuild {
  const { player, build } = state;
  const slottedSpells = arrayOfStrings(build.spell_slots);
  const unlockedSpells = arrayOfStrings(build.spells_unlocked);
  const spells = slottedSpells.length > 0 ? slottedSpells : unlockedSpells;
  const spellIds = spells.length > 0 ? spells : [DEFAULT_SPELL_ID];

  return {
    id: player.id,
    displayName: stringValue(player.username, DEFAULT_PLAYER_NAME),
    level: numberValue(player.level, 1),
    weaponId: stringValue(build.weapon_type, DEFAULT_WEAPON_ID),
    weaponLevel: numberValue(build.weapon_level, 1),
    weaponQualityTier: weaponQualityTierFromQualityId(build.weapon_quality),
    spellIds,
    spellLevels: spellLevelMap(spellIds, numberValue(player.level, 1)),
    passiveId: build.passive_id ?? undefined,
    passiveLevel: build.passive_id === null
      ? undefined
      : numberValue(build.passive_level, 1),
    petId: build.pet_id ?? undefined,
    petLevel: build.pet_id === null
      ? undefined
      : numberValue(build.pet_level, 1),
    spellBehaviors: spellBehaviorMap(state.spellBehaviors),
    potionSlot: potionSlotForBattle(state),
  };
}

export function botCombatantFromRow(bot: BattleBotBuildRow): CombatantBuild {
  const data = isObject(bot.build_data) ? bot.build_data : {};
  const spellIds = arrayOfStrings(data.spell_ids);
  const passiveId = optionalString(data.passive_id);
  const petId = optionalString(data.pet_id);
  return {
    id: bot.id,
    displayName: stringValue(data.display_name, DEFAULT_BOT_NAME),
    level: numberValue(data.level, 5),
    weaponId: stringValue(data.weapon_id, DEFAULT_WEAPON_ID),
    weaponLevel: numberValue(data.weapon_level, 5),
    weaponQualityTier: weaponQualityTierFromQualityId(
      stringValue(data.weapon_quality, DEFAULT_BOT_WEAPON_QUALITY),
    ),
    spellIds: spellIds.length > 0 ? spellIds : [DEFAULT_SPELL_ID],
    spellLevels: recordOfNumbers(data.spell_levels),
    passiveId,
    passiveLevel: passiveId === undefined
      ? undefined
      : numberValue(data.passive_level, 1),
    petId,
    petLevel: petId === undefined ? undefined : numberValue(data.pet_level, 1),
  };
}

export function potionSlotForBattle(state: {
  inventory: BattleConsumableRow[];
  potionSlots: BattlePotionSlotRow[];
}): BattlePotionSlot | undefined {
  const slot = state.potionSlots.find((candidate) =>
    candidate.slot_index === 1
  );
  if (slot === undefined || slot.potion_id === null || !POTION_IDS.has(slot.potion_id)) {
    return undefined;
  }
  const inventory = state.inventory.find((item) =>
    item.item_id === slot.potion_id
  );
  const quantity = inventory?.quantity ?? 0;
  if (quantity <= 0) {
    return undefined;
  }
  return {
    slotIndex: 1,
    itemId: slot.potion_id,
    quantity,
    behavior: normalizeBehavior(
      slot.behavior,
      potionDefinition(slot.potion_id)?.defaultBehavior ?? DEFAULT_POTION_BEHAVIOR,
    ),
  };
}

export function spellBehaviorMap(
  rows: BattleSpellBehaviorRow[],
): Record<string, BehaviorConfig> {
  const result: Record<string, BehaviorConfig> = {};
  for (const row of rows) {
    result[row.spell_id] = normalizeBehavior(
      row.behavior,
      DEFAULT_SPELL_BEHAVIOR,
    );
  }
  return result;
}

export function normalizeBehavior(
  value: unknown,
  fallback: BehaviorConfig,
): BehaviorConfig {
  const payload = isObject(value) ? value : {};
  return {
    enabled: typeof payload.enabled === "boolean"
      ? payload.enabled
      : fallback.enabled,
    hp: normalizeCondition(payload.hp, fallback.hp),
    mana: normalizeCondition(payload.mana, fallback.mana),
  };
}

export function normalizeCondition(
  value: unknown,
  fallback: BehaviorCondition,
): BehaviorCondition {
  if (!isObject(value)) {
    return fallback;
  }
  const mode = stringValue(value.mode, fallback.mode);
  const percent = numberValue(value.percent, fallback.percent);
  if (mode !== "ignore" && mode !== "below" && mode !== "above") {
    return fallback;
  }
  return { mode, percent: Math.max(0, Math.min(100, Math.trunc(percent))) };
}

export function arrayOfStrings(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string =>
      typeof item === "string" && item !== ""
    )
    : [];
}

export function recordOfNumbers(value: unknown): Record<string, number> {
  if (!isObject(value)) {
    return {};
  }

  const result: Record<string, number> = {};
  for (const [key, raw] of Object.entries(value)) {
    result[key] = numberValue(raw, 1);
  }
  return result;
}

export function optionalString(value: unknown): string | undefined {
  return typeof value === "string" && value !== "" ? value : undefined;
}

export function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

export function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }

  return fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
