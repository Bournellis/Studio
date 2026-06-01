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

const headers = authHeaders(accessToken, "progression_lab");
await postJson(
  `${SUPABASE_URL}/functions/v1/account/guest`,
  {
    invite_code: "ALPHA-TEST",
    device_label: "build-equip-smoke",
    request_id: crypto.randomUUID(),
  },
  headers,
);

await postJson(
  `${SUPABASE_URL}/functions/v1/progression-lab/apply`,
  {
    request_id: crypto.randomUUID(),
    profile_id: "free_100_rewards",
    milestone_id: "20h",
    save_id: "free_100_rewards_20h",
  },
  headers,
);

const initialState = await getJson(
  `${SUPABASE_URL}/functions/v1/build/state`,
  headers,
);
assertEquipmentOptions(initialState);

const equipRequestId = crypto.randomUUID();
const equipped = await postJson(
  `${SUPABASE_URL}/functions/v1/build/equip`,
  {
    request_id: equipRequestId,
    weapon: { type: "varinha_cinzas", quality: "starter" },
    spell_slots: [{ slot_index: 1, spell_id: "sussurro_medo" }],
    passive_id: "doutrina_pavor",
    pet_id: "corvo_pressagio",
  },
  headers,
);
assertEquippedState(equipped, {
  weapon_type: "varinha_cinzas",
  spell_id: "sussurro_medo",
  passive_id: "doutrina_pavor",
  pet_id: "corvo_pressagio",
});

const repeated = await postJson(
  `${SUPABASE_URL}/functions/v1/build/equip`,
  {
    request_id: equipRequestId,
    weapon: { type: "varinha_cinzas", quality: "starter" },
    spell_slots: [{ slot_index: 1, spell_id: "sussurro_medo" }],
    passive_id: "doutrina_pavor",
    pet_id: "corvo_pressagio",
  },
  headers,
);
assertEquippedState(repeated, {
  weapon_type: "varinha_cinzas",
  spell_id: "sussurro_medo",
  passive_id: "doutrina_pavor",
  pet_id: "corvo_pressagio",
});

const removed = await postJson(
  `${SUPABASE_URL}/functions/v1/build/equip`,
  {
    request_id: crypto.randomUUID(),
    spell_slots: [{ slot_index: 1, spell_id: null }],
    passive_id: null,
    pet_id: null,
  },
  headers,
);
const removedBuild = combatBuild(removed);
assertEq(
  spellSlot(removedBuild, 1).spell_id ?? null,
  null,
  "build/equip should remove a spell from a position",
);
assertEq(
  removedBuild.passive_id ?? null,
  null,
  "build/equip should remove doctrine",
);
assertEq(removedBuild.pet_id ?? null, null, "build/equip should remove familiar");

const lockedSlot = await postJson(
  `${SUPABASE_URL}/functions/v1/build/equip`,
  {
    request_id: crypto.randomUUID(),
    spell_slots: [{ slot_index: 3, spell_id: "sussurro_medo" }],
  },
  headers,
  false,
);
assertEq(
  errorCode(lockedSlot),
  "SPELL_SLOT_LOCKED",
  "build/equip should reject locked spell positions",
);

const invalidFamiliar = await postJson(
  `${SUPABASE_URL}/functions/v1/build/equip`,
  {
    request_id: crypto.randomUUID(),
    pet_id: "familiar_inexistente",
  },
  headers,
  false,
);
assertEq(
  errorCode(invalidFamiliar),
  "INVALID_FAMILIAR",
  "build/equip should reject unknown familiars",
);

const duplicateSpell = await postJson(
  `${SUPABASE_URL}/functions/v1/build/equip`,
  {
    request_id: crypto.randomUUID(),
    spell_slots: [
      { slot_index: 1, spell_id: "sussurro_medo" },
      { slot_index: 2, spell_id: "sussurro_medo" },
    ],
  },
  headers,
  false,
);
assertEq(
  errorCode(duplicateSpell),
  "DUPLICATE_SPELL",
  "build/equip should reject duplicate spells",
);

console.log("[build-equip-smoke] OK", {
  url: SUPABASE_URL,
  power: numberField(combatBuild(equipped), "power"),
});

function assertEquipmentOptions(payload: JsonObject): void {
  const build = combatBuild(payload);
  const options = objectField(build, "equipment_options");
  assert(arrayField(options, "weapons").length > 0, "weapons should be listed");
  assert(arrayField(options, "spells").length > 0, "spells should be listed");
  assert(arrayField(options, "doutrines").length > 0, "doutrines should be listed");
  assert(arrayField(options, "familiars").length > 0, "familiars should be listed");
  assert(
    stringField(arrayField(options, "weapons")[0] as JsonObject, "display_name") !== "",
    "equipment options should include public names",
  );
}

function assertEquippedState(
  payload: JsonObject,
  expected: {
    weapon_type: string;
    spell_id: string;
    passive_id: string;
    pet_id: string;
  },
): void {
  const build = combatBuild(payload);
  assertEq(
    stringField(build, "weapon_type"),
    expected.weapon_type,
    "build/equip should equip weapon",
  );
  assertEq(
    stringField(spellSlot(build, 1), "spell_id"),
    expected.spell_id,
    "build/equip should equip spell position 1",
  );
  assertEq(
    stringField(build, "passive_id"),
    expected.passive_id,
    "build/equip should equip doctrine",
  );
  assertEq(
    stringField(build, "pet_id"),
    expected.pet_id,
    "build/equip should equip familiar",
  );
  assertEq(
    numberField(objectField(payload, "player"), "power"),
    numberField(build, "power"),
    "players.power should be recalculated by server",
  );
}

function combatBuild(payload: JsonObject): JsonObject {
  return objectField(payload, "combat_build");
}

function spellSlot(build: JsonObject, position: number): JsonObject {
  const slots = arrayField(build, "spell_slots");
  const found = slots.find((slot) =>
    isObject(slot) && numberField(slot, "slot_index") === position
  );
  assert(isObject(found), `spell position ${position} should exist`);
  return found;
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
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
