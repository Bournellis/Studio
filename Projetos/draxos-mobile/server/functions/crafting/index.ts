import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

type Route = "state" | "crush_bones" | "craft";
type ResourceKey = "almas" | "energia" | "sangue" | "cristais" | "ossos" | "po_osso" | "diamante";

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

interface ResourceRow {
  player_id: string;
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  po_osso: string | number;
  diamante: string | number;
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

interface IdempotencyRow {
  response_payload: unknown;
}

interface CraftingState {
  player: PlayerRow;
  resources: ResourceRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
}

interface PotionDefinition {
  id: string;
  displayName: string;
  description: string;
  effect: Record<string, unknown>;
  defaultBehavior: BehaviorConfig;
}

interface CraftingRecipe {
  id: string;
  displayName: string;
  input: Partial<Record<ResourceKey, number>>;
  output: { itemId: string; quantity: number };
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
const DEFAULT_POTION_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "below", percent: 40 },
  mana: { mode: "ignore", percent: 0 },
};
const POTIONS: PotionDefinition[] = [
  {
    id: "pocao_vida",
    displayName: "Pocao de Vida",
    description: "Recupera 20% da vida maxima em 5 segundos.",
    effect: {
      type: "heal_over_time",
      total_percent_max_hp: 20,
      duration_seconds: 5,
      tick_percent_max_hp: 4,
      tick_seconds: 1,
    },
    defaultBehavior: DEFAULT_POTION_BEHAVIOR,
  },
];
const RECIPES: CraftingRecipe[] = [
  {
    id: "craft_pocao_vida",
    displayName: "Criar Pocao de Vida",
    input: { po_osso: 50 },
    output: { itemId: "pocao_vida", quantity: 1 },
  },
];

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown crafting endpoint.", 404);
    }
    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /crafting/state.", 405);
    }
    if (route === "crush_bones" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /crafting/crush-bones.", 405);
    }
    if (route === "craft" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /crafting/craft.", 405);
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
    if (route === "crush_bones") {
      return await handleCrushBones(request, auth.value, config.value);
    }
    return await handleCraft(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected crafting service error.", 500);
  }
});

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const state = await loadCraftingState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(craftingStatePayload(state.value));
}

async function handleCrushBones(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const amount = positiveIntegerField(body, "amount", 1);
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (amount === null) {
    return errorResponse("INVALID_AMOUNT", "amount must be a positive integer.", 400);
  }

  const state = await loadCraftingState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "crafting/crush-bones",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  if (numberValue(state.value.resources.ossos, 0) < amount) {
    return errorResponse("INSUFFICIENT_RESOURCES", "Not enough Ossos to crush.", 409);
  }

  const now = new Date().toISOString();
  const patch = {
    ossos: numberValue(state.value.resources.ossos, 0) - amount,
    po_osso: numberValue(state.value.resources.po_osso, 0) + amount,
    updated_at: now,
  };
  const resourcePatch = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${encodeURIComponent(state.value.player.id)}&select=*`,
    {
      method: "PATCH",
      headers: { prefer: "return=representation" },
      body: JSON.stringify(patch),
    },
  );
  if (resourcePatch.error !== null || resourcePatch.value.length === 0) {
    return errorResponse("CRUSH_BONES_FAILED", "Unable to crush Ossos.", 500);
  }

  const delta = { ossos: -amount, po_osso: amount };
  const ledger = await insertResourceLedger(
    config,
    state.value.player.id,
    "crafting/crush-bones",
    requestId,
    delta,
  );
  if (ledger !== null) {
    return errorResponse(ledger.code, ledger.message, ledger.status);
  }

  const refreshed = await loadCraftingState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...craftingStatePayload(refreshed.value),
    conversion: { input: { ossos: amount }, output: { po_osso: amount } },
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "crafting/crush-bones",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function handleCraft(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const recipeId = stringField(body, "recipe_id");
  const quantity = positiveIntegerField(body, "quantity", 1);
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (quantity === null) {
    return errorResponse("INVALID_QUANTITY", "quantity must be a positive integer.", 400);
  }
  const recipe = RECIPES.find((item) => item.id === recipeId);
  if (recipe === undefined) {
    return errorResponse("INVALID_RECIPE", "recipe_id is not part of Crafting v1.", 400);
  }

  const state = await loadCraftingState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "crafting/craft",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  const cost = scaledResourceDelta(recipe.input, -quantity);
  if (!canApplyDelta(state.value.resources, cost)) {
    return errorResponse("INSUFFICIENT_RESOURCES", "Not enough resources for this recipe.", 409);
  }

  const updatedResources = await applyResources(config, state.value.resources, cost);
  if (updatedResources.error !== null) {
    return errorResponse(
      updatedResources.error.code,
      updatedResources.error.message,
      updatedResources.error.status,
    );
  }

  const outputQuantity = recipe.output.quantity * quantity;
  const existingItem = state.value.inventory.find((item) => item.item_id === recipe.output.itemId);
  const nextQuantity = (existingItem?.quantity ?? 0) + outputQuantity;
  const upsertItem = await restRequest<ConsumableRow[]>(
    config,
    "player_consumables?on_conflict=player_id,item_id&select=*",
    {
      method: "POST",
      headers: { prefer: "resolution=merge-duplicates,return=representation" },
      body: JSON.stringify({
        player_id: state.value.player.id,
        item_id: recipe.output.itemId,
        quantity: nextQuantity,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (upsertItem.error !== null || upsertItem.value.length === 0) {
    return errorResponse("CRAFT_FAILED", "Unable to add crafted item.", 500);
  }

  const ledger = await insertResourceLedger(
    config,
    state.value.player.id,
    "crafting/craft",
    requestId,
    resourceDelta(cost),
  );
  if (ledger !== null) {
    return errorResponse(ledger.code, ledger.message, ledger.status);
  }
  const itemLedger = await insertItemLedger(
    config,
    state.value.player.id,
    "crafting/craft",
    requestId,
    recipe.output.itemId,
    outputQuantity,
    { recipe_id: recipe.id },
  );
  if (itemLedger !== null) {
    return errorResponse(itemLedger.code, itemLedger.message, itemLedger.status);
  }

  const refreshed = await loadCraftingState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...craftingStatePayload(refreshed.value),
    crafted: {
      recipe_id: recipe.id,
      output: { item_id: recipe.output.itemId, quantity: outputQuantity },
      cost: resourceDelta(cost),
    },
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "crafting/craft",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function loadCraftingState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: CraftingState; error: null } | { value: null; error: RestError }> {
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
  const resourcesResult = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=player_id,almas,energia,sangue,cristais,ossos,po_osso,diamante,updated_at&limit=1`,
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
  if (
    resourcesResult.error !== null || inventoryResult.error !== null || slotsResult.error !== null
  ) {
    return { value: null, error: stateReadError() };
  }
  const resources = resourcesResult.value[0] ?? null;
  if (resources === null) {
    return {
      value: null,
      error: { code: "RESOURCES_NOT_FOUND", message: "Resources row is missing.", status: 409 },
    };
  }
  return {
    value: {
      player,
      resources,
      inventory: inventoryResult.value,
      potionSlots: slotsResult.value,
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

async function applyResources(
  config: EdgeConfig,
  resources: ResourceRow,
  delta: Partial<Record<ResourceKey, number>>,
): Promise<{ value: ResourceRow; error: null } | { value: null; error: RestError }> {
  const patch: Record<string, number | string> = {};
  for (const key of resourceKeys()) {
    const change = numberValue(delta[key], 0);
    if (change !== 0) {
      patch[key] = numberValue(resources[key], 0) + change;
    }
  }
  patch.updated_at = new Date().toISOString();
  const result = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${encodeURIComponent(resources.player_id)}&select=*`,
    {
      method: "PATCH",
      headers: { prefer: "return=representation" },
      body: JSON.stringify(patch),
    },
  );
  if (result.error !== null || result.value.length === 0) {
    return {
      value: null,
      error: {
        code: "RESOURCES_UPDATE_FAILED",
        message: "Unable to apply resource delta.",
        status: 500,
      },
    };
  }
  return { value: result.value[0], error: null };
}

function craftingStatePayload(state: CraftingState): Record<string, unknown> {
  return {
    ok: true,
    resources: state.resources,
    crafting: {
      resources: {
        ossos: numberValue(state.resources.ossos, 0),
        po_osso: numberValue(state.resources.po_osso, 0),
      },
      potions: POTIONS.map(potionPayload),
      recipes: RECIPES.map(recipePayload),
      inventory: state.inventory.map((item) => ({
        item_id: item.item_id,
        quantity: item.quantity,
        updated_at: item.updated_at,
      })),
      potion_slots: state.potionSlots.map((slot) => ({
        slot_index: slot.slot_index,
        unlocked: true,
        potion_id: slot.potion_id,
        behavior: normalizeBehaviorOrDefault(slot.behavior, DEFAULT_POTION_BEHAVIOR),
        updated_at: slot.updated_at,
      })),
    },
  };
}

function potionPayload(potion: PotionDefinition): Record<string, unknown> {
  return {
    id: potion.id,
    display_name: potion.displayName,
    description: potion.description,
    effect: potion.effect,
    default_behavior: potion.defaultBehavior,
  };
}

function recipePayload(recipe: CraftingRecipe): Record<string, unknown> {
  return {
    id: recipe.id,
    display_name: recipe.displayName,
    input: resourceDelta(recipe.input),
    output: {
      item_id: recipe.output.itemId,
      quantity: recipe.output.quantity,
    },
  };
}

function scaledResourceDelta(
  input: Partial<Record<ResourceKey, number>>,
  quantityMultiplier: number,
): Partial<Record<ResourceKey, number>> {
  const delta: Partial<Record<ResourceKey, number>> = {};
  for (const [key, value] of Object.entries(input)) {
    const resourceKey = key as ResourceKey;
    delta[resourceKey] = numberValue(value, 0) * quantityMultiplier;
  }
  return delta;
}

function canApplyDelta(
  resources: ResourceRow,
  delta: Partial<Record<ResourceKey, number>>,
): boolean {
  for (const key of resourceKeys()) {
    const nextValue = numberValue(resources[key], 0) + numberValue(delta[key], 0);
    if (nextValue < 0) return false;
  }
  return true;
}

function resourceDelta(delta: Partial<Record<ResourceKey, number>>): Record<string, number> {
  const payload: Record<string, number> = {};
  for (const key of resourceKeys()) {
    const value = numberValue(delta[key], 0);
    if (value !== 0) payload[key] = value;
  }
  return payload;
}

function normalizeBehaviorOrDefault(value: unknown, fallback: BehaviorConfig): BehaviorConfig {
  const normalized = normalizeBehavior(value);
  return normalized.error === null ? normalized.value : fallback;
}

function normalizeBehavior(value: unknown): { value: BehaviorConfig; error: null } | {
  value: null;
  error: RestError;
} {
  const payload = isObject(value) ? value : {};
  const enabled = typeof payload.enabled === "boolean" ? payload.enabled : true;
  const hp = normalizeCondition(payload.hp, { mode: "ignore", percent: 0 });
  if (hp.error !== null) return { value: null, error: hp.error };
  const mana = normalizeCondition(payload.mana, { mode: "ignore", percent: 0 });
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
    message: "Unable to persist crafting idempotency.",
    status: 500,
  };
}

async function insertResourceLedger(
  config: EdgeConfig,
  playerId: string,
  source: string,
  requestId: string,
  delta: Record<string, number>,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "resource_transactions", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({ player_id: playerId, source, request_id: requestId, delta }),
  });
  return result.error === null ? null : {
    code: "LEDGER_WRITE_FAILED",
    message: "Unable to record resource ledger.",
    status: 500,
  };
}

async function insertItemLedger(
  config: EdgeConfig,
  playerId: string,
  source: string,
  requestId: string,
  itemId: string,
  delta: number,
  payload: Record<string, unknown>,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "item_transactions", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      source,
      request_id: requestId,
      item_id: itemId,
      delta,
      payload,
    }),
  });
  return result.error === null ? null : {
    code: "ITEM_LEDGER_WRITE_FAILED",
    message: "Unable to record item ledger.",
    status: 500,
  };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/crush-bones")) return "crush_bones";
  if (pathname.endsWith("/craft")) return "craft";
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
        message: "Crafting function is missing Supabase runtime configuration.",
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
  return { code: "STATE_READ_FAILED", message: "Unable to load crafting state.", status: 500 };
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

function resourceKeys(): ResourceKey[] {
  return ["almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"];
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
