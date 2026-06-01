const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";
const BATTLE_FUNCTION_URL = (Deno.env.get("BATTLE_FUNCTION_URL") ??
  `${SUPABASE_URL}/functions/v1/battle`).replace(/\/$/, "");

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

const normalHeaders = authHeaders(accessToken, "normal");
const labHeaders = authHeaders(accessToken, "progression_lab");

const unauthenticatedHistory = await getJson(
  battleUrl("history"),
  baseHeaders(),
  false,
);
assertEq(
  errorCode(unauthenticatedHistory),
  "UNAUTHENTICATED",
  "battle/history should require auth",
);

await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-battle-history-smoke",
  request_id: crypto.randomUUID(),
}, normalHeaders);

const firstBattle = await requestFirstSlice(crypto.randomUUID(), normalHeaders);
const secondBattle = await requestFirstSlice(crypto.randomUUID(), normalHeaders);
const secondLog = objectField(secondBattle, "battle_log");
const secondBattleId = stringField(secondLog, "battle_id");
assert(secondBattleId !== "", "second normal battle should return battle_id");

const stateBeforeRead = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  normalHeaders,
);
const historyLimitOne = await getJson(
  battleUrl("history?limit=1"),
  normalHeaders,
);
const historyPayload = arrayField(historyLimitOne, "history");
assertEq(
  stringField(historyLimitOne, "schema_version"),
  "battle_history_v1",
  "history schema should match",
);
assertEq(stringField(historyLimitOne, "save_type"), "normal", "history save should be normal");
assertEq(historyPayload.length, 1, "limit=1 should return one history entry");

const latestEntry = objectFromArray(historyPayload, 0);
assertEq(
  stringField(latestEntry, "battle_id"),
  secondBattleId,
  "history should list newest battle first",
);
assertEq(
  stringField(latestEntry, "mode"),
  "FIRST_SLICE_SIM",
  "history entry should expose battle mode",
);
assert(!("events" in latestEntry), "history entry must not include full event log");
assert(numberField(latestEntry, "event_count") > 0, "history should expose event count");

const replay = await getJson(
  battleUrl(`replay?battle_id=${secondBattleId}`),
  normalHeaders,
);
const replayLog = objectField(replay, "battle_log");
assertEq(
  stringField(replayLog, "battle_id"),
  secondBattleId,
  "replay should return the requested battle",
);
assertEq(
  stringField(replayLog, "schema_version"),
  "battle_log_v1",
  "replay should keep battle_log_v1",
);
assertEq(
  arrayField(replayLog, "events").length,
  arrayField(secondLog, "events").length,
  "replay should return full saved event log",
);
assertEq(
  objectField(replay, "replay").read_only,
  true,
  "replay metadata should be read-only",
);

const invalidReplay = await getJson(
  battleUrl("replay?battle_id=not-a-uuid"),
  normalHeaders,
  false,
);
assertEq(errorCode(invalidReplay), "INVALID_BATTLE_ID", "invalid battle id should be rejected");

const stateAfterRead = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  normalHeaders,
);
assertEq(
  numberField(objectField(stateBeforeRead, "player"), "xp"),
  numberField(objectField(stateAfterRead, "player"), "xp"),
  "history/replay reads must not change XP",
);
assertApprox(
  numberField(objectField(stateBeforeRead, "resources"), "ossos"),
  numberField(objectField(stateAfterRead, "resources"), "ossos"),
  "history/replay reads must not change resources",
);

await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-battle-history-smoke-lab",
  request_id: crypto.randomUUID(),
}, labHeaders);
const labBattle = await requestFirstSlice(crypto.randomUUID(), labHeaders);
const labBattleId = stringField(objectField(labBattle, "battle_log"), "battle_id");
assert(labBattleId !== "", "lab battle should return battle_id");

const normalReplayForLabBattle = await getJson(
  battleUrl(`replay?battle_id=${labBattleId}`),
  normalHeaders,
  false,
);
assertEq(
  errorCode(normalReplayForLabBattle),
  "BATTLE_NOT_FOUND",
  "normal save must not read lab replay",
);

const labHistory = await getJson(
  battleUrl("history?limit=5"),
  labHeaders,
);
const labEntries = arrayField(labHistory, "history");
assert(
  labEntries.some((entry) =>
    isObject(entry) && stringField(entry, "battle_id") === labBattleId
  ),
  "lab history should include lab battle",
);

const normalHistory = await getJson(
  battleUrl("history?limit=20"),
  normalHeaders,
);
assert(
  !arrayField(normalHistory, "history").some((entry) =>
    isObject(entry) && stringField(entry, "battle_id") === labBattleId
  ),
  "normal history should not include lab battle",
);

console.log("[battle-history-smoke] OK", {
  latest_battle_id: secondBattleId,
  lab_battle_id: labBattleId,
  normal_history: arrayField(normalHistory, "history").length,
  lab_history: labEntries.length,
});

async function requestFirstSlice(
  requestId: string,
  headersToSend: Record<string, string>,
): Promise<JsonObject> {
  return await postJson(
    battleUrl("request"),
    {
      request_id: requestId,
      mode: "FIRST_SLICE_SIM",
      opponent_bot_id: "bot_effect_trainer_01",
    },
    headersToSend,
  );
}

function battleUrl(path: string): string {
  return `${BATTLE_FUNCTION_URL}/${path.replace(/^\//, "")}`;
}

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function authHeaders(accessToken: string, saveType: string): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
    "x-draxos-save-type": saveType,
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
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "GET",
    headers: headersToSend,
  });
  return await parseResponse(response, requireOk);
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
      `request failed with status ${response.status}: ${JSON.stringify(payload)}`,
    );
    assert(
      payload.ok === true,
      `response ok should be true: ${JSON.stringify(payload)}`,
    );
  }
  return payload;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function objectFromArray(payload: unknown[], index: number): JsonObject {
  const value = payload[index];
  assert(isObject(value), `array item ${index} should be an object`);
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

function errorCode(payload: JsonObject): string {
  const gatewayMessage = stringField(payload, "message");
  if (gatewayMessage.toLowerCase().includes("authorization")) {
    return "UNAUTHENTICATED";
  }
  return stringField(objectField(payload, "error"), "code");
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

function assertApprox(actual: number, expected: number, message: string): void {
  if (Math.abs(actual - expected) > 0.001) {
    throw new Error(`${message}. Expected ${expected}, got ${actual}`);
  }
}
