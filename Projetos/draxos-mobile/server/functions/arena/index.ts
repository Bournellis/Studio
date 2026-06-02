import { validateApiVersion } from "../_shared/api_version.ts";
import {
  type BattleBotBuildRow,
  type BattleBuildRow,
  type BattleConsumableRow,
  type BattlePotionSlotRow,
  type BattleSpellBehaviorRow,
  type CombatantBuild,
  playerCombatantFromState,
  potionSlotForBattle,
  spellBehaviorMap,
} from "../_shared/battle_combatants.ts";
import { arenaOpponentCombatantFromBot } from "../_shared/pve_arena_combatants.ts";
import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { simulateFirstSliceBattle } from "../_shared/battle_simulator.ts";
import {
  arenaBuffDefinitions,
  arenaDefinitions,
  type ArenaPlayerSnapshot,
  type ArenaProgressSnapshot,
  arenaRewardProfile,
  arenaTierById,
  arenaTierUnlockState,
  type PveArenaDefinition,
  type PveArenaDifficultyTier,
  type PveArenaRewardProfile,
  pveEnemyDefinition,
} from "../_shared/pve_arena_catalog.ts";
import {
  type FoundationGameSaveRow,
  loadFoundationGameSave,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "list" | "start" | "duel/request" | "buff/choose" | "claim" | "abandon";
type BuffStat =
  | "max_hp"
  | "ritual_power"
  | "guard"
  | "max_mana"
  | "mana_regen"
  | "ritual_haste"
  | "will"
  | "ritual_control";

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

interface BuildRow extends BattleBuildRow {
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

interface ConsumableRow extends BattleConsumableRow {
  player_id: string;
  updated_at: string;
}

interface PotionSlotRow extends BattlePotionSlotRow {
  player_id: string;
  updated_at: string;
}

interface SpellBehaviorRow extends BattleSpellBehaviorRow {
  player_id: string;
  updated_at: string;
}

interface BotBuildRow extends BattleBotBuildRow {
  id: string;
  power: number;
  power_band: string;
  build_data: unknown;
  is_active: boolean;
}

interface PlayerState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  resources: ResourceRow;
  build: BuildRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
  spellBehaviors: SpellBehaviorRow[];
}

interface ArenaListState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
}

interface ArenaProgressRow {
  game_save_id: string;
  player_id: string;
  tutorial_completed: boolean;
  best_completed_difficulty: number;
  best_completed_length: number;
  best_attempt_step: number;
  total_attempts: number;
  total_clears: number;
  last_attempt_id: string | null;
  metadata: unknown;
  created_at: string;
  updated_at: string;
}

interface ArenaAttemptRow {
  id: string;
  game_save_id: string;
  player_id: string;
  arena_id: string;
  difficulty_id: string;
  difficulty_rank: number;
  max_steps: number;
  current_step_index: number;
  status: "active" | "completed" | "failed" | "abandoned";
  seed: string;
  enemy_sequence: unknown;
  loadout_snapshot: unknown;
  active_buffs: unknown;
  reward_payload: unknown;
  started_at: string;
  completed_at: string | null;
  abandoned_at: string | null;
  updated_at: string;
}

interface ArenaStepRow {
  id: string;
  attempt_id: string;
  step_index: number;
  step_type: string;
  status: string;
  opponent_bot_id: string | null;
  seed: string | null;
  battle_log: unknown;
  result: unknown;
  reward_payload: unknown;
  buff_options: unknown;
  selected_buff: unknown;
  created_at: string;
  completed_at: string | null;
}

interface BuffOption {
  id: string;
  label: string;
  stat: BuffStat;
  amount_percent: number;
  stat_modifiers: { stat: BuffStat; operation: "add_percent"; value: number }[];
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
      return errorResponse("NOT_FOUND", "Unknown arena endpoint.", 404);
    }

    if (route === "list" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /arena/pve/state.", 405);
    }
    if (route === "start" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST /arena/pve/start.", 405);
    }
    if (route === "duel/request" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /arena/pve/duel/request.",
        405,
      );
    }
    if (route === "buff/choose" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /arena/pve/buff/select.",
        405,
      );
    }
    if (route === "claim" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /arena/pve/claim.",
        405,
      );
    }
    if (route === "abandon" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /arena/pve/abandon.",
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

    if (route === "list") {
      return await handleList(auth.value, config.value);
    }
    if (route === "start") {
      return await handleStart(request, auth.value, config.value);
    }
    if (route === "duel/request") {
      return await handleDuelRequest(request, auth.value, config.value);
    }
    if (route === "buff/choose") {
      return await handleBuffChoose(request, auth.value, config.value);
    }
    if (route === "claim") {
      return await handleClaim(request, auth.value, config.value);
    }
    return await handleAbandon(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse(
      "INTERNAL_ERROR",
      "Unexpected arena service error.",
      500,
    );
  }

}

async function handleList(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const startedAtMs = performance.now();
  const state = await loadArenaListState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }

  const [progress, attempts] = await Promise.all([
    loadArenaProgress(config, state.value.gameSave.id),
    restRequest<ArenaAttemptRow[]>(
      config,
      `arena_attempts?game_save_id=eq.${
        encodeURIComponent(state.value.gameSave.id)
      }&select=id,game_save_id,player_id,arena_id,difficulty_id,difficulty_rank,max_steps,current_step_index,status,seed,enemy_sequence,active_buffs,reward_payload,started_at,completed_at,abandoned_at,updated_at&order=started_at.desc&limit=5`,
      { method: "GET" },
    ),
  ]);
  if (progress.error !== null) {
    return errorResponse(
      progress.error.code,
      progress.error.message,
      progress.error.status,
    );
  }
  if (attempts.error !== null) {
    return errorResponse(
      "ARENA_STATE_READ_FAILED",
      "Unable to load Arena PVE attempts.",
      500,
    );
  }

  return jsonResponse(stateEnvelope({
    ok: true,
    schema_version: "arena_list_response_v1",
    save_type: auth.saveType,
    progress: progress.value ?? defaultProgress(state.value),
    arenas: arenaDefinitions().map((definition) =>
      arenaSummary(definition, progress.value, state.value.player)
    ),
    attempts: attempts.value,
    active_attempt: attempts.value.find((attempt) => attempt.status === "active") ?? null,
    ranking: { mutated: false, reason: "ARENA_PVE_DOES_NOT_RANK" },
  }, {
    surface: "arena",
    saveType: auth.saveType,
    schemaVersion: "arena_list_response_v1",
    startedAtMs,
  }));
}

async function handleStart(
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
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const state = await loadPlayerState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }

  const progress = await loadArenaProgress(config, state.value.gameSave.id);
  if (progress.error !== null) {
    return errorResponse(
      progress.error.code,
      progress.error.message,
      progress.error.status,
    );
  }

  const tier = tierForStart(body, progress.value, state.value.player);
  if (tier === null) {
    return errorResponse(
      "ARENA_NOT_UNLOCKED",
      "Arena PVE definition is not available for this save.",
      409,
    );
  }

  const seed = `arena:${state.value.player.id}:${requestId}`;
  const enemySequence = [...tier.enemy_sequence];
  const loadoutSnapshot = {
    schema_version: "arena_loadout_snapshot_v1",
    locked_at: new Date().toISOString(),
    combatant: playerCombatantFromState(state.value),
  };
  const requestHash = await mutationRequestHash("arena/start", body, {
    request_id: requestId,
    save_type: auth.saveType,
    arena_id: tier.arena_id,
    difficulty_id: tier.difficulty_id,
    difficulty_rank: tier.difficulty_rank,
    max_steps: enemySequence.length,
    enemy_sequence: enemySequence,
    seed,
  });
  const rpc = await restRequest<unknown>(config, "rpc/arena_start_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        arena_id: tier.arena_id,
        difficulty_id: tier.difficulty_id,
        difficulty_rank: tier.difficulty_rank,
        max_steps: enemySequence.length,
        enemy_sequence: enemySequence,
        seed,
        loadout_snapshot: loadoutSnapshot,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapArenaDatabaseError(rpc.error, "ARENA_START_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(stateEnvelope(responsePayload(rpc.value), {
    surface: "arena",
    saveType: auth.saveType,
  }));
}

async function handleDuelRequest(
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
  const attemptId = stringField(body, "attempt_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (!UUID_PATTERN.test(attemptId)) {
    return errorResponse(
      "INVALID_ARENA_ATTEMPT",
      "attempt_id must be a UUID.",
      400,
    );
  }

  const state = await loadPlayerState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }

  const attempt = await loadActiveAttempt(config, state.value.gameSave.id, attemptId);
  if (attempt.error !== null) {
    return errorResponse(
      attempt.error.code,
      attempt.error.message,
      attempt.error.status,
    );
  }

  const nextStep = attempt.value.current_step_index + 1;
  if (nextStep > attempt.value.max_steps) {
    return errorResponse(
      "ARENA_ATTEMPT_COMPLETE",
      "Arena PVE attempt has no remaining duels.",
      409,
    );
  }

  const activeTier = arenaTierById(attempt.value.arena_id, attempt.value.difficulty_id);
  const enemySequence = activeTier === null
    ? arrayOfStrings(attempt.value.enemy_sequence)
    : [...activeTier.enemy_sequence];
  const enemyId = enemySequence[nextStep - 1] ?? enemySequence.at(-1) ??
    "pve_aprendiz_cinzas";
  const duelPowerTarget = activeTier?.duel_power_targets[nextStep - 1] ??
    activeTier?.duel_power_targets.at(-1) ??
    null;
  const opponentBotId = sourceBotIdForEnemy(enemyId);
  const bot = await loadBot(config, opponentBotId);
  if (bot.error !== null) {
    return errorResponse(bot.error.code, bot.error.message, bot.error.status);
  }
  const progress = await loadArenaProgress(config, state.value.gameSave.id);
  if (progress.error !== null) {
    return errorResponse(
      progress.error.code,
      progress.error.message,
      progress.error.status,
    );
  }

  const battleId = crypto.randomUUID();
  const seed = `arena:${attempt.value.id}:${nextStep}:${requestId}`;
  const lockedCombatant = combatantFromAttemptSnapshot(attempt.value) ??
    playerCombatantFromState(state.value);
  const playerCombatant = withCurrentBehavior(
    applyArenaBuffs(lockedCombatant, attempt.value.active_buffs),
    state.value,
  );
  const simulation = simulateFirstSliceBattle({
    battleId,
    seed,
    player: playerCombatant,
    opponent: arenaOpponentCombatantFromBot(
      bot.value,
      enemyId,
      activeTier,
      duelPowerTarget,
    ),
  });
  const buffOptions = simulation.battleLog.result.winner === "player" &&
      nextStep < attempt.value.max_steps
    ? buffOptionsForStep(attempt.value, nextStep)
    : [];
  const arenaBattleLog = {
    ...simulation.battleLog,
    arena: {
      attempt_id: attempt.value.id,
      arena_id: attempt.value.arena_id,
      mode: "PVE_ARENA_V1",
      difficulty_id: attempt.value.difficulty_id,
      step_index: nextStep,
      max_steps: attempt.value.max_steps,
      enemy_id: enemyId,
      opponent_bot_id: bot.value.id,
      tier_id: activeTier?.id ?? null,
      duel_power_target: duelPowerTarget,
      hp_reset_per_duel: true,
      ranking_mutated: false,
    },
    metadata: {
      ...(isObject((simulation.battleLog as Record<string, unknown>).metadata)
        ? (simulation.battleLog as Record<string, unknown>).metadata as Record<string, unknown>
        : {}),
      arena_id: attempt.value.arena_id,
      difficulty_id: attempt.value.difficulty_id,
      attempt_id: attempt.value.id,
      step_index: nextStep,
      enemy_id: enemyId,
      tier_id: activeTier?.id ?? null,
      duel_power_target: duelPowerTarget,
      active_buffs: attempt.value.active_buffs,
      hp_reset_per_duel: true,
      ranking_mutated: false,
    },
  };
  const rewardPayload = arenaRewardPayload(
    attempt.value,
    nextStep,
    simulation.reward,
    progress.value,
  );
  const requestHash = await mutationRequestHash("arena/duel/request", body, {
    request_id: requestId,
    save_type: auth.saveType,
    attempt_id: attempt.value.id,
    step_index: nextStep,
    enemy_id: enemyId,
    opponent_bot_id: bot.value.id,
    tier_id: activeTier?.id ?? null,
    duel_power_target: duelPowerTarget,
    seed,
  });
  const rpc = await restRequest<unknown>(config, "rpc/arena_record_duel_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        attempt_id: attempt.value.id,
        step_index: nextStep,
        enemy_id: enemyId,
        opponent_bot_id: bot.value.id,
        seed,
        battle_log: arenaBattleLog,
        result: simulation.battleLog.result,
        reward_payload: rewardPayload,
        reward_delta: rewardPayload.economy_delta,
        consumables_used: simulation.consumables.used,
        buff_options: buffOptions,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapArenaDatabaseError(rpc.error, "ARENA_DUEL_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(stateEnvelope(responsePayload(rpc.value), {
    surface: "arena",
    saveType: auth.saveType,
  }));
}

async function handleBuffChoose(
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
  const attemptId = stringField(body, "attempt_id");
  const buffId = stringField(body, "buff_id");
  const stepIndex = integerField(body, "step_index", 0);
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (!UUID_PATTERN.test(attemptId) || stepIndex <= 0 || buffId === "") {
    return errorResponse(
      "INVALID_ARENA_PAYLOAD",
      "attempt_id, step_index and buff_id are required.",
      400,
    );
  }

  const state = await loadPlayerState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }
  const requestHash = await mutationRequestHash("arena/pve/buff/select", body, {
    request_id: requestId,
    save_type: auth.saveType,
    attempt_id: attemptId,
    step_index: stepIndex,
    buff_id: buffId,
  });
  const rpc = await restRequest<unknown>(config, "rpc/arena_choose_buff_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        attempt_id: attemptId,
        step_index: stepIndex,
        buff_id: buffId,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapArenaDatabaseError(rpc.error, "ARENA_BUFF_CHOOSE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(stateEnvelope(responsePayload(rpc.value), {
    surface: "arena",
    saveType: auth.saveType,
  }));
}

async function handleClaim(
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
  const attemptId = stringField(body, "attempt_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (!UUID_PATTERN.test(attemptId)) {
    return errorResponse(
      "INVALID_ARENA_ATTEMPT",
      "attempt_id must be a UUID.",
      400,
    );
  }

  const state = await loadPlayerState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }
  const attempt = await loadAttempt(config, state.value.gameSave.id, attemptId);
  if (attempt.error !== null) {
    return errorResponse(
      attempt.error.code,
      attempt.error.message,
      attempt.error.status,
    );
  }
  if (attempt.value.status === "active") {
    return errorResponse(
      "ARENA_ATTEMPT_NOT_COMPLETE",
      "Arena PVE attempt must finish before summary claim.",
      409,
    );
  }
  const progress = await loadArenaProgress(config, state.value.gameSave.id);
  if (progress.error !== null) {
    return errorResponse(
      progress.error.code,
      progress.error.message,
      progress.error.status,
    );
  }
  const requestHash = await mutationRequestHash("arena/pve/claim", body, {
    request_id: requestId,
    save_type: auth.saveType,
    attempt_id: attempt.value.id,
    status: attempt.value.status,
  });
  return jsonResponse(stateEnvelope({
    ok: true,
    schema_version: "arena_claim_response_v1",
    endpoint: "arena/pve/claim",
    request_id: requestId,
    request_hash: requestHash,
    game_save_id: state.value.gameSave.id,
    legacy_player_id: state.value.player.id,
    attempt: attempt.value,
    progress: progress.value ?? defaultProgress(state.value),
    player: state.value.player,
    resources: state.value.resources,
    reward_payload: attempt.value.reward_payload,
    reward_already_applied: attempt.value.status === "completed",
    mutates_economy: false,
    ranking: { mutated: false, reason: "ARENA_PVE_DOES_NOT_RANK" },
  }, {
    surface: "arena",
    saveType: auth.saveType,
    schemaVersion: "arena_claim_response_v1",
  }));
}

async function handleAbandon(
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
  const attemptId = stringField(body, "attempt_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (!UUID_PATTERN.test(attemptId)) {
    return errorResponse(
      "INVALID_ARENA_ATTEMPT",
      "attempt_id must be a UUID.",
      400,
    );
  }
  const state = await loadPlayerState(auth, config);
  if (state.error !== null) {
    return errorResponse(
      state.error.code,
      state.error.message,
      state.error.status,
    );
  }
  const requestHash = await mutationRequestHash("arena/abandon", body, {
    request_id: requestId,
    save_type: auth.saveType,
    attempt_id: attemptId,
  });
  const rpc = await restRequest<unknown>(config, "rpc/arena_abandon_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        attempt_id: attemptId,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapArenaDatabaseError(rpc.error, "ARENA_ABANDON_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  return jsonResponse(stateEnvelope(responsePayload(rpc.value), {
    surface: "arena",
    saveType: auth.saveType,
  }));
}

async function loadPlayerState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerState; error: null } | { value: null; error: RestError }> {
  const listState = await loadArenaListState(auth, config);
  if (listState.error !== null) {
    return { value: null, error: listState.error };
  }
  const { player, gameSave } = listState.value;

  const playerId = encodeURIComponent(player.id);
  const [resourcesResult, buildResult, inventoryResult, slotsResult, behaviorsResult] = await Promise.all([
    restRequest<ResourceRow[]>(
      config,
      `resources?player_id=eq.${playerId}&select=almas,energia,sangue,cristais,ossos,po_osso,diamante&limit=1`,
      { method: "GET" },
    ),
    restRequest<BuildRow[]>(
      config,
      `builds?player_id=eq.${playerId}&select=weapon_type,weapon_quality,weapon_level,spell_slots,spells_unlocked,pet_id,pet_level,passive_id,passive_level&limit=1`,
      { method: "GET" },
    ),
    restRequest<ConsumableRow[]>(
      config,
      `player_consumables?player_id=eq.${playerId}&select=player_id,item_id,quantity,updated_at&order=item_id.asc`,
      { method: "GET" },
    ),
    restRequest<PotionSlotRow[]>(
      config,
      `player_potion_slots?player_id=eq.${playerId}&select=player_id,slot_index,potion_id,behavior,updated_at&order=slot_index.asc`,
      { method: "GET" },
    ),
    restRequest<SpellBehaviorRow[]>(
      config,
      `player_spell_behaviors?player_id=eq.${playerId}&select=player_id,spell_id,behavior,updated_at&order=spell_id.asc`,
      { method: "GET" },
    ),
  ]);

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
      gameSave,
      resources,
      build,
      inventory: inventoryResult.value,
      potionSlots: slotsResult.value,
      spellBehaviors: behaviorsResult.value,
    },
    error: null,
  };
}

async function loadArenaListState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: ArenaListState; error: null } | { value: null; error: RestError }> {
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
  return {
    value: {
      player,
      gameSave: gameSave.value,
    },
    error: null,
  };
}

async function loadArenaProgress(
  config: EdgeConfig,
  gameSaveId: string,
): Promise<
  { value: ArenaProgressRow | null; error: null } | { value: null; error: RestError }
> {
  const result = await restRequest<ArenaProgressRow[]>(
    config,
    `arena_progress?game_save_id=eq.${encodeURIComponent(gameSaveId)}&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return {
      value: null,
      error: {
        code: "ARENA_STATE_READ_FAILED",
        message: "Unable to load Arena PVE progress.",
        status: 500,
      },
    };
  }
  return { value: result.value[0] ?? null, error: null };
}

async function loadActiveAttempt(
  config: EdgeConfig,
  gameSaveId: string,
  attemptId: string,
): Promise<
  { value: ArenaAttemptRow; error: null } | { value: null; error: RestError }
> {
  const result = await restRequest<ArenaAttemptRow[]>(
    config,
    `arena_attempts?id=eq.${encodeURIComponent(attemptId)}&game_save_id=eq.${
      encodeURIComponent(gameSaveId)
    }&status=eq.active&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const attempt = result.value[0] ?? null;
  if (attempt === null) {
    return {
      value: null,
      error: {
        code: "ARENA_ATTEMPT_NOT_ACTIVE",
        message: "Arena PVE attempt is not active.",
        status: 409,
      },
    };
  }
  return { value: attempt, error: null };
}

async function loadAttempt(
  config: EdgeConfig,
  gameSaveId: string,
  attemptId: string,
): Promise<
  { value: ArenaAttemptRow; error: null } | { value: null; error: RestError }
> {
  const result = await restRequest<ArenaAttemptRow[]>(
    config,
    `arena_attempts?id=eq.${encodeURIComponent(attemptId)}&game_save_id=eq.${
      encodeURIComponent(gameSaveId)
    }&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  const attempt = result.value[0] ?? null;
  if (attempt === null) {
    return {
      value: null,
      error: {
        code: "ARENA_ATTEMPT_NOT_FOUND",
        message: "Arena PVE attempt was not found.",
        status: 404,
      },
    };
  }
  return { value: attempt, error: null };
}

async function loadBot(
  config: EdgeConfig,
  botId: string,
): Promise<{ value: BotBuildRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<BotBuildRow[]>(
    config,
    `bot_builds?id=eq.${
      encodeURIComponent(botId)
    }&is_active=eq.true&select=id,power,power_band,build_data,is_active&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return {
      value: null,
      error: {
        code: "ARENA_BOT_READ_FAILED",
        message: "Unable to load Arena PVE enemy.",
        status: 500,
      },
    };
  }
  const bot = result.value[0] ?? null;
  if (bot === null || !isObject(bot.build_data)) {
    return {
      value: null,
      error: {
        code: "ARENA_BOT_NOT_FOUND",
        message: "Arena PVE enemy is unavailable.",
        status: 404,
      },
    };
  }
  return { value: bot, error: null };
}

function tierForStart(
  body: Record<string, unknown>,
  progress: ArenaProgressRow | null,
  player: PlayerRow,
): PveArenaDifficultyTier | null {
  const requestedArenaId = stringField(body, "arena_id");
  const fallbackArenaId = progress?.tutorial_completed === true
    ? "arena_cinzas_curta"
    : "arena_tutorial_cinzas";
  const arena =
    arenaDefinitions().find((candidate) =>
      candidate.id === (requestedArenaId || fallbackArenaId)
    ) ??
      null;
  if (arena === null) {
    return null;
  }
  const requestedDifficultyId = stringField(body, "difficulty_id");
  const legacyDifficultyTier = integerField(body, "difficulty_tier", -1);
  const difficultyId = requestedDifficultyId ||
    difficultyIdForLegacyTier(arena, legacyDifficultyTier) ||
    arena.difficulty_catalog.default_difficulty_id;
  const tier = arenaTierById(arena.id, difficultyId);
  if (tier === null) {
    return null;
  }
  const unlock = arenaTierUnlockState(
    progressSnapshot(progress),
    playerSnapshot(player),
    tier.arena_id,
    tier.difficulty_id,
  )[0];
  return unlock?.unlocked === true ? tier : null;
}

function arenaSummary(
  definition: PveArenaDefinition,
  progress: ArenaProgressRow | null,
  player: PlayerRow,
): Record<string, unknown> {
  const tiers = definition.difficulty_catalog.season_1_difficulty_ids
    .map((difficultyId) => arenaTierById(definition.id, difficultyId))
    .filter((tier): tier is PveArenaDifficultyTier => tier !== null);
  const unlocks = arenaTierUnlockState(
    progressSnapshot(progress),
    playerSnapshot(player),
    definition.id,
  );
  const defaultTier = arenaTierById(
    definition.id,
    definition.difficulty_catalog.default_difficulty_id,
  ) ?? tiers[0] ?? null;
  const difficulties = tiers.map((tier) => {
    const unlock = unlocks.find((item) => item.difficulty_id === tier.difficulty_id) ?? {
      unlocked: false,
      reason: "Bloqueada",
    };
    const reward = arenaRewardProfile(tier.reward_profile_id);
    return {
      id: tier.id,
      arena_id: tier.arena_id,
      difficulty_id: tier.difficulty_id,
      display_name: tier.display_name,
      difficulty_rank: tier.difficulty_rank,
      difficulty_tier: tier.difficulty_rank,
      recommended_level_min: tier.recommended_level_min,
      recommended_level_max: tier.recommended_level_max,
      recommended_power_min: tier.recommended_power_min,
      recommended_power_max: tier.recommended_power_max,
      recommended_level: `${tier.recommended_level_min}-${tier.recommended_level_max}`,
      recommended_power: `${tier.recommended_power_min}-${tier.recommended_power_max}`,
      final_enemy_power: tier.final_enemy_power,
      duel_power_targets: tier.duel_power_targets,
      enemy_count: tier.enemy_sequence.length,
      max_steps: tier.enemy_sequence.length,
      reward_profile_id: tier.reward_profile_id,
      reward_preview: reward === null ? {} : recordOfNumbers(reward.resources),
      clear_rate_target: {
        min_percent: tier.clear_rate_target_min_percent,
        max_percent: tier.clear_rate_target_max_percent,
      },
      unlocked: unlock.unlocked,
      locked_reason: unlock.unlocked ? "" : unlock.reason,
    };
  });
  const unlockedDifficulties = difficulties.filter((item) => item.unlocked === true);
  const firstDifficulty = difficulties[0] ?? null;
  const visibleTier = defaultTier ?? tiers[0] ?? null;
  return {
    id: definition.id,
    display_name: definition.display_name,
    description: definition.description,
    duel_count: definition.duel_count,
    default_difficulty_id: definition.difficulty_catalog.default_difficulty_id,
    difficulty_catalog: definition.difficulty_catalog,
    difficulty_id: visibleTier?.difficulty_id ?? "",
    difficulty_rank: visibleTier?.difficulty_rank ?? definition.difficulty_tier,
    difficulty_tier: visibleTier?.difficulty_rank ?? definition.difficulty_tier,
    max_steps: visibleTier?.enemy_sequence.length ?? definition.duel_count,
    enemy_count: visibleTier?.enemy_sequence.length ?? definition.duel_count,
    recommended_level_min: visibleTier?.recommended_level_min ?? 1,
    recommended_level_max: visibleTier?.recommended_level_max ?? 1,
    recommended_power_min: visibleTier?.recommended_power_min ?? 0,
    recommended_power_max: visibleTier?.recommended_power_max ?? 0,
    reward_profile_id: visibleTier?.reward_profile_id ?? definition.reward_profile_id,
    clear_rate_target: visibleTier === null ? {} : {
      min_percent: visibleTier.clear_rate_target_min_percent,
      max_percent: visibleTier.clear_rate_target_max_percent,
    },
    unlocked: unlockedDifficulties.length > 0,
    locked_reason: unlockedDifficulties.length > 0
      ? ""
      : stringValue(firstDifficulty?.locked_reason, "Bloqueada"),
    difficulties,
    unlock_rule: definition.unlock,
    hp_reset_per_duel: true,
    loadout_locked: true,
    ranking_mutated: false,
  };
}

function difficultyIdForLegacyTier(
  arena: PveArenaDefinition,
  legacyDifficultyTier: number,
): string {
  if (legacyDifficultyTier < 0) {
    return "";
  }
  const tier = arena.difficulty_catalog.season_1_difficulty_ids
    .map((difficultyId) => arenaTierById(arena.id, difficultyId))
    .filter((candidate): candidate is PveArenaDifficultyTier => candidate !== null)
    .find((candidate) => candidate.difficulty_rank === legacyDifficultyTier);
  return tier?.difficulty_id ?? "";
}

function sourceBotIdForEnemy(enemyId: string): string {
  return pveEnemyDefinition(enemyId)?.source_bot_build_id ?? enemyId;
}

function progressSnapshot(progress: ArenaProgressRow | null): ArenaProgressSnapshot {
  if (progress === null) {
    return {
      tutorial_completed: false,
      best_completed_difficulty: 0,
      best_completed_length: 0,
      metadata: {},
    };
  }
  return {
    tutorial_completed: progress.tutorial_completed,
    best_completed_difficulty: progress.best_completed_difficulty,
    best_completed_length: progress.best_completed_length,
    metadata: isObject(progress.metadata) ? progress.metadata : {},
  };
}

function playerSnapshot(player: PlayerRow): ArenaPlayerSnapshot {
  return {
    level: numberValue(player.level, 1),
    power: numberValue(player.power, 0),
  };
}

function defaultProgress(state: ArenaListState): ArenaProgressRow {
  const now = new Date().toISOString();
  return {
    game_save_id: state.gameSave.id,
    player_id: state.player.id,
    tutorial_completed: false,
    best_completed_difficulty: 0,
    best_completed_length: 0,
    best_attempt_step: 0,
    total_attempts: 0,
    total_clears: 0,
    last_attempt_id: null,
    metadata: {},
    created_at: now,
    updated_at: now,
  };
}

function combatantFromAttemptSnapshot(
  attempt: ArenaAttemptRow,
): CombatantBuild | null {
  const snapshot = isObject(attempt.loadout_snapshot) ? attempt.loadout_snapshot : {};
  const combatant = isObject(snapshot.combatant) ? snapshot.combatant : null;
  if (combatant === null) {
    return null;
  }
  const id = stringField(combatant, "id");
  const displayName = stringField(combatant, "displayName") ||
    stringField(combatant, "display_name");
  if (id === "") {
    return null;
  }
  return {
    id,
    displayName: displayName || "Draxos",
    level: integerField(combatant, "level", 1),
    weaponId: optionalString(combatant.weaponId) ??
      optionalString(combatant.weapon_id),
    weaponLevel: integerField(combatant, "weaponLevel", 1),
    weaponQualityTier: integerField(combatant, "weaponQualityTier", 0),
    spellIds: arrayOfStrings(combatant.spellIds),
    spellLevels: recordOfNumbers(combatant.spellLevels),
    passiveId: optionalString(combatant.passiveId),
    passiveLevel: optionalInteger(combatant.passiveLevel),
    petId: optionalString(combatant.petId),
    petLevel: optionalInteger(combatant.petLevel),
    spellBehaviors: isObject(combatant.spellBehaviors)
      ? combatant.spellBehaviors as CombatantBuild["spellBehaviors"]
      : undefined,
    potionSlot: isObject(combatant.potionSlot)
      ? combatant.potionSlot as unknown as CombatantBuild["potionSlot"]
      : undefined,
  };
}

function withCurrentBehavior(
  locked: CombatantBuild,
  state: PlayerState,
): CombatantBuild {
  const currentPotionSlot = potionSlotForBattle(state);
  const lockedPotion = locked.potionSlot;
  const livePotionQuantity = lockedPotion === undefined
    ? 0
    : (state.inventory.find((item) => item.item_id === lockedPotion.itemId)?.quantity ?? 0);
  return {
    ...locked,
    spellBehaviors: spellBehaviorMap(state.spellBehaviors),
    potionSlot: lockedPotion === undefined || livePotionQuantity <= 0 ? undefined : {
      ...lockedPotion,
      quantity: livePotionQuantity,
      behavior: currentPotionSlot?.behavior ?? lockedPotion.behavior,
    },
  };
}

function applyArenaBuffs(
  combatant: CombatantBuild,
  activeBuffs: unknown,
): CombatantBuild {
  const buffs = Array.isArray(activeBuffs) ? activeBuffs.filter(isObject) : [];
  const potency = totalBuffPercent(buffs, "ritual_power") +
    totalBuffPercent(buffs, "ritual_haste") +
    totalBuffPercent(buffs, "ritual_control");
  const vitality = totalBuffPercent(buffs, "max_hp") +
    totalBuffPercent(buffs, "guard");
  const manaFlow = totalBuffPercent(buffs, "max_mana") +
    totalBuffPercent(buffs, "mana_regen") +
    totalBuffPercent(buffs, "will");
  return {
    ...combatant,
    level: combatant.level + Math.floor(vitality / 5),
    weaponLevel: combatant.weaponLevel + Math.floor((potency + manaFlow) / 4),
  };
}

function totalBuffPercent(
  buffs: Record<string, unknown>[],
  stat: BuffStat,
): number {
  return buffs.reduce((total, buff) => {
    if (buff.stat === stat) {
      return total + numberValue(buff.amount_percent, 0);
    }
    const modifiers = Array.isArray(buff.stat_modifiers)
      ? buff.stat_modifiers.filter(isObject)
      : [];
    return total + modifiers
      .filter((modifier) => modifier.stat === stat)
      .reduce((modifierTotal, modifier) => modifierTotal + numberValue(modifier.value, 0), 0);
  }, 0);
}

function buffOptionsForStep(
  attempt: ArenaAttemptRow,
  stepIndex: number,
): BuffOption[] {
  const pool = catalogBuffPool();
  const offset = (attempt.difficulty_rank + stepIndex - 1) % pool.length;
  return [0, 1, 2].map((index) => pool[(offset + index) % pool.length]);
}

function catalogBuffPool(): BuffOption[] {
  return arenaBuffDefinitions().map((buff) => {
    const statModifiers = buff.stat_modifiers.map((modifier) => ({
      stat: buffStatValue(modifier.stat),
      operation: "add_percent" as const,
      value: numberValue(modifier.value, 0),
    }));
    const firstModifier = statModifiers[0] ?? {
      stat: "ritual_power" as const,
      operation: "add_percent" as const,
      value: 0,
    };
    return {
      id: buff.id,
      label: buff.display_name,
      stat: firstModifier.stat,
      amount_percent: firstModifier.value,
      stat_modifiers: statModifiers,
    };
  });
}

function buffStatValue(value: unknown): BuffStat {
  const allowed: BuffStat[] = [
    "max_hp",
    "ritual_power",
    "guard",
    "max_mana",
    "mana_regen",
    "ritual_haste",
    "will",
    "ritual_control",
  ];
  return allowed.includes(value as BuffStat) ? value as BuffStat : "ritual_power";
}

function arenaRewardPayload(
  attempt: ArenaAttemptRow,
  stepIndex: number,
  duelReward: { type: string; reward_id: string; resources: Record<string, number> },
  progress: ArenaProgressRow | null,
): Record<string, unknown> {
  const completed = stepIndex >= attempt.max_steps;
  const economyDelta = completed ? arenaCompletionReward(attempt, progress) : {};
  return {
    schema_version: "arena_reward_payload_v1",
    economy_applied: completed,
    reason: completed ? "COMPLETION_REWARD_APPLIED_ON_DUEL_CLEAR" : "DUEL_REWARD_PREVIEW_ONLY",
    economy_delta: economyDelta,
    duel_reward_preview: duelReward,
    completion: {
      completed,
      arena_id: attempt.arena_id,
      difficulty_id: attempt.difficulty_id,
      step_index: stepIndex,
      max_steps: attempt.max_steps,
    },
    repeat_reduction_applied: completed && arenaRewardIsRepeat(attempt, progress),
  };
}

function arenaCompletionReward(
  attempt: ArenaAttemptRow,
  progress: ArenaProgressRow | null,
): Record<string, number> {
  const profile = rewardProfileForAttempt(attempt);
  if (profile === null) {
    return {};
  }
  const repeat = arenaRewardIsRepeat(attempt, progress);
  const multiplier = repeat ? profile.repeat_multiplier : profile.first_clear_multiplier;
  const delta = scaleResourceMap(recordOfNumbers(profile.resources), multiplier);
  if (!repeat && attempt.difficulty_rank > (progress?.best_completed_difficulty ?? 0)) {
    return mergeResourceMaps(delta, recordOfNumbers(profile.record_bonus));
  }
  return delta;
}

function arenaRewardIsRepeat(
  attempt: ArenaAttemptRow,
  progress: ArenaProgressRow | null,
): boolean {
  if (hasCompletedTier(progress, attempt.arena_id, attempt.difficulty_id)) {
    return true;
  }
  if (attempt.arena_id === "arena_tutorial_cinzas") {
    return progress?.tutorial_completed === true;
  }
  return (progress?.best_completed_difficulty ?? 0) >= attempt.difficulty_rank &&
    (progress?.best_completed_length ?? 0) >= attempt.max_steps;
}

function rewardProfileForAttempt(attempt: ArenaAttemptRow): PveArenaRewardProfile | null {
  const tier = arenaTierById(attempt.arena_id, attempt.difficulty_id);
  if (tier === null) {
    return null;
  }
  return arenaRewardProfile(tier.reward_profile_id);
}

function hasCompletedTier(
  progress: ArenaProgressRow | null,
  arenaId: string,
  difficultyId: string,
): boolean {
  if (progress === null || !isObject(progress.metadata)) {
    return false;
  }
  const completedTiers = progress.metadata.completed_tiers;
  const tierKey = `${arenaId}:${difficultyId}`;
  return isObject(completedTiers) && completedTiers[tierKey] === true;
}

function scaleResourceMap(
  resources: Record<string, number>,
  multiplier: number,
): Record<string, number> {
  const output: Record<string, number> = {};
  for (const [key, value] of Object.entries(resources)) {
    output[key] = Math.max(0, Math.round(value * multiplier));
  }
  return output;
}

function mergeResourceMaps(
  left: Record<string, number>,
  right: Record<string, number>,
): Record<string, number> {
  const output = { ...left };
  for (const [key, value] of Object.entries(right)) {
    output[key] = Math.max(0, Math.round((output[key] ?? 0) + value));
  }
  return output;
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/list") || pathname.endsWith("/pve/state")) return "list";
  if (pathname.endsWith("/start") || pathname.endsWith("/pve/start")) return "start";
  if (pathname.endsWith("/duel/request")) return "duel/request";
  if (pathname.endsWith("/buff/choose") || pathname.endsWith("/pve/buff/select")) {
    return "buff/choose";
  }
  if (pathname.endsWith("/claim") || pathname.endsWith("/pve/claim")) return "claim";
  if (pathname.endsWith("/abandon") || pathname.endsWith("/pve/abandon")) return "abandon";
  return null;
}

function decodeAuthContext(
  request: Request,
): { value: AuthContext; error: null } | { value: null; error: RestError } {
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
  return { value: { userId: payload.sub, saveType }, error: null };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(
      atob(padded),
      (character) => character.charCodeAt(0),
    );
    const payload: unknown = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
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
        message: "Arena function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return {
    value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey },
    error: null,
  };
}

async function readJsonObject(
  request: Request,
): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
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
  return { value: data as T, error: null };
}

function mapArenaDatabaseError(error: RestError, fallbackCode: string): RestError {
  const message = error.message.toUpperCase();
  const codes = [
    "IDEMPOTENCY_HASH_MISMATCH",
    "INVALID_GAME_SAVE_ID",
    "INVALID_REQUEST_ID",
    "INVALID_REQUEST_HASH",
    "INVALID_ARENA_ATTEMPT",
    "INVALID_ARENA_PAYLOAD",
    "INVALID_ARENA_REWARD",
    "INVALID_ARENA_LENGTH",
    "GAME_SAVE_NOT_FOUND",
    "GAME_SAVE_WITHOUT_LEGACY_PLAYER",
    "RULESET_NOT_FOUND",
    "ARENA_ATTEMPT_ALREADY_ACTIVE",
    "ARENA_ATTEMPT_NOT_FOUND",
    "ARENA_ATTEMPT_NOT_ACTIVE",
    "ARENA_ATTEMPT_COMPLETE",
    "ARENA_ATTEMPT_NOT_COMPLETE",
    "ARENA_STEP_NOT_FOUND",
    "ARENA_BUFF_ALREADY_CHOSEN",
    "ARENA_BUFF_NOT_AVAILABLE",
  ];
  for (const code of codes) {
    if (message.includes(code)) {
      return {
        code,
        message: arenaErrorMessage(code),
        status: arenaStatus(code, error.status),
      };
    }
  }
  return {
    code: fallbackCode,
    message: arenaErrorMessage(fallbackCode),
    status: error.status >= 400 ? error.status : 500,
  };
}

function arenaStatus(code: string, fallback: number): number {
  if (
    code.startsWith("INVALID_") ||
    code === "ARENA_BUFF_NOT_AVAILABLE"
  ) {
    return 400;
  }
  if (
    code === "GAME_SAVE_NOT_FOUND" ||
    code === "ARENA_STEP_NOT_FOUND" ||
    code === "ARENA_ATTEMPT_NOT_FOUND"
  ) {
    return 404;
  }
  if (
    code === "IDEMPOTENCY_HASH_MISMATCH" ||
    code === "ARENA_ATTEMPT_ALREADY_ACTIVE" ||
    code === "ARENA_ATTEMPT_NOT_ACTIVE" ||
    code === "ARENA_ATTEMPT_COMPLETE" ||
    code === "ARENA_ATTEMPT_NOT_COMPLETE" ||
    code === "ARENA_BUFF_ALREADY_CHOSEN"
  ) {
    return 409;
  }
  return fallback >= 400 ? fallback : 500;
}

function arenaErrorMessage(code: string): string {
  switch (code) {
    case "IDEMPOTENCY_HASH_MISMATCH":
      return "request_id was already used with a different request_hash.";
    case "ARENA_ATTEMPT_ALREADY_ACTIVE":
      return "Finish or abandon the active Arena PVE attempt before starting another.";
    case "ARENA_ATTEMPT_NOT_ACTIVE":
      return "Arena PVE attempt is not active.";
    case "ARENA_ATTEMPT_NOT_FOUND":
      return "Arena PVE attempt was not found.";
    case "ARENA_ATTEMPT_COMPLETE":
      return "Arena PVE attempt has no remaining duels.";
    case "ARENA_ATTEMPT_NOT_COMPLETE":
      return "Arena PVE attempt must be finished before summary claim.";
    case "ARENA_STEP_NOT_FOUND":
      return "Arena PVE step was not found.";
    case "ARENA_BUFF_ALREADY_CHOSEN":
      return "A buff was already chosen for this Arena PVE step.";
    case "ARENA_BUFF_NOT_AVAILABLE":
      return "Buff is not one of the offered Arena PVE options.";
    case "INVALID_ARENA_LENGTH":
      return "Arena PVE length must be between 1 and 10 duels.";
    case "INVALID_ARENA_ATTEMPT":
      return "attempt_id must be a UUID.";
    case "INVALID_ARENA_PAYLOAD":
      return "Arena PVE request payload is invalid.";
    case "INVALID_ARENA_REWARD":
      return "Arena PVE reward payload is invalid.";
    case "GAME_SAVE_NOT_FOUND":
      return "Account save foundation row was not created yet.";
    case "GAME_SAVE_WITHOUT_LEGACY_PLAYER":
      return "Account save is missing its compatibility player row.";
    case "RULESET_NOT_FOUND":
      return "Active ruleset publication was not found.";
    default:
      return "Arena PVE mutation could not be completed.";
  }
}

function stateReadError(): RestError {
  return {
    code: "STATE_READ_FAILED",
    message: "Unable to load Arena PVE state.",
    status: 500,
  };
}

function errorResponse(
  code: string,
  message: string,
  status: number,
): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
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

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function optionalString(value: unknown): string | undefined {
  return typeof value === "string" && value !== "" ? value : undefined;
}

function integerField(
  payload: Record<string, unknown>,
  key: string,
  fallback: number,
): number {
  return numberValue(payload[key], fallback);
}

function optionalInteger(value: unknown): number | undefined {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? Math.trunc(parsed) : undefined;
  }
  return undefined;
}

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? Math.trunc(parsed) : fallback;
  }
  return fallback;
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

function responsePayload(value: unknown): Record<string, unknown> {
  if (isObject(value)) {
    return value;
  }
  return { ok: true, value };
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
