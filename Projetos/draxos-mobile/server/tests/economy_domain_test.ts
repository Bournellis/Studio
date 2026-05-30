import {
  alphaProductDefinition,
  alphaProductPayload,
  alphaPurchaseProjection,
  canApplyDelta,
  combineResourceDeltas,
  type CraftingProjectionState,
  craftingRecipe,
  craftingStatePayload,
  craftProjection,
  crushBonesConversion,
  dateKeySaoPaulo,
  type EconomyResourceRow,
  type MonetizationProjectionState,
  monetizationStatePayload,
  resourceDelta,
  rewardClaimProjection,
  rewardDefinition,
  rewardPeriodKey,
  weekKeyUTC,
} from "../functions/_shared/economy_domain.ts";
import {
  craftingStatePayload as supabaseCraftingStatePayload,
  monetizationStatePayload as supabaseMonetizationStatePayload,
} from "../../supabase/functions/_shared/economy_domain.ts";

const SERVER_MODULE_PATH = "server/functions/_shared/economy_domain.ts";
const SUPABASE_MODULE_PATH = "supabase/functions/_shared/economy_domain.ts";
const NOW = new Date("2026-05-30T12:00:00.000Z");

Deno.test("economy domain module is mirrored and adapter-free", async () => {
  const serverModule = await Deno.readTextFile(SERVER_MODULE_PATH);
  const supabaseModule = await Deno.readTextFile(SUPABASE_MODULE_PATH);

  assertEq(
    normalizeNewlines(serverModule),
    normalizeNewlines(supabaseModule),
    "server and supabase economy domain modules should mirror exactly",
  );
  assertNotIncludes(
    serverModule,
    "Deno.serve",
    "economy domain must not serve HTTP",
  );
  assertNotIncludes(
    serverModule,
    "fetch(",
    "economy domain must not call Supabase REST",
  );
  assertNotIncludes(
    serverModule,
    "rpc/",
    "economy domain must not call transactional RPCs",
  );
});

Deno.test("economy domain preserves monetization state and reward projections", () => {
  const state = sampleMonetizationState();
  const payload = monetizationStatePayload(state, NOW);
  const supabasePayload = supabaseMonetizationStatePayload(state, NOW);

  assertEq(stableStringify(payload), stableStringify(supabasePayload));
  assertEq(payload.ok, true);
  const monetization = objectField(payload, "monetization");
  const periodKeys = objectField(monetization, "period_keys");
  assertEq(stringField(periodKeys, "daily"), "2026-05-30");
  assertEq(stringField(periodKeys, "weekly"), "2026-W22");
  assertEq(stringField(periodKeys, "battle_pass"), "pass_alpha_1");

  const daily = rewardDefinition("daily_first_victory");
  assert(daily !== undefined, "daily_first_victory should exist");
  const dailyClaim = rewardClaimProjection(daily, state.pass, NOW);
  assertEq(dailyClaim.periodKey, "2026-05-30");
  assertEq(dailyClaim.passXpDelta, 120);
  assertEq(
    stableStringify(dailyClaim.resourcesPayload),
    stableStringify({
      almas: 8,
      energia: 4,
      ossos: 100,
      sangue: 2,
    }),
  );

  const battlePass = rewardDefinition("bp_free_tier_1");
  assert(battlePass !== undefined, "bp_free_tier_1 should exist");
  const passClaim = rewardClaimProjection(battlePass, state.pass, NOW);
  assertEq(passClaim.periodKey, "pass_alpha_1");
  assertEq(passClaim.passXpDelta, 0);
  assertEq(rewardPeriodKey(battlePass, state.pass, NOW), "pass_alpha_1");
  assertEq(dateKeySaoPaulo(NOW), "2026-05-30");
  assertEq(weekKeyUTC(NOW), "2026-W22");
});

Deno.test("economy domain applies resource deltas and alpha purchase lock reasons", () => {
  assertEq(
    stableStringify(combineResourceDeltas({ diamante: -250 }, {
      almas: 50,
      energia: 120,
    })),
    stableStringify({ almas: 50, diamante: -250, energia: 120 }),
  );
  assertEq(
    stableStringify(resourceDelta({ almas: 0, energia: 5 })),
    stableStringify({
      energia: 5,
    }),
  );
  assertEq(canApplyDelta(resourceRow({ diamante: 100 }), { diamante: -250 }), false);
  assertEq(canApplyDelta(resourceRow({ diamante: 100 }), { diamante: -80 }), true);

  const product = alphaProductDefinition("alpha_resource_pack_medium");
  assert(product !== undefined, "alpha_resource_pack_medium should exist");
  const purchasable = sampleMonetizationState({ resources: resourceRow({ diamante: 300 }) });
  const projection = alphaPurchaseProjection(product, purchasable, "2026-05-30");
  assertEq(
    stableStringify(projection.deltaPayload),
    stableStringify({
      almas: 50,
      cristais: 10,
      diamante: -250,
      energia: 120,
      ossos: 500,
      sangue: 20,
    }),
  );
  assertEq(booleanField(objectValue(projection.productPayload), "can_purchase"), true);

  const insufficient = sampleMonetizationState({ resources: resourceRow({ diamante: 100 }) });
  const locked = alphaProductPayload(product, insufficient, "2026-05-30");
  assertEq(stringField(locked, "locked_reason"), "INSUFFICIENT_RESOURCES");

  const dailyRedeem = alphaProductDefinition("alpha_redeem_small");
  assert(dailyRedeem !== undefined, "alpha_redeem_small should exist");
  const redeemed = sampleMonetizationState({
    purchases: [{
      id: "purchase-1",
      product_id: dailyRedeem.id,
      request_id: "00000000-0000-4000-8000-000000000001",
      purchase_payload: { redeem_period_key: "2026-05-30" },
      created_at: "2026-05-30T10:00:00.000Z",
    }],
  });
  const redeemPayload = alphaProductPayload(dailyRedeem, redeemed, "2026-05-30");
  assertEq(booleanField(redeemPayload, "already_redeemed"), true);
  assertEq(stringField(redeemPayload, "locked_reason"), "DAILY_REDEEM_ALREADY_CLAIMED");
});

Deno.test("economy domain preserves crafting payload and source-sink projections", () => {
  const state = sampleCraftingState();
  const payload = craftingStatePayload(state);
  const supabasePayload = supabaseCraftingStatePayload(state);

  assertEq(stableStringify(payload), stableStringify(supabasePayload));
  assertEq(payload.ok, true);
  const crafting = objectField(payload, "crafting");
  assertEq(arrayField(crafting, "potions").length, 1);
  assertEq(arrayField(crafting, "recipes").length, 1);
  const slot = objectValue(arrayField(crafting, "potion_slots")[0]);
  assertEq(booleanField(slot, "unlocked"), true);
  assertEq(stringField(slot, "potion_id"), "pocao_vida");

  const recipe = craftingRecipe("craft_pocao_vida");
  assert(recipe !== undefined, "craft_pocao_vida should exist");
  const craft = craftProjection(recipe, 2);
  assertEq(stableStringify(craft.costPayload), stableStringify({ po_osso: -100 }));
  assertEq(
    stableStringify(craft.outputPayload),
    stableStringify({
      item_id: "pocao_vida",
      quantity: 2,
    }),
  );
  assertEq(
    stableStringify(crushBonesConversion(7)),
    stableStringify({
      input: { ossos: 7 },
      output: { po_osso: 7 },
    }),
  );
});

function sampleMonetizationState(
  overrides: Partial<MonetizationProjectionState> = {},
): MonetizationProjectionState {
  return {
    player: { id: "player-1", level: 10, power: 420 },
    resources: resourceRow({ diamante: 100 }),
    pass: {
      id: "pass_alpha_1",
      season_id: "season_alpha_1",
      pass_index: 1,
      display_name: "Alpha Pass",
      starts_at: "2026-05-01T00:00:00.000Z",
      ends_at: "2026-06-01T00:00:00.000Z",
      free_rewards: {},
      premium_rewards: {},
      is_active: true,
    },
    progress: {
      player_id: "player-1",
      pass_id: "pass_alpha_1",
      pass_xp: 140,
      premium_unlocked: false,
      updated_at: "2026-05-30T00:00:00.000Z",
    },
    claims: [],
    purchases: [],
    ...overrides,
  };
}

function sampleCraftingState(): CraftingProjectionState {
  return {
    resources: resourceRow({ ossos: 42, po_osso: 120 }),
    inventory: [{
      item_id: "pocao_vida",
      quantity: 3,
      updated_at: "2026-05-30T00:00:00.000Z",
    }],
    potionSlots: [{
      slot_index: 1,
      potion_id: "pocao_vida",
      behavior: {
        enabled: true,
        hp: { mode: "below", percent: 40 },
        mana: { mode: "ignore", percent: 0 },
      },
      updated_at: "2026-05-30T00:00:00.000Z",
    }],
  };
}

function resourceRow(overrides: Partial<EconomyResourceRow> = {}): EconomyResourceRow {
  return {
    almas: 0,
    energia: 0,
    sangue: 0,
    cristais: 0,
    ossos: 0,
    po_osso: 0,
    diamante: 0,
    updated_at: "2026-05-30T00:00:00.000Z",
    ...overrides,
  };
}

function normalizeNewlines(value: string): string {
  return value.replace(/\r\n/g, "\n");
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function objectValue(value: unknown): Record<string, unknown> {
  assert(isObject(value), `value should be object: ${JSON.stringify(value)}`);
  return value;
}

function objectField(
  payload: Record<string, unknown>,
  key: string,
): Record<string, unknown> {
  return objectValue(payload[key]);
}

function arrayField(payload: Record<string, unknown>, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  if (typeof value === "number") return String(value);
  return typeof value === "string" ? value : "";
}

function booleanField(payload: Record<string, unknown>, key: string): boolean {
  const value = payload[key];
  assert(typeof value === "boolean", `${key} should be boolean`);
  return value;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message?: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message ?? "values should match"}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}

function assertNotIncludes(
  actual: string,
  search: string,
  message: string,
): void {
  if (actual.includes(search)) {
    throw new Error(message);
  }
}
