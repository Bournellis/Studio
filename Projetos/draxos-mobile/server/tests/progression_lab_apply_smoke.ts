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

const normalHeaders = authHeaders(accessToken, "normal");
const labHeaders = authHeaders(accessToken, "progression_lab");
const normalGuestRequestId = crypto.randomUUID();
const labGuestRequestId = crypto.randomUUID();

const normalAccount = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "progression-lab-apply-normal",
    request_id: normalGuestRequestId,
  },
  normalHeaders,
);
const normalPlayer = objectField(normalAccount, "player");

const labAccount = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "progression-lab-apply-lab",
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

const normalApply = await postJson(
  `${SUPABASE_URL}/functions/v1/progression-lab/apply`,
  {
    request_id: crypto.randomUUID(),
    profile_id: "free_100_rewards",
    milestone_id: "10h",
    save_id: "free_100_rewards_10h",
  },
  normalHeaders,
  false,
);
assertEq(
  stringField(objectField(normalApply, "error"), "code"),
  "PROGRESSION_LAB_SAVE_REQUIRED",
  "normal save should not accept Progression Lab apply",
);

const applyRequestId = crypto.randomUUID();
const applied = await postJson(
  `${SUPABASE_URL}/functions/v1/progression-lab/apply`,
  {
    request_id: applyRequestId,
    profile_id: "free_100_rewards",
    milestone_id: "10h",
    save_id: "free_100_rewards_10h",
  },
  labHeaders,
);
const appliedPlayer = objectField(applied, "player");
const appliedBuild = objectField(applied, "build");
const appliedMetadata = objectField(applied, "progression_lab");
assertEq(
  stringField(appliedPlayer, "id"),
  stringField(labPlayer, "id"),
  "apply should preserve lab player id",
);
assertEq(
  stringField(appliedPlayer, "save_type"),
  "progression_lab",
  "apply should target progression_lab save",
);
assertEq(numberField(appliedPlayer, "level"), 14, "10h free_100 save should set level 14");
assertEq(
  stringField(appliedBuild, "weapon_type"),
  "cajado_ossario",
  "10h free_100 save should set generated weapon",
);
assertEq(
  stringField(appliedMetadata, "save_id"),
  "free_100_rewards_10h",
  "apply should return progression metadata",
);
assertEq(
  appliedMetadata.local_only,
  false,
  "server-backed progression metadata should not be local-only",
);

const appliedRepeat = await postJson(
  `${SUPABASE_URL}/functions/v1/progression-lab/apply`,
  {
    request_id: applyRequestId,
    profile_id: "free_100_rewards",
    milestone_id: "10h",
    save_id: "free_100_rewards_10h",
  },
  labHeaders,
);
assertEq(
  stringField(objectField(appliedRepeat, "progression_lab"), "save_id"),
  "free_100_rewards_10h",
  "apply should be idempotent by request_id",
);

const labState = await getJson(`${SUPABASE_URL}/functions/v1/account/state`, labHeaders);
assertEq(
  numberField(objectField(labState, "player"), "level"),
  14,
  "lab state should persist applied level",
);
assertEq(
  stringField(objectField(labState, "build"), "weapon_type"),
  "cajado_ossario",
  "lab state should persist applied build",
);

const labRanking = await getJson(
  `${SUPABASE_URL}/functions/v1/competition/ranking/current`,
  labHeaders,
);
assertEq(
  objectField(labRanking, "ranking").excluded_reason,
  "PROGRESSION_LAB_DOES_NOT_RANK",
  "applied lab save should remain out of ranking",
);

const labLatest = await getJson(`${SUPABASE_URL}/functions/v1/battle/latest`, labHeaders);
assert(
  objectFieldOrNull(labLatest, "battle_log") === null,
  "apply should clear previous lab battle log",
);

const labBattle = await postJson(`${SUPABASE_URL}/functions/v1/battle/request`, {
  request_id: crypto.randomUUID(),
  mode: "FIRST_SLICE_SIM",
}, labHeaders);
assertEq(
  stringField(objectField(labBattle, "battle_log"), "schema_version"),
  "battle_log_v1",
  "applied lab save should be playable in battle",
);

const labGuestReplay = await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "progression-lab-apply-lab",
    request_id: labGuestRequestId,
  },
  labHeaders,
);
assertEq(
  numberField(objectField(labGuestReplay, "player"), "level"),
  14,
  "account/guest idempotency should return applied lab state",
);

const normalAfterApply = await getJson(`${SUPABASE_URL}/functions/v1/account/state`, normalHeaders);
assertEq(
  stringField(objectField(normalAfterApply, "player"), "id"),
  stringField(normalPlayer, "id"),
  "normal player id should survive lab apply",
);
assertEq(
  numberField(objectField(normalAfterApply, "player"), "xp"),
  5,
  "normal xp should survive lab apply",
);
assertEq(
  numberField(objectField(normalAfterApply, "resources"), "diamante"),
  500,
  "normal diamonds should survive lab apply",
);

console.log("[progression-lab-apply-smoke] OK", {
  normal_player_id: normalPlayer.id,
  lab_player_id: labPlayer.id,
  applied_save: appliedMetadata.save_id,
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

function objectFieldOrNull(payload: JsonObject, key: string): JsonObject | null {
  const value = payload[key];
  if (value === null || value === undefined) return null;
  assert(isObject(value), `${key} should be an object or null`);
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
