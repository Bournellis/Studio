const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

interface JsonObject {
  [key: string]: unknown;
}

const auth = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  { data: { provider: "guest" } },
  baseHeaders(),
  false,
);
const accessToken = stringField(auth, "access_token");
assert(accessToken !== "", "anonymous auth should return access_token");

const headers = {
  ...baseHeaders(),
  authorization: `Bearer ${accessToken}`,
};

const unauthenticated = await getJson(
  `${SUPABASE_URL}/functions/v1/monetization/state`,
  baseHeaders(),
  false,
);
assertEq(
  errorCode(unauthenticated),
  "UNAUTHENTICATED",
  "monetization/state should require auth",
);

const account = await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-monetization-smoke",
  request_id: crypto.randomUUID(),
}, headers);
const player = objectField(account, "player");

const state = await getJson(
  `${SUPABASE_URL}/functions/v1/monetization/state`,
  headers,
);
const monetization = objectField(state, "monetization");
assert(
  isObject(objectField(monetization, "battle_pass")),
  "state should include battle pass",
);
assert(
  arrayField(monetization, "daily_rewards").length >= 5,
  "state should include daily rewards",
);
assert(
  arrayField(monetization, "weekly_rewards").length >= 3,
  "state should include weekly rewards",
);
assertEq(
  arrayField(monetization, "alpha_products").length,
  8,
  "state should include the alpha shop product catalog",
);
assertEq(
  numberField(objectField(monetization, "shop_summary"), "daily_redeems_total"),
  4,
  "shop summary should expose four daily redeem packages",
);

const claimRequestId = crypto.randomUUID();
const firstClaim = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/rewards/claim`,
  { request_id: claimRequestId, reward_id: "daily_collect_base" },
  headers,
);
const repeatedClaim = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/rewards/claim`,
  { request_id: claimRequestId, reward_id: "daily_collect_base" },
  headers,
);
assertEq(
  resourceSummary(objectField(firstClaim, "resources")),
  resourceSummary(objectField(repeatedClaim, "resources")),
  "daily reward claim should be idempotent",
);

const alreadyClaimed = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/rewards/claim`,
  { request_id: crypto.randomUUID(), reward_id: "daily_collect_base" },
  headers,
);
assertEq(
  alreadyClaimed.already_claimed,
  true,
  "same daily reward should not double grant in the same period",
);
assertEq(
  resourceSummary(objectField(firstClaim, "resources")),
  resourceSummary(objectField(alreadyClaimed, "resources")),
  "already claimed response should not mutate resources",
);

const smallRedeemRequestId = crypto.randomUUID();
const firstSmallRedeem = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: smallRedeemRequestId, product_id: "alpha_redeem_small" },
  headers,
);
const repeatedSmallRedeem = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: smallRedeemRequestId, product_id: "alpha_redeem_small" },
  headers,
);
assertEq(
  numberField(objectField(firstSmallRedeem, "resources"), "diamante"),
  150,
  "small alpha redeem should grant Diamante",
);
assertEq(
  resourceSummary(objectField(firstSmallRedeem, "resources")),
  resourceSummary(objectField(repeatedSmallRedeem, "resources")),
  "alpha redeem should be idempotent by request_id",
);

const duplicateSmallRedeem = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_redeem_small" },
  headers,
);
assertEq(
  duplicateSmallRedeem.already_redeemed,
  true,
  "same daily redeem should not double grant in the same Sao Paulo day",
);
assertEq(
  resourceSummary(objectField(firstSmallRedeem, "resources")),
  resourceSummary(objectField(duplicateSmallRedeem, "resources")),
  "already redeemed response should not mutate resources",
);

const premiumRedeem = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_redeem_premium" },
  headers,
);
assertEq(
  numberField(objectField(premiumRedeem, "resources"), "diamante"),
  3150,
  "premium alpha redeem should fund the convenience shop",
);

const premium = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_battle_pass_premium" },
  headers,
);
const premiumProgress = objectField(
  objectField(objectField(premium, "monetization"), "battle_pass"),
  "progress",
);
assertEq(
  premiumProgress.premium_unlocked,
  true,
  "premium alpha purchase should spend Diamante and unlock premium pass",
);
assertEq(
  numberField(objectField(premium, "resources"), "diamante"),
  1950,
  "premium alpha purchase should cost Diamante",
);

const doubleQueue = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
  { request_id: crypto.randomUUID(), product_id: "alpha_double_construction_queue" },
  headers,
);
assertEq(
  numberField(objectField(doubleQueue, "resources"), "diamante"),
  1050,
  "double construction queue should cost Diamante",
);
assert(
  arrayField(
    objectField(objectField(doubleQueue, "monetization"), "shop_summary"),
    "convenience_owned",
  )
    .includes("alpha_double_construction_queue"),
  "shop summary should list owned convenience products",
);

const premiumReward = await postJson(
  `${SUPABASE_URL}/functions/v1/monetization/rewards/claim`,
  { request_id: crypto.randomUUID(), reward_id: "bp_premium_tier_1" },
  headers,
);
assertEq(
  objectField(premiumReward, "reward").id,
  "bp_premium_tier_1",
  "premium reward should be claimable after unlock",
);

const directRewardInsert = await postJson(
  `${SUPABASE_URL}/rest/v1/reward_claims`,
  {
    player_id: player.id,
    source: "daily",
    reward_id: "direct_forbidden",
    period_key: "forbidden",
    request_id: crypto.randomUUID(),
    reward_payload: {},
  },
  headers,
  false,
);
assert(
  !directRewardInsert.ok,
  "direct anon insert into reward_claims should be blocked by RLS",
);

console.log("[monetization-rewards-smoke] OK", {
  player_id: player.id,
  diamonds: numberField(objectField(doubleQueue, "resources"), "diamante"),
  premium_unlocked: premiumProgress.premium_unlocked,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

async function postJson(
  url: string,
  body: JsonObject,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });
  return await parseResponse(response, requireOk);
}

async function getJson(
  url: string,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response, requireOk);
}

async function parseResponse(
  response: Response,
  requireOk: boolean,
): Promise<JsonObject> {
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${text}`,
    );
    assert(payload.ok === true, `response ok should be true: ${text}`);
  }
  return payload;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function arrayField(payload: JsonObject, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  if (typeof value === "number") return value;
  if (typeof value === "string") return Number(value);
  return 0;
}

function errorCode(payload: JsonObject): string {
  return stringField(objectField(payload, "error"), "code");
}

function resourceSummary(payload: JsonObject): string {
  return ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]
    .map((key) => `${key}:${String(payload[key] ?? 0)}`)
    .join("|");
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
