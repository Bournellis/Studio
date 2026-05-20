const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

interface JsonObject {
  [key: string]: unknown;
}

const auth = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  {
    data: { provider: "guest" },
  },
  baseHeaders(),
  false,
);
const accessToken = stringField(auth, "access_token");
assert(accessToken !== "", "anonymous auth should return access_token");

const headers = {
  ...baseHeaders(),
  authorization: `Bearer ${accessToken}`,
};

await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-first-slice-smoke",
  request_id: crypto.randomUUID(),
}, headers);

const effectRequestId = crypto.randomUUID();
const effectBattle = await requestFirstSlice(
  effectRequestId,
  "bot_effect_trainer_01",
);
const repeatedEffectBattle = await requestFirstSlice(
  effectRequestId,
  "bot_effect_trainer_01",
);
const summonBattle = await requestFirstSlice(
  crypto.randomUUID(),
  "bot_summon_trainer_01",
);
const defaultBattle = await requestFirstSlice(crypto.randomUUID());
const latest = await getJson(
  `${SUPABASE_URL}/functions/v1/battle/latest`,
  headers,
);
const state = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  headers,
);

const effectLog = objectField(effectBattle, "battle_log");
const repeatedEffectLog = objectField(repeatedEffectBattle, "battle_log");
const summonLog = objectField(summonBattle, "battle_log");
const defaultLog = objectField(defaultBattle, "battle_log");
const latestLog = objectField(latest, "battle_log");

assertEq(
  stringField(effectLog, "mode"),
  "FIRST_SLICE_SIM",
  "effect battle mode should match",
);
assertEq(
  stringField(effectLog, "battle_id"),
  stringField(repeatedEffectLog, "battle_id"),
  "repeated request_id should return the same first-slice battle",
);
assertEq(
  stringField(defaultLog, "battle_id"),
  stringField(latestLog, "battle_id"),
  "latest battle should match the newest first-slice battle",
);
assertEq(
  stringField(
    objectField(objectField(defaultLog, "participants"), "opponent"),
    "id",
  ),
  "bot_effect_trainer_01",
  "default first-slice opponent should be effect trainer",
);

assertEvent(effectLog, "dot_apply");
assertEvent(effectLog, "dot_tick");
assertEvent(effectLog, "status_apply");
assertEvent(effectLog, "barrier_absorb");
assertEvent(effectLog, "pet_attack");
assertEvent(summonLog, "summon_spawn");
assertEvent(summonLog, "summon_attack");

const effectRewards = objectField(effectBattle, "rewards");
const summonRewards = objectField(summonBattle, "rewards");
const defaultRewards = objectField(defaultBattle, "rewards");
assertEq(
  stringField(effectRewards, "type"),
  "FIRST_SLICE_SIM",
  "effect reward type should match",
);
assertEq(
  stringField(summonRewards, "type"),
  "FIRST_SLICE_SIM",
  "summon reward type should match",
);
assertEq(
  stringField(defaultRewards, "type"),
  "FIRST_SLICE_SIM",
  "default reward type should match",
);

const expectedXp = resourceNumber(effectRewards, "xp") +
  resourceNumber(summonRewards, "xp") + resourceNumber(defaultRewards, "xp");
const expectedAlmas = resourceNumber(effectRewards, "almas") +
  resourceNumber(summonRewards, "almas") +
  resourceNumber(defaultRewards, "almas");
const expectedEnergia = resourceNumber(effectRewards, "energia") +
  resourceNumber(summonRewards, "energia") +
  resourceNumber(defaultRewards, "energia");
const expectedSangue = resourceNumber(effectRewards, "sangue") +
  resourceNumber(summonRewards, "sangue") +
  resourceNumber(defaultRewards, "sangue");
const expectedOssos = resourceNumber(effectRewards, "ossos") +
  resourceNumber(summonRewards, "ossos") +
  resourceNumber(defaultRewards, "ossos");

assertEq(
  numberField(objectField(state, "player"), "xp"),
  expectedXp,
  "XP should not duplicate",
);
assertApprox(
  numberField(objectField(state, "resources"), "almas"),
  expectedAlmas,
  "Almas should match",
);
assertApprox(
  numberField(objectField(state, "resources"), "energia"),
  expectedEnergia,
  "Energia should match",
);
assertApprox(
  numberField(objectField(state, "resources"), "sangue"),
  expectedSangue,
  "Sangue should match",
);
assertApprox(
  numberField(objectField(state, "resources"), "ossos"),
  expectedOssos,
  "Ossos should match",
);

console.log("[first-slice-smoke] OK", {
  effect_battle_id: stringField(effectLog, "battle_id"),
  summon_battle_id: stringField(summonLog, "battle_id"),
  default_battle_id: stringField(defaultLog, "battle_id"),
  effect_events: (effectLog.events as unknown[]).length,
  summon_events: (summonLog.events as unknown[]).length,
  xp: numberField(objectField(state, "player"), "xp"),
  almas: numberField(objectField(state, "resources"), "almas"),
});

async function requestFirstSlice(
  requestId: string,
  opponentBotId = "",
): Promise<JsonObject> {
  const body: JsonObject = {
    request_id: requestId,
    mode: "FIRST_SLICE_SIM",
  };
  if (opponentBotId !== "") {
    body.opponent_bot_id = opponentBotId;
  }

  return await postJson(
    `${SUPABASE_URL}/functions/v1/battle/request`,
    body,
    headers,
  );
}

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

async function postJson(
  url: string,
  body: JsonObject,
  headersToSend: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "POST",
    headers: headersToSend,
    body: JSON.stringify(body),
  });
  return await parseResponse(response, requireOk);
}

async function getJson(
  url: string,
  headersToSend: Record<string, string>,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "GET",
    headers: headersToSend,
  });
  return await parseResponse(response, true);
}

async function parseResponse(
  response: Response,
  requireOk: boolean,
): Promise<JsonObject> {
  const payload = await response.json() as unknown;
  assert(isObject(payload), "response should be a JSON object");
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${
        JSON.stringify(payload)
      }`,
    );
    assert(
      payload.ok === true,
      `response ok should be true: ${JSON.stringify(payload)}`,
    );
  }
  return payload;
}

function assertEvent(log: JsonObject, eventType: string): void {
  const events = log.events;
  assert(Array.isArray(events), "battle log should include events");
  assert(
    events.some((event) => isObject(event) && event.type === eventType),
    `battle log should include ${eventType}`,
  );
}

function resourceNumber(rewards: JsonObject, key: string): number {
  return numberField(objectField(rewards, "resources"), key);
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  if (typeof value === "number") {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }
  throw new Error(`${key} should be numeric, got ${JSON.stringify(value)}`);
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
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}

function assertApprox(actual: number, expected: number, message: string): void {
  if (Math.abs(actual - expected) > 0.001) {
    throw new Error(`${message}. Expected ${expected}, got ${actual}`);
  }
}
