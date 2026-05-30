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
  gameSaveId: string;
}

const sql = postgres(DATABASE_URL, {
  max: 1,
  connect_timeout: 5,
  idle_timeout: 1,
});

try {
  await assertLocalDatabaseIsCurrent();
  const primary = await createTestAccount("live-rpc-primary");
  const secondary = await createTestAccount("live-rpc-secondary");
  const joinOwner = await createTestAccount("live-rpc-join-owner");
  const joinMember = await createTestAccount("live-rpc-join-member");

  await proveBattleRollbackRetryAndIdempotency(primary);
  await proveBuildEquipIdempotency(primary);
  await proveCraftIdempotency(primary);
  await proveRewardClaimRollbackRetryAndIdempotency(primary);
  await proveAlphaPurchaseRollbackRetryAndIdempotency(primary);
  await proveGuildCreateRollbackRetryAndIdempotency(primary);
  await proveGuildJoinIdempotency(joinOwner, joinMember);

  console.log("[transactional-rpc-live-test] OK", {
    supabase_url: SUPABASE_URL,
    primary_player: primary.playerId,
    secondary_player: secondary.playerId,
    join_owner: joinOwner.playerId,
    join_member: joinMember.playerId,
  });
} finally {
  await sql.end();
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
  const user = objectField(auth, "user");
  const authUserId = stringField(user, "id");
  assert(authUserId !== "", "anonymous signup should return user.id");

  const createRequestId = crypto.randomUUID();
  const [created] = await sql<{ payload: JsonObject }[]>`
    select public.create_guest_account(
      ${authUserId}::uuid,
      ${"ALPHA-TEST"},
      ${createRequestId}::uuid,
      ${label},
      ${"normal"}
    ) as payload
  `;
  const playerId = stringField(objectField(created.payload, "player"), "id");
  assert(playerId !== "", "create_guest_account should return player.id");

  await sql`
    select public.ensure_foundation_profile_and_saves(
      ${authUserId}::uuid,
      ${"foundation_ruleset_v0"}
    )
  `;

  const [save] = await sql<{ id: string }[]>`
    select id::text as id
    from public.game_saves
    where legacy_player_id = ${playerId}::uuid
      and save_type = 'normal'
      and lifecycle_status = 'active'
    limit 1
  `;
  assert(
    save?.id !== undefined,
    "foundation game save should exist for test account",
  );

  return { authUserId, playerId, gameSaveId: save.id };
}

async function proveBattleRollbackRetryAndIdempotency(
  account: TestAccount,
): Promise<void> {
  await sql`
    update public.resources
    set almas = 0, energia = 0, sangue = 0, cristais = 0, ossos = 0, po_osso = 0, diamante = 0
    where player_id = ${account.playerId}::uuid
  `;
  await sql`
    delete from public.player_consumables
    where player_id = ${account.playerId}::uuid
      and item_id = 'pocao_vida'
  `;

  const requestId = crypto.randomUUID();
  const battleId = crypto.randomUUID();
  const hash = liveHash("battle", requestId);
  const payload = {
    request_id: requestId,
    battle_id: battleId,
    seed: `live-battle-${requestId}`,
    defender_id: "mvp_training_bot",
    defender_is_bot: true,
    battle_log: {
      schema_version: "battle_log_v1",
      result: { winner: "player", reason: "live_rpc_test" },
      events: [{ seq: 1, type: "battle_result", winner: "player" }],
    },
    reward_payload: {
      resources: { xp: 50, almas: 4, energia: 2, sangue: 1, ossos: 20 },
    },
    reward_delta: { xp: 50, almas: 4, energia: 2, sangue: 1, ossos: 20 },
    consumables: {
      used: [{
        owner: "player",
        item_id: "pocao_vida",
        quantity: 1,
        slot_index: 1,
      }],
    },
    competition: { ranked: false },
  };

  await assertRejects(
    () => requestBattle(account, requestId, hash, payload),
    "CONSUMABLE_APPLY_FAILED",
    "battle/request should fail before partial battle reward sticks when consumable stock is missing",
  );
  await assertNoRows(
    "battle rollback should remove battle row",
    sql`select 1 from public.battles where id = ${battleId}::uuid`,
  );
  await assertNoRows(
    "battle rollback should remove resource ledger",
    sql`select 1 from public.resource_transactions where request_id = ${requestId}::uuid`,
  );
  await assertNoRows(
    "battle rollback should remove pending idempotency row",
    sql`
      select 1 from public.idempotency_keys
      where player_id = ${account.playerId}::uuid
        and endpoint = 'battle/request'
        and request_id = ${requestId}::uuid
    `,
  );
  assertEq(
    numberField(await resourcesFor(account.playerId), "ossos"),
    0,
    "battle rollback should preserve resource balance",
  );

  await sql`
    insert into public.player_consumables (player_id, item_id, quantity)
    values (${account.playerId}::uuid, 'pocao_vida', 1)
  `;

  const first = await requestBattle(account, requestId, hash, payload);
  const afterFirst = await resourcesFor(account.playerId);
  assertEq(
    numberField(afterFirst, "ossos"),
    20,
    "battle retry should apply reward once",
  );
  assertEq(
    numberField(afterFirst, "almas"),
    4,
    "battle retry should apply Almas once",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.battles where id = ${battleId}::uuid`,
    ),
    1,
    "battle row should exist once",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.item_transactions where request_id = ${requestId}::uuid`,
    ),
    1,
    "battle consumable ledger should exist once",
  );

  const repeated = await requestBattle(account, requestId, hash, payload);
  assertStableJson(
    first,
    repeated,
    "battle/request retry should return stored idempotent payload",
  );
  assertEq(
    numberField(await resourcesFor(account.playerId), "ossos"),
    20,
    "battle repeat should not duplicate reward",
  );

  await assertRejects(
    () => requestBattle(account, requestId, `${hash}:changed`, payload),
    "IDEMPOTENCY_HASH_MISMATCH",
    "battle/request should reject same request_id with a different hash",
  );
}

async function proveBuildEquipIdempotency(account: TestAccount): Promise<void> {
  const requestId = crypto.randomUUID();
  const hash = liveHash("build", requestId);
  const payload = {
    request_id: requestId,
    build: {
      weapon_type: "varinha_cinzas",
      weapon_quality: "starter",
      spell_slots: [{ slot_index: 1, spell_id: "sussurro_medo" }],
      passive_id: "doutrina_pavor",
      pet_id: "corvo_pressagio",
    },
    player_power: 123,
    equipped_build: {
      weapon_type: "varinha_cinzas",
      spell_slots: [{ slot_index: 1, spell_id: "sussurro_medo" }],
      passive_id: "doutrina_pavor",
      pet_id: "corvo_pressagio",
      power: 123,
    },
  };

  const first = await equipBuild(account, requestId, hash, payload);
  const repeated = await equipBuild(account, requestId, hash, payload);
  assertStableJson(
    first,
    repeated,
    "build/equip should return stored idempotent payload",
  );

  const [player] = await sql<{ power: number }[]>`
    select power
    from public.players
    where id = ${account.playerId}::uuid
  `;
  assertEq(player.power, 123, "build/equip should update player power once");

  await assertRejects(
    () => equipBuild(account, requestId, `${hash}:changed`, payload),
    "IDEMPOTENCY_HASH_MISMATCH",
    "build/equip should reject same request_id with a different hash",
  );
}

async function proveCraftIdempotency(account: TestAccount): Promise<void> {
  await sql`
    update public.resources
    set po_osso = 100
    where player_id = ${account.playerId}::uuid
  `;

  const requestId = crypto.randomUUID();
  const hash = liveHash("craft", requestId);
  const payload = {
    request_id: requestId,
    recipe_id: "craft_pocao_vida",
    quantity: 1,
    resource_delta: { po_osso: -50 },
    output: { item_id: "pocao_vida", quantity: 1 },
  };

  const first = await craftItem(account, requestId, hash, payload);
  const afterFirst = await resourcesFor(account.playerId);
  assertEq(
    numberField(afterFirst, "po_osso"),
    50,
    "craft should spend Po de Osso once",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.item_transactions where request_id = ${requestId}::uuid`,
    ),
    1,
    "craft item ledger should exist once",
  );

  const repeated = await craftItem(account, requestId, hash, payload);
  assertStableJson(
    first,
    repeated,
    "crafting/craft should return stored idempotent payload",
  );
  assertEq(
    numberField(await resourcesFor(account.playerId), "po_osso"),
    50,
    "craft repeat should not spend again",
  );

  await assertRejects(
    () => craftItem(account, requestId, `${hash}:changed`, payload),
    "IDEMPOTENCY_HASH_MISMATCH",
    "crafting/craft should reject same request_id with a different hash",
  );
}

async function proveRewardClaimRollbackRetryAndIdempotency(
  account: TestAccount,
): Promise<void> {
  await sql`
    update public.resources
    set almas = 0, energia = 0, sangue = 0, cristais = 0, ossos = 0, po_osso = 0, diamante = 0
    where player_id = ${account.playerId}::uuid
  `;
  await sql`
    update public.players
    set xp = 0
    where id = ${account.playerId}::uuid
  `;

  const requestId = crypto.randomUUID();
  const rewardId = `live_reward_${requestId.slice(0, 8)}`;
  const periodKey = `live-${requestId}`;
  const hash = liveHash("reward-claim", requestId);
  const validPayload = {
    request_id: requestId,
    reward_id: rewardId,
    source: "daily",
    period_key: periodKey,
    pass_id: "bp_s1_01",
    resources: { almas: 3, ossos: 7 },
    xp: 25,
    pass_xp_delta: 10,
    reward_payload: { source: "transactional_rpc_live_test" },
  };
  const invalidPayload = { ...validPayload, source: "invalid_source" };

  await assertRejects(
    () => claimReward(account, requestId, hash, invalidPayload),
    "reward_claims_source_check",
    "reward claim should roll back resource/xp changes when claim insert fails",
  );
  await assertNoRows(
    "reward claim rollback should not create claim row",
    sql`select 1 from public.reward_claims where request_id = ${requestId}::uuid`,
  );
  await assertNoRows(
    "reward claim rollback should not create resource ledger",
    sql`select 1 from public.resource_transactions where request_id = ${requestId}::uuid`,
  );
  await assertNoRows(
    "reward claim rollback should not leave battle pass progress",
    sql`
      select 1
      from public.battle_pass_progress
      where player_id = ${account.playerId}::uuid
        and pass_id = 'bp_s1_01'
    `,
  );
  await assertNoRows(
    "reward claim rollback should remove idempotency row",
    sql`
      select 1 from public.idempotency_keys
      where player_id = ${account.playerId}::uuid
        and endpoint = 'monetization/rewards/claim'
        and request_id = ${requestId}::uuid
    `,
  );
  assertEq(
    numberField(await resourcesFor(account.playerId), "almas"),
    0,
    "reward claim rollback should preserve resources",
  );
  assertEq(
    await playerXpFor(account.playerId),
    0,
    "reward claim rollback should preserve player xp",
  );

  const first = await claimReward(account, requestId, hash, validPayload);
  const afterFirst = await resourcesFor(account.playerId);
  assertEq(
    numberField(afterFirst, "almas"),
    3,
    "reward claim retry should add Almas once",
  );
  assertEq(
    numberField(afterFirst, "ossos"),
    7,
    "reward claim retry should add Ossos once",
  );
  assertEq(
    await playerXpFor(account.playerId),
    25,
    "reward claim should add XP once",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.reward_claims where request_id = ${requestId}::uuid`,
    ),
    1,
    "reward claim row should exist once",
  );

  const repeated = await claimReward(account, requestId, hash, validPayload);
  assertStableJson(
    first,
    repeated,
    "monetization/rewards/claim should return stored idempotent payload",
  );
  assertEq(
    numberField(await resourcesFor(account.playerId), "almas"),
    3,
    "reward claim repeat should not add resources again",
  );
  assertEq(
    await playerXpFor(account.playerId),
    25,
    "reward claim repeat should not add XP again",
  );

  await assertRejects(
    () => claimReward(account, requestId, `${hash}:changed`, validPayload),
    "IDEMPOTENCY_HASH_MISMATCH",
    "monetization/rewards/claim should reject same request_id with a different hash",
  );
}

async function proveAlphaPurchaseRollbackRetryAndIdempotency(
  account: TestAccount,
): Promise<void> {
  await sql`
    update public.resources
    set diamante = 0
    where player_id = ${account.playerId}::uuid
  `;

  const requestId = crypto.randomUUID();
  const hash = liveHash("alpha", requestId);
  const payload = {
    request_id: requestId,
    product_id: "live_rpc_alpha_cost",
    pass_id: "bp_s1_01",
    resource_delta: { diamante: -10 },
    product_payload: { id: "live_rpc_alpha_cost", label: "Live RPC cost test" },
    purchase_payload: {
      id: "live_rpc_alpha_cost",
      source: "transactional_rpc_live_test",
    },
  };

  await assertRejects(
    () => alphaPurchase(account, requestId, hash, payload),
    "INSUFFICIENT_RESOURCES",
    "alpha purchase should fail before partial purchase sticks when resources are missing",
  );
  await assertNoRows(
    "alpha rollback should not create purchase row",
    sql`select 1 from public.alpha_purchases where request_id = ${requestId}::uuid`,
  );
  await assertNoRows(
    "alpha rollback should not create idempotency row",
    sql`
      select 1 from public.idempotency_keys
      where player_id = ${account.playerId}::uuid
        and endpoint = 'monetization/alpha-purchase'
        and request_id = ${requestId}::uuid
    `,
  );

  await sql`
    update public.resources
    set diamante = 20
    where player_id = ${account.playerId}::uuid
  `;

  const first = await alphaPurchase(account, requestId, hash, payload);
  assertEq(
    numberField(await resourcesFor(account.playerId), "diamante"),
    10,
    "alpha retry should spend once",
  );

  const repeated = await alphaPurchase(account, requestId, hash, payload);
  assertStableJson(
    first,
    repeated,
    "alpha purchase should return stored idempotent payload",
  );
  assertEq(
    numberField(await resourcesFor(account.playerId), "diamante"),
    10,
    "alpha repeat should not spend again",
  );
  assertEq(
    await countRows(
      sql`select 1 from public.alpha_purchases where request_id = ${requestId}::uuid`,
    ),
    1,
    "alpha purchase row should exist once",
  );
}

async function proveGuildCreateRollbackRetryAndIdempotency(
  account: TestAccount,
): Promise<void> {
  const requestId = crypto.randomUUID();
  const guildName = `Live ${requestId.slice(0, 8)}`;
  const hash = liveHash("guild-create", requestId);
  const invalidPayload = {
    request_id: requestId,
    name: guildName,
    structures: ["invalid_structure"],
  };
  const validPayload = {
    request_id: requestId,
    name: guildName,
    structures: [
      "oficina_ritual",
      "condensador_astral",
      "arquivo_de_dominio",
      "cofre_abissal",
    ],
  };

  await assertRejects(
    () => guildCreate(account, requestId, hash, invalidPayload),
    "guild_structures_structure_id_check",
    "guild/create should roll back guild bootstrap when structure seed fails",
  );
  await assertNoRows(
    "guild/create rollback should remove guild row",
    sql`select 1 from public.guilds where name = ${guildName}`,
  );
  await assertNoRows(
    "guild/create rollback should remove idempotency row",
    sql`
      select 1 from public.idempotency_keys
      where player_id = ${account.playerId}::uuid
        and endpoint = 'guild/create'
        and request_id = ${requestId}::uuid
    `,
  );

  const first = await guildCreate(account, requestId, hash, validPayload);
  const guild = objectField(first, "guild");
  assertEq(
    stringField(guild, "name"),
    guildName,
    "guild retry should create requested guild",
  );

  const repeated = await guildCreate(account, requestId, hash, validPayload);
  assertStableJson(
    first,
    repeated,
    "guild/create should return stored idempotent payload",
  );
  assertEq(
    await countRows(sql`select 1 from public.guilds where name = ${guildName}`),
    1,
    "guild should exist once",
  );
}

async function proveGuildJoinIdempotency(
  owner: TestAccount,
  member: TestAccount,
): Promise<void> {
  const ownerGuildName = `Join ${crypto.randomUUID().slice(0, 8)}`;
  await guildCreate(
    owner,
    crypto.randomUUID(),
    liveHash("owner-guild", ownerGuildName),
    {
      name: ownerGuildName,
      structures: [
        "oficina_ritual",
        "condensador_astral",
        "arquivo_de_dominio",
        "cofre_abissal",
      ],
    },
  );

  const requestId = crypto.randomUUID();
  const hash = liveHash("guild-join", requestId);
  const payload = { request_id: requestId, name: ownerGuildName };

  const first = await guildJoin(member, requestId, hash, payload);
  const repeated = await guildJoin(member, requestId, hash, payload);
  assertStableJson(
    first,
    repeated,
    "guild/join should return stored idempotent payload",
  );

  const [guild] = await sql<{ member_count: number }[]>`
    select member_count
    from public.guilds
    where name = ${ownerGuildName}
  `;
  assertEq(
    guild.member_count,
    2,
    "guild/join repeat should not increment member_count twice",
  );

  await assertRejects(
    () => guildJoin(member, requestId, `${hash}:changed`, payload),
    "IDEMPOTENCY_HASH_MISMATCH",
    "guild/join should reject same request_id with a different hash",
  );
}

async function requestBattle(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.request_battle_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function equipBuild(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.equip_build_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function craftItem(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.craft_item_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function claimReward(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.claim_reward_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function alphaPurchase(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.alpha_purchase_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function guildCreate(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.guild_create_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function guildJoin(
  account: TestAccount,
  requestId: string,
  requestHash: string,
  payload: JsonObject,
): Promise<JsonObject> {
  const [row] = await sql<{ payload: JsonObject }[]>`
    select public.guild_join_v1(
      ${account.gameSaveId}::uuid,
      ${requestId}::uuid,
      ${requestHash},
      ${sql.json(payload as any)}
    ) as payload
  `;
  return row.payload;
}

async function resourcesFor(playerId: string): Promise<JsonObject> {
  const [row] = await sql<JsonObject[]>`
    select almas, energia, sangue, cristais, ossos, po_osso, diamante
    from public.resources
    where player_id = ${playerId}::uuid
  `;
  assert(isObject(row), `resources should exist for ${playerId}`);
  return row;
}

async function playerXpFor(playerId: string): Promise<number> {
  const [row] = await sql<{ xp: number }[]>`
    select xp
    from public.players
    where id = ${playerId}::uuid
  `;
  assert(row !== undefined, `player should exist for ${playerId}`);
  return row.xp;
}

async function countRows(
  query: PromiseLike<readonly unknown[]>,
): Promise<number> {
  return (await query).length;
}

async function assertNoRows(
  label: string,
  query: PromiseLike<readonly unknown[]>,
): Promise<void> {
  const count = await countRows(query);
  assertEq(count, 0, label);
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
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${text}`,
    );
  }
  return payload;
}

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function liveHash(scope: string, value: string): string {
  return `live:${scope}:${value}`;
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

async function assertRejects(
  fn: () => Promise<unknown>,
  expectedText: string,
  message: string,
): Promise<void> {
  try {
    await fn();
  } catch (error) {
    const rendered = error instanceof Error
      ? `${error.name}: ${error.message}`
      : String(error);
    if (!rendered.includes(expectedText)) {
      throw new Error(
        `${message}. Expected error containing ${expectedText}, got ${rendered}`,
      );
    }
    return;
  }
  throw new Error(`${message}. Expected rejection containing ${expectedText}`);
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
