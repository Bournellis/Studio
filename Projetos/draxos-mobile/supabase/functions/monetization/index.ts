import { emptyResponse, jsonResponse } from "../_shared/http.ts";

type Route = "state" | "reward_claim" | "alpha_purchase";
type RewardSource = "daily" | "weekly" | "battle_pass";
type ResourceKey = "almas" | "energia" | "sangue" | "cristais" | "ossos" | "diamante";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
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
  username: string | null;
  level: number;
  xp: number | string;
  power: number;
}

interface ResourceRow {
  player_id: string;
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  diamante: string | number;
  updated_at: string;
}

interface BattlePassRow {
  id: string;
  season_id: string;
  pass_index: number;
  display_name: string;
  starts_at: string;
  ends_at: string;
  free_rewards: unknown;
  premium_rewards: unknown;
  is_active: boolean;
}

interface BattlePassProgressRow {
  player_id: string;
  pass_id: string;
  pass_xp: number;
  premium_unlocked: boolean;
  updated_at: string;
}

interface RewardClaimRow {
  id: string;
  source: RewardSource;
  reward_id: string;
  period_key: string;
  reward_payload: unknown;
  created_at: string;
}

interface IdempotencyRow {
  response_payload: unknown;
}

interface RewardDefinition {
  id: string;
  source: RewardSource;
  label: string;
  xp: number;
  resources: Partial<Record<ResourceKey, number>>;
  tier?: number;
  premiumRequired?: boolean;
}

interface AlphaProduct {
  id: string;
  label: string;
  kind: "grant" | "premium_unlock" | "resource_pack";
  resources?: Partial<Record<ResourceKey, number>>;
  cost?: Partial<Record<ResourceKey, number>>;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const RESOURCE_KEYS: ResourceKey[] = [
  "almas",
  "energia",
  "sangue",
  "cristais",
  "ossos",
  "diamante",
];

const DAILY_REWARDS: RewardDefinition[] = [
  {
    id: "daily_first_victory",
    source: "daily",
    label: "Primeira vitoria diaria",
    xp: 120,
    resources: { almas: 8, energia: 4, sangue: 2, ossos: 1 },
  },
  {
    id: "daily_second_victory",
    source: "daily",
    label: "Segunda vitoria diaria",
    xp: 100,
    resources: { almas: 7, energia: 4, sangue: 2, cristais: 1, ossos: 1 },
  },
  {
    id: "daily_third_victory",
    source: "daily",
    label: "Terceira vitoria diaria",
    xp: 80,
    resources: { almas: 5, energia: 4, sangue: 2, cristais: 1, ossos: 1 },
  },
  {
    id: "daily_collect_base",
    source: "daily",
    label: "Coleta diaria do Refugio",
    xp: 25,
    resources: { almas: 2, energia: 4, sangue: 1, cristais: 1 },
  },
  {
    id: "daily_build_or_upgrade",
    source: "daily",
    label: "Construcao diaria",
    xp: 25,
    resources: { almas: 3, energia: 4, sangue: 1, cristais: 1 },
  },
];

const WEEKLY_REWARDS: RewardDefinition[] = [
  {
    id: "weekly_arena_participation",
    source: "weekly",
    label: "Participacao semanal na Arena",
    xp: 420,
    resources: { almas: 36, energia: 36, sangue: 12, cristais: 6, ossos: 3 },
  },
  {
    id: "weekly_arena_mastery",
    source: "weekly",
    label: "Dominio semanal da Arena",
    xp: 360,
    resources: { almas: 36, energia: 24, sangue: 8, cristais: 4, ossos: 2 },
  },
  {
    id: "weekly_refuge_routine",
    source: "weekly",
    label: "Rotina semanal do Refugio",
    xp: 200,
    resources: { almas: 12, energia: 24, sangue: 8, cristais: 4, ossos: 2 },
  },
];

const BATTLE_PASS_REWARDS: RewardDefinition[] = [
  {
    id: "bp_free_tier_1",
    source: "battle_pass",
    label: "Battle Pass Free Tier 1",
    tier: 1,
    xp: 160,
    resources: { almas: 16, energia: 16, sangue: 6, cristais: 4, ossos: 2, diamante: 1 },
  },
  {
    id: "bp_premium_tier_1",
    source: "battle_pass",
    label: "Battle Pass Premium Tier 1",
    tier: 1,
    xp: 300,
    resources: { almas: 30, energia: 30, sangue: 14, cristais: 8, ossos: 4, diamante: 1 },
    premiumRequired: true,
  },
];

const ALPHA_PRODUCTS: AlphaProduct[] = [
  {
    id: "alpha_battle_pass_premium",
    label: "Premium Battle Pass Alpha",
    kind: "premium_unlock",
  },
  {
    id: "alpha_diamante_500",
    label: "Diamante Alpha 500",
    kind: "grant",
    resources: { diamante: 500 },
  },
  {
    id: "alpha_energy_pack_small",
    label: "Pacote de Energia Alpha",
    kind: "resource_pack",
    cost: { diamante: -80 },
    resources: { energia: 80 },
  },
];

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown monetization endpoint.", 404);
    }
    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /monetization/state.", 405);
    }
    if (route === "reward_claim" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /monetization/rewards/claim.",
        405,
      );
    }
    if (route === "alpha_purchase" && request.method !== "POST") {
      return errorResponse(
        "METHOD_NOT_ALLOWED",
        "Use POST /monetization/alpha-purchase.",
        405,
      );
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
    if (route === "reward_claim") {
      return await handleRewardClaim(request, auth.value, config.value);
    }
    return await handleAlphaPurchase(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected monetization service error.", 500);
  }
});

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const state = await loadMonetizationState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(monetizationStatePayload(state.value, new Date()));
}

async function handleRewardClaim(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const rewardId = stringField(body, "reward_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }

  const definition = rewardDefinition(rewardId);
  if (definition === undefined) {
    return errorResponse("INVALID_REWARD", "reward_id is not part of Rewards v0.", 400);
  }

  const state = await loadMonetizationState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }

  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "monetization/rewards/claim",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  if (definition.premiumRequired === true && !state.value.progress.premium_unlocked) {
    return errorResponse("PREMIUM_REQUIRED", "Premium Battle Pass is not unlocked.", 409);
  }

  const now = new Date();
  const periodKey = rewardPeriodKey(definition, state.value.pass, now);
  const previousClaim = await loadRewardClaim(
    config,
    state.value.player.id,
    definition.source,
    definition.id,
    periodKey,
  );
  if (previousClaim.error !== null) {
    return errorResponse(
      previousClaim.error.code,
      previousClaim.error.message,
      previousClaim.error.status,
    );
  }
  if (previousClaim.value !== null) {
    const responsePayload = {
      ...monetizationStatePayload(state.value, now),
      already_claimed: true,
      reward: {
        id: definition.id,
        source: definition.source,
        period_key: periodKey,
        payload: previousClaim.value.reward_payload,
      },
    };
    const idem = await insertIdempotency(
      config,
      state.value.player.id,
      "monetization/rewards/claim",
      requestId,
      responsePayload,
    );
    if (idem !== null) {
      return errorResponse(idem.code, idem.message, idem.status);
    }
    return jsonResponse(responsePayload);
  }

  const updatedPlayer = await applyXp(config, state.value.player, definition.xp);
  if (updatedPlayer.error !== null) {
    return errorResponse(
      updatedPlayer.error.code,
      updatedPlayer.error.message,
      updatedPlayer.error.status,
    );
  }
  const updatedResources = await applyResources(
    config,
    state.value.resources,
    definition.resources,
  );
  if (updatedResources.error !== null) {
    return errorResponse(
      updatedResources.error.code,
      updatedResources.error.message,
      updatedResources.error.status,
    );
  }
  const passXpDelta = definition.source === "battle_pass" ? 0 : definition.xp;
  const updatedProgress = await updateBattlePassProgress(
    config,
    state.value.progress,
    passXpDelta,
    false,
  );
  if (updatedProgress.error !== null) {
    return errorResponse(
      updatedProgress.error.code,
      updatedProgress.error.message,
      updatedProgress.error.status,
    );
  }

  const rewardPayload = {
    label: definition.label,
    tier: definition.tier ?? null,
    xp: definition.xp,
    resources: resourceDelta(definition.resources),
  };
  const claimError = await insertRewardClaim(
    config,
    state.value.player.id,
    definition,
    periodKey,
    requestId,
    rewardPayload,
  );
  if (claimError !== null) {
    return errorResponse(claimError.code, claimError.message, claimError.status);
  }
  const ledgerError = await insertLedger(
    config,
    state.value.player.id,
    "monetization/reward",
    requestId,
    {
      xp: definition.xp,
      ...resourceDelta(definition.resources),
    },
  );
  if (ledgerError !== null) {
    return errorResponse(ledgerError.code, ledgerError.message, ledgerError.status);
  }

  const responsePayload = {
    ...monetizationStatePayload({
      player: updatedPlayer.value,
      resources: updatedResources.value,
      pass: state.value.pass,
      progress: updatedProgress.value,
      claims: [
        ...state.value.claims,
        {
          id: "",
          source: definition.source,
          reward_id: definition.id,
          period_key: periodKey,
          reward_payload: rewardPayload,
          created_at: now.toISOString(),
        },
      ],
    }, now),
    already_claimed: false,
    reward: {
      id: definition.id,
      source: definition.source,
      period_key: periodKey,
      payload: rewardPayload,
    },
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "monetization/rewards/claim",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function handleAlphaPurchase(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const productId = stringField(body, "product_id");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  const product = ALPHA_PRODUCTS.find((item) => item.id === productId);
  if (product === undefined) {
    return errorResponse("INVALID_PRODUCT", "product_id is not part of Alpha monetization.", 400);
  }

  const state = await loadMonetizationState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  const existing = await loadIdempotency(
    config,
    state.value.player.id,
    "monetization/alpha-purchase",
    requestId,
  );
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) {
    return jsonResponse(existing.value);
  }

  const delta = combineResourceDeltas(product.cost ?? {}, product.resources ?? {});
  if (!canApplyDelta(state.value.resources, delta)) {
    return errorResponse("INSUFFICIENT_RESOURCES", "Not enough resources for alpha product.", 409);
  }

  const updatedResources = await applyResources(config, state.value.resources, delta);
  if (updatedResources.error !== null) {
    return errorResponse(
      updatedResources.error.code,
      updatedResources.error.message,
      updatedResources.error.status,
    );
  }
  const updatedProgress = await updateBattlePassProgress(
    config,
    state.value.progress,
    0,
    product.kind === "premium_unlock",
  );
  if (updatedProgress.error !== null) {
    return errorResponse(
      updatedProgress.error.code,
      updatedProgress.error.message,
      updatedProgress.error.status,
    );
  }

  const purchasePayload = {
    product_id: product.id,
    label: product.label,
    kind: product.kind,
    alpha_simulated: true,
    delta: resourceDelta(delta),
  };
  const purchaseError = await insertAlphaPurchase(
    config,
    state.value.player.id,
    product.id,
    requestId,
    purchasePayload,
  );
  if (purchaseError !== null) {
    return errorResponse(purchaseError.code, purchaseError.message, purchaseError.status);
  }
  const ledgerError = await insertLedger(
    config,
    state.value.player.id,
    "monetization/alpha-purchase",
    requestId,
    resourceDelta(delta),
  );
  if (ledgerError !== null) {
    return errorResponse(ledgerError.code, ledgerError.message, ledgerError.status);
  }

  const responsePayload = {
    ...monetizationStatePayload({
      ...state.value,
      resources: updatedResources.value,
      progress: updatedProgress.value,
    }, new Date()),
    purchase: purchasePayload,
  };
  const idem = await insertIdempotency(
    config,
    state.value.player.id,
    "monetization/alpha-purchase",
    requestId,
    responsePayload,
  );
  if (idem !== null) {
    return errorResponse(idem.code, idem.message, idem.status);
  }
  return jsonResponse(responsePayload);
}

async function loadMonetizationState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<
  {
    value: {
      player: PlayerRow;
      resources: ResourceRow;
      pass: BattlePassRow;
      progress: BattlePassProgressRow;
      claims: RewardClaimRow[];
    };
    error: null;
  } | { value: null; error: RestError }
> {
  const player = await loadPlayer(auth, config);
  if (player.error !== null) return { value: null, error: player.error };
  const resources = await loadResources(config, player.value.id);
  if (resources.error !== null) return { value: null, error: resources.error };
  const pass = await activeBattlePass(config);
  if (pass.error !== null) return { value: null, error: pass.error };
  const progress = await ensureBattlePassProgress(config, player.value.id, pass.value.id);
  if (progress.error !== null) return { value: null, error: progress.error };
  const claims = await loadRewardClaims(config, player.value.id);
  if (claims.error !== null) return { value: null, error: claims.error };
  return {
    value: {
      player: player.value,
      resources: resources.value,
      pass: pass.value,
      progress: progress.value,
      claims: claims.value,
    },
    error: null,
  };
}

function monetizationStatePayload(state: {
  player: PlayerRow;
  resources: ResourceRow;
  pass: BattlePassRow;
  progress: BattlePassProgressRow;
  claims: RewardClaimRow[];
}, now: Date) {
  const dailyKey = dateKeyUTC(now);
  const weeklyKey = weekKeyUTC(now);
  const passKey = state.pass.id;
  return {
    ok: true,
    player: state.player,
    resources: state.resources,
    monetization: {
      battle_pass: {
        pass: state.pass,
        progress: state.progress,
        rewards: BATTLE_PASS_REWARDS.map((reward) =>
          rewardPayload(reward, isClaimed(state.claims, reward, passKey), passKey)
        ),
      },
      daily_rewards: DAILY_REWARDS.map((reward) =>
        rewardPayload(reward, isClaimed(state.claims, reward, dailyKey), dailyKey)
      ),
      weekly_rewards: WEEKLY_REWARDS.map((reward) =>
        rewardPayload(reward, isClaimed(state.claims, reward, weeklyKey), weeklyKey)
      ),
      alpha_products: ALPHA_PRODUCTS,
      claimed: state.claims,
      period_keys: {
        daily: dailyKey,
        weekly: weeklyKey,
        battle_pass: passKey,
      },
      server_time: now.toISOString(),
    },
  };
}

function rewardPayload(reward: RewardDefinition, claimed: boolean, periodKey: string) {
  return {
    id: reward.id,
    source: reward.source,
    label: reward.label,
    tier: reward.tier ?? null,
    premium_required: reward.premiumRequired === true,
    xp: reward.xp,
    resources: resourceDelta(reward.resources),
    claimed,
    period_key: periodKey,
  };
}

async function loadPlayer(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${
      encodeURIComponent(auth.userId)
    }&select=id,username,level,xp,power&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const player = result.value[0] ?? null;
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

async function loadResources(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: ResourceRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<ResourceRow[]>(
    config,
    `resources?player_id=eq.${encodeURIComponent(playerId)}&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const resources = result.value[0] ?? null;
  if (resources === null) {
    return {
      value: null,
      error: { code: "RESOURCES_NOT_FOUND", message: "Resources row is missing.", status: 409 },
    };
  }
  return { value: resources, error: null };
}

async function activeBattlePass(
  config: EdgeConfig,
): Promise<{ value: BattlePassRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<BattlePassRow[]>(
    config,
    "battle_passes?is_active=eq.true&select=*&order=starts_at.desc&limit=1",
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const pass = result.value[0] ?? null;
  if (pass === null) {
    return {
      value: null,
      error: {
        code: "BATTLE_PASS_NOT_FOUND",
        message: "No active Battle Pass is configured.",
        status: 500,
      },
    };
  }
  return { value: pass, error: null };
}

async function ensureBattlePassProgress(
  config: EdgeConfig,
  playerId: string,
  passId: string,
): Promise<{ value: BattlePassProgressRow; error: null } | { value: null; error: RestError }> {
  await restRequest<unknown>(config, "battle_pass_progress", {
    method: "POST",
    headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
    body: JSON.stringify({ player_id: playerId, pass_id: passId }),
  });
  const result = await restRequest<BattlePassProgressRow[]>(
    config,
    `battle_pass_progress?player_id=eq.${encodeURIComponent(playerId)}&pass_id=eq.${
      encodeURIComponent(passId)
    }&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const progress = result.value[0] ?? null;
  if (progress === null) {
    return {
      value: null,
      error: {
        code: "BATTLE_PASS_PROGRESS_MISSING",
        message: "Progress row is missing.",
        status: 409,
      },
    };
  }
  return { value: progress, error: null };
}

async function loadRewardClaims(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: RewardClaimRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<RewardClaimRow[]>(
    config,
    `reward_claims?player_id=eq.${
      encodeURIComponent(playerId)
    }&select=id,source,reward_id,period_key,reward_payload,created_at&order=created_at.desc&limit=100`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value, error: null };
}

async function loadRewardClaim(
  config: EdgeConfig,
  playerId: string,
  source: RewardSource,
  rewardId: string,
  periodKey: string,
): Promise<{ value: RewardClaimRow | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<RewardClaimRow[]>(
    config,
    `reward_claims?player_id=eq.${encodeURIComponent(playerId)}&source=eq.${source}&reward_id=eq.${
      encodeURIComponent(rewardId)
    }&period_key=eq.${encodeURIComponent(periodKey)}&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0] ?? null, error: null };
}

async function applyXp(
  config: EdgeConfig,
  player: PlayerRow,
  xpDelta: number,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  if (xpDelta === 0) return { value: player, error: null };
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?id=eq.${encodeURIComponent(player.id)}&select=id,username,level,xp,power`,
    {
      method: "PATCH",
      headers: { prefer: "return=representation" },
      body: JSON.stringify({
        xp: numberValue(player.xp, 0) + xpDelta,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (result.error !== null || result.value.length === 0) {
    return {
      value: null,
      error: { code: "PLAYER_UPDATE_FAILED", message: "Unable to apply reward XP.", status: 500 },
    };
  }
  return { value: result.value[0], error: null };
}

async function applyResources(
  config: EdgeConfig,
  resources: ResourceRow,
  delta: Partial<Record<ResourceKey, number>>,
): Promise<{ value: ResourceRow; error: null } | { value: null; error: RestError }> {
  const patch: Record<string, number | string> = {};
  for (const key of RESOURCE_KEYS) {
    const change = numberValue(delta[key], 0);
    if (change !== 0) {
      patch[key] = numberValue(resources[key], 0) + change;
    }
  }
  if (Object.keys(patch).length === 0) return { value: resources, error: null };
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

async function updateBattlePassProgress(
  config: EdgeConfig,
  progress: BattlePassProgressRow,
  passXpDelta: number,
  unlockPremium: boolean,
): Promise<
  { value: BattlePassProgressRow; error: null } | { value: null; error: RestError }
> {
  if (passXpDelta === 0 && !unlockPremium) return { value: progress, error: null };
  const result = await restRequest<BattlePassProgressRow[]>(
    config,
    `battle_pass_progress?player_id=eq.${encodeURIComponent(progress.player_id)}&pass_id=eq.${
      encodeURIComponent(progress.pass_id)
    }&select=*`,
    {
      method: "PATCH",
      headers: { prefer: "return=representation" },
      body: JSON.stringify({
        pass_xp: progress.pass_xp + passXpDelta,
        premium_unlocked: progress.premium_unlocked || unlockPremium,
        updated_at: new Date().toISOString(),
      }),
    },
  );
  if (result.error !== null || result.value.length === 0) {
    return {
      value: null,
      error: {
        code: "BATTLE_PASS_UPDATE_FAILED",
        message: "Unable to update Battle Pass progress.",
        status: 500,
      },
    };
  }
  return { value: result.value[0], error: null };
}

async function insertRewardClaim(
  config: EdgeConfig,
  playerId: string,
  reward: RewardDefinition,
  periodKey: string,
  requestId: string,
  payload: unknown,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "reward_claims", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      source: reward.source,
      reward_id: reward.id,
      period_key: periodKey,
      request_id: requestId,
      reward_payload: payload,
    }),
  });
  return result.error === null ? null : {
    code: "REWARD_CLAIM_FAILED",
    message: "Unable to persist reward claim.",
    status: 500,
  };
}

async function insertAlphaPurchase(
  config: EdgeConfig,
  playerId: string,
  productId: string,
  requestId: string,
  payload: unknown,
): Promise<RestError | null> {
  const result = await restRequest<unknown>(config, "alpha_purchases", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      product_id: productId,
      request_id: requestId,
      purchase_payload: payload,
    }),
  });
  return result.error === null ? null : {
    code: "ALPHA_PURCHASE_FAILED",
    message: "Unable to persist alpha purchase.",
    status: 500,
  };
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
  if (result.error !== null) return { value: null, error: stateReadError() };
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
    message: "Unable to persist monetization idempotency.",
    status: 500,
  };
}

async function insertLedger(
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
  return result.error === null
    ? null
    : { code: "LEDGER_WRITE_FAILED", message: "Unable to record resource ledger.", status: 500 };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/rewards/claim")) return "reward_claim";
  if (pathname.endsWith("/alpha-purchase")) return "alpha_purchase";
  return null;
}

function rewardDefinition(rewardId: string): RewardDefinition | undefined {
  return [...DAILY_REWARDS, ...WEEKLY_REWARDS, ...BATTLE_PASS_REWARDS].find((reward) =>
    reward.id === rewardId
  );
}

function rewardPeriodKey(reward: RewardDefinition, pass: BattlePassRow, now: Date): string {
  if (reward.source === "daily") return dateKeyUTC(now);
  if (reward.source === "weekly") return weekKeyUTC(now);
  return pass.id;
}

function isClaimed(claims: RewardClaimRow[], reward: RewardDefinition, periodKey: string): boolean {
  return claims.some((claim) =>
    claim.source === reward.source && claim.reward_id === reward.id &&
    claim.period_key === periodKey
  );
}

function canApplyDelta(
  resources: ResourceRow,
  delta: Partial<Record<ResourceKey, number>>,
): boolean {
  for (const key of RESOURCE_KEYS) {
    const nextValue = numberValue(resources[key], 0) + numberValue(delta[key], 0);
    if (nextValue < 0) return false;
  }
  return true;
}

function combineResourceDeltas(
  left: Partial<Record<ResourceKey, number>>,
  right: Partial<Record<ResourceKey, number>>,
): Partial<Record<ResourceKey, number>> {
  const combined: Partial<Record<ResourceKey, number>> = {};
  for (const key of RESOURCE_KEYS) {
    const value = numberValue(left[key], 0) + numberValue(right[key], 0);
    if (value !== 0) combined[key] = value;
  }
  return combined;
}

function resourceDelta(delta: Partial<Record<ResourceKey, number>>): Record<string, number> {
  const payload: Record<string, number> = {};
  for (const key of RESOURCE_KEYS) {
    const value = numberValue(delta[key], 0);
    if (value !== 0) payload[key] = value;
  }
  return payload;
}

function dateKeyUTC(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function weekKeyUTC(date: Date): string {
  const cursor = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  const dayNumber = cursor.getUTCDay() || 7;
  cursor.setUTCDate(cursor.getUTCDate() + 4 - dayNumber);
  const yearStart = new Date(Date.UTC(cursor.getUTCFullYear(), 0, 1));
  const weekNumber = Math.ceil(((cursor.getTime() - yearStart.getTime()) / 86_400_000 + 1) / 7);
  return `${cursor.getUTCFullYear()}-W${String(weekNumber).padStart(2, "0")}`;
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
  if (payload.is_anonymous === false) {
    return {
      value: null,
      error: {
        code: "AUTH_NOT_ANONYMOUS",
        message: "Use an anonymous Supabase Auth session.",
        status: 403,
      },
    };
  }
  return { value: { userId: payload.sub }, error: null };
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
        message: "Monetization function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
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
  return { code: "STATE_READ_FAILED", message: "Unable to load monetization state.", status: 500 };
}

function errorResponse(code: string, message: string, status: number): Response {
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
