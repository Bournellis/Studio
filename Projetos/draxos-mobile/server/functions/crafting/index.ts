import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import { type AuthContext, verifiedAuthContext } from "../_shared/auth_context.ts";
import {
  type FoundationGameSaveRow,
  foundationRpcPayload,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import {
  type CraftingInventoryRow,
  type CraftingPotionSlotRow,
  type CraftingProjectionState,
  craftingRecipe,
  craftingStatePayload,
  craftProjection,
  crushBonesConversion,
  DEFAULT_POTION_BEHAVIOR,
  type EconomyResourceRow,
} from "../_shared/economy_domain.ts";
import { type SaveType, saveTypeQuery } from "../_shared/save_context.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "state" | "crush_bones" | "craft";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

interface PlayerRow {
  id: string;
  save_type: SaveType;
  level: number;
}

interface ResourceRow extends EconomyResourceRow {
  player_id: string;
  updated_at: string;
}

interface ConsumableRow extends CraftingInventoryRow {
  player_id: string;
}

interface PotionSlotRow extends CraftingPotionSlotRow {
  player_id: string;
}

interface CraftingState extends CraftingProjectionState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  resources: ResourceRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request: Request) => {
  return withCorsResponse(request, await handleCorsRequest(request));
});

async function handleCorsRequest(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  const apiVersionError = validateApiVersion(request);
  if (apiVersionError !== null) {
    return apiVersionError;
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

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }
    const auth = await verifiedAuthContext(request, {
      supabaseUrl: config.value.supabaseUrl,
      serviceRoleKey: config.value.serviceRoleKey,
    });
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
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

}

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const startedAtMs = performance.now();
  const state = await loadCraftingState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(stateEnvelope(craftingStatePayload(state.value), {
    surface: "crafting",
    saveType: auth.saveType,
    startedAtMs,
  }));
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

  const requestHash = await mutationRequestHash("crafting/crush-bones", body, {
    request_id: requestId,
    save_type: auth.saveType,
    amount,
  });
  const rpc = await restRequest<unknown>(config, "rpc/crush_bones_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: { request_id: requestId, amount },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "CRUSH_BONES_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = foundationRpcPayload(rpc.value);

  const refreshed = await loadCraftingState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...craftingStatePayload(refreshed.value),
    conversion: rpcPayload.conversion ?? crushBonesConversion(amount),
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "crafting",
    saveType: auth.saveType,
  }));
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
  const recipe = craftingRecipe(recipeId);
  if (recipe === undefined) {
    return errorResponse("INVALID_RECIPE", "recipe_id is not part of Crafting v1.", 400);
  }

  const state = await loadCraftingState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }

  const projection = craftProjection(recipe, quantity);
  const requestHash = await mutationRequestHash("crafting/craft", body, {
    request_id: requestId,
    save_type: auth.saveType,
    recipe_id: recipe.id,
    quantity,
    resource_delta: projection.costPayload,
    output: projection.outputPayload,
  });
  const rpc = await restRequest<unknown>(config, "rpc/craft_item_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        recipe_id: recipe.id,
        quantity,
        resource_delta: projection.costPayload,
        output: projection.outputPayload,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "CRAFT_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = foundationRpcPayload(rpc.value);

  const refreshed = await loadCraftingState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...craftingStatePayload(refreshed.value),
    crafted: rpcPayload.crafted ?? {
      recipe_id: recipe.id,
      output: projection.outputPayload,
      cost: projection.costPayload,
    },
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "crafting",
    saveType: auth.saveType,
  }));
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

  const playerId = encodeURIComponent(player.id);
  const gameSavePromise = loadFoundationGameSave(
    config,
    restRequest,
    auth.userId,
    auth.saveType,
    player.id,
  );
  const resourcesPromise = restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=player_id,almas,energia,sangue,cristais,ossos,po_osso,diamante,updated_at&limit=1`,
    { method: "GET" },
  );
  const inventoryPromise = restRequest<ConsumableRow[]>(
    config,
    `player_consumables?player_id=eq.${playerId}&select=player_id,item_id,quantity,updated_at&order=item_id.asc`,
    { method: "GET" },
  );

  await ensurePotionSlot(config, player.id);
  const [gameSave, resourcesResult, inventoryResult, slotsResult] = await Promise.all([
    gameSavePromise,
    resourcesPromise,
    inventoryPromise,
    restRequest<PotionSlotRow[]>(
      config,
      `player_potion_slots?player_id=eq.${playerId}&select=player_id,slot_index,potion_id,behavior,updated_at&order=slot_index.asc`,
      { method: "GET" },
    ),
  ]);
  if (gameSave.error !== null) {
    return { value: null, error: gameSave.error };
  }
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
      gameSave: gameSave.value,
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

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/crush-bones")) return "crush_bones";
  if (pathname.endsWith("/craft")) return "craft";
  return null;
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

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
