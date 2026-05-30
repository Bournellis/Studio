import postgres from "npm:postgres@3.4.5";

const SUPABASE_URL = (Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321")
  .replace(/\/+$/, "");
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";
const DATABASE_URL = Deno.env.get("DRAXOS_LOCAL_DB_URL") ??
  "postgres://postgres:postgres@127.0.0.1:54322/postgres";

interface JsonObject {
  [key: string]: unknown;
}

interface TestAccount {
  authUserId: string;
  playerId: string;
  username: string;
  headers: Record<string, string>;
}

interface IdempotencyRow {
  endpoint: string;
  request_hash: string;
  scope_id: string | null;
  status: string;
  response_payload: JsonObject;
}

const sql = postgres(DATABASE_URL, {
  max: 1,
  connect_timeout: 5,
  idle_timeout: 1,
});

try {
  await assertLocalEdgeIsReachable();
  await assertLocalDatabaseIsCurrent();

  const primary = await createTestAccount("edge-rpc-primary");
  const guildOwner = await createTestAccount("edge-rpc-guild-owner");
  const guildMember = await createTestAccount("edge-rpc-guild-member");

  await proveBaseCollectAdapter(primary);
  await proveRewardClaimAdapter(primary);
  await proveAlphaPurchaseAdapter(primary);
  await proveBaseUpgradeAdapter(primary);
  await proveBattleRequestAdapter(primary);
  await proveCraftingAdapters(primary);
  await proveBuildEquipAdapter(primary);
  await proveBuildBehaviorAdapters(primary);
  await proveSocialFriendAdapter(primary, guildOwner);
  await proveGuildAdapters(guildOwner, guildMember);
  await proveApiVersionHeader(primary);

  console.log("[transactional-edge-rpc-smoke] OK", {
    supabase_url: SUPABASE_URL,
    primary_player: primary.playerId,
    guild_owner: guildOwner.playerId,
    guild_member: guildMember.playerId,
  });
} finally {
  await sql.end();
}

async function assertLocalEdgeIsReachable(): Promise<void> {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/healthcheck`, {
    method: "GET",
    headers: baseHeaders(),
  });
  const text = await response.text();
  assert(
    response.ok,
    `local Edge Runtime should serve healthcheck at ${SUPABASE_URL}: ${text}`,
  );
}

async function assertLocalDatabaseIsCurrent(): Promise<void> {
  const rows = await sql<{ proname: string }[]>`
    select proname
    from pg_proc
    where proname in (
      'request_battle_v1',
      'build_spell_behavior_v1',
      'build_potion_equip_v1',
      'build_potion_behavior_v1',
      'social_friend_add_v1',
      'social_chat_send_v1'
    )
  `;
  const names = new Set(rows.map((row) => row.proname));
  const missing = [
    "request_battle_v1",
    "build_spell_behavior_v1",
    "build_potion_equip_v1",
    "build_potion_behavior_v1",
    "social_friend_add_v1",
    "social_chat_send_v1",
  ].filter((name) => !names.has(name));
  assert(
    missing.length === 0,
    `local database must include Foundation Closeout RPC migrations. Missing: ${missing.join(", ")}`,
  );
}

async function createTestAccount(label: string): Promise<TestAccount> {
  const auth = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { data: { provider: "guest" } },
    baseHeaders(),
    false,
  );
  const accessToken = stringField(auth, "access_token");
  const user = objectField(auth, "user");
  const authUserId = stringField(user, "id");
  assert(accessToken !== "", "anonymous auth should return access_token");
  assert(authUserId !== "", "anonymous auth should return user.id");

  const headers = {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
  };
  const account = await postJson(
    `${SUPABASE_URL}/functions/v1/account/guest`,
    {
      invite_code: "ALPHA-TEST",
      device_label: label,
      request_id: crypto.randomUUID(),
    },
    headers,
  );
  const player = objectField(account, "player");
  const playerId = stringField(player, "id");
  const username = stringField(player, "username");
  assert(playerId !== "", "account/guest should return player.id");
  assert(username !== "", "account/guest should return player.username");
  return { authUserId, playerId, username, headers };
}

async function proveBaseCollectAdapter(account: TestAccount): Promise<void> {
  const requestId = crypto.randomUUID();
  const body = { request_id: requestId };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/base/collect`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/base/collect`,
    body,
    account.headers,
  );
  assertStableJson(
    objectField(first, "collected"),
    objectField(repeated, "collected"),
    "base/collect should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("base/collect", requestId);
}

async function proveRewardClaimAdapter(account: TestAccount): Promise<void> {
  const requestId = crypto.randomUUID();
  const body = { request_id: requestId, reward_id: "daily_first_victory" };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/monetization/rewards/claim`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/monetization/rewards/claim`,
    body,
    account.headers,
  );
  assertEq(
    resourceSummary(objectField(first, "resources")),
    resourceSummary(objectField(repeated, "resources")),
    "reward claim should not duplicate resources through HTTP adapter",
  );
  await assertCompletedIdempotency("monetization/rewards/claim", requestId);
  assertEq(
    await countRows(
      sql`select 1 from public.reward_claims where request_id = ${requestId}::uuid`,
    ),
    1,
    "reward claim should persist once",
  );
}

async function proveAlphaPurchaseAdapter(account: TestAccount): Promise<void> {
  const requestId = crypto.randomUUID();
  const body = { request_id: requestId, product_id: "alpha_redeem_large" };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
    body,
    account.headers,
  );
  assertEq(
    resourceSummary(objectField(first, "resources")),
    resourceSummary(objectField(repeated, "resources")),
    "alpha purchase should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("monetization/alpha-purchase", requestId);
  assertEq(
    await countRows(
      sql`select 1 from public.alpha_purchases where request_id = ${requestId}::uuid`,
    ),
    1,
    "alpha purchase should persist once",
  );
}

async function proveBaseUpgradeAdapter(account: TestAccount): Promise<void> {
  const energyRequestId = crypto.randomUUID();
  await postJson(
    `${SUPABASE_URL}/functions/v1/monetization/alpha-purchase`,
    { request_id: energyRequestId, product_id: "alpha_energy_pack_small" },
    account.headers,
  );
  await assertCompletedIdempotency(
    "monetization/alpha-purchase",
    energyRequestId,
  );

  const requestId = crypto.randomUUID();
  const body = { request_id: requestId, structure_id: "nucleo_energia" };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/base/upgrade`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/base/upgrade`,
    body,
    account.headers,
  );
  assertEq(
    stringField(objectField(first, "job"), "id"),
    stringField(objectField(repeated, "job"), "id"),
    "base/upgrade should return the same job for repeated request_id",
  );
  await assertCompletedIdempotency("base/upgrade", requestId);
}

async function proveBattleRequestAdapter(account: TestAccount): Promise<void> {
  const requestId = crypto.randomUUID();
  const body = {
    request_id: requestId,
    mode: "FIRST_SLICE_SIM",
    opponent_bot_id: "bot_effect_trainer_01",
  };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/battle/request`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/battle/request`,
    body,
    account.headers,
  );
  const firstLog = objectField(first, "battle_log");
  const repeatedLog = objectField(repeated, "battle_log");
  assertEq(
    stringField(firstLog, "battle_id"),
    stringField(repeatedLog, "battle_id"),
    "battle/request FIRST_SLICE_SIM should be idempotent through HTTP adapter",
  );
  assertEq(
    stringField(firstLog, "mode"),
    "FIRST_SLICE_SIM",
    "battle/request should exercise the v1 simulator adapter",
  );
  await assertCompletedIdempotency("battle/request", requestId);
  assertEq(
    await countRows(
      sql`select 1 from public.battles where id = ${
        stringField(firstLog, "battle_id")
      }::uuid`,
    ),
    1,
    "battle/request should persist one battle",
  );
  const mismatch = await postJson(
    `${SUPABASE_URL}/functions/v1/battle/request`,
    { ...body, request_hash: "manual:mismatch" },
    account.headers,
    false,
  );
  assertEq(
    errorCode(mismatch),
    "IDEMPOTENCY_HASH_MISMATCH",
    "battle/request should route explicit hash mismatch to the transactional RPC",
  );
}

async function proveCraftingAdapters(account: TestAccount): Promise<void> {
  const crushRequestId = crypto.randomUUID();
  const crushBody = { request_id: crushRequestId, amount: 50 };
  const firstCrush = await postJson(
    `${SUPABASE_URL}/functions/v1/crafting/crush-bones`,
    crushBody,
    account.headers,
  );
  const repeatedCrush = await postJson(
    `${SUPABASE_URL}/functions/v1/crafting/crush-bones`,
    crushBody,
    account.headers,
  );
  assertEq(
    resourceSummary(objectField(firstCrush, "resources")),
    resourceSummary(objectField(repeatedCrush, "resources")),
    "crafting/crush-bones should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("crafting/crush-bones", crushRequestId);

  const craftRequestId = crypto.randomUUID();
  const craftBody = {
    request_id: craftRequestId,
    recipe_id: "craft_pocao_vida",
    quantity: 1,
  };
  const firstCraft = await postJson(
    `${SUPABASE_URL}/functions/v1/crafting/craft`,
    craftBody,
    account.headers,
  );
  const repeatedCraft = await postJson(
    `${SUPABASE_URL}/functions/v1/crafting/craft`,
    craftBody,
    account.headers,
  );
  assertEq(
    inventorySummary(objectField(firstCraft, "crafting")),
    inventorySummary(objectField(repeatedCraft, "crafting")),
    "crafting/craft should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("crafting/craft", craftRequestId);
}

async function proveBuildEquipAdapter(account: TestAccount): Promise<void> {
  const requestId = crypto.randomUUID();
  const body = {
    request_id: requestId,
    weapon: { type: "varinha_cinzas", quality: "starter" },
  };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/build/equip`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/build/equip`,
    body,
    account.headers,
  );
  assertEq(
    buildSummary(objectField(first, "combat_build")),
    buildSummary(objectField(repeated, "combat_build")),
    "build/equip should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("build/equip", requestId);
}

async function proveBuildBehaviorAdapters(account: TestAccount): Promise<void> {
  const spellRequestId = crypto.randomUUID();
  const spellBody = {
    request_id: spellRequestId,
    spell_id: "sussurro_medo",
    behavior: {
      enabled: true,
      hp: { mode: "ignore", percent: 0 },
      mana: { mode: "above", percent: 25 },
    },
  };
  const firstSpell = await postJson(
    `${SUPABASE_URL}/functions/v1/build/spell-behavior`,
    spellBody,
    account.headers,
  );
  const repeatedSpell = await postJson(
    `${SUPABASE_URL}/functions/v1/build/spell-behavior`,
    spellBody,
    account.headers,
  );
  assertStableJson(
    objectField(firstSpell, "updated_behavior"),
    objectField(repeatedSpell, "updated_behavior"),
    "build/spell-behavior should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("build/spell-behavior", spellRequestId);

  const equipRequestId = crypto.randomUUID();
  const equipBody = {
    request_id: equipRequestId,
    slot_index: 1,
    item_id: "pocao_vida",
  };
  const firstEquip = await postJson(
    `${SUPABASE_URL}/functions/v1/build/potion/equip`,
    equipBody,
    account.headers,
  );
  const repeatedEquip = await postJson(
    `${SUPABASE_URL}/functions/v1/build/potion/equip`,
    equipBody,
    account.headers,
  );
  assertStableJson(
    objectField(firstEquip, "equipped_potion"),
    objectField(repeatedEquip, "equipped_potion"),
    "build/potion/equip should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("build/potion/equip", equipRequestId);

  const behaviorRequestId = crypto.randomUUID();
  const behaviorBody = {
    request_id: behaviorRequestId,
    slot_index: 1,
    behavior: {
      enabled: true,
      hp: { mode: "below", percent: 55 },
      mana: { mode: "ignore", percent: 0 },
    },
  };
  const firstBehavior = await postJson(
    `${SUPABASE_URL}/functions/v1/build/potion-behavior`,
    behaviorBody,
    account.headers,
  );
  const repeatedBehavior = await postJson(
    `${SUPABASE_URL}/functions/v1/build/potion-behavior`,
    behaviorBody,
    account.headers,
  );
  assertStableJson(
    objectField(firstBehavior, "updated_behavior"),
    objectField(repeatedBehavior, "updated_behavior"),
    "build/potion-behavior should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("build/potion-behavior", behaviorRequestId);
}

async function proveSocialFriendAdapter(
  account: TestAccount,
  target: TestAccount,
): Promise<void> {
  const requestId = crypto.randomUUID();
  const body = {
    request_id: requestId,
    username: target.username,
  };
  const first = await postJson(
    `${SUPABASE_URL}/functions/v1/social/friends/add`,
    body,
    account.headers,
  );
  const repeated = await postJson(
    `${SUPABASE_URL}/functions/v1/social/friends/add`,
    body,
    account.headers,
  );
  assertEq(
    arrayField(objectField(first, "social"), "friends").length,
    arrayField(objectField(repeated, "social"), "friends").length,
    "social/friends/add should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("social/friends/add", requestId);
}

async function proveGuildAdapters(
  owner: TestAccount,
  member: TestAccount,
): Promise<void> {
  const createRequestId = crypto.randomUUID();
  const guildName = `Edge ${createRequestId.slice(0, 8)}`;
  const createBody = { request_id: createRequestId, name: guildName };
  const firstCreate = await postJson(
    `${SUPABASE_URL}/functions/v1/social/guild/create`,
    createBody,
    owner.headers,
  );
  const repeatedCreate = await postJson(
    `${SUPABASE_URL}/functions/v1/social/guild/create`,
    createBody,
    owner.headers,
  );
  const guild = objectField(objectField(firstCreate, "social"), "guild");
  const repeatedGuild = objectField(
    objectField(repeatedCreate, "social"),
    "guild",
  );
  assertEq(
    stringField(guild, "id"),
    stringField(repeatedGuild, "id"),
    "guild/create should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("guild/create", createRequestId);

  const joinRequestId = crypto.randomUUID();
  const joinBody = { request_id: joinRequestId, name: guildName };
  const firstJoin = await postJson(
    `${SUPABASE_URL}/functions/v1/social/guild/join`,
    joinBody,
    member.headers,
  );
  const repeatedJoin = await postJson(
    `${SUPABASE_URL}/functions/v1/social/guild/join`,
    joinBody,
    member.headers,
  );
  assertEq(
    memberCount(firstJoin),
    memberCount(repeatedJoin),
    "guild/join should be idempotent through HTTP adapter",
  );
  assertEq(
    memberCount(firstJoin),
    2,
    "guild/join should keep member count at two",
  );
  await assertCompletedIdempotency("guild/join", joinRequestId);

  const chatRequestId = crypto.randomUUID();
  const chatBody = {
    request_id: chatRequestId,
    content: `edge closeout ${chatRequestId.slice(0, 8)}`,
  };
  const firstChat = await postJson(
    `${SUPABASE_URL}/functions/v1/social/chat/send`,
    chatBody,
    member.headers,
  );
  const repeatedChat = await postJson(
    `${SUPABASE_URL}/functions/v1/social/chat/send`,
    chatBody,
    member.headers,
  );
  assertEq(
    arrayField(objectField(firstChat, "social"), "guild_chat").length,
    arrayField(objectField(repeatedChat, "social"), "guild_chat").length,
    "social/chat/send should be idempotent through HTTP adapter",
  );
  await assertCompletedIdempotency("social/chat/send", chatRequestId);
}

async function proveApiVersionHeader(account: TestAccount): Promise<void> {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/account/state`, {
    method: "GET",
    headers: {
      ...account.headers,
      "x-draxos-api-version": "2",
    },
  });
  const payload = await parseResponse(response, false);
  assertEq(
    errorCode(payload),
    "UNSUPPORTED_API_VERSION",
    "explicit unsupported API version should fail",
  );
}

async function assertCompletedIdempotency(
  endpoint: string,
  requestId: string,
): Promise<IdempotencyRow> {
  const rows = await sql<IdempotencyRow[]>`
    select
      endpoint,
      request_hash,
      scope_id::text as scope_id,
      status,
      response_payload
    from public.idempotency_keys
    where endpoint = ${endpoint}
      and request_id = ${requestId}::uuid
  `;
  assertEq(rows.length, 1, `${endpoint} should create one idempotency row`);
  const row = rows[0];
  assertEq(
    row.status,
    "completed",
    `${endpoint} idempotency row should complete`,
  );
  assert(
    row.request_hash.startsWith("sha256:"),
    `${endpoint} should receive an adapter-computed request_hash`,
  );
  assert(
    isObject(row.response_payload),
    `${endpoint} should store response_payload`,
  );
  return row;
}

async function countRows(
  query: PromiseLike<readonly unknown[]>,
): Promise<number> {
  return (await query).length;
}

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
    "x-draxos-api-version": "1",
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

function memberCount(payload: JsonObject): number {
  return arrayField(objectField(payload, "social"), "guild_members").length;
}

function buildSummary(build: JsonObject): string {
  const slots = arrayField(build, "spell_slots")
    .map((slot) =>
      isObject(slot)
        ? `${numberField(slot, "slot_index")}:${stringField(slot, "spell_id")}`
        : ""
    )
    .join("|");
  return [
    stringField(build, "weapon_type"),
    stringField(build, "weapon_quality"),
    slots,
    String(build.passive_id ?? ""),
    String(build.pet_id ?? ""),
    String(numberField(build, "power")),
  ].join("|");
}

function inventorySummary(crafting: JsonObject): string {
  return arrayField(crafting, "inventory")
    .map((item) =>
      isObject(item)
        ? `${stringField(item, "item_id")}:${numberField(item, "quantity")}`
        : ""
    )
    .sort()
    .join("|");
}

function resourceSummary(payload: JsonObject): string {
  return [
    "almas",
    "energia",
    "sangue",
    "cristais",
    "ossos",
    "po_osso",
    "diamante",
  ]
    .map((key) => `${key}:${String(payload[key] ?? 0)}`)
    .join("|");
}

function errorCode(payload: JsonObject): string {
  const gatewayMessage = stringField(payload, "message");
  if (gatewayMessage.toLowerCase().includes("authorization")) {
    return "UNAUTHENTICATED";
  }
  return stringField(objectField(payload, "error"), "code");
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
  throw new Error(`${key} should be numeric, got ${JSON.stringify(value)}`);
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
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

function assertStableJson(
  actual: unknown,
  expected: unknown,
  message: string,
): void {
  assertEq(stableStringify(actual), stableStringify(expected), message);
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
