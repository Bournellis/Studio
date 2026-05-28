import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

type Route = "state" | "spell_behavior" | "potion_equip" | "potion_behavior";

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

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const ITEM_ID_PATTERN = /^[a-z0-9_]+$/;
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
    }&select=id,save_type,level&limit=1`,
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
      build,
      inventory: inventoryResult.value,
      potionSlots: slotsResult.value,
      spellBehaviors: behaviorsResult.value,
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
  const equipped = equippedSpellIds(state.build);
  const behaviors = Object.fromEntries(
    state.spellBehaviors.map((row) => [
      row.spell_id,
      normalizeBehaviorOrDefault(row.behavior, DEFAULT_SPELL_BEHAVIOR),
    ]),
  );
  return {
    ok: true,
    build: state.build,
    combat_build: {
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
    },
  };
}

function equippedSpellIds(build: BuildRow): string[] {
  const slots = arrayOfStrings(build.spell_slots);
  return slots.length > 0 ? slots : arrayOfStrings(build.spells_unlocked);
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

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
