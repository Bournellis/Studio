import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import {
  type FoundationGameSaveRow,
  foundationRpcPayload,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import { GRIMOIRE_CATALOG } from "../_shared/grimoire_catalog.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

type Route = "state" | "equip" | "spell_behavior" | "potion_equip" | "potion_behavior";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
  saveType: SaveType;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

interface JwtPayload {
  sub?: unknown;
}

interface PlayerRow {
  id: string;
  save_type: SaveType;
  level: number;
  power: number;
}

interface BuildRow {
  player_id: string;
  weapon_type: string;
  weapon_quality: string;
  weapon_level: number;
  spell_slots: unknown;
  spells_unlocked: unknown;
  pet_id: string | null;
  pet_level: number;
  passive_id: string | null;
  passive_level: number;
  updated_at: string;
}

interface ConsumableRow {
  player_id: string;
  item_id: string;
  quantity: number;
  updated_at: string;
}

interface PotionSlotRow {
  player_id: string;
  slot_index: number;
  potion_id: string | null;
  behavior: unknown;
  updated_at: string;
}

interface SpellBehaviorRow {
  player_id: string;
  spell_id: string;
  behavior: unknown;
  updated_at: string;
}

interface IdempotencyRow {
  response_payload: unknown;
}

interface BuildState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  build: BuildRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
  spellBehaviors: SpellBehaviorRow[];
}

interface BehaviorConfig {
  enabled: boolean;
  hp: BehaviorCondition;
  mana: BehaviorCondition;
}

interface BehaviorCondition {
  mode: "ignore" | "below" | "above";
  percent: number;
}

interface CatalogItem {
  id: string;
  display_name?: string;
  description?: string;
  enabled?: boolean;
  unlock_level?: number;
  qualities?: unknown;
}

interface EquipResolution {
  update: {
    weapon_type: string;
    weapon_quality: string;
    spell_slots: Array<string | null>;
    passive_id: string | null;
    pet_id: string | null;
  };
  summary: Record<string, unknown>;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const ITEM_ID_PATTERN = /^[a-z0-9_]+$/;
const DEFAULT_WEAPON_QUALITY = "starter";
const SPELL_SLOT_UNLOCK_LEVELS = new Map<number, number>([
  [1, 3],
  [2, 7],
  [3, 25],
]);
const PASSIVE_UNLOCK_LEVEL = 10;
const PET_UNLOCK_LEVEL = 15;
const POWER_WEIGHTS = {
  level: 42,
  weaponLevel: 28,
  spellLevel: 40,
  petLevel: 34,
  passiveLevel: 22,
  weaponQualityTier: 30,
};
const DEFAULT_SPELL_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "ignore", percent: 0 },
  mana: { mode: "ignore", percent: 0 },
};
const DEFAULT_POTION_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "below", percent: 40 },
  mana: { mode: "ignore", percent: 0 },
};
const POTION_IDS = new Set(["pocao_vida"]);

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown build endpoint.", 404);
    }
    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /build/state.", 405);
    }
    if (route === "equip" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /build/equip.", 405);
    }
    if (route === "spell_behavior" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /build/spell-behavior.", 405);
    }
    if (route === "potion_equip" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /build/potion/equip.", 405);
    }
    if (route === "potion_behavior" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /build/potion-behavior.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }
    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "state") {
      return await handleState(auth.value, config.value);
    }
    if (route === "equip") {
      return await handleBuildEquip(request, auth.value, config.value);
    }
    if (route === "spell_behavior") {
      return await handleSpellBehavior(request, auth.value, config.value);
    }
    if (route === "potion_equip") {
      return await handlePotionEquip(request, auth.value, config.value);
    }
    return await handlePotionBehavior(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected build service error.", 500);
  }
});

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const state = await loadBuildState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(buildStatePayload(state.value));
}

async function handleBuildEquip(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const state = await loadBuildState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }

  const resolution = resolveEquipRequest(body, state.value);
  if (resolution.error !== null) {
    return errorResponse(resolution.error.code, resolution.error.message, resolution.error.status);
  }

  const candidateBuild: BuildRow = {
    ...state.value.build,
    ...resolution.value.update,
  };
  const nextPower = calculatePower(state.value.player, candidateBuild);
  const requestHash = await mutationRequestHash("build/equip", body, {
    request_id: requestId,
    save_type: auth.saveType,
    build: resolution.value.update,
    player_power: nextPower,
  });
  const rpc = await restRequest<unknown>(config, "rpc/equip_build_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        build: resolution.value.update,
        equipped_build: resolution.value.summary,
        player_power: nextPower,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "BUILD_EQUIP_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = foundationRpcPayload(rpc.value);

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    equipped_build: rpcPayload.equipped_build ?? resolution.value.summary,
  };
  return jsonResponse(responsePayload);
}

async function handleSpellBehavior(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const spellId = stringField(body, "spell_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (!ITEM_ID_PATTERN.test(spellId)) {
    return errorResponse("INVALID_SPELL", "spell_id is invalid.", 400);
  }
  const behavior = normalizeBehavior(body.behavior, DEFAULT_SPELL_BEHAVIOR);
  if (behavior.error !== null) {
    return errorResponse(behavior.error.code, behavior.error.message, behavior.error.status);
  }

  const state = await loadBuildState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "build/spell-behavior",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  const equippedSpells = equippedSpellIds(state.value.build);
  if (!equippedSpells.includes(spellId)) {
    return errorResponse("SPELL_NOT_EQUIPPED", "Spell behavior can only be set for equipped spells.", 409);
  }

  const upsert = await restRequest<SpellBehaviorRow[]>(
    config,
    "player_spell_behaviors?on_conflict=player_id,spell_id&select=*",
    {
      method: "POST",
      headers: { prefer: "resolution=merge-duplicates,return=representation" },
      body: JSON.stringify({
        player_id: state.value.player.id,
        spell_id: spellId,
        behavior: behavior.value,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (upsert.error !== null || upsert.value.length === 0) {
    return errorResponse("BEHAVIOR_UPDATE_FAILED", "Unable to update spell behavior.", 500);
  }

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    updated_behavior: { spell_id: spellId, behavior: behavior.value },
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "build/spell-behavior",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function handlePotionEquip(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const slotIndex = positiveIntegerField(body, "slot_index", 1);
  const requestedItemId = optionalString(body.item_id);
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (slotIndex !== 1) {
    return errorResponse("INVALID_SLOT", "Only potion slot 1 is available.", 400);
  }
  if (requestedItemId !== null && !POTION_IDS.has(requestedItemId)) {
    return errorResponse("INVALID_POTION", "item_id is not an available potion.", 400);
  }

  const state = await loadBuildState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "build/potion/equip",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  if (requestedItemId !== null) {
    const item = state.value.inventory.find((candidate) => candidate.item_id === requestedItemId);
    if (item === undefined || item.quantity <= 0) {
      return errorResponse("POTION_NOT_OWNED", "This potion is not in inventory.", 409);
    }
  }

  const existingSlot = slotFor(state.value, slotIndex);
  const behavior = normalizeBehaviorOrDefault(existingSlot?.behavior, DEFAULT_POTION_BEHAVIOR);
  const upsert = await restRequest<PotionSlotRow[]>(
    config,
    "player_potion_slots?on_conflict=player_id,slot_index&select=*",
    {
      method: "POST",
      headers: { prefer: "resolution=merge-duplicates,return=representation" },
      body: JSON.stringify({
        player_id: state.value.player.id,
        slot_index: slotIndex,
        potion_id: requestedItemId,
        behavior,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (upsert.error !== null || upsert.value.length === 0) {
    return errorResponse("POTION_EQUIP_FAILED", "Unable to update potion slot.", 500);
  }

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    equipped_potion: { slot_index: slotIndex, potion_id: requestedItemId },
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "build/potion/equip",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function handlePotionBehavior(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const slotIndex = positiveIntegerField(body, "slot_index", 1);
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (slotIndex !== 1) {
    return errorResponse("INVALID_SLOT", "Only potion slot 1 is available.", 400);
  }
  const behavior = normalizeBehavior(body.behavior, DEFAULT_POTION_BEHAVIOR);
  if (behavior.error !== null) {
    return errorResponse(behavior.error.code, behavior.error.message, behavior.error.status);
  }

  const state = await loadBuildState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "build/potion-behavior",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  const existingSlot = slotFor(state.value, slotIndex);
  const upsert = await restRequest<PotionSlotRow[]>(
    config,
    "player_potion_slots?on_conflict=player_id,slot_index&select=*",
    {
      method: "POST",
      headers: { prefer: "resolution=merge-duplicates,return=representation" },
      body: JSON.stringify({
        player_id: state.value.player.id,
        slot_index: slotIndex,
        potion_id: existingSlot?.potion_id ?? null,
        behavior: behavior.value,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (upsert.error !== null || upsert.value.length === 0) {
    return errorResponse("BEHAVIOR_UPDATE_FAILED", "Unable to update potion behavior.", 500);
  }

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    updated_behavior: { slot_index: slotIndex, behavior: behavior.value },
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "build/potion-behavior",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function loadBuildState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: BuildState; error: null } | { value: null; error: RestError }> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,save_type,level,power&limit=1`,
    { method: "GET" },
  );
  if (playerResult.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const player = playerResult.value[0] ?? null;
  if (player === null) {
    return {
      value: null,
      error: {
        code: "PLAYER_NOT_FOUND",
        message: "Guest account was not created yet.",
        status: 404,
      },
    };
  }

  const gameSave = await loadFoundationGameSave(
    config,
    restRequest,
    auth.userId,
    auth.saveType,
    player.id,
  );
  if (gameSave.error !== null) {
    return { value: null, error: gameSave.error };
  }

  await ensurePotionSlot(config, player.id);
  const playerId = encodeURIComponent(player.id);
  const buildResult = await restRequest<BuildRow[]>(
    config,
    `builds?player_id=eq.${playerId}&select=player_id,weapon_type,weapon_quality,weapon_level,spell_slots,spells_unlocked,pet_id,pet_level,passive_id,passive_level,updated_at&limit=1`,
    { method: "GET" },
  );
  const inventoryResult = await restRequest<ConsumableRow[]>(
    config,
    `player_consumables?player_id=eq.${playerId}&select=player_id,item_id,quantity,updated_at&order=item_id.asc`,
    { method: "GET" },
  );
  const slotsResult = await restRequest<PotionSlotRow[]>(
    config,
    `player_potion_slots?player_id=eq.${playerId}&select=player_id,slot_index,potion_id,behavior,updated_at&order=slot_index.asc`,
    { method: "GET" },
  );
  const behaviorsResult = await restRequest<SpellBehaviorRow[]>(
    config,
    `player_spell_behaviors?player_id=eq.${playerId}&select=player_id,spell_id,behavior,updated_at&order=spell_id.asc`,
    { method: "GET" },
  );
  if (
    buildResult.error !== null || inventoryResult.error !== null ||
    slotsResult.error !== null || behaviorsResult.error !== null
  ) {
    return { value: null, error: stateReadError() };
  }
  const build = buildResult.value[0] ?? null;
  if (build === null) {
    return {
      value: null,
      error: { code: "BUILD_NOT_FOUND", message: "Build row is missing.", status: 409 },
    };
  }
  return {
    value: {
      player,
      gameSave: gameSave.value,
      build,
      inventory: inventoryResult.value,
      potionSlots: slotsResult.value,
      spellBehaviors: behaviorsResult.value,
    },
    error: null,
  };
}

function resolveEquipRequest(
  body: Record<string, unknown>,
  state: BuildState,
): { value: EquipResolution; error: null } | { value: null; error: RestError } {
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
    const requestedQuality = isObject(body.weapon)
      ? optionalString(body.weapon.quality)
      : null;
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
          return equipError("SPELL_SLOT_LOCKED", "Espaco de habilidade bloqueado para este nivel.", 409);
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

async function ensurePotionSlot(config: EdgeConfig, playerId: string): Promise<void> {
  await restRequest<unknown>(config, "player_potion_slots", {
    method: "POST",
    headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      slot_index: 1,
      behavior: DEFAULT_POTION_BEHAVIOR,
    }),
  });
}

function buildStatePayload(state: BuildState): Record<string, unknown> {
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
      doctrine: state.build.passive_id === null
        ? null
        : optionForCurrent("doutrines", state.build.passive_id, state.player.level, PASSIVE_UNLOCK_LEVEL),
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
          behavior: spellId === null ? DEFAULT_SPELL_BEHAVIOR : behaviors[spellId] ?? DEFAULT_SPELL_BEHAVIOR,
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

function equippedSpellIds(build: BuildRow): string[] {
  const slots = arrayOfStrings(build.spell_slots);
  return slots.length > 0 ? slots : arrayOfStrings(build.spells_unlocked);
}

function normalizedSpellSlots(build: BuildRow): Array<string | null> {
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

function trimTrailingEmptySpellSlots(slots: Array<string | null>): Array<string | null> {
  const next = slots.slice(0, 3);
  while (next.length > 0 && next[next.length - 1] === null) {
    next.pop();
  }
  return next;
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

function catalogItem(collection: string, id: string): CatalogItem | null {
  return catalogItems(collection).find((item) => item.id === id) ?? null;
}

function catalogItemEnabled(item: CatalogItem): boolean {
  return item.enabled !== false;
}

function itemUnlockLevel(item: CatalogItem, fallback: number): number {
  return numberValue(item.unlock_level, fallback);
}

function optionForCurrent(
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

function catalogOptions(
  collection: string,
  playerLevel: number,
  selected: string | Set<string> | null,
  minimumUnlock = 1,
): Record<string, unknown>[] {
  return catalogItems(collection)
    .filter(catalogItemEnabled)
    .map((item) => {
      const equipped = selected instanceof Set
        ? selected.has(item.id)
        : selected === item.id;
      const unlock = Math.max(minimumUnlock, itemUnlockLevel(item, minimumUnlock));
      return optionPayload(item, playerLevel, equipped, unlock);
    });
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

function validWeaponQuality(weapon: CatalogItem, qualityId: string): boolean {
  const qualities = Array.isArray(weapon.qualities) ? weapon.qualities : [];
  if (qualities.length === 0) {
    return qualityId === DEFAULT_WEAPON_QUALITY;
  }
  return qualities.some((quality) => isObject(quality) && quality.id === qualityId);
}

function weaponQualityTier(weapon: CatalogItem | null, qualityId: string): number {
  const qualities = Array.isArray(weapon?.qualities) ? weapon?.qualities as unknown[] : [];
  const found = qualities.find((quality) => isObject(quality) && quality.id === qualityId);
  return isObject(found) ? numberValue(found.tier, 0) : 0;
}

function calculatePower(player: PlayerRow, build: BuildRow): number {
  const weapon = catalogItem("weapons", build.weapon_type);
  const spellTotal = normalizedSpellSlots(build).filter((spellId) => spellId !== null).length;
  const petLevel = build.pet_id === null ? 0 : Math.max(1, numberValue(build.pet_level, 1));
  const passiveLevel = build.passive_id === null ? 0 : Math.max(1, numberValue(build.passive_level, 1));
  return Math.max(
    1,
    Math.round(
      player.level * POWER_WEIGHTS.level +
        build.weapon_level * POWER_WEIGHTS.weaponLevel +
        spellTotal * POWER_WEIGHTS.spellLevel +
        petLevel * POWER_WEIGHTS.petLevel +
        passiveLevel * POWER_WEIGHTS.passiveLevel +
        weaponQualityTier(weapon, build.weapon_quality) * POWER_WEIGHTS.weaponQualityTier,
    ),
  );
}

function slotFor(state: BuildState, slotIndex: number): PotionSlotRow | undefined {
  return state.potionSlots.find((slot) => slot.slot_index === slotIndex);
}

function normalizeBehaviorOrDefault(value: unknown, fallback: BehaviorConfig): BehaviorConfig {
  const normalized = normalizeBehavior(value, fallback);
  return normalized.error === null ? normalized.value : fallback;
}

function normalizeBehavior(
  value: unknown,
  fallback: BehaviorConfig,
): { value: BehaviorConfig; error: null } | { value: null; error: RestError } {
  const payload = isObject(value) ? value : {};
  const enabled = typeof payload.enabled === "boolean" ? payload.enabled : fallback.enabled;
  const hp = normalizeCondition(payload.hp, fallback.hp);
  if (hp.error !== null) return { value: null, error: hp.error };
  const mana = normalizeCondition(payload.mana, fallback.mana);
  if (mana.error !== null) return { value: null, error: mana.error };
  return { value: { enabled, hp: hp.value, mana: mana.value }, error: null };
}

function normalizeCondition(
  value: unknown,
  fallback: BehaviorCondition,
): { value: BehaviorCondition; error: null } | { value: null; error: RestError } {
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

async function loadIdempotency(
  config: EdgeConfig,
  playerId: string,
  endpoint: string,
  requestId: string,
): Promise<{ value: unknown | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<IdempotencyRow[]>(
    config,
    `idempotency_keys?player_id=eq.${encodeURIComponent(playerId)}&endpoint=eq.${
      encodeURIComponent(endpoint)
    }&request_id=eq.${encodeURIComponent(requestId)}&select=response_payload&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  return { value: result.value[0]?.response_payload ?? null, error: null };
}

async function insertIdempotency(
  config: EdgeConfig,
  playerId: string,
  endpoint: string,
  requestId: string,
  responsePayload: unknown,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "idempotency_keys", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      endpoint,
      request_id: requestId,
      response_payload: responsePayload,
    }),
  });
  return result.error === null ? null : {
    code: "IDEMPOTENCY_WRITE_FAILED",
    message: "Unable to persist build idempotency.",
    status: 500,
  };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/spell-behavior")) return "spell_behavior";
  if (pathname.endsWith("/potion/equip")) return "potion_equip";
  if (pathname.endsWith("/equip")) return "equip";
  if (pathname.endsWith("/potion-behavior")) return "potion_behavior";
  return null;
}

function decodeAuthContext(request: Request): { value: AuthContext; error: null } | {
  value: null;
  error: RestError;
} {
  const header = request.headers.get("authorization") ?? "";
  if (!header.startsWith("Bearer ")) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Bearer token is required.", status: 401 },
    };
  }
  const token = header.slice("Bearer ".length);
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Invalid bearer token.", status: 401 },
    };
  }
  const payload = decodeJwtPayload(parts[1]);
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Token subject is invalid.", status: 401 },
    };
  }
  const saveType = saveTypeFromRequest(request);
  if (saveType === null) {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: "Save type must be normal or progression_lab.",
        status: 400,
      },
    };
  }
  return { value: { userId: payload.sub, saveType }, error: null };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const payload: unknown = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
}

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Build function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

async function restRequest<T>(
  config: EdgeConfig,
  path: string,
  init: RequestInit,
): Promise<{ value: T; error: null } | { value: null; error: RestError }> {
  const headers = new Headers(init.headers);
  headers.set("accept", "application/json");
  headers.set("apikey", config.serviceRoleKey);
  headers.set("authorization", `Bearer ${config.serviceRoleKey}`);
  if (init.body !== undefined) {
    headers.set("content-type", "application/json");
  }
  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, { ...init, headers });
  const text = await response.text();
  const data = text === "" ? null : parseJson(text);
  if (!response.ok) {
    const body = isObject(data) ? data : {};
    return {
      value: null,
      error: {
        code: stringValue(body.code, "REST_ERROR"),
        message: stringValue(body.message, response.statusText),
        status: response.status,
      },
    };
  }
  return { value: data as T, error: null };
}

function stateReadError(): RestError {
  return { code: "STATE_READ_FAILED", message: "Unable to load build state.", status: 500 };
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function equipError(
  code: string,
  message: string,
  status: number,
): { value: null; error: RestError } {
  return { value: null, error: { code, message, status } };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
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
