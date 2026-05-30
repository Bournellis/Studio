import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import {
  battleLogFromRow,
  historyEntryFromRow,
  rulesetMetadata,
  rulesetMetadataFromRow,
} from "../_shared/battle_log_projection.ts";
import {
  type BattleConsumableUse,
  type BehaviorConfig,
  type CombatantBuild,
  simulateFirstSliceBattle,
} from "../_shared/battle_simulator.ts";
import {
  effectivePower,
  spellLevelMap,
  weaponQualityTierFromQualityId,
} from "../_shared/progression_domain.ts";
import {
  type FoundationGameSaveRow,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import {
  isProgressionLabSave,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";

type Route = "request" | "latest" | "history" | "replay";
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
  power?: number;
}

interface ResourceRow {
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  po_osso: string | number;
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

interface BattleRow {
  id: string;
  schema_version: string;
  ruleset_id?: string | null;
  ruleset_version?: number | string | null;
  seed: string;
  defender_id: string;
  defender_is_bot: boolean;
  result: unknown;
  event_log: unknown;
  reward_payload: unknown;
  created_at?: string;
}

interface IdempotencyRow {
  response_payload: unknown;
}

interface SeasonRow {
  id: string;
  display_name: string;
  starts_at: string;
  ends_at: string;
}

interface RankingRow {
  season_id: string;
  player_id: string;
  arena_points: number;
  wins: number;
  losses: number;
  updated_at: string;
}

type BattleOutcome = "win" | "loss" | "draw";

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const DEFAULT_FIRST_SLICE_BOT_ID = "bot_effect_trainer_01";
const BOT_ID_PATTERN = /^[a-z0-9_]+$/;
const ARENA_SCORING_MODEL = "alpha_v0_power_adjusted";
const DEFAULT_HISTORY_LIMIT = 10;
const MAX_HISTORY_LIMIT = 20;

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
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /battle/request.",
        405,
      );
    }

    if (route === "latest" && request.method !== "GET") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use GET /battle/latest.",
        405,
      );
    }

    if (route === "history" && request.method !== "GET") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use GET /battle/history.",
        405,
      );
    }

    if (route === "replay" && request.method !== "GET") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use GET /battle/replay?battle_id=...",
        405,
      );
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(
        auth.error.code,
        auth.error.message,
        auth.error.status,
      );
    }

    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(
        config.error.code,
        config.error.message,
        config.error.status,
      );
    }

    if (route === "request") {
      return await handleRequest(request, auth.value, config.value);
    }

    if (route === "latest") {
      return await handleLatest(auth.value, config.value);
    }

    if (route === "history") {
      return await handleHistory(request, auth.value, config.value);
    }

    return await handleReplay(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse(
      "INTERNAL_ERROR",
      "Unexpected battle service error.",
      500,
    );
  }
});

async function handleRequest(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse(
      "INVALID_JSON",
      "Request body must be a JSON object.",
      400,
    );
  }

  const requestId = stringField(body, "request_id");
  const mode = battleMode(stringField(body, "mode") || "MVP_ONLY");

  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse(
      "INVALID_REQUEST_ID",
      "request_id must be a UUID.",
      400,
    );
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

  const opponentBotId = stringField(body, "opponent_bot_id") ||
    DEFAULT_FIRST_SLICE_BOT_ID;
  if (!BOT_ID_PATTERN.test(opponentBotId)) {
    return errorResponse("INVALID_BOT_ID", "opponent_bot_id is invalid.", 400);
  }

  return await handleFirstSliceRequest(
    auth,
    config,
    requestId,
    opponentBotId,
    body,
  );
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
  body: Record<string, unknown>,
): Promise<Response> {
  const playerState = await loadPlayerState(auth, config);
  if (playerState.error !== null) {
    return errorResponse(
      playerState.error.code,
      playerState.error.message,
      playerState.error.status,
    );
  }

  const botResult = await restRequest<BotBuildRow[]>(
    config,
    `bot_builds?id=eq.${
      encodeURIComponent(opponentBotId)
    }&is_active=eq.true&select=id,power,power_band,build_data,is_active&limit=1`,
    { method: "GET" },
  );
  if (botResult.error !== null) {
    return errorResponse(
      "STATE_READ_FAILED",
      "Unable to load first-slice bot.",
      500,
    );
  }
  const bot = botResult.value[0] ?? null;
  if (bot === null || !isObject(bot.build_data)) {
    return errorResponse(
      "SIMULATION_FAILED",
      "First-slice bot build is unavailable.",
      500,
    );
  }

  const battleId = crypto.randomUUID();
  const seed = `first_slice:${playerState.value.player.id}:${requestId}`;
  const simulation = simulateFirstSliceBattle({
    battleId,
    seed,
    player: playerCombatant(playerState.value),
    opponent: botCombatant(bot),
  });
  const reward = simulation.reward.resources;

  const competition = await prepareArenaMutationPayload(
    config,
    auth,
    playerState.value.player,
    bot,
    battleOutcome(simulation.battleLog.result),
  );
  if (competition.error !== null) {
    return errorResponse(
      competition.error.code,
      competition.error.message,
      competition.error.status,
    );
  }

  const requestHash = await mutationRequestHash("battle/request", body, {
    request_id: requestId,
    save_type: auth.saveType,
    mode: "FIRST_SLICE_SIM",
    opponent_bot_id: bot.id,
    seed,
  });
  const rpc = await restRequest<unknown>(config, "rpc/request_battle_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: playerState.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        battle_id: battleId,
        seed,
        defender_id: bot.id,
        defender_is_bot: true,
        battle_log: simulation.battleLog,
        reward_payload: simulation.reward,
        reward_delta: reward,
        consumables: simulation.consumables,
        competition: competition.value,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "SIMULATION_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  return jsonResponse(rpc.value);
}

async function handleLatest(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const player = await loadPlayerForRead(auth, config);
  if (player.error !== null) {
    return errorResponse(
      player.error.code,
      player.error.message,
      player.error.status,
    );
  }

  const battleResult = await restRequest<BattleRow[]>(
    config,
    `battles?attacker_id=eq.${
      encodeURIComponent(player.value.id)
    }&select=id,schema_version,ruleset_id,ruleset_version,seed,defender_id,defender_is_bot,result,event_log,reward_payload,created_at&order=created_at.desc&limit=1`,
    { method: "GET" },
  );

  if (battleResult.error !== null) {
    return errorResponse(
      "BATTLE_READ_FAILED",
      "Unable to load latest battle.",
      500,
    );
  }

  const battle = battleResult.value[0] ?? null;
  if (battle === null) {
    return jsonResponse({
      ok: true,
      battle_log: null,
      rewards: null,
    });
  }

  return jsonResponse({
    ok: true,
    battle_log: battleLogFromRow(player.value, battle),
    ruleset: rulesetMetadataFromRow(battle),
    rewards: battle.reward_payload,
  });
}

async function handleHistory(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const player = await loadPlayerForRead(auth, config);
  if (player.error !== null) {
    return errorResponse(
      player.error.code,
      player.error.message,
      player.error.status,
    );
  }

  const limit = historyLimit(new URL(request.url));
  const battleResult = await restRequest<BattleRow[]>(
    config,
    `battles?attacker_id=eq.${
      encodeURIComponent(player.value.id)
    }&select=id,schema_version,ruleset_id,ruleset_version,seed,defender_id,defender_is_bot,result,event_log,reward_payload,created_at&order=created_at.desc&limit=${limit}`,
    { method: "GET" },
  );

  if (battleResult.error !== null) {
    return errorResponse(
      "BATTLE_HISTORY_READ_FAILED",
      "Unable to load battle history.",
      500,
    );
  }

  return jsonResponse({
    ok: true,
    schema_version: "battle_history_v1",
    save_type: player.value.save_type ?? auth.saveType,
    ruleset: rulesetMetadata(),
    history: battleResult.value.map((battle) => historyEntryFromRow(battle)),
  });
}

async function handleReplay(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const battleId = new URL(request.url).searchParams.get("battle_id")?.trim() ??
    "";
  if (!UUID_PATTERN.test(battleId)) {
    return errorResponse("INVALID_BATTLE_ID", "battle_id must be a UUID.", 400);
  }

  const player = await loadPlayerForRead(auth, config);
  if (player.error !== null) {
    return errorResponse(
      player.error.code,
      player.error.message,
      player.error.status,
    );
  }

  const battleResult = await restRequest<BattleRow[]>(
    config,
    `battles?attacker_id=eq.${encodeURIComponent(player.value.id)}&id=eq.${
      encodeURIComponent(battleId)
    }&select=id,schema_version,ruleset_id,ruleset_version,seed,defender_id,defender_is_bot,result,event_log,reward_payload,created_at&limit=1`,
    { method: "GET" },
  );

  if (battleResult.error !== null) {
    return errorResponse(
      "BATTLE_REPLAY_READ_FAILED",
      "Unable to load battle replay.",
      500,
    );
  }

  const battle = battleResult.value[0] ?? null;
  if (battle === null) {
    return errorResponse(
      "BATTLE_NOT_FOUND",
      "Battle was not found for the active save.",
      404,
    );
  }

  return jsonResponse({
    ok: true,
    battle_log: battleLogFromRow(player.value, battle),
    ruleset: rulesetMetadataFromRow(battle),
    rewards: battle.reward_payload,
    replay: {
      battle_id: battle.id,
      created_at: battle.created_at ?? null,
      save_type: player.value.save_type ?? auth.saveType,
      read_only: true,
    },
  });
}

async function loadPlayerForRead(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<
  { value: PlayerRow; error: null } | { value: null; error: RestError }
> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,save_type&limit=1`,
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

  return { value: player, error: null };
}

function historyLimit(url: URL): number {
  const requested = Number(
    url.searchParams.get("limit") ?? DEFAULT_HISTORY_LIMIT,
  );
  if (!Number.isFinite(requested)) {
    return DEFAULT_HISTORY_LIMIT;
  }
  return Math.max(1, Math.min(MAX_HISTORY_LIMIT, Math.trunc(requested)));
}

async function loadPlayerState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<
  {
    value: {
      player: PlayerRow;
      gameSave: FoundationGameSaveRow;
      resources: ResourceRow;
      build: BuildRow;
      inventory: ConsumableRow[];
      potionSlots: PotionSlotRow[];
      spellBehaviors: SpellBehaviorRow[];
    };
    error: null;
  } | { value: null; error: RestError }
> {
  const playerResult = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,username,save_type,level,xp,power&limit=1`,
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

  const resourcesResult = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${playerId}&select=almas,energia,sangue,cristais,ossos,po_osso,diamante&limit=1`,
    { method: "GET" },
  );
  const buildResult = await restRequest<BuildRow[]>(
    config,
    `builds?player_id=eq.${playerId}&select=weapon_type,weapon_quality,weapon_level,spell_slots,spells_unlocked,pet_id,pet_level,passive_id,passive_level&limit=1`,
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
    resourcesResult.error !== null || buildResult.error !== null ||
    inventoryResult.error !== null || slotsResult.error !== null ||
    behaviorsResult.error !== null
  ) {
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

  return {
    value: {
      player,
      gameSave: gameSave.value,
      resources,
      build,
      inventory: inventoryResult.value,
      potionSlots: slotsResult.value,
      spellBehaviors: behaviorsResult.value,
    },
    error: null,
  };
}

async function prepareArenaMutationPayload(
  config: EdgeConfig,
  auth: AuthContext,
  player: PlayerRow,
  bot: BotBuildRow,
  outcome: BattleOutcome,
): Promise<
  { value: Record<string, unknown>; error: null } | {
    value: null;
    error: RestError;
  }
> {
  if (isProgressionLabSave(auth.saveType)) {
    return {
      value: {
        ranked: false,
        excluded_reason: "PROGRESSION_LAB_DOES_NOT_RANK",
        scoring_model: ARENA_SCORING_MODEL,
      },
      error: null,
    };
  }

  const season = await activeSeason(config);
  if (season.error !== null) {
    return { value: null, error: season.error };
  }

  const playerPower = effectivePower(player.power, player.level);
  const opponentPower = Math.max(1, numberValue(bot.power, 1));
  const rawArenaDelta = arenaPointDelta(outcome, playerPower, opponentPower);

  return {
    value: {
      ranked: true,
      season: season.value,
      result: outcome,
      scoring_model: ARENA_SCORING_MODEL,
      arena_delta_raw: rawArenaDelta,
      player_power: playerPower,
      opponent_power: opponentPower,
      opponent: {
        id: bot.id,
        power: bot.power,
        power_band: bot.power_band,
        is_bot: true,
        is_ranked: false,
      },
    },
    error: null,
  };
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
        almas: numberValue(state.resources.almas, 0) +
          numberValue(reward.almas, 0),
        energia: numberValue(state.resources.energia, 0) +
          numberValue(reward.energia, 0),
        sangue: numberValue(state.resources.sangue, 0) +
          numberValue(reward.sangue, 0),
        ossos: numberValue(state.resources.ossos, 0) +
          numberValue(reward.ossos, 0),
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

  const transaction = await restRequest<unknown>(
    config,
    "resource_transactions",
    {
      method: "POST",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({
        player_id: state.player.id,
        source: "battle/request",
        request_id: requestId,
        delta: reward,
      }),
    },
  );
  if (transaction.error !== null) {
    return {
      code: "REWARD_APPLY_FAILED",
      message: "Unable to record battle reward transaction.",
      status: 500,
    };
  }

  return null;
}

async function applyBattleConsumables(
  config: EdgeConfig,
  state: { player: PlayerRow; inventory: ConsumableRow[] },
  requestId: string,
  consumablesUsed: BattleConsumableUse[],
): Promise<RestError | null> {
  const playerConsumables = consumablesUsed.filter((item) => item.owner === "player");
  if (playerConsumables.length === 0) {
    return null;
  }

  for (const used of playerConsumables) {
    const current = state.inventory.find((item) => item.item_id === used.item_id);
    if (current === undefined || current.quantity < used.quantity) {
      return {
        code: "CONSUMABLE_APPLY_FAILED",
        message: "Potion stock changed before battle could be applied.",
        status: 409,
      };
    }
    const nextQuantity = current.quantity - used.quantity;
    const update = await restRequest<unknown>(
      config,
      `player_consumables?player_id=eq.${encodeURIComponent(state.player.id)}&item_id=eq.${
        encodeURIComponent(used.item_id)
      }`,
      {
        method: "PATCH",
        headers: { prefer: "return=minimal" },
        body: JSON.stringify({
          quantity: nextQuantity,
          updated_at: new Date().toISOString(),
        }),
      },
    );
    if (update.error !== null) {
      return {
        code: "CONSUMABLE_APPLY_FAILED",
        message: "Unable to consume potion stock.",
        status: 500,
      };
    }
    const ledger = await restRequest<unknown>(config, "item_transactions", {
      method: "POST",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({
        player_id: state.player.id,
        source: "battle/request",
        request_id: requestId,
        item_id: used.item_id,
        delta: -used.quantity,
        payload: { slot_index: used.slot_index },
      }),
    });
    if (ledger.error !== null) {
      return {
        code: "CONSUMABLE_APPLY_FAILED",
        message: "Unable to record consumed potion.",
        status: 500,
      };
    }
  }

  return null;
}

async function applyArenaResult(
  config: EdgeConfig,
  auth: AuthContext,
  player: PlayerRow,
  bot: BotBuildRow,
  outcome: BattleOutcome,
): Promise<
  { value: Record<string, unknown>; error: null } | {
    value: null;
    error: RestError;
  }
> {
  if (isProgressionLabSave(auth.saveType)) {
    return {
      value: {
        ranked: false,
        excluded_reason: "PROGRESSION_LAB_DOES_NOT_RANK",
        scoring_model: ARENA_SCORING_MODEL,
      },
      error: null,
    };
  }

  const season = await activeSeason(config);
  if (season.error !== null) {
    return { value: null, error: season.error };
  }

  const ensureRanking = await restRequest<unknown>(config, "ranking", {
    method: "POST",
    headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
    body: JSON.stringify({
      season_id: season.value.id,
      player_id: player.id,
    }),
  });
  if (ensureRanking.error !== null) {
    return {
      value: null,
      error: {
        code: "RANKING_APPLY_FAILED",
        message: "Unable to initialize arena ranking.",
        status: 500,
      },
    };
  }

  const currentRanking = await restRequest<RankingRow[]>(
    config,
    `ranking?season_id=eq.${encodeURIComponent(season.value.id)}&player_id=eq.${
      encodeURIComponent(player.id)
    }&select=season_id,player_id,arena_points,wins,losses,updated_at&limit=1`,
    { method: "GET" },
  );
  if (currentRanking.error !== null) {
    return {
      value: null,
      error: {
        code: "RANKING_APPLY_FAILED",
        message: "Unable to read arena ranking.",
        status: 500,
      },
    };
  }

  const current = currentRanking.value[0] ?? {
    season_id: season.value.id,
    player_id: player.id,
    arena_points: 0,
    wins: 0,
    losses: 0,
    updated_at: new Date().toISOString(),
  };
  const currentPoints = numberValue(current.arena_points, 0);
  const playerPower = effectivePower(player.power, player.level);
  const opponentPower = Math.max(1, numberValue(bot.power, 1));
  const rawArenaDelta = arenaPointDelta(outcome, playerPower, opponentPower);
  const nextPoints = Math.max(0, currentPoints + rawArenaDelta);
  const arenaDelta = nextPoints - currentPoints;
  const nextWins = numberValue(current.wins, 0) + (outcome === "win" ? 1 : 0);
  const nextLosses = numberValue(current.losses, 0) +
    (outcome === "loss" ? 1 : 0);
  const updatedAt = new Date().toISOString();

  const updateRanking = await restRequest<RankingRow[]>(
    config,
    `ranking?season_id=eq.${encodeURIComponent(season.value.id)}&player_id=eq.${
      encodeURIComponent(player.id)
    }&select=season_id,player_id,arena_points,wins,losses,updated_at`,
    {
      method: "PATCH",
      headers: { prefer: "return=representation" },
      body: JSON.stringify({
        arena_points: nextPoints,
        wins: nextWins,
        losses: nextLosses,
        updated_at: updatedAt,
      }),
    },
  );
  if (updateRanking.error !== null) {
    return {
      value: null,
      error: {
        code: "RANKING_APPLY_FAILED",
        message: "Unable to update arena ranking.",
        status: 500,
      },
    };
  }

  return {
    value: {
      ranked: true,
      season: season.value,
      result: outcome,
      scoring_model: ARENA_SCORING_MODEL,
      arena_delta: arenaDelta,
      arena_delta_raw: rawArenaDelta,
      player_power: playerPower,
      opponent_power: opponentPower,
      opponent: {
        id: bot.id,
        power: bot.power,
        power_band: bot.power_band,
        is_bot: true,
        is_ranked: false,
      },
      ranking: updateRanking.value[0] ?? {
        season_id: season.value.id,
        player_id: player.id,
        arena_points: nextPoints,
        wins: nextWins,
        losses: nextLosses,
        updated_at: updatedAt,
      },
    },
    error: null,
  };
}

async function activeSeason(
  config: EdgeConfig,
): Promise<
  { value: SeasonRow; error: null } | { value: null; error: RestError }
> {
  const result = await restRequest<SeasonRow[]>(
    config,
    "seasons?status=eq.active&select=id,display_name,starts_at,ends_at&order=starts_at.desc&limit=1",
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }

  const season = result.value[0] ?? null;
  if (season === null) {
    return {
      value: null,
      error: {
        code: "SEASON_NOT_FOUND",
        message: "No active season is configured.",
        status: 500,
      },
    };
  }

  return { value: season, error: null };
}

function battleOutcome(result: unknown): BattleOutcome {
  if (!isObject(result)) {
    return "draw";
  }

  const winner = stringValue(result.winner, "");
  if (winner === "player") {
    return "win";
  }
  if (winner === "opponent") {
    return "loss";
  }
  return "draw";
}

function arenaPointDelta(
  outcome: BattleOutcome,
  playerPower: number,
  opponentPower: number,
): number {
  if (outcome === "draw") {
    return 0;
  }

  const referencePower = Math.max(1, playerPower);
  const differenceRatio = Math.min(
    Math.abs(opponentPower - playerPower) / referencePower,
    0.35,
  );
  const normalized = differenceRatio / 0.35;
  if (outcome === "win") {
    if (opponentPower > playerPower) {
      return 20 + Math.round(normalized * 10);
    }
    if (opponentPower < playerPower) {
      return 20 - Math.round(normalized * 8);
    }
    return 20;
  }

  if (opponentPower > playerPower) {
    return -10 + Math.round(normalized * 5);
  }
  if (opponentPower < playerPower) {
    return -10 - Math.round(normalized * 5);
  }
  return -10;
}

function playerCombatant(state: {
  player: PlayerRow;
  build: BuildRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
  spellBehaviors: SpellBehaviorRow[];
}): CombatantBuild {
  const { player, build } = state;
  const spells = arrayOfStrings(build.spell_slots).length > 0
    ? arrayOfStrings(build.spell_slots)
    : arrayOfStrings(build.spells_unlocked);
  const potionSlot = potionSlotForBattle(state);

  return {
    id: player.id,
    displayName: stringValue(player.username, "Draxos"),
    level: numberValue(player.level, 1),
    weaponId: stringValue(build.weapon_type, "varinha_cinzas"),
    weaponLevel: numberValue(build.weapon_level, 1),
    weaponQualityTier: weaponQualityTierFromQualityId(build.weapon_quality),
    spellIds: spells.length > 0 ? spells : ["sussurro_medo"],
    spellLevels: spellLevelMap(
      spells.length > 0 ? spells : ["sussurro_medo"],
      numberValue(player.level, 1),
    ),
    passiveId: build.passive_id ?? undefined,
    passiveLevel: build.passive_id === null ? undefined : numberValue(build.passive_level, 1),
    petId: build.pet_id ?? undefined,
    petLevel: build.pet_id === null ? undefined : numberValue(build.pet_level, 1),
    spellBehaviors: spellBehaviorMap(state.spellBehaviors),
    potionSlot,
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
    weaponQualityTier: weaponQualityTierFromQualityId(
      stringValue(data.weapon_quality, "reforcada"),
    ),
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

function potionSlotForBattle(state: {
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
}): CombatantBuild["potionSlot"] {
  const slot = state.potionSlots.find((candidate) => candidate.slot_index === 1);
  if (slot === undefined || slot.potion_id !== "pocao_vida") {
    return undefined;
  }
  const inventory = state.inventory.find((item) => item.item_id === slot.potion_id);
  const quantity = inventory?.quantity ?? 0;
  if (quantity <= 0) {
    return undefined;
  }
  return {
    slotIndex: 1,
    itemId: "pocao_vida",
    quantity,
    behavior: normalizeBehavior(slot.behavior, {
      enabled: true,
      hp: { mode: "below", percent: 40 },
      mana: { mode: "ignore", percent: 0 },
    }),
  };
}

function spellBehaviorMap(
  rows: SpellBehaviorRow[],
): Record<string, BehaviorConfig> {
  const result: Record<string, BehaviorConfig> = {};
  for (const row of rows) {
    result[row.spell_id] = normalizeBehavior(row.behavior, {
      enabled: true,
      hp: { mode: "ignore", percent: 0 },
      mana: { mode: "ignore", percent: 0 },
    });
  }
  return result;
}

function normalizeBehavior(
  value: unknown,
  fallback: BehaviorConfig,
): BehaviorConfig {
  const payload = isObject(value) ? value : {};
  return {
    enabled: typeof payload.enabled === "boolean" ? payload.enabled : fallback.enabled,
    hp: normalizeCondition(payload.hp, fallback.hp),
    mana: normalizeCondition(payload.mana, fallback.mana),
  };
}

function normalizeCondition(
  value: unknown,
  fallback: BehaviorConfig["hp"],
): BehaviorConfig["hp"] {
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

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/request")) {
    return "request";
  }

  if (pathname.endsWith("/latest")) {
    return "latest";
  }

  if (pathname.endsWith("/history")) {
    return "history";
  }

  if (pathname.endsWith("/replay")) {
    return "replay";
  }

  return null;
}

function decodeAuthContext(
  request: Request,
): { value: AuthContext; error: null } | {
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
  if (
    payload === null || typeof payload.sub !== "string" ||
    !UUID_PATTERN.test(payload.sub)
  ) {
    return {
      value: null,
      error: {
        code: "UNAUTHENTICATED",
        message: "Token subject is invalid.",
        status: 401,
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
    const bytes = Uint8Array.from(
      atob(padded),
      (character) => character.charCodeAt(0),
    );
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

function loadConfig(): { value: EdgeConfig; error: null } | {
  value: null;
  error: RestError;
} {
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

async function readJsonObject(
  request: Request,
): Promise<Record<string, unknown> | null> {
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

function errorResponse(
  code: string,
  message: string,
  status: number,
): Response {
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
