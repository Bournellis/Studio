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
  buildStatePayload,
  calculatePower,
  DEFAULT_POTION_BEHAVIOR,
  DEFAULT_SPELL_BEHAVIOR,
  normalizeBehavior,
  type ProgressionBuildRow,
  type ProgressionBuildState,
  type ProgressionConsumableRow,
  type ProgressionPotionSlotRow,
  type ProgressionSpellBehaviorRow,
  resolveEquipRequest,
} from "../_shared/progression_domain.ts";
import { type SaveType, saveTypeQuery } from "../_shared/save_context.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "state" | "equip" | "spell_behavior" | "potion_equip" | "potion_behavior";

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
  power: number;
}

interface BuildRow extends ProgressionBuildRow {
  player_id: string;
  updated_at: string;
}

interface ConsumableRow extends ProgressionConsumableRow {
  player_id: string;
}

interface PotionSlotRow extends ProgressionPotionSlotRow {
  player_id: string;
}

interface SpellBehaviorRow extends ProgressionSpellBehaviorRow {
  player_id: string;
  updated_at: string;
}

interface BuildState extends ProgressionBuildState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  build: BuildRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
  spellBehaviors: SpellBehaviorRow[];
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const ITEM_ID_PATTERN = /^[a-z0-9_]+$/;
const POTION_IDS = new Set(["pocao_vida"]);

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

}

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const startedAtMs = performance.now();
  const state = await loadBuildState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(stateEnvelope(buildStatePayload(state.value), {
    surface: "build",
    saveType: auth.saveType,
    startedAtMs,
  }));
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
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "build",
    saveType: auth.saveType,
  }));
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
  const requestHash = await mutationRequestHash("build/spell-behavior", body, {
    request_id: requestId,
    spell_id: spellId,
    behavior: behavior.value,
  });
  const rpc = await restRequest<unknown>(config, "rpc/build_spell_behavior_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        spell_id: spellId,
        behavior: behavior.value,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "BEHAVIOR_UPDATE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    updated_behavior: { spell_id: spellId, behavior: behavior.value },
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "build",
    saveType: auth.saveType,
  }));
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
  const requestHash = await mutationRequestHash("build/potion/equip", body, {
    request_id: requestId,
    slot_index: slotIndex,
    item_id: requestedItemId,
  });
  const rpc = await restRequest<unknown>(config, "rpc/build_potion_equip_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        slot_index: slotIndex,
        item_id: requestedItemId,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "POTION_EQUIP_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    equipped_potion: { slot_index: slotIndex, potion_id: requestedItemId },
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "build",
    saveType: auth.saveType,
  }));
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
  const requestHash = await mutationRequestHash("build/potion-behavior", body, {
    request_id: requestId,
    slot_index: slotIndex,
    behavior: behavior.value,
  });
  const rpc = await restRequest<unknown>(config, "rpc/build_potion_behavior_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        slot_index: slotIndex,
        behavior: behavior.value,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "BEHAVIOR_UPDATE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const refreshed = await loadBuildState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...buildStatePayload(refreshed.value),
    updated_behavior: { slot_index: slotIndex, behavior: behavior.value },
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "build",
    saveType: auth.saveType,
  }));
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

  const playerId = encodeURIComponent(player.id);
  const gameSavePromise = loadFoundationGameSave(
    config,
    restRequest,
    auth.userId,
    auth.saveType,
    player.id,
  );
  const buildPromise = restRequest<BuildRow[]>(
    config,
    `builds?player_id=eq.${playerId}&select=player_id,weapon_type,weapon_quality,weapon_level,spell_slots,spells_unlocked,pet_id,pet_level,passive_id,passive_level,updated_at&limit=1`,
    { method: "GET" },
  );
  const inventoryPromise = restRequest<ConsumableRow[]>(
    config,
    `player_consumables?player_id=eq.${playerId}&select=player_id,item_id,quantity,updated_at&order=item_id.asc`,
    { method: "GET" },
  );
  const behaviorsPromise = restRequest<SpellBehaviorRow[]>(
    config,
    `player_spell_behaviors?player_id=eq.${playerId}&select=player_id,spell_id,behavior,updated_at&order=spell_id.asc`,
    { method: "GET" },
  );

  await ensurePotionSlot(config, player.id);
  const [gameSave, buildResult, inventoryResult, slotsResult, behaviorsResult] =
    await Promise.all([
      gameSavePromise,
      buildPromise,
      inventoryPromise,
      restRequest<PotionSlotRow[]>(
        config,
        `player_potion_slots?player_id=eq.${playerId}&select=player_id,slot_index,potion_id,behavior,updated_at&order=slot_index.asc`,
        { method: "GET" },
      ),
      behaviorsPromise,
    ]);
  if (gameSave.error !== null) {
    return { value: null, error: gameSave.error };
  }
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
  if (pathname.endsWith("/spell-behavior")) return "spell_behavior";
  if (pathname.endsWith("/potion/equip")) return "potion_equip";
  if (pathname.endsWith("/equip")) return "equip";
  if (pathname.endsWith("/potion-behavior")) return "potion_behavior";
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
