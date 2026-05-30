import { GRIMOIRE_CATALOG } from "./grimoire_catalog.ts";

export interface ProgressionDomainError {
  code: string;
  message: string;
  status: number;
}

export interface ProgressionPlayerRow {
  id?: string;
  level: number;
  power: number;
}

export interface ProgressionBuildRow {
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

export interface ProgressionConsumableRow {
  item_id: string;
  quantity: number;
  updated_at: string;
}

export interface ProgressionPotionSlotRow {
  slot_index: number;
  potion_id: string | null;
  behavior: unknown;
  updated_at: string;
}

export interface ProgressionSpellBehaviorRow {
  spell_id: string;
  behavior: unknown;
}

export interface ProgressionBuildState {
  player: ProgressionPlayerRow;
  build: ProgressionBuildRow;
  inventory: ProgressionConsumableRow[];
  potionSlots: ProgressionPotionSlotRow[];
  spellBehaviors: ProgressionSpellBehaviorRow[];
}

export interface ProgressionBehaviorConfig {
  enabled: boolean;
  hp: ProgressionBehaviorCondition;
  mana: ProgressionBehaviorCondition;
}

export interface ProgressionBehaviorCondition {
  mode: "ignore" | "below" | "above";
  percent: number;
}

export interface CatalogItem {
  id: string;
  display_name?: string;
  description?: string;
  enabled?: boolean;
  unlock_level?: number;
  qualities?: unknown;
}

export interface EquipResolution {
  update: {
    weapon_type: string;
    weapon_quality: string;
    spell_slots: Array<string | null>;
    passive_id: string | null;
    pet_id: string | null;
  };
  summary: Record<string, unknown>;
}

const ITEM_ID_PATTERN = /^[a-z0-9_]+$/;

export const DEFAULT_WEAPON_QUALITY = "starter";
export const SPELL_SLOT_UNLOCK_LEVELS = new Map<number, number>([
  [1, 3],
  [2, 7],
  [3, 25],
]);
export const PASSIVE_UNLOCK_LEVEL = 10;
export const PET_UNLOCK_LEVEL = 15;
export const POWER_WEIGHTS = {
  level: 42,
  weaponLevel: 28,
  spellLevel: 40,
  petLevel: 34,
  passiveLevel: 22,
  weaponQualityTier: 30,
};

export const DEFAULT_SPELL_BEHAVIOR: ProgressionBehaviorConfig = {
  enabled: true,
  hp: { mode: "ignore", percent: 0 },
  mana: { mode: "ignore", percent: 0 },
};

export const DEFAULT_POTION_BEHAVIOR: ProgressionBehaviorConfig = {
  enabled: true,
  hp: { mode: "below", percent: 40 },
  mana: { mode: "ignore", percent: 0 },
};

export function resolveEquipRequest(
  body: Record<string, unknown>,
  state: ProgressionBuildState,
): { value: EquipResolution; error: null } | {
  value: null;
  error: ProgressionDomainError;
} {
  let weaponType = state.build.weapon_type;
  let weaponQuality = state.build.weapon_quality || DEFAULT_WEAPON_QUALITY;
  const spellSlots = normalizedSpellSlots(state.build);
  let passiveId = state.build.passive_id;
  let petId = state.build.pet_id;

  if (hasOwn(body, "weapon")) {
    if (!isObject(body.weapon)) {
      return equipError("INVALID_WEAPON", "Instrumento Ritual invalido.", 400);
    }
    const requestedWeapon = stringField(body.weapon, "type");
    if (!ITEM_ID_PATTERN.test(requestedWeapon)) {
      return equipError("INVALID_WEAPON", "Instrumento Ritual invalido.", 400);
    }
    const weapon = catalogItem("weapons", requestedWeapon);
    if (weapon === null || !catalogItemEnabled(weapon)) {
      return equipError("INVALID_WEAPON", "Instrumento Ritual indisponivel.", 400);
    }
    const unlock = itemUnlockLevel(weapon, 1);
    if (state.player.level < unlock) {
      return equipError("WEAPON_LOCKED", "Instrumento Ritual bloqueado para este nivel.", 409);
    }
    const requestedQuality = optionalString(body.weapon.quality);
    const nextQuality = requestedQuality ??
      (requestedWeapon === weaponType ? weaponQuality : DEFAULT_WEAPON_QUALITY);
    if (!validWeaponQuality(weapon, nextQuality)) {
      return equipError("INVALID_WEAPON_QUALITY", "Qualidade de instrumento indisponivel.", 400);
    }
    weaponType = requestedWeapon;
    weaponQuality = nextQuality;
  }

  if (hasOwn(body, "spell_slots")) {
    if (!Array.isArray(body.spell_slots)) {
      return equipError("INVALID_SPELL_SLOT", "Habilidade invalida.", 400);
    }
    for (const entry of body.spell_slots) {
      if (!isObject(entry)) {
        return equipError("INVALID_SPELL_SLOT", "Habilidade invalida.", 400);
      }
      const slotIndex = positiveIntegerField(entry, "slot_index", 0);
      if (slotIndex === null || slotIndex < 1 || slotIndex > 3) {
        return equipError("INVALID_SPELL_SLOT", "Espaco de habilidade invalido.", 400);
      }
      const requestedSpell = hasOwn(entry, "spell_id") ? optionalString(entry.spell_id) : null;
      if (requestedSpell !== null) {
        if (!ITEM_ID_PATTERN.test(requestedSpell)) {
          return equipError("INVALID_SPELL", "Habilidade invalida.", 400);
        }
        const slotUnlock = SPELL_SLOT_UNLOCK_LEVELS.get(slotIndex) ?? 25;
        if (state.player.level < slotUnlock) {
          return equipError(
            "SPELL_SLOT_LOCKED",
            "Espaco de habilidade bloqueado para este nivel.",
            409,
          );
        }
        const spell = catalogItem("spells", requestedSpell);
        if (spell === null || !catalogItemEnabled(spell)) {
          return equipError("INVALID_SPELL", "Habilidade indisponivel.", 400);
        }
        const spellUnlock = itemUnlockLevel(spell, 1);
        if (state.player.level < spellUnlock) {
          return equipError("SPELL_LOCKED", "Habilidade bloqueada para este nivel.", 409);
        }
      }
      spellSlots[slotIndex - 1] = requestedSpell;
    }
  }

  const selectedSpells = spellSlots.filter((spellId): spellId is string =>
    typeof spellId === "string" && spellId !== ""
  );
  if (new Set(selectedSpells).size !== selectedSpells.length) {
    return equipError("DUPLICATE_SPELL", "A mesma habilidade nao pode ocupar dois espacos.", 409);
  }

  if (hasOwn(body, "passive_id")) {
    const requestedPassive = optionalString(body.passive_id);
    if (requestedPassive !== null) {
      if (!ITEM_ID_PATTERN.test(requestedPassive)) {
        return equipError("INVALID_DOCTRINE", "Doutrina invalida.", 400);
      }
      const passive = catalogItem("doutrines", requestedPassive);
      if (passive === null || !catalogItemEnabled(passive)) {
        return equipError("INVALID_DOCTRINE", "Doutrina indisponivel.", 400);
      }
      const unlock = Math.max(PASSIVE_UNLOCK_LEVEL, itemUnlockLevel(passive, PASSIVE_UNLOCK_LEVEL));
      if (state.player.level < unlock) {
        return equipError("DOCTRINE_LOCKED", "Doutrina bloqueada para este nivel.", 409);
      }
    }
    passiveId = requestedPassive;
  }

  if (hasOwn(body, "pet_id")) {
    const requestedPet = optionalString(body.pet_id);
    if (requestedPet !== null) {
      if (!ITEM_ID_PATTERN.test(requestedPet)) {
        return equipError("INVALID_FAMILIAR", "Familiar invalido.", 400);
      }
      const pet = catalogItem("familiars", requestedPet);
      if (pet === null || !catalogItemEnabled(pet)) {
        return equipError("INVALID_FAMILIAR", "Familiar indisponivel.", 400);
      }
      const unlock = Math.max(PET_UNLOCK_LEVEL, itemUnlockLevel(pet, PET_UNLOCK_LEVEL));
      if (state.player.level < unlock) {
        return equipError("FAMILIAR_LOCKED", "Familiar bloqueado para este nivel.", 409);
      }
    }
    petId = requestedPet;
  }

  const update = {
    weapon_type: weaponType,
    weapon_quality: weaponQuality,
    spell_slots: trimTrailingEmptySpellSlots(spellSlots),
    passive_id: passiveId,
    pet_id: petId,
  };
  return {
    value: {
      update,
      summary: {
        weapon_type: update.weapon_type,
        weapon_quality: update.weapon_quality,
        spell_slots: update.spell_slots,
        passive_id: update.passive_id,
        pet_id: update.pet_id,
      },
    },
    error: null,
  };
}

export function buildStatePayload(state: ProgressionBuildState): Record<string, unknown> {
  const spellSlots = normalizedSpellSlots(state.build);
  const equipped = spellSlots.filter((spellId): spellId is string =>
    typeof spellId === "string" && spellId !== ""
  );
  const behaviors = Object.fromEntries(
    state.spellBehaviors.map((row) => [
      row.spell_id,
      normalizeBehaviorOrDefault(row.behavior, DEFAULT_SPELL_BEHAVIOR),
    ]),
  );
  return {
    ok: true,
    player: {
      level: state.player.level,
      power: state.player.power,
    },
    build: state.build,
    combat_build: {
      power: state.player.power,
      weapon_type: state.build.weapon_type,
      weapon_quality: state.build.weapon_quality ?? DEFAULT_WEAPON_QUALITY,
      weapon_level: state.build.weapon_level,
      passive_id: state.build.passive_id,
      passive_level: state.build.passive_level,
      pet_id: state.build.pet_id,
      pet_level: state.build.pet_level,
      instrument: optionForCurrent("weapons", state.build.weapon_type, state.player.level),
      doctrine: state.build.passive_id === null ? null : optionForCurrent(
        "doutrines",
        state.build.passive_id,
        state.player.level,
        PASSIVE_UNLOCK_LEVEL,
      ),
      familiar: state.build.pet_id === null
        ? null
        : optionForCurrent("familiars", state.build.pet_id, state.player.level, PET_UNLOCK_LEVEL),
      spell_slots: [1, 2, 3].map((slotIndex) => {
        const spellId = spellSlots[slotIndex - 1];
        return {
          slot_index: slotIndex,
          unlock_level: SPELL_SLOT_UNLOCK_LEVELS.get(slotIndex) ?? 25,
          unlocked: state.player.level >= (SPELL_SLOT_UNLOCK_LEVELS.get(slotIndex) ?? 25),
          spell_id: spellId ?? null,
          spell: spellId === null ? null : optionForCurrent("spells", spellId, state.player.level),
          behavior: spellId === null
            ? DEFAULT_SPELL_BEHAVIOR
            : behaviors[spellId] ?? DEFAULT_SPELL_BEHAVIOR,
        };
      }),
      equipped_spells: equipped.map((spellId) => ({
        spell_id: spellId,
        behavior: behaviors[spellId] ?? DEFAULT_SPELL_BEHAVIOR,
      })),
      spell_behaviors: behaviors,
      potion_slots: state.potionSlots.map((slot) => ({
        slot_index: slot.slot_index,
        unlocked: true,
        potion_id: slot.potion_id,
        behavior: normalizeBehaviorOrDefault(slot.behavior, DEFAULT_POTION_BEHAVIOR),
        updated_at: slot.updated_at,
      })),
      inventory: state.inventory.map((item) => ({
        item_id: item.item_id,
        quantity: item.quantity,
        updated_at: item.updated_at,
      })),
      equipment_options: {
        weapons: catalogOptions("weapons", state.player.level, state.build.weapon_type),
        spells: catalogOptions("spells", state.player.level, selectedSet(equipped)),
        doutrines: catalogOptions(
          "doutrines",
          state.player.level,
          state.build.passive_id,
          PASSIVE_UNLOCK_LEVEL,
        ),
        familiars: catalogOptions(
          "familiars",
          state.player.level,
          state.build.pet_id,
          PET_UNLOCK_LEVEL,
        ),
      },
    },
  };
}

export function calculatePower(
  player: Pick<ProgressionPlayerRow, "level">,
  build: ProgressionBuildRow,
): number {
  const weapon = catalogItem("weapons", build.weapon_type);
  const spellTotal = normalizedSpellSlots(build).filter((spellId) => spellId !== null).length;
  const petLevel = build.pet_id === null ? 0 : Math.max(1, numberValue(build.pet_level, 1));
  const passiveLevel = build.passive_id === null
    ? 0
    : Math.max(1, numberValue(build.passive_level, 1));
  return Math.max(
    1,
    Math.round(
      player.level * POWER_WEIGHTS.level +
        build.weapon_level * POWER_WEIGHTS.weaponLevel +
        spellTotal * POWER_WEIGHTS.spellLevel +
        petLevel * POWER_WEIGHTS.petLevel +
        passiveLevel * POWER_WEIGHTS.passiveLevel +
        weaponQualityTierFromCatalog(weapon, build.weapon_quality) *
          POWER_WEIGHTS.weaponQualityTier,
    ),
  );
}

export function equippedSpellIds(build: ProgressionBuildRow): string[] {
  const slots = arrayOfStrings(build.spell_slots);
  return slots.length > 0 ? slots : arrayOfStrings(build.spells_unlocked);
}

export function normalizedSpellSlots(build: ProgressionBuildRow): Array<string | null> {
  const rawSlots = Array.isArray(build.spell_slots) ? build.spell_slots : [];
  const fallback = equippedSpellIds(build);
  const slots: Array<string | null> = [null, null, null];
  const source = rawSlots.length > 0 ? rawSlots : fallback;
  for (let index = 0; index < Math.min(source.length, 3); index += 1) {
    const value = source[index];
    slots[index] = typeof value === "string" && value.trim() !== "" ? value.trim() : null;
  }
  return slots;
}

export function trimTrailingEmptySpellSlots(slots: Array<string | null>): Array<string | null> {
  const next = slots.slice(0, 3);
  while (next.length > 0 && next[next.length - 1] === null) {
    next.pop();
  }
  return next;
}

export function normalizeBehaviorOrDefault(
  value: unknown,
  fallback: ProgressionBehaviorConfig,
): ProgressionBehaviorConfig {
  const normalized = normalizeBehavior(value, fallback);
  return normalized.error === null ? normalized.value : fallback;
}

export function normalizeBehavior(
  value: unknown,
  fallback: ProgressionBehaviorConfig,
): { value: ProgressionBehaviorConfig; error: null } | {
  value: null;
  error: ProgressionDomainError;
} {
  const payload = isObject(value) ? value : {};
  const enabled = typeof payload.enabled === "boolean" ? payload.enabled : fallback.enabled;
  const hp = normalizeCondition(payload.hp, fallback.hp);
  if (hp.error !== null) return { value: null, error: hp.error };
  const mana = normalizeCondition(payload.mana, fallback.mana);
  if (mana.error !== null) return { value: null, error: mana.error };
  return { value: { enabled, hp: hp.value, mana: mana.value }, error: null };
}

export function effectivePower(power: unknown, level: unknown): number {
  const explicitPower = numberValue(power, 0);
  if (explicitPower > 0) {
    return explicitPower;
  }

  return Math.max(50, numberValue(level, 1) * 50);
}

export function spellLevelMap(
  spellIds: string[],
  level: number,
): Record<string, number> {
  const result: Record<string, number> = {};
  for (const spellId of spellIds) {
    result[spellId] = Math.max(1, Math.min(40, Math.trunc(level)));
  }
  return result;
}

export function weaponQualityTierFromQualityId(quality: unknown): number {
  const tiers: Record<string, number> = {
    starter: 0,
    varinha_simples: 0,
    inicial: 0,
    reforcada: 1,
    ritual: 2,
    abissal: 3,
    cosmica: 4,
  };
  return tiers[stringValue(quality, "")] ?? 0;
}

export function catalogItem(collection: string, id: string): CatalogItem | null {
  return catalogItems(collection).find((item) => item.id === id) ?? null;
}

export function catalogItemEnabled(item: CatalogItem): boolean {
  return item.enabled !== false;
}

export function itemUnlockLevel(item: CatalogItem, fallback: number): number {
  return numberValue(item.unlock_level, fallback);
}

export function catalogOptions(
  collection: string,
  playerLevel: number,
  selected: string | Set<string> | null,
  minimumUnlock = 1,
): Record<string, unknown>[] {
  return catalogItems(collection)
    .filter(catalogItemEnabled)
    .map((item) => {
      const equipped = selected instanceof Set ? selected.has(item.id) : selected === item.id;
      const unlock = Math.max(minimumUnlock, itemUnlockLevel(item, minimumUnlock));
      return optionPayload(item, playerLevel, equipped, unlock);
    });
}

export function optionForCurrent(
  collection: string,
  id: string,
  playerLevel: number,
  minimumUnlock = 1,
): Record<string, unknown> {
  const item = catalogItem(collection, id);
  if (item === null) {
    return {
      id,
      display_name: id,
      description: "",
      unlock_level: minimumUnlock,
      enabled: true,
      unlocked: true,
      equipped: true,
    };
  }
  const unlock = Math.max(minimumUnlock, itemUnlockLevel(item, minimumUnlock));
  return optionPayload(item, playerLevel, true, unlock);
}

export function validWeaponQuality(weapon: CatalogItem, qualityId: string): boolean {
  const qualities = Array.isArray(weapon.qualities) ? weapon.qualities : [];
  if (qualities.length === 0) {
    return qualityId === DEFAULT_WEAPON_QUALITY;
  }
  return qualities.some((quality) => isObject(quality) && quality.id === qualityId);
}

export function weaponQualityTierFromCatalog(
  weapon: CatalogItem | null,
  qualityId: string,
): number {
  const qualities = Array.isArray(weapon?.qualities) ? weapon?.qualities as unknown[] : [];
  const found = qualities.find((quality) => isObject(quality) && quality.id === qualityId);
  return isObject(found) ? numberValue(found.tier, 0) : 0;
}

function selectedSet(ids: string[]): Set<string> {
  return new Set(ids);
}

function catalogCollections(): Record<string, unknown[]> {
  const collections = (GRIMOIRE_CATALOG as { collections?: unknown }).collections;
  return isObject(collections) ? collections as Record<string, unknown[]> : {};
}

function catalogItems(collection: string): CatalogItem[] {
  const items = catalogCollections()[collection];
  if (!Array.isArray(items)) return [];
  return items.filter(isObject).map((item) => item as unknown as CatalogItem);
}

function optionPayload(
  item: CatalogItem,
  playerLevel: number,
  equipped: boolean,
  unlockLevel: number,
): Record<string, unknown> {
  const unlocked = playerLevel >= unlockLevel;
  return {
    id: item.id,
    display_name: stringValue(item.display_name, item.id),
    description: stringValue(item.description, ""),
    unlock_level: unlockLevel,
    enabled: catalogItemEnabled(item),
    unlocked,
    equipped,
    locked_reason: unlocked ? null : `Desbloqueia no nivel ${unlockLevel}.`,
  };
}

function normalizeCondition(
  value: unknown,
  fallback: ProgressionBehaviorCondition,
): { value: ProgressionBehaviorCondition; error: null } | {
  value: null;
  error: ProgressionDomainError;
} {
  if (!isObject(value)) {
    return { value: fallback, error: null };
  }
  const mode = stringValue(value.mode, fallback.mode);
  if (mode !== "ignore" && mode !== "below" && mode !== "above") {
    return {
      value: null,
      error: { code: "INVALID_BEHAVIOR", message: "Behavior mode is invalid.", status: 400 },
    };
  }
  const percent = numberValue(value.percent, fallback.percent);
  if (percent < 0 || percent > 100) {
    return {
      value: null,
      error: {
        code: "INVALID_BEHAVIOR_PERCENT",
        message: "Behavior percent must be between 0 and 100.",
        status: 400,
      },
    };
  }
  return { value: { mode, percent: Math.trunc(percent) }, error: null };
}

function equipError(
  code: string,
  message: string,
  status: number,
): { value: null; error: ProgressionDomainError } {
  return { value: null, error: { code, message, status } };
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
}

function positiveIntegerField(
  payload: Record<string, unknown>,
  key: string,
  fallback: number,
): number | null {
  const value = payload[key] ?? fallback;
  const parsed = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(parsed)) return null;
  const integer = Math.trunc(parsed);
  return integer > 0 && integer === parsed ? integer : null;
}

function optionalString(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  if (typeof value !== "string") return null;
  const trimmed = value.trim();
  return trimmed === "" ? null : trimmed;
}

function arrayOfStrings(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string" && item !== "")
    : [];
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

function hasOwn(payload: Record<string, unknown>, key: string): boolean {
  return Object.prototype.hasOwnProperty.call(payload, key);
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
