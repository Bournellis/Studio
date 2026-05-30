import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import {
  type FoundationGameSaveRow,
  foundationRpcPayload,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";

type Route = "state" | "reward_claim" | "alpha_purchase";
type RewardSource = "daily" | "weekly" | "battle_pass";
type ResourceKey =
  | "almas"
  | "energia"
  | "sangue"
  | "cristais"
  | "ossos"
  | "po_osso"
  | "diamante";

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
  username: string | null;
  save_type: SaveType;
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
  po_osso: string | number;
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

interface AlphaPurchaseRow {
  id: string;
  product_id: string;
  request_id: string;
  purchase_payload: unknown;
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
  description: string;
  kind: "daily_redeem" | "premium_unlock" | "resource_pack" | "convenience_unlock";
  resources?: Partial<Record<ResourceKey, number>>;
  cost?: Partial<Record<ResourceKey, number>>;
  dailyRedeem?: boolean;
  redeemTier?: "pequeno" | "medio" | "grande" | "premium";
  effect?: Record<string, unknown>;
  sortOrder: number;
}

interface MonetizationState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  resources: ResourceRow;
  pass: BattlePassRow;
  progress: BattlePassProgressRow;
  claims: RewardClaimRow[];
  purchases: AlphaPurchaseRow[];
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const RESOURCE_KEYS: ResourceKey[] = [
  "almas",
  "energia",
  "sangue",
  "cristais",
  "ossos",
  "po_osso",
  "diamante",
];

const DAILY_REWARDS: RewardDefinition[] = [
  {
    id: "daily_first_victory",
    source: "daily",
    label: "Primeira vitoria diaria",
    xp: 120,
    resources: { almas: 8, energia: 4, sangue: 2, ossos: 100 },
  },
  {
    id: "daily_second_victory",
    source: "daily",
    label: "Segunda vitoria diaria",
    xp: 100,
    resources: { almas: 7, energia: 4, sangue: 2, cristais: 1, ossos: 100 },
  },
  {
    id: "daily_third_victory",
    source: "daily",
    label: "Terceira vitoria diaria",
    xp: 80,
    resources: { almas: 5, energia: 4, sangue: 2, cristais: 1, ossos: 100 },
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
    resources: { almas: 36, energia: 36, sangue: 12, cristais: 6, ossos: 300 },
  },
  {
    id: "weekly_arena_mastery",
    source: "weekly",
    label: "Dominio semanal da Arena",
    xp: 360,
    resources: { almas: 36, energia: 24, sangue: 8, cristais: 4, ossos: 200 },
  },
  {
    id: "weekly_refuge_routine",
    source: "weekly",
    label: "Rotina semanal do Refugio",
    xp: 200,
    resources: { almas: 12, energia: 24, sangue: 8, cristais: 4, ossos: 200 },
  },
];

const BATTLE_PASS_REWARDS: RewardDefinition[] = [
  {
    id: "bp_free_tier_1",
    source: "battle_pass",
    label: "Battle Pass Free Tier 1",
    tier: 1,
    xp: 160,
    resources: { almas: 16, energia: 16, sangue: 6, cristais: 4, ossos: 200, diamante: 1 },
  },
  {
    id: "bp_premium_tier_1",
    source: "battle_pass",
    label: "Battle Pass Premium Tier 1",
    tier: 1,
    xp: 300,
    resources: { almas: 30, energia: 30, sangue: 14, cristais: 8, ossos: 400, diamante: 1 },
    premiumRequired: true,
  },
];

const ALPHA_PRODUCTS: AlphaProduct[] = [
  {
    id: "alpha_redeem_small",
    label: "Redeem diario pequeno",
    description: "Credita Diamante para testar um impulso leve de loja neste save.",
    kind: "daily_redeem",
    resources: { diamante: 150 },
    dailyRedeem: true,
    redeemTier: "pequeno",
    sortOrder: 10,
  },
  {
    id: "alpha_redeem_medium",
    label: "Redeem diario medio",
    description: "Credita Diamante suficiente para alguns pacotes de recurso alpha.",
    kind: "daily_redeem",
    resources: { diamante: 500 },
    dailyRedeem: true,
    redeemTier: "medio",
    sortOrder: 20,
  },
  {
    id: "alpha_redeem_large",
    label: "Redeem diario grande",
    description: "Credita Diamante para acelerar uma sessao de teste sem resetar o save.",
    kind: "daily_redeem",
    resources: { diamante: 1200 },
    dailyRedeem: true,
    redeemTier: "grande",
    sortOrder: 30,
  },
  {
    id: "alpha_redeem_premium",
    label: "Redeem diario premium",
    description:
      "Credita Diamante para comprar Battle Pass, fila dupla e conveniencias alpha no mesmo dia.",
    kind: "daily_redeem",
    resources: { diamante: 3000 },
    dailyRedeem: true,
    redeemTier: "premium",
    sortOrder: 40,
  },
  {
    id: "alpha_battle_pass_premium",
    label: "Premium Battle Pass Alpha",
    description: "Compra a trilha premium do Battle Pass alpha no save ativo.",
    kind: "premium_unlock",
    cost: { diamante: -1200 },
    sortOrder: 100,
  },
  {
    id: "alpha_double_construction_queue",
    label: "Fila dupla de construcao",
    description: "Libera dois upgrades de predio ativos ao mesmo tempo na Base deste save.",
    kind: "convenience_unlock",
    cost: { diamante: -900 },
    effect: { type: "construction_slots", value: 2 },
    sortOrder: 110,
  },
  {
    id: "alpha_energy_pack_small",
    label: "Pacote de Energia Alpha",
    kind: "resource_pack",
    description: "Converte Diamante em Energia para continuar upgrades da Base.",
    cost: { diamante: -80 },
    resources: { energia: 80 },
    sortOrder: 200,
  },
  {
    id: "alpha_resource_pack_medium",
    label: "Pacote de recursos Alpha",
    description: "Converte Diamante em recursos mistos para simular compra de progresso.",
    kind: "resource_pack",
    cost: { diamante: -250 },
    resources: { almas: 50, energia: 120, sangue: 20, cristais: 10, ossos: 500 },
    sortOrder: 210,
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

  if (definition.premiumRequired === true && !state.value.progress.premium_unlocked) {
    return errorResponse("PREMIUM_REQUIRED", "Premium Battle Pass is not unlocked.", 409);
  }

  const now = new Date();
  const periodKey = rewardPeriodKey(definition, state.value.pass, now);
  const passXpDelta = definition.source === "battle_pass" ? 0 : definition.xp;
  const rewardPayload = {
    label: definition.label,
    tier: definition.tier ?? null,
    xp: definition.xp,
    resources: resourceDelta(definition.resources),
  };
  const resourcesPayload = resourceDelta(definition.resources);
  const requestHash = await mutationRequestHash("monetization/rewards/claim", body, {
    request_id: requestId,
    save_type: auth.saveType,
    reward_id: definition.id,
    source: definition.source,
    period_key: periodKey,
    pass_id: state.value.pass.id,
    premium_required: definition.premiumRequired === true,
    xp: definition.xp,
    pass_xp_delta: passXpDelta,
    resources: resourcesPayload,
  });
  const rpc = await restRequest<unknown>(config, "rpc/claim_reward_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        reward_id: definition.id,
        source: definition.source,
        period_key: periodKey,
        pass_id: state.value.pass.id,
        premium_required: definition.premiumRequired === true,
        xp: definition.xp,
        pass_xp_delta: passXpDelta,
        resources: resourcesPayload,
        reward_payload: rewardPayload,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "REWARD_CLAIM_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = foundationRpcPayload(rpc.value);
  const refreshed = await loadMonetizationState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...monetizationStatePayload(refreshed.value, now),
    already_claimed: rpcPayload.already_claimed === true,
    reward: rpcPayload.reward ?? {
      id: definition.id,
      source: definition.source,
      period_key: periodKey,
      payload: rewardPayload,
    },
  };
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

  const now = new Date();
  const dailyRedeemPeriodKey = dateKeySaoPaulo(now);

  const delta = combineResourceDeltas(product.cost ?? {}, product.resources ?? {});
  const purchasePayload = {
    product_id: product.id,
    label: product.label,
    description: product.description,
    kind: product.kind,
    alpha_simulated: true,
    cost: resourceDelta(product.cost ?? {}),
    resources: resourceDelta(product.resources ?? {}),
    delta: resourceDelta(delta),
    redeem_period_key: product.dailyRedeem === true ? dailyRedeemPeriodKey : null,
    effect: product.effect ?? null,
  };
  const deltaPayload = resourceDelta(delta);
  const productPayload = alphaProductPayload(product, state.value, dailyRedeemPeriodKey);
  const requestHash = await mutationRequestHash("monetization/alpha-purchase", body, {
    request_id: requestId,
    save_type: auth.saveType,
    product_id: product.id,
    pass_id: state.value.pass.id,
    resource_delta: deltaPayload,
    daily_redeem_period_key: dailyRedeemPeriodKey,
  });
  const rpc = await restRequest<unknown>(config, "rpc/alpha_purchase_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: state.value.gameSave.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        product_id: product.id,
        pass_id: state.value.pass.id,
        resource_delta: deltaPayload,
        purchase_payload: purchasePayload,
        product_payload: productPayload,
        daily_redeem: product.dailyRedeem === true,
        daily_redeem_period_key: dailyRedeemPeriodKey,
        unlock_premium: product.kind === "premium_unlock",
        owned_once: product.kind === "convenience_unlock",
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "ALPHA_PURCHASE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }
  const rpcPayload = foundationRpcPayload(rpc.value);
  const refreshed = await loadMonetizationState(auth, config);
  if (refreshed.error !== null) {
    return errorResponse(refreshed.error.code, refreshed.error.message, refreshed.error.status);
  }
  const responsePayload = {
    ...monetizationStatePayload(refreshed.value, now),
    already_redeemed: rpcPayload.already_redeemed === true,
    already_owned: rpcPayload.already_owned === true,
    purchase: rpcPayload.purchase ?? purchasePayload,
  };
  return jsonResponse(responsePayload);
}

async function loadMonetizationState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: MonetizationState; error: null } | { value: null; error: RestError }> {
  const player = await loadPlayer(auth, config);
  if (player.error !== null) return { value: null, error: player.error };
  const gameSave = await loadFoundationGameSave(
    config,
    restRequest,
    auth.userId,
    auth.saveType,
    player.value.id,
  );
  if (gameSave.error !== null) return { value: null, error: gameSave.error };
  const resources = await loadResources(config, player.value.id);
  if (resources.error !== null) return { value: null, error: resources.error };
  const pass = await activeBattlePass(config);
  if (pass.error !== null) return { value: null, error: pass.error };
  const progress = await ensureBattlePassProgress(config, player.value.id, pass.value.id);
  if (progress.error !== null) return { value: null, error: progress.error };
  const claims = await loadRewardClaims(config, player.value.id);
  if (claims.error !== null) return { value: null, error: claims.error };
  const purchases = await loadAlphaPurchases(config, player.value.id);
  if (purchases.error !== null) return { value: null, error: purchases.error };
  return {
    value: {
      player: player.value,
      gameSave: gameSave.value,
      resources: resources.value,
      pass: pass.value,
      progress: progress.value,
      claims: claims.value,
      purchases: purchases.value,
    },
    error: null,
  };
}

function monetizationStatePayload(state: MonetizationState, now: Date) {
  const dailyKey = dateKeySaoPaulo(now);
  const weeklyKey = weekKeyUTC(now);
  const passKey = state.pass.id;
  const products = ALPHA_PRODUCTS.toSorted((left, right) => left.sortOrder - right.sortOrder).map(
    (product) => alphaProductPayload(product, state, dailyKey),
  );
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
      alpha_products: products,
      shop_summary: alphaShopSummary(state, dailyKey),
      claimed: state.claims,
      alpha_purchases: state.purchases,
      period_keys: {
        daily: dailyKey,
        weekly: weeklyKey,
        battle_pass: passKey,
        alpha_redeem_daily: dailyKey,
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

function alphaProductPayload(
  product: AlphaProduct,
  state: MonetizationState,
  dailyRedeemPeriodKey: string,
) {
  const delta = combineResourceDeltas(product.cost ?? {}, product.resources ?? {});
  const alreadyRedeemed = product.dailyRedeem === true &&
    isDailyRedeemClaimed(state.purchases, product, dailyRedeemPeriodKey);
  const alreadyOwned = isAlphaProductOwned(state, product);
  let lockedReason = "";
  if (alreadyRedeemed) {
    lockedReason = "DAILY_REDEEM_ALREADY_CLAIMED";
  } else if (alreadyOwned) {
    lockedReason = "ALREADY_OWNED";
  } else if (!canApplyDelta(state.resources, delta)) {
    lockedReason = "INSUFFICIENT_RESOURCES";
  }
  return {
    id: product.id,
    label: product.label,
    description: product.description,
    kind: product.kind,
    cost: resourceDelta(product.cost ?? {}),
    resources: resourceDelta(product.resources ?? {}),
    delta: resourceDelta(delta),
    daily_redeem: product.dailyRedeem === true,
    redeem_tier: product.redeemTier ?? null,
    redeem_period_key: product.dailyRedeem === true ? dailyRedeemPeriodKey : null,
    effect: product.effect ?? null,
    already_redeemed: alreadyRedeemed,
    already_owned: alreadyOwned,
    can_purchase: lockedReason === "",
    locked_reason: lockedReason,
    alpha_simulated: true,
    sort_order: product.sortOrder,
  };
}

function alphaShopSummary(state: MonetizationState, dailyRedeemPeriodKey: string) {
  const dailyRedeemProducts = ALPHA_PRODUCTS.filter((product) => product.dailyRedeem === true);
  const dailyRedeemsClaimed =
    dailyRedeemProducts.filter((product) =>
      isDailyRedeemClaimed(state.purchases, product, dailyRedeemPeriodKey)
    ).length;
  const convenienceOwned = ALPHA_PRODUCTS.filter((product) =>
    product.kind === "convenience_unlock" && isAlphaProductOwned(state, product)
  ).map((product) => product.id);
  return {
    environment: "internal_alpha_v0",
    alpha_simulated: true,
    currency: "diamante",
    diamond_balance: numberValue(state.resources.diamante, 0),
    premium_unlocked: state.progress.premium_unlocked,
    daily_redeem_period_key: dailyRedeemPeriodKey,
    daily_redeems_total: dailyRedeemProducts.length,
    daily_redeems_claimed: dailyRedeemsClaimed,
    convenience_owned: convenienceOwned,
    reset_timezone: "America/Sao_Paulo",
  };
}

async function loadPlayer(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,username,save_type,level,xp,power&limit=1`,
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

async function loadAlphaPurchases(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: AlphaPurchaseRow[]; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<AlphaPurchaseRow[]>(
    config,
    `alpha_purchases?player_id=eq.${
      encodeURIComponent(playerId)
    }&select=id,product_id,request_id,purchase_payload,created_at&order=created_at.desc&limit=200`,
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
    `players?id=eq.${encodeURIComponent(player.id)}&select=id,username,save_type,level,xp,power`,
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
  if (reward.source === "daily") return dateKeySaoPaulo(now);
  if (reward.source === "weekly") return weekKeyUTC(now);
  return pass.id;
}

function isClaimed(claims: RewardClaimRow[], reward: RewardDefinition, periodKey: string): boolean {
  return claims.some((claim) =>
    claim.source === reward.source && claim.reward_id === reward.id &&
    claim.period_key === periodKey
  );
}

function isDailyRedeemClaimed(
  purchases: AlphaPurchaseRow[],
  product: AlphaProduct,
  periodKey: string,
): boolean {
  if (product.dailyRedeem !== true) return false;
  return purchases.some((purchase) => {
    if (purchase.product_id !== product.id) return false;
    const payload = isObject(purchase.purchase_payload) ? purchase.purchase_payload : {};
    if (stringValue(payload.redeem_period_key, "") === periodKey) return true;
    if ("redeem_period_key" in payload) return false;
    return dateKeySaoPaulo(new Date(purchase.created_at)) === periodKey;
  });
}

function isAlphaProductOwned(state: MonetizationState, product: AlphaProduct): boolean {
  if (product.kind === "premium_unlock") {
    return state.progress.premium_unlocked;
  }
  if (product.kind === "convenience_unlock") {
    return state.purchases.some((purchase) => purchase.product_id === product.id);
  }
  return false;
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

function dateKeySaoPaulo(date: Date): string {
  return new Date(date.getTime() - 3 * 60 * 60 * 1000).toISOString().slice(0, 10);
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
