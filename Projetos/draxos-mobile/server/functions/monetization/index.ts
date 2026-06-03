import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  type FoundationGameSaveRow,
  foundationRpcPayload,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import {
  alphaProductDefinition,
  alphaPurchaseProjection,
  type AlphaPurchaseRow,
  type BattlePassProgressRow,
  type BattlePassRow,
  dateKeySaoPaulo,
  type EconomyResourceRow,
  type MonetizationProjectionState,
  monetizationStatePayload,
  rewardClaimProjection,
  type RewardClaimRow,
  rewardDefinition,
  type RewardSource,
} from "../_shared/economy_domain.ts";
import {
  baseStatePayload,
  DEFAULT_CONSTRUCTION_SLOTS,
  DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID,
  type BaseConstructionJobRow,
  type BaseStructureRow,
} from "../_shared/base_domain.ts";
import { type SaveType, saveTypeFromRequest, saveTypeQuery } from "../_shared/save_context.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "state" | "reward_claim" | "alpha_purchase";

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

interface ResourceRow extends EconomyResourceRow {
  player_id: string;
  updated_at: string;
}

interface MonetizationState extends MonetizationProjectionState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  resources: ResourceRow;
  pass: BattlePassRow;
  progress: BattlePassProgressRow;
  claims: RewardClaimRow[];
  purchases: AlphaPurchaseRow[];
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

}

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const startedAtMs = performance.now();
  const state = await loadMonetizationState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }
  return jsonResponse(stateEnvelope(monetizationStatePayload(state.value, new Date()), {
    surface: "monetization",
    saveType: auth.saveType,
    startedAtMs,
  }));
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
  const claimProjection = rewardClaimProjection(definition, state.value.pass, now);
  const requestHash = await mutationRequestHash("monetization/rewards/claim", body, {
    request_id: requestId,
    save_type: auth.saveType,
    reward_id: definition.id,
    source: definition.source,
    period_key: claimProjection.periodKey,
    pass_id: state.value.pass.id,
    premium_required: definition.premiumRequired === true,
    xp: definition.xp,
    pass_xp_delta: claimProjection.passXpDelta,
    resources: claimProjection.resourcesPayload,
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
        period_key: claimProjection.periodKey,
        pass_id: state.value.pass.id,
        premium_required: definition.premiumRequired === true,
        xp: definition.xp,
        pass_xp_delta: claimProjection.passXpDelta,
        resources: claimProjection.resourcesPayload,
        reward_payload: claimProjection.rewardPayload,
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
      period_key: claimProjection.periodKey,
      payload: claimProjection.rewardPayload,
    },
  };
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "monetization",
    saveType: auth.saveType,
  }));
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
  const product = alphaProductDefinition(productId);
  if (product === undefined) {
    return errorResponse("INVALID_PRODUCT", "product_id is not part of Alpha monetization.", 400);
  }

  const state = await loadMonetizationState(auth, config);
  if (state.error !== null) {
    return errorResponse(state.error.code, state.error.message, state.error.status);
  }

  const now = new Date();
  const dailyRedeemPeriodKey = dateKeySaoPaulo(now);
  const purchaseProjection = alphaPurchaseProjection(
    product,
    state.value,
    dailyRedeemPeriodKey,
  );
  const requestHash = await mutationRequestHash("monetization/alpha-purchase", body, {
    request_id: requestId,
    save_type: auth.saveType,
    product_id: product.id,
    pass_id: state.value.pass.id,
    resource_delta: purchaseProjection.deltaPayload,
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
        resource_delta: purchaseProjection.deltaPayload,
        purchase_payload: purchaseProjection.purchasePayload,
        product_payload: purchaseProjection.productPayload,
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
    purchase: rpcPayload.purchase ?? purchaseProjection.purchasePayload,
  };
  Object.assign(responsePayload, await baseDeltaPayload(config, refreshed.value));
  return jsonResponse(stateEnvelope(responsePayload, {
    surface: "monetization",
    saveType: auth.saveType,
  }));
}

async function loadMonetizationState(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: MonetizationState; error: null } | { value: null; error: RestError }> {
  const player = await loadPlayer(auth, config);
  if (player.error !== null) return { value: null, error: player.error };
  const gameSavePromise = loadFoundationGameSave(
    config,
    restRequest,
    auth.userId,
    auth.saveType,
    player.value.id,
  );
  const resourcesPromise = loadResources(config, player.value.id);
  const claimsPromise = loadRewardClaims(config, player.value.id);
  const purchasesPromise = loadAlphaPurchases(config, player.value.id);
  const pass = await activeBattlePass(config);
  if (pass.error !== null) return { value: null, error: pass.error };
  const [gameSave, resources, progress, claims, purchases] = await Promise.all([
    gameSavePromise,
    resourcesPromise,
    ensureBattlePassProgress(config, player.value.id, pass.value.id),
    claimsPromise,
    purchasesPromise,
  ]);
  if (gameSave.error !== null) return { value: null, error: gameSave.error };
  if (resources.error !== null) return { value: null, error: resources.error };
  if (progress.error !== null) return { value: null, error: progress.error };
  if (claims.error !== null) return { value: null, error: claims.error };
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

async function baseDeltaPayload(
  config: EdgeConfig,
  state: MonetizationState,
): Promise<Record<string, unknown>> {
  const playerId = encodeURIComponent(state.player.id);
  const [slots, structuresResult, jobsResult] = await Promise.all([
    loadConstructionSlots(config, state.player.id),
    restRequest<BaseStructureRow[]>(
      config,
      `base_structures?player_id=eq.${playerId}&select=player_id,structure_id,level,last_collected_at,updated_at&order=structure_id.asc`,
      { method: "GET" },
    ),
    restRequest<BaseConstructionJobRow[]>(
      config,
      `construction_jobs?player_id=eq.${playerId}&select=*&order=created_at.desc`,
      { method: "GET" },
    ),
  ]);
  if (slots.error !== null || structuresResult.error !== null || jobsResult.error !== null) {
    return {};
  }
  return baseStatePayload({
    player: state.player,
    resources: state.resources,
    structures: structuresResult.value,
    jobs: jobsResult.value,
    constructionSlots: slots.value,
  });
}

async function loadConstructionSlots(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: number; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<{ id: string }[]>(
    config,
    `alpha_purchases?player_id=eq.${encodeURIComponent(playerId)}&product_id=eq.${
      encodeURIComponent(DOUBLE_CONSTRUCTION_QUEUE_PRODUCT_ID)
    }&select=id&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }
  return {
    value: result.value.length > 0 ? 2 : DEFAULT_CONSTRUCTION_SLOTS,
    error: null,
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

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/rewards/claim")) return "reward_claim";
  if (pathname.endsWith("/alpha-purchase")) return "alpha_purchase";
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

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
