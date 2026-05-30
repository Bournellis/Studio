import {
  buildStatePayload,
  calculatePower,
  DEFAULT_POTION_BEHAVIOR,
  effectivePower,
  normalizedSpellSlots,
  type ProgressionBuildRow,
  type ProgressionBuildState,
  resolveEquipRequest,
  spellLevelMap,
  weaponQualityTierFromQualityId,
} from "../functions/_shared/progression_domain.ts";
import {
  buildStatePayload as supabaseBuildStatePayload,
  calculatePower as supabaseCalculatePower,
  effectivePower as supabaseEffectivePower,
} from "../../supabase/functions/_shared/progression_domain.ts";

const SERVER_MODULE_PATH = "server/functions/_shared/progression_domain.ts";
const SUPABASE_MODULE_PATH = "supabase/functions/_shared/progression_domain.ts";

Deno.test("progression domain module is mirrored and adapter-free", async () => {
  const serverModule = await Deno.readTextFile(SERVER_MODULE_PATH);
  const supabaseModule = await Deno.readTextFile(SUPABASE_MODULE_PATH);

  assertEq(
    normalizeNewlines(serverModule),
    normalizeNewlines(supabaseModule),
    "server and supabase progression domain modules should mirror exactly",
  );
  assertNotIncludes(
    serverModule,
    "Deno.serve",
    "progression domain must not serve HTTP",
  );
  assertNotIncludes(
    serverModule,
    "fetch(",
    "progression domain must not call Supabase REST",
  );
  assertNotIncludes(
    serverModule,
    "rpc/",
    "progression domain must not call transactional RPCs",
  );
});

Deno.test("progression domain preserves build state payload contract", () => {
  const state = sampleState({
    player: { id: "player-1", level: 6, power: 333 },
    build: sampleBuild({
      weapon_quality: "starter",
      spell_slots: ["sussurro_medo"],
      spells_unlocked: [],
    }),
  });

  const payload = buildStatePayload(state);
  const supabasePayload = supabaseBuildStatePayload(state);

  assertEq(stableStringify(payload), stableStringify(supabasePayload));
  assertEq(payload.ok, true);
  assertEq(numberField(objectField(payload, "player"), "power"), 333);

  const combatBuild = objectField(payload, "combat_build");
  assertEq(stringField(combatBuild, "weapon_quality"), "starter");
  assertEq(arrayField(combatBuild, "equipped_spells").length, 1);
  assertEq(arrayField(combatBuild, "potion_slots").length, 1);

  const spellSlots = arrayField(combatBuild, "spell_slots");
  assertEq(spellSlots.length, 3);
  const firstSlot = objectValue(spellSlots[0]);
  const secondSlot = objectValue(spellSlots[1]);
  assertEq(numberField(firstSlot, "unlock_level"), 3);
  assertEq(booleanField(firstSlot, "unlocked"), true);
  assertEq(stringField(firstSlot, "spell_id"), "sussurro_medo");
  assertEq(numberField(secondSlot, "unlock_level"), 7);
  assertEq(booleanField(secondSlot, "unlocked"), false);

  const options = objectField(combatBuild, "equipment_options");
  const spells = arrayField(options, "spells").map(objectValue);
  const lockedSpell = spells.find((spell) =>
    stringField(spell, "id") === "coroa_cinzas"
  );
  assert(lockedSpell !== undefined, "coroa_cinzas option should exist");
  assertEq(booleanField(lockedSpell, "unlocked"), false);
  assertEq(
    stringField(lockedSpell, "locked_reason"),
    "Desbloqueia no nivel 25.",
  );
});

Deno.test("progression domain validates equip unlocks and duplicate spells", () => {
  const lowLevel = sampleState({
    player: { id: "player-1", level: 6, power: 120 },
  });

  const lockedSlot = resolveEquipRequest({
    spell_slots: [{ slot_index: 2, spell_id: "descarga_nervosa" }],
  }, lowLevel);
  assertEq(lockedSlot.error?.code, "SPELL_SLOT_LOCKED");

  const unknownPet = resolveEquipRequest({
    pet_id: "familiar_inexistente",
  }, sampleState({ player: { id: "player-1", level: 25, power: 120 } }));
  assertEq(unknownPet.error?.code, "INVALID_FAMILIAR");

  const duplicateSpell = resolveEquipRequest({
    spell_slots: [
      { slot_index: 1, spell_id: "sussurro_medo" },
      { slot_index: 2, spell_id: "sussurro_medo" },
    ],
  }, sampleState({ player: { id: "player-1", level: 25, power: 120 } }));
  assertEq(duplicateSpell.error?.code, "DUPLICATE_SPELL");

  const accepted = resolveEquipRequest({
    weapon: { type: "varinha_cinzas", quality: "reforcada" },
    spell_slots: [{ slot_index: 1, spell_id: "sussurro_medo" }],
    passive_id: "doutrina_pavor",
    pet_id: "corvo_pressagio",
  }, sampleState({ player: { id: "player-1", level: 25, power: 120 } }));
  assertEq(accepted.error, null);
  assertEq(accepted.value?.update.weapon_quality, "reforcada");
  assertEq(accepted.value?.update.passive_id, "doutrina_pavor");
  assertEq(accepted.value?.update.pet_id, "corvo_pressagio");
});

Deno.test("progression domain projects runtime power and battle helper values", () => {
  const starterBuild = sampleBuild({
    weapon_level: 4,
    spell_slots: ["sussurro_medo"],
    pet_id: null,
    passive_id: null,
  });

  assertEq(calculatePower({ level: 10 }, starterBuild), 572);
  assertEq(supabaseCalculatePower({ level: 10 }, starterBuild), 572);

  const equippedBuild = sampleBuild({
    weapon_quality: "reforcada",
    weapon_level: 4,
    spell_slots: ["sussurro_medo", "descarga_nervosa"],
    pet_id: "corvo_pressagio",
    pet_level: 3,
    passive_id: "doutrina_pavor",
    passive_level: 2,
  });
  assertEq(calculatePower({ level: 10 }, equippedBuild), 788);

  assertEq(effectivePower(0, 2), 100);
  assertEq(effectivePower(77, 2), 77);
  assertEq(supabaseEffectivePower(0, 2), 100);
  assertEq(spellLevelMap(["sussurro_medo"], 99).sussurro_medo, 40);
  assertEq(weaponQualityTierFromQualityId("starter"), 0);
  assertEq(weaponQualityTierFromQualityId("cosmica"), 4);
  assertEq(
    normalizedSpellSlots(sampleBuild({
      spell_slots: [],
      spells_unlocked: ["sussurro_medo"],
    }))[0],
    "sussurro_medo",
  );
});

function sampleState(
  overrides: Partial<ProgressionBuildState> = {},
): ProgressionBuildState {
  return {
    player: { id: "player-1", level: 25, power: 572 },
    build: sampleBuild(),
    inventory: [{
      item_id: "pocao_vida",
      quantity: 2,
      updated_at: "2026-05-30T00:00:00.000Z",
    }],
    potionSlots: [{
      slot_index: 1,
      potion_id: "pocao_vida",
      behavior: DEFAULT_POTION_BEHAVIOR,
      updated_at: "2026-05-30T00:00:00.000Z",
    }],
    spellBehaviors: [],
    ...overrides,
  };
}

function sampleBuild(
  overrides: Partial<ProgressionBuildRow> = {},
): ProgressionBuildRow {
  return {
    weapon_type: "varinha_cinzas",
    weapon_quality: "starter",
    weapon_level: 1,
    spell_slots: [],
    spells_unlocked: [],
    pet_id: null,
    pet_level: 1,
    passive_id: null,
    passive_level: 1,
    ...overrides,
  };
}

function normalizeNewlines(value: string): string {
  return value.replace(/\r\n/g, "\n");
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function objectValue(value: unknown): Record<string, unknown> {
  assert(isObject(value), `value should be object: ${JSON.stringify(value)}`);
  return value;
}

function objectField(
  payload: Record<string, unknown>,
  key: string,
): Record<string, unknown> {
  return objectValue(payload[key]);
}

function arrayField(payload: Record<string, unknown>, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  if (typeof value === "number") return String(value);
  return typeof value === "string" ? value : "";
}

function numberField(payload: Record<string, unknown>, key: string): number {
  const value = payload[key];
  if (typeof value === "number") return value;
  if (typeof value === "string") return Number(value);
  throw new Error(`${key} should be numeric, got ${JSON.stringify(value)}`);
}

function booleanField(payload: Record<string, unknown>, key: string): boolean {
  const value = payload[key];
  assert(typeof value === "boolean", `${key} should be boolean`);
  return value;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message?: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message ?? "values should match"}. Expected ${
        JSON.stringify(expected)
      }, got ${JSON.stringify(actual)}`,
    );
  }
}

function assertNotIncludes(
  actual: string,
  search: string,
  message: string,
): void {
  if (actual.includes(search)) {
    throw new Error(`${message}. Unexpected ${search}.`);
  }
}
