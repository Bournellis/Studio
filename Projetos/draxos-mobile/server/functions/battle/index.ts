import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import { type CombatantBuild, simulateFirstSliceBattle } from "../_shared/battle_simulator.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

type Route = "request" | "latest";
type BattleMode = "MVP_ONLY" | "FIRST_SLICE_SIM";

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
  is_anonymous?: unknown;
}

interface PlayerRow {
  id: string;
  username?: string | null;
  save_type?: SaveType;
  level?: number;
  xp?: number;
}

interface ResourceRow {
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  diamante: string | number;
}

interface BuildRow {
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

interface BotBuildRow {
  id: string;
  power: number;
  power_band: string;
  build_data: unknown;
  is_active: boolean;
}

interface BattleRow {
  id: string;
  schema_version: string;
  seed: string;
  defender_id: string;
  defender_is_bot: boolean;
  result: unknown;
  event_log: unknown;
  reward_payload: unknown;
}

interface IdempotencyRow {
  response_payload: unknown;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const DEFAULT_FIRST_SLICE_BOT_ID = "bot_effect_trainer_01";
const BOT_ID_PATTERN = /^[a-z0-9_]+$/;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown battle endpoint.", 404);
    }

    if (route === "request" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /battle/request.", 405);
    }

    if (route === "latest" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /battle/latest.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "request") {
      return await handleRequest(request, auth.value, config.value);
    }

    return await handleLatest(auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected battle service error.", 500);
  }
});

async function handleRequest(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }

  const requestId = stringField(body, "request_id");
  const mode = battleMode(stringField(body, "mode") || "MVP_ONLY");

  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  if (mode === null) {
    return errorResponse(
      "UNSUPPORTED_MODE",
      "Use MVP_ONLY or FIRST_SLICE_SIM for battle/request.",
      400,
    );
  }

  if (mode === "MVP_ONLY") {
    return await handleMvpRequest(auth, config, requestId, mode);
  }

  const opponentBotId = stringField(body, "opponent_bot_id") || DEFAULT_FIRST_SLICE_BOT_ID;
  if (!BOT_ID_PATTERN.test(opponentBotId)) {
    return errorResponse("INVALID_BOT_ID", "opponent_bot_id is invalid.", 400);
  }

  return await handleFirstSliceRequest(auth, config, requestId, opponentBotId);
}

async function handleMvpRequest(
  auth: AuthContext,
  config: EdgeConfig,
  requestId: string,
  mode: BattleMode,
): Promise<Response> {
  const rpc = await restRequest<unknown>(config, "rpc/request_mvp_battle", {
    method: "POST",
    body: JSON.stringify({
      p_auth_user_id: auth.userId,
      p_request_id: requestId,
      p_mode: mode,
      p_save_type: auth.saveType,
    }),
  });

  if (rpc.error !== null) {
    const mapped = mapDatabaseError(rpc.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  return jsonResponse(rpc.value);
}

async function handleFirstSliceRequest(
  auth: AuthContext,
  config: EdgeConfig,
  requestId: string,
  opponentBotId: string,
): Promise<Response> {
  const playerState = await loadPlayerState(auth, config);
  if (playerState.error !== null) {
    return errorResponse(
      playerState.error.code,
      playerState.error.message,
      playerState.error.status,
    );
  }

  const playerId = encodeURIComponent(playerState.value.player.id);
  const existing = await restRequest<IdempotencyRow[]>(
    config,
    `idempotency_keys?player_id=eq.${playerId}&endpoint=eq.battle/request&request_id=eq.${
      encodeURIComponent(requestId)
    }&select=response_payload&limit=1`,
    { method: "GET" },
  );
  if (existing.error !== null) {
    return errorResponse("STATE_READ_FAILED", "Unable to check battle idempotency.", 500);
  }
  const existingPayload = existing.value[0]?.response_payload ?? null;
  if (existingPayload !== null) {
    return jsonResponse(existingPayload);
  }

  const botResult = await restRequest<BotBuildRow[]>(
    config,
    `bot_builds?id=eq.${
      encodeURIComponent(opponentBotId)
    }&is_active=eq.true&select=id,power,power_band,build_data,is_active&limit=1`,
    { method: "GET" },
  );
  if (botResult.error !== null) {
    return errorResponse("STATE_READ_FAILED", "Unable to load first-slice bot.", 500);
  }
  const bot = botResult.value[0] ?? null;
  if (bot === null || !isObject(bot.build_data)) {
    return errorResponse("SIMULATION_FAILED", "First-slice bot build is unavailable.", 500);
  }

  const battleId = crypto.randomUUID();
  const seed = `first_slice:${playerState.value.player.id}:${requestId}`;
  const simulation = simulateFirstSliceBattle({
    battleId,
    seed,
    player: playerCombatant(playerState.value.player, playerState.value.build),
    opponent: botCombatant(bot),
  });
  const reward = simulation.reward.resources;

  const insertBattle = await restRequest<unknown>(config, "battles", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      id: battleId,
      attacker_id: playerState.value.player.id,
      defender_id: bot.id,
      defender_is_bot: true,
      schema_version: simulation.battleLog.schema_version,
      seed,
      result: simulation.battleLog.result,
      event_log: simulation.battleLog.events,
      reward_payload: simulation.reward,
      reward_applied: true,
      request_id: requestId,
    }),
  });
  if (insertBattle.error !== null) {
    const mapped = mapDatabaseError(insertBattle.error);
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const applyReward = await applyBattleReward(config, playerState.value, requestId, reward);
  if (applyReward !== null) {
    return errorResponse(applyReward.code, applyReward.message, applyReward.status);
  }

  const responsePayload = {
    ok: true,
    battle_log: simulation.battleLog,
    rewards: simulation.reward,
  };
  const insertIdempotency = await restRequest<unknown>(config, "idempotency_keys", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerState.value.player.id,
      endpoint: "battle/request",
      request_id: requestId,
      response_payload: responsePayload,
    }),
  });
  if (insertIdempotency.error !== null) {
    return errorResponse("SIMULATION_FAILED", "Unable to persist battle idempotency.", 500);
  }

  return jsonResponse(responsePayload);
}

async function handleLatest(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,save_type&limit=1`,
    { method: "GET" },
  );

  if (playerResult.error !== null) {
    return errorResponse("STATE_READ_FAILED", "Unable to load player state.", 500);
  }

  const player = playerResult.value[0] ?? null;
  if (player === null) {
    return errorResponse("PLAYER_NOT_FOUND", "Guest account was not created yet.", 404);
  }

  const battleResult = await restRequest<BattleRow[]>(
    config,
    `battles?attacker_id=eq.${
      encodeURIComponent(player.id)
    }&select=id,schema_version,seed,defender_id,defender_is_bot,result,event_log,reward_payload&order=created_at.desc&limit=1`,
    { method: "GET" },
  );

  if (battleResult.error !== null) {
    return errorResponse("BATTLE_READ_FAILED", "Unable to load latest battle.", 500);
  }

  const battle = battleResult.value[0] ?? null;
  if (battle === null) {
    return jsonResponse({
      ok: true,
      battle_log: null,
      rewards: null,
    });
  }

  const rewardPayload = isObject(battle.reward_payload) ? battle.reward_payload : {};
  const events = Array.isArray(battle.event_log) ? battle.event_log : [];
  const lastEvent = events.findLast((event) => isObject(event) && typeof event.t === "number");
  const rewardType = stringValue(rewardPayload.type, "MVP_ONLY");
  const mode = rewardType === "FIRST_SLICE_SIM" ? "FIRST_SLICE_SIM" : "MVP_ONLY";

  return jsonResponse({
    ok: true,
    battle_log: {
      schema_version: battle.schema_version,
      battle_id: battle.id,
      seed: battle.seed,
      mode,
      duration: isObject(lastEvent) ? numberValue(lastEvent.t, 4.2) : 4.2,
      participants: {
        player: { id: player.id, display_name: "Draxos" },
        opponent: {
          id: battle.defender_id,
          display_name: mode === "FIRST_SLICE_SIM"
            ? "Treinador da Primeira Ruina"
            : "Bot de Treino",
          is_bot: battle.defender_is_bot,
        },
      },
      result: battle.result,
      events: battle.event_log,
    },
    rewards: battle.reward_payload,
  });
}

async function loadPlayerState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<
  {
    value: { player: PlayerRow; resources: ResourceRow; build: BuildRow };
    error: null;
  } | { value: null; error: RestError }
> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,username,save_type,level,xp&limit=1`,
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
  const resourcesResult = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=almas,energia,sangue,cristais,ossos,diamante&limit=1`,
    { method: "GET" },
  );
  const buildResult = await restRequest<BuildRow[]>(
    config,
    `builds?player_id=eq.${playerId}&select=weapon_type,weapon_quality,weapon_level,spell_slots,spells_unlocked,pet_id,pet_level,passive_id,passive_level&limit=1`,
    { method: "GET" },
  );

  if (resourcesResult.error !== null || buildResult.error !== null) {
    return { value: null, error: stateReadError() };
  }

  const resources = resourcesResult.value[0] ?? null;
  const build = buildResult.value[0] ?? null;
  if (resources === null || build === null) {
    return {
      value: null,
      error: {
        code: "ACCOUNT_STATE_INCOMPLETE",
        message: "Guest account state is incomplete.",
        status: 409,
      },
    };
  }

  return { value: { player, resources, build }, error: null };
}

async function applyBattleReward(
  config: EdgeConfig,
  state: { player: PlayerRow; resources: ResourceRow },
  requestId: string,
  reward: Record<string, number>,
): Promise<RestError | null> {
  const xp = numberValue(reward.xp, 0);
  const playerPatch = await restRequest<unknown>(
    config,
    `players?id=eq.${encodeURIComponent(state.player.id)}`,
    {
      method: "PATCH",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({
        xp: numberValue(state.player.xp, 0) + xp,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (playerPatch.error !== null) {
    return {
      code: "REWARD_APPLY_FAILED",
      message: "Unable to apply player XP reward.",
      status: 500,
    };
  }

  const resourcePatch = await restRequest<unknown>(
    config,
    `resources?player_id=eq.${encodeURIComponent(state.player.id)}`,
    {
      method: "PATCH",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({
        almas: numberValue(state.resources.almas, 0) + numberValue(reward.almas, 0),
        energia: numberValue(state.resources.energia, 0) + numberValue(reward.energia, 0),
        sangue: numberValue(state.resources.sangue, 0) + numberValue(reward.sangue, 0),
        ossos: numberValue(state.resources.ossos, 0) + numberValue(reward.ossos, 0),
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (resourcePatch.error !== null) {
    return {
      code: "REWARD_APPLY_FAILED",
      message: "Unable to apply resource reward.",
      status: 500,
    };
  }

  const transaction = await restRequest<unknown>(config, "resource_transactions", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: state.player.id,
      source: "battle/request",
      request_id: requestId,
      delta: reward,
    }),
  });
  if (transaction.error !== null) {
    return {
      code: "REWARD_APPLY_FAILED",
      message: "Unable to record battle reward transaction.",
      status: 500,
    };
  }

  return null;
}

function playerCombatant(player: PlayerRow, build: BuildRow): CombatantBuild {
  const spells = arrayOfStrings(build.spell_slots).length > 0
    ? arrayOfStrings(build.spell_slots)
    : arrayOfStrings(build.spells_unlocked);

  return {
    id: player.id,
    displayName: stringValue(player.username, "Draxos"),
    level: numberValue(player.level, 1),
    weaponId: stringValue(build.weapon_type, "varinha_cinzas"),
    weaponLevel: numberValue(build.weapon_level, 1),
    weaponQualityTier: weaponQualityTier(build.weapon_quality),
    spellIds: spells.length > 0 ? spells : ["sussurro_medo"],
    spellLevels: spellLevelMap(
      spells.length > 0 ? spells : ["sussurro_medo"],
      numberValue(player.level, 1),
    ),
    passiveId: build.passive_id ?? undefined,
    passiveLevel: build.passive_id === null ? undefined : numberValue(build.passive_level, 1),
    petId: build.pet_id ?? undefined,
    petLevel: build.pet_id === null ? undefined : numberValue(build.pet_level, 1),
  };
}

function botCombatant(bot: BotBuildRow): CombatantBuild {
  const data = isObject(bot.build_data) ? bot.build_data : {};
  const spellIds = arrayOfStrings(data.spell_ids);
  return {
    id: bot.id,
    displayName: stringValue(data.display_name, "Treinador da Primeira Ruina"),
    level: numberValue(data.level, 5),
    weaponId: stringValue(data.weapon_id, "varinha_cinzas"),
    weaponLevel: numberValue(data.weapon_level, 5),
    weaponQualityTier: weaponQualityTier(stringValue(data.weapon_quality, "reforcada")),
    spellIds: spellIds.length > 0 ? spellIds : ["sussurro_medo"],
    spellLevels: recordOfNumbers(data.spell_levels),
    passiveId: optionalString(data.passive_id),
    passiveLevel: optionalString(data.passive_id) === undefined
      ? undefined
      : numberValue(data.passive_level, 1),
    petId: optionalString(data.pet_id),
    petLevel: optionalString(data.pet_id) === undefined
      ? undefined
      : numberValue(data.pet_level, 1),
  };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/request")) {
    return "request";
  }

  if (pathname.endsWith("/latest")) {
    return "latest";
  }

  return null;
}

function decodeAuthContext(request: Request): { value: AuthContext; error: null } | {
  value: null;
  error: RestError;
} {
  const header = request.headers.get("authorization") ?? "";
  const prefix = "Bearer ";
  if (!header.startsWith(prefix)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Bearer token is required.",
        status: 401,
      },
    };
  }

  const token = header.slice(prefix.length);
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Invalid bearer token.",
        status: 401,
      },
    };
  }

  const payload = decodeJwtPayload(parts[1]);
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Token subject is invalid.",
        status: 401,
      },
    };
  }

  if (payload.is_anonymous === false) {
    return {
      value: null,
      error: {
        code: "AUTH_NOT_ANONYMOUS",
        message: "Use an anonymous Supabase Auth session for the MVP battle request.",
        status: 403,
      },
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

  return {
    value: { userId: payload.sub, saveType },
    error: null,
  };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const decoded = new TextDecoder().decode(bytes);
    const payload: unknown = JSON.parse(decoded);
    if (isObject(payload)) {
      return payload as JwtPayload;
    }
  } catch {
    return null;
  }

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
        message: "Battle function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }

  return {
    value: {
      supabaseUrl: supabaseUrl.replace(/\/$/, ""),
      serviceRoleKey,
    },
    error: null,
  };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    if (isObject(payload)) {
      return payload;
    }
  } catch {
    return null;
  }

  return null;
}

function battleMode(mode: string): BattleMode | null {
  const normalized = mode.trim().toUpperCase();
  if (normalized === "MVP_ONLY" || normalized === "FIRST_SLICE_SIM") {
    return normalized;
  }

  return null;
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
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

  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, {
    ...init,
    headers,
  });
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

  return {
    value: data as T,
    error: null,
  };
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function mapDatabaseError(error: RestError): RestError {
  const message = error.message.toUpperCase();

  if (message.includes("PLAYER_NOT_FOUND")) {
    return {
      code: "PLAYER_NOT_FOUND",
      message: "Guest account was not created yet.",
      status: 404,
    };
  }

  if (message.includes("UNSUPPORTED_MODE")) {
    return {
      code: "UNSUPPORTED_MODE",
      message: "Use MVP_ONLY or FIRST_SLICE_SIM for battle/request.",
      status: 400,
    };
  }

  if (message.includes("INVALID_REQUEST_ID")) {
    return {
      code: "INVALID_REQUEST_ID",
      message: "request_id must be a UUID.",
      status: 400,
    };
  }

  if (message.includes("INVALID_SAVE_TYPE")) {
    return {
      code: "INVALID_SAVE_TYPE",
      message: "Save type must be normal or progression_lab.",
      status: 400,
    };
  }

  if (message.includes("UNAUTHENTICATED")) {
    return {
      code: "UNAUTHENTICATED",
      message: "Anonymous auth session is required.",
      status: 401,
    };
  }

  return {
    code: "SIMULATION_FAILED",
    message: "Battle simulation failed.",
    status: error.status >= 400 ? error.status : 500,
  };
}

function stateReadError(): RestError {
  return {
    code: "STATE_READ_FAILED",
    message: "Unable to load player state.",
    status: 500,
  };
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({
    ok: false,
    error: {
      code,
      message,
    },
  }, status);
}

function arrayOfStrings(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string" && item !== "")
    : [];
}

function recordOfNumbers(value: unknown): Record<string, number> {
  if (!isObject(value)) {
    return {};
  }

  const result: Record<string, number> = {};
  for (const [key, raw] of Object.entries(value)) {
    result[key] = numberValue(raw, 1);
  }
  return result;
}

function spellLevelMap(spellIds: string[], level: number): Record<string, number> {
  const result: Record<string, number> = {};
  for (const spellId of spellIds) {
    result[spellId] = Math.max(1, Math.min(40, Math.trunc(level)));
  }
  return result;
}

function weaponQualityTier(quality: string): number {
  const tiers: Record<string, number> = {
    varinha_simples: 0,
    inicial: 0,
    reforcada: 1,
    ritual: 2,
    abissal: 3,
    cosmica: 4,
  };
  return tiers[quality] ?? 0;
}

function optionalString(value: unknown): string | undefined {
  return typeof value === "string" && value !== "" ? value : undefined;
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function numberValue(value: unknown, fallback: number): number {
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
