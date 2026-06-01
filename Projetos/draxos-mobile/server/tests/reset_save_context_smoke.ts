const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";

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
const normalGuestRequestId = crypto.randomUUID();
const labGuestRequestId = crypto.randomUUID();

const normalAccount = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "reset-save-normal-smoke",
    request_id: normalGuestRequestId,
  },
  normalHeaders,
);
const normalPlayer = objectField(normalAccount, "player");

const labAccount = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "reset-save-lab-smoke",
    request_id: labGuestRequestId,
  },
  labHeaders,
);
const labPlayer = objectField(labAccount, "player");

await postJson(`${SUPABASE_URL}/functions/v1/battle/request`, {
  request_id: crypto.randomUUID(),
  mode: "MVP_ONLY",
}, normalHeaders);
await postJson(`${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`, {
  request_id: crypto.randomUUID(),
  product_id: "alpha_redeem_medium",
}, normalHeaders);
await postJson(`${SUPABASE_URL}/functions/v1/battle/request`, {
  request_id: crypto.randomUUID(),
  mode: "MVP_ONLY",
}, labHeaders);
await postJson(`${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`, {
  request_id: crypto.randomUUID(),
  product_id: "alpha_redeem_medium",
}, labHeaders);

const progressedNormal = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  normalHeaders,
);
assertEq(
  numberField(objectField(progressedNormal, "player"), "xp"),
  5,
  "normal should have battle xp",
);
assertEq(
  numberField(objectField(progressedNormal, "resources"), "diamante"),
  500,
  "normal should have alpha diamonds",
);

const progressedLab = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  labHeaders,
);
assertEq(
  numberField(objectField(progressedLab, "player"), "xp"),
  5,
  "lab should have battle xp",
);

const mismatchReset = await postJson(
  `${SUPABASE_URL}/functions/v1/account/saves/reset`,
  { request_id: crypto.randomUUID(), save_type: "progression_lab" },
  normalHeaders,
  false,
);
assertEq(
  stringField(objectField(mismatchReset, "error"), "code"),
  "SAVE_TYPE_MISMATCH",
  "body save_type should match active save header",
);

const labReset = await postJson(
  `${SUPABASE_URL}/functions/v1/account/saves/reset`,
  {
    request_id: crypto.randomUUID(),
    save_type: "progression_lab",
  },
  labHeaders,
);
assertEq(
  stringField(objectField(labReset, "player"), "id"),
  stringField(labPlayer, "id"),
  "lab reset should keep lab player id",
);
assertEq(
  numberField(objectField(labReset, "player"), "xp"),
  0,
  "lab xp should reset",
);
assertEq(
  numberField(objectField(labReset, "resources"), "diamante"),
  0,
  "lab diamonds should reset",
);

const labLatest = await getJson(
  `${SUPABASE_URL}/functions/v1/battle/latest`,
  labHeaders,
);
assert(
  objectFieldOrNull(labLatest, "battle_log") === null,
  "lab battles should be cleared by lab reset",
);

const labGuestReplay = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "reset-save-lab-smoke",
    request_id: labGuestRequestId,
  },
  labHeaders,
);
assertEq(
  numberField(objectField(labGuestReplay, "player"), "xp"),
  0,
  "account/guest idempotency should return reset lab state",
);

const normalAfterLabReset = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  normalHeaders,
);
assertEq(
  stringField(objectField(normalAfterLabReset, "player"), "id"),
  stringField(normalPlayer, "id"),
  "normal player id should be preserved after lab reset",
);
assertEq(
  numberField(objectField(normalAfterLabReset, "player"), "xp"),
  5,
  "normal xp should survive lab reset",
);
assertEq(
  numberField(objectField(normalAfterLabReset, "resources"), "diamante"),
  500,
  "normal diamonds should survive lab reset",
);

const normalResetRequestId = crypto.randomUUID();
const normalReset = await postJson(
  `${SUPABASE_URL}/functions/v1/account/saves/reset`,
  {
    request_id: normalResetRequestId,
    save_type: "normal",
  },
  normalHeaders,
);
const normalResetRepeat = await postJson(
  `${SUPABASE_URL}/functions/v1/account/saves/reset`,
  {
    request_id: normalResetRequestId,
    save_type: "normal",
  },
  normalHeaders,
);
assertEq(
  stringField(objectField(normalResetRepeat, "player"), "id"),
  stringField(objectField(normalReset, "player"), "id"),
  "reset should be idempotent by request_id",
);
assertEq(
  numberField(objectField(normalReset, "player"), "xp"),
  0,
  "normal xp should reset",
);
assertEq(
  numberField(objectField(normalReset, "resources"), "diamante"),
  0,
  "normal diamonds should reset",
);

const labAfterNormalReset = await getJson(
  `${SUPABASE_URL}/functions/v1/account/state`,
  labHeaders,
);
assertEq(
  stringField(objectField(labAfterNormalReset, "player"), "id"),
  stringField(labPlayer, "id"),
  "lab player id should survive normal reset",
);
assertEq(
  numberField(objectField(labAfterNormalReset, "player"), "xp"),
  0,
  "lab reset state should survive normal reset",
);

console.log("[reset-save-context-smoke] OK", {
  normal_player_id: normalPlayer.id,
  lab_player_id: labPlayer.id,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function authHeaders(
  accessToken: string,
  saveType: string,
): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
    "x-draxos-save-type": saveType,
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

function objectFieldOrNull(
  payload: JsonObject,
  key: string,
): JsonObject | null {
  const value = payload[key];
  if (value === null) {
    return null;
  }
  assert(isObject(value), `${key} should be an object or null`);
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
    return Number.isFinite(parsed) ? parsed : 0;
  }
  return 0;
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
