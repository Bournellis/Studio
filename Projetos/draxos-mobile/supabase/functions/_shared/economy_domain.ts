export type EconomyResourceKey =
  | "almas"
  | "energia"
  | "sangue"
  | "cristais"
  | "ossos"
  | "po_osso"
  | "diamante";

export type RewardSource = "daily" | "weekly" | "battle_pass";

export interface EconomyResourceRow {
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  po_osso: string | number;
  diamante: string | number;
  updated_at?: string;
}

export interface BattlePassRow {
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

export interface BattlePassProgressRow {
  player_id: string;
  pass_id: string;
  pass_xp: number;
  premium_unlocked: boolean;
  updated_at: string;
}

export interface RewardClaimRow {
  id: string;
  source: RewardSource;
  reward_id: string;
  period_key: string;
  reward_payload: unknown;
  created_at: string;
}

export interface AlphaPurchaseRow {
  id: string;
  product_id: string;
  request_id: string;
  purchase_payload: unknown;
  created_at: string;
}

export interface RewardDefinition {
  id: string;
  source: RewardSource;
  label: string;
  xp: number;
  resources: Partial<Record<EconomyResourceKey, number>>;
  tier?: number;
  premiumRequired?: boolean;
}

export interface AlphaProduct {
  id: string;
  label: string;
  description: string;
  kind: "daily_redeem" | "premium_unlock" | "resource_pack" | "convenience_unlock";
  resources?: Partial<Record<EconomyResourceKey, number>>;
  cost?: Partial<Record<EconomyResourceKey, number>>;
  dailyRedeem?: boolean;
  redeemTier?: "pequeno" | "medio" | "grande" | "premium";
  effect?: Record<string, unknown>;
  sortOrder: number;
}

export interface MonetizationProjectionState {
  player: unknown;
  resources: EconomyResourceRow;
  pass: BattlePassRow;
  progress: BattlePassProgressRow;
  claims: RewardClaimRow[];
  purchases: AlphaPurchaseRow[];
}

export interface BehaviorConfig {
  enabled: boolean;
  hp: BehaviorCondition;
  mana: BehaviorCondition;
}

export interface BehaviorCondition {
  mode: "ignore" | "below" | "above";
  percent: number;
}

export interface PotionDefinition {
  id: string;
  displayName: string;
  description: string;
  effect: Record<string, unknown>;
  defaultBehavior: BehaviorConfig;
}

export type CraftingInputDomain = "account_resource" | "openworld_chest";
export type CraftingOutputDomain = "account_consumable";

export interface CraftingRecipeInput {
  domain: CraftingInputDomain;
  itemId: string;
  quantity: number;
}

export interface CraftingRecipeOutput {
  domain: CraftingOutputDomain;
  itemId: string;
  quantity: number;
}

export interface CraftingRecipeStation {
  modeId: "openworld";
  sliceId: "forest";
  stationId: "fogueira_estavel_1";
  displayName: string;
}

export interface CraftingRecipe {
  id: string;
  displayName: string;
  input?: Partial<Record<EconomyResourceKey, number>>;
  output: { itemId: string; quantity: number };
  inputs?: CraftingRecipeInput[];
  outputs?: CraftingRecipeOutput[];
  station?: CraftingRecipeStation;
}

export interface CraftingInventoryRow {
  item_id: string;
  quantity: number;
  updated_at: string;
}

export interface CraftingPotionSlotRow {
  slot_index: number;
  potion_id: string | null;
  behavior: unknown;
  updated_at: string;
}

export interface CraftingProjectionState {
  resources: EconomyResourceRow;
  inventory: CraftingInventoryRow[];
  potionSlots: CraftingPotionSlotRow[];
}

export const ECONOMY_RESOURCE_KEYS: EconomyResourceKey[] = [
  "almas",
  "energia",
  "sangue",
  "cristais",
  "ossos",
  "po_osso",
  "diamante",
];

export const DAILY_REWARDS: RewardDefinition[] = [
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

export const WEEKLY_REWARDS: RewardDefinition[] = [
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

export const BATTLE_PASS_REWARDS: RewardDefinition[] = [
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

export const ALPHA_PRODUCTS: AlphaProduct[] = [
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

export const DEFAULT_POTION_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "below", percent: 40 },
  mana: { mode: "ignore", percent: 0 },
};

export const DEFAULT_FOCUS_POTION_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "ignore", percent: 0 },
  mana: { mode: "below", percent: 35 },
};

export const DEFAULT_WARD_POTION_BEHAVIOR: BehaviorConfig = {
  enabled: true,
  hp: { mode: "below", percent: 55 },
  mana: { mode: "ignore", percent: 0 },
};

export const POTIONS: PotionDefinition[] = [
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
  {
    id: "pocao_foco",
    displayName: "Pocao de Foco",
    description: "Restaura 25% da mana maxima quando o ritual perde folego.",
    effect: {
      type: "mana_restore",
      percent_max_mana: 25,
    },
    defaultBehavior: DEFAULT_FOCUS_POTION_BEHAVIOR,
  },
  {
    id: "pocao_resguardo",
    displayName: "Pocao de Resguardo",
    description: "Concede uma barreira de 12% da vida maxima.",
    effect: {
      type: "barrier_gain",
      percent_max_hp: 12,
    },
    defaultBehavior: DEFAULT_WARD_POTION_BEHAVIOR,
  },
];

export const CRAFTING_RECIPES: CraftingRecipe[] = [
  {
    id: "craft_pocao_vida",
    displayName: "Preparar Pocao de Vida",
    output: { itemId: "pocao_vida", quantity: 1 },
    inputs: [
      { domain: "openworld_chest", itemId: "folha", quantity: 2 },
      { domain: "openworld_chest", itemId: "cogumelo", quantity: 1 },
      { domain: "account_resource", itemId: "po_osso", quantity: 25 },
    ],
    outputs: [{ domain: "account_consumable", itemId: "pocao_vida", quantity: 1 }],
    station: {
      modeId: "openworld",
      sliceId: "forest",
      stationId: "fogueira_estavel_1",
      displayName: "Fogueira Estavel I",
    },
  },
  {
    id: "craft_pocao_foco",
    displayName: "Preparar Pocao de Foco",
    output: { itemId: "pocao_foco", quantity: 1 },
    inputs: [
      { domain: "openworld_chest", itemId: "fungo", quantity: 1 },
      { domain: "openworld_chest", itemId: "inseto", quantity: 1 },
      { domain: "account_resource", itemId: "po_osso", quantity: 15 },
    ],
    outputs: [{ domain: "account_consumable", itemId: "pocao_foco", quantity: 1 }],
    station: {
      modeId: "openworld",
      sliceId: "forest",
      stationId: "fogueira_estavel_1",
      displayName: "Fogueira Estavel I",
    },
  },
  {
    id: "craft_pocao_resguardo",
    displayName: "Preparar Pocao de Resguardo",
    output: { itemId: "pocao_resguardo", quantity: 1 },
    inputs: [
      { domain: "openworld_chest", itemId: "resina", quantity: 1 },
      { domain: "openworld_chest", itemId: "pedra_pequena", quantity: 1 },
      { domain: "account_resource", itemId: "po_osso", quantity: 20 },
    ],
    outputs: [{ domain: "account_consumable", itemId: "pocao_resguardo", quantity: 1 }],
    station: {
      modeId: "openworld",
      sliceId: "forest",
      stationId: "fogueira_estavel_1",
      displayName: "Fogueira Estavel I",
    },
  },
];

export const POTION_IDS = new Set(POTIONS.map((potion) => potion.id));

export function monetizationStatePayload(
  state: MonetizationProjectionState,
  now: Date,
): Record<string, unknown> {
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

export function rewardPayload(
  reward: RewardDefinition,
  claimed: boolean,
  periodKey: string,
): Record<string, unknown> {
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

export function rewardClaimProjection(
  reward: RewardDefinition,
  pass: BattlePassRow,
  now: Date,
): {
  periodKey: string;
  passXpDelta: number;
  resourcesPayload: Record<string, number>;
  rewardPayload: Record<string, unknown>;
} {
  const periodKey = rewardPeriodKey(reward, pass, now);
  const passXpDelta = reward.source === "battle_pass" ? 0 : reward.xp;
  const resourcesPayload = resourceDelta(reward.resources);
  return {
    periodKey,
    passXpDelta,
    resourcesPayload,
    rewardPayload: {
      label: reward.label,
      tier: reward.tier ?? null,
      xp: reward.xp,
      resources: resourcesPayload,
    },
  };
}

export function alphaProductPayload(
  product: AlphaProduct,
  state: MonetizationProjectionState,
  dailyRedeemPeriodKey: string,
): Record<string, unknown> {
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

export function alphaPurchaseProjection(
  product: AlphaProduct,
  state: MonetizationProjectionState,
  dailyRedeemPeriodKey: string,
): {
  deltaPayload: Record<string, number>;
  productPayload: Record<string, unknown>;
  purchasePayload: Record<string, unknown>;
} {
  const delta = combineResourceDeltas(product.cost ?? {}, product.resources ?? {});
  const deltaPayload = resourceDelta(delta);
  return {
    deltaPayload,
    productPayload: alphaProductPayload(product, state, dailyRedeemPeriodKey),
    purchasePayload: {
      product_id: product.id,
      label: product.label,
      description: product.description,
      kind: product.kind,
      alpha_simulated: true,
      cost: resourceDelta(product.cost ?? {}),
      resources: resourceDelta(product.resources ?? {}),
      delta: deltaPayload,
      redeem_period_key: product.dailyRedeem === true ? dailyRedeemPeriodKey : null,
      effect: product.effect ?? null,
    },
  };
}

export function alphaShopSummary(
  state: MonetizationProjectionState,
  dailyRedeemPeriodKey: string,
): Record<string, unknown> {
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

export function rewardDefinition(rewardId: string): RewardDefinition | undefined {
  return [...DAILY_REWARDS, ...WEEKLY_REWARDS, ...BATTLE_PASS_REWARDS].find((reward) =>
    reward.id === rewardId
  );
}

export function alphaProductDefinition(productId: string): AlphaProduct | undefined {
  return ALPHA_PRODUCTS.find((product) => product.id === productId);
}

export function rewardPeriodKey(
  reward: RewardDefinition,
  pass: BattlePassRow,
  now: Date,
): string {
  if (reward.source === "daily") return dateKeySaoPaulo(now);
  if (reward.source === "weekly") return weekKeyUTC(now);
  return pass.id;
}

export function isClaimed(
  claims: RewardClaimRow[],
  reward: RewardDefinition,
  periodKey: string,
): boolean {
  return claims.some((claim) =>
    claim.source === reward.source && claim.reward_id === reward.id &&
    claim.period_key === periodKey
  );
}

export function isDailyRedeemClaimed(
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

export function isAlphaProductOwned(
  state: MonetizationProjectionState,
  product: AlphaProduct,
): boolean {
  if (product.kind === "premium_unlock") {
    return state.progress.premium_unlocked;
  }
  if (product.kind === "convenience_unlock") {
    return state.purchases.some((purchase) => purchase.product_id === product.id);
  }
  return false;
}

export function canApplyDelta(
  resources: EconomyResourceRow,
  delta: Partial<Record<EconomyResourceKey, number>>,
): boolean {
  for (const key of ECONOMY_RESOURCE_KEYS) {
    const nextValue = numberValue(resources[key], 0) + numberValue(delta[key], 0);
    if (nextValue < 0) return false;
  }
  return true;
}

export function combineResourceDeltas(
  left: Partial<Record<EconomyResourceKey, number>>,
  right: Partial<Record<EconomyResourceKey, number>>,
): Partial<Record<EconomyResourceKey, number>> {
  const combined: Partial<Record<EconomyResourceKey, number>> = {};
  for (const key of ECONOMY_RESOURCE_KEYS) {
    const value = numberValue(left[key], 0) + numberValue(right[key], 0);
    if (value !== 0) combined[key] = value;
  }
  return combined;
}

export function scaledResourceDelta(
  input: Partial<Record<EconomyResourceKey, number>>,
  quantityMultiplier: number,
): Partial<Record<EconomyResourceKey, number>> {
  const delta: Partial<Record<EconomyResourceKey, number>> = {};
  for (const [key, value] of Object.entries(input)) {
    const resourceKey = key as EconomyResourceKey;
    delta[resourceKey] = numberValue(value, 0) * quantityMultiplier;
  }
  return delta;
}

export function resourceDelta(
  delta: Partial<Record<EconomyResourceKey, number>>,
): Record<string, number> {
  const payload: Record<string, number> = {};
  for (const key of ECONOMY_RESOURCE_KEYS) {
    const value = numberValue(delta[key], 0);
    if (value !== 0) payload[key] = value;
  }
  return payload;
}

export function dateKeySaoPaulo(date: Date): string {
  return new Date(date.getTime() - 3 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

export function weekKeyUTC(date: Date): string {
  const cursor = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  const dayNumber = cursor.getUTCDay() || 7;
  cursor.setUTCDate(cursor.getUTCDate() + 4 - dayNumber);
  const yearStart = new Date(Date.UTC(cursor.getUTCFullYear(), 0, 1));
  const weekNumber = Math.ceil(((cursor.getTime() - yearStart.getTime()) / 86_400_000 + 1) / 7);
  return `${cursor.getUTCFullYear()}-W${String(weekNumber).padStart(2, "0")}`;
}

export function craftingStatePayload(state: CraftingProjectionState): Record<string, unknown> {
  return {
    ok: true,
    resources: state.resources,
    crafting: {
      resources: {
        ossos: numberValue(state.resources.ossos, 0),
        po_osso: numberValue(state.resources.po_osso, 0),
      },
      potions: POTIONS.map(potionPayload),
      recipes: CRAFTING_RECIPES.map(recipePayload),
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

export function potionPayload(potion: PotionDefinition): Record<string, unknown> {
  return {
    id: potion.id,
    display_name: potion.displayName,
    description: potion.description,
    effect: potion.effect,
    default_behavior: potion.defaultBehavior,
  };
}

export function recipePayload(recipe: CraftingRecipe): Record<string, unknown> {
  const legacyInput = recipe.input === undefined ? {} : resourceDelta(recipe.input);
  const inputs = (recipe.inputs ?? recipeInputsFromLegacy(recipe)).map((input) => ({
    domain: input.domain,
    item_id: input.itemId,
    quantity: input.quantity,
  }));
  const outputs = (recipe.outputs ?? recipeOutputsFromLegacy(recipe)).map((output) => ({
    domain: output.domain,
    item_id: output.itemId,
    quantity: output.quantity,
  }));
  return {
    id: recipe.id,
    display_name: recipe.displayName,
    input: legacyInput,
    inputs,
    output: {
      item_id: recipe.output.itemId,
      quantity: recipe.output.quantity,
    },
    outputs,
    station: recipe.station === undefined ? null : {
      mode_id: recipe.station.modeId,
      slice_id: recipe.station.sliceId,
      station_id: recipe.station.stationId,
      display_name: recipe.station.displayName,
    },
  };
}

export function craftingRecipe(recipeId: string): CraftingRecipe | undefined {
  return CRAFTING_RECIPES.find((recipe) => recipe.id === recipeId);
}

export function potionDefinition(itemId: string): PotionDefinition | undefined {
  return POTIONS.find((potion) => potion.id === itemId);
}

export function craftProjection(
  recipe: CraftingRecipe,
  quantity: number,
): {
  costPayload: Record<string, number>;
  outputPayload: { item_id: string; quantity: number };
} {
  if (recipe.station !== undefined) {
    throw new Error("STATION_REQUIRED");
  }
  return {
    costPayload: resourceDelta(scaledResourceDelta(recipe.input ?? {}, -quantity)),
    outputPayload: {
      item_id: recipe.output.itemId,
      quantity: recipe.output.quantity * quantity,
    },
  };
}

export function stationCraftProjection(
  recipe: CraftingRecipe,
  quantity: number,
): {
  accountCostPayload: Record<string, number>;
  openworldChestCostPayload: Record<string, number>;
  outputPayload: { item_id: string; quantity: number };
  inputsPayload: Array<Record<string, unknown>>;
  outputsPayload: Array<Record<string, unknown>>;
} {
  const accountCost: Partial<Record<EconomyResourceKey, number>> = {};
  const openworldChestCost: Record<string, number> = {};
  for (const input of recipe.inputs ?? recipeInputsFromLegacy(recipe)) {
    const scaledQuantity = input.quantity * quantity;
    if (input.domain === "account_resource") {
      const key = input.itemId as EconomyResourceKey;
      accountCost[key] = numberValue(accountCost[key], 0) - scaledQuantity;
    } else if (input.domain === "openworld_chest") {
      openworldChestCost[input.itemId] = numberValue(openworldChestCost[input.itemId], 0) -
        scaledQuantity;
    }
  }
  const output = recipe.outputs?.[0] ?? recipeOutputsFromLegacy(recipe)[0];
  return {
    accountCostPayload: resourceDelta(accountCost),
    openworldChestCostPayload: openworldChestCost,
    outputPayload: {
      item_id: output.itemId,
      quantity: output.quantity * quantity,
    },
    inputsPayload: (recipe.inputs ?? recipeInputsFromLegacy(recipe)).map((input) => ({
      domain: input.domain,
      item_id: input.itemId,
      quantity: input.quantity * quantity,
    })),
    outputsPayload: (recipe.outputs ?? recipeOutputsFromLegacy(recipe)).map((recipeOutput) => ({
      domain: recipeOutput.domain,
      item_id: recipeOutput.itemId,
      quantity: recipeOutput.quantity * quantity,
    })),
  };
}

export function crushBonesConversion(amount: number): {
  input: Record<string, number>;
  output: Record<string, number>;
} {
  return { input: { ossos: amount }, output: { po_osso: amount } };
}

export function normalizeBehaviorOrDefault(
  value: unknown,
  fallback: BehaviorConfig,
): BehaviorConfig {
  const normalized = normalizeBehavior(value);
  return normalized.error === null ? normalized.value : fallback;
}

export function normalizeBehavior(value: unknown): { value: BehaviorConfig; error: null } | {
  value: null;
  error: { code: string; message: string; status: number };
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
): { value: BehaviorCondition; error: null } | {
  value: null;
  error: { code: string; message: string; status: number };
} {
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

function recipeInputsFromLegacy(recipe: CraftingRecipe): CraftingRecipeInput[] {
  return Object.entries(recipe.input ?? {}).map(([itemId, quantity]) => ({
    domain: "account_resource",
    itemId,
    quantity: Math.max(0, Math.trunc(numberValue(quantity, 0))),
  }));
}

function recipeOutputsFromLegacy(recipe: CraftingRecipe): CraftingRecipeOutput[] {
  return [{
    domain: "account_consumable",
    itemId: recipe.output.itemId,
    quantity: recipe.output.quantity,
  }];
}
