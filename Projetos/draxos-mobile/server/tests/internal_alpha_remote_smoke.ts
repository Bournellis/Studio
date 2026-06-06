const SUPABASE_URL = requiredEnv("SUPABASE_URL").replace(/\/+$/, "");
const PUBLISHABLE_KEY = requiredEnv("SUPABASE_PUBLISHABLE_KEY");
const RUN_ANON_AUTH = Deno.env.get("DRAXOS_REMOTE_ANON_AUTH_SMOKE") === "1";
const RUN_ACCOUNT_STATE = Deno.env.get("DRAXOS_REMOTE_ACCOUNT_SMOKE") === "1";
const RUN_EMAIL_AUTH = Deno.env.get("DRAXOS_REMOTE_EMAIL_AUTH_SMOKE") === "1";
const RUN_RELEASE_MANIFEST = Deno.env.get("DRAXOS_REMOTE_RELEASE_SMOKE") === "1";
const RUN_MODE = Deno.env.get("DRAXOS_REMOTE_MODE_SMOKE") === "1";
const RUN_ARENA = Deno.env.get("DRAXOS_REMOTE_ARENA_SMOKE") === "1";
const CORS_ORIGIN = Deno.env.get("DRAXOS_REMOTE_CORS_ORIGIN") ??
  "https://draxos-mobile-internal-alpha.pages.dev";

const MODE_MODE_ID = "openworld";
const MODE_SLICE_ID = "forest";
const MODE_RULESET_ID = "openworld_forest_ruleset_v1";
const MODE_RULESET_VERSION = 1;

assertRemoteUrl(SUPABASE_URL);
assertClientKey(PUBLISHABLE_KEY);
assert(
  !RUN_MODE || RUN_EMAIL_AUTH,
  "DRAXOS_REMOTE_MODE_SMOKE requires DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1",
);
assert(
  !RUN_ARENA || RUN_EMAIL_AUTH,
  "DRAXOS_REMOTE_ARENA_SMOKE requires DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1",
);

interface JsonObject {
  [key: string]: unknown;
}

const healthcheck = await getJson(
  `${SUPABASE_URL}/functions/v1/healthcheck`,
  baseHeaders(),
);
assertEq(healthcheck.ok, true, "remote healthcheck should return ok");

await assertCorsPreflights([
  { url: `${SUPABASE_URL}/auth/v1/token?grant_type=password`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/account/guest`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/account/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/base/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/battle/request`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/build/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/social/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/competition/ranking/current`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/monetization/state`, method: "GET" },
  { url: `${SUPABASE_URL}/functions/v1/telemetry/client-event`, method: "POST" },
  { url: `${SUPABASE_URL}/functions/v1/release/manifest`, method: "GET" },
]);

let releaseManifestChecked = false;
if (RUN_RELEASE_MANIFEST) {
  const manifest = await getJson(
    `${SUPABASE_URL}/functions/v1/release/manifest`,
    baseHeaders(),
    false,
  );
  assertEq(
    stringField(manifest, "schema_version"),
    "internal_alpha_manifest_v1",
    "release manifest schema should match the Godot contract",
  );
  assertEq(
    stringField(manifest, "channel"),
    "internal_alpha",
    "release manifest should use the internal alpha channel",
  );
  assertEq(
    manifest.latest_version_code,
    6,
    "release manifest should expose the current version code",
  );
  assert(
    isObject(manifest.artifacts),
    "release manifest should include artifacts",
  );
  releaseManifestChecked = true;
}

let authUser = "";
let playerId = "";
if (RUN_ANON_AUTH || RUN_ACCOUNT_STATE) {
  const auth = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { data: { provider: "guest" } },
    baseHeaders(),
    false,
  );
  authUser = stringField(objectField(auth, "user"), "id");
  assert(stringField(auth, "access_token") !== "", "auth should return token");
  assert(authUser !== "", "auth should return user id");

  if (RUN_ACCOUNT_STATE) {
    const headers = {
      ...baseHeaders(),
      authorization: `Bearer ${stringField(auth, "access_token")}`,
    };
    const account = await postJson(
      `${SUPABASE_URL}/functions/v1/account/guest`,
      {
        invite_code: Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ??
          "ALPHA-TEST",
        device_label: "deno-internal-alpha-remote-smoke",
        request_id: crypto.randomUUID(),
      },
      headers,
    );
    playerId = stringField(objectField(account, "player"), "id");
    assert(playerId !== "", "account/guest should return player id");

    const state = await getJson(
      `${SUPABASE_URL}/functions/v1/account/state`,
      headers,
    );
    assertEq(
      stringField(objectField(state, "player"), "id"),
      playerId,
      "account/state should return the same player",
    );
  }
}

let emailUser = "";
let emailPlayerId = "";
let labPlayerId = "";
let emailBattleId = "";
let modeSessionId = "";
let arenaAttemptId = "";
if (RUN_EMAIL_AUTH) {
  const runId = crypto.randomUUID().replaceAll("-", "").slice(0, 12);
  const email = `draxosremotealpha${runId}@gmail.com`;
  const password = `alpha-${runId}`;
  const username = `remote_${runId.slice(0, 10)}`;
  const signup = await postJson(
    `${SUPABASE_URL}/auth/v1/signup`,
    { email, password },
    baseHeaders(),
  );
  const signupToken = stringField(signup, "access_token");
  emailUser = stringField(objectField(signup, "user"), "id");
  assert(signupToken !== "", "email signup should return token");
  assert(emailUser !== "", "email signup should return user id");

  const headers = {
    ...baseHeaders(),
    authorization: `Bearer ${signupToken}`,
  };
  const account = await postJson(
    `${SUPABASE_URL}/functions/v1/account/bootstrap`,
    {
      invite_code: Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ?? "ALPHA-TEST",
      username,
      device_label: "deno-internal-alpha-email-smoke",
      request_id: crypto.randomUUID(),
    },
    headers,
  );
  emailPlayerId = stringField(objectField(account, "player"), "id");
  assert(
    emailPlayerId !== "",
    "account/bootstrap should return email player id",
  );
  assertEq(
    stringField(objectField(account, "player"), "account_type"),
    "registered",
    "email bootstrap should create registered player",
  );

  const labHeaders = {
    ...headers,
    "x-draxos-save-type": "progression_lab",
  };
  const lab = await postJson(
    `${SUPABASE_URL}/functions/v1/account/bootstrap`,
    {
      invite_code: Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ?? "ALPHA-TEST",
      username,
      device_label: "deno-internal-alpha-email-smoke",
      request_id: crypto.randomUUID(),
    },
    labHeaders,
  );
  labPlayerId = stringField(objectField(lab, "player"), "id");
  assert(labPlayerId !== "", "account/bootstrap should return lab player id");
  assertEq(
    stringField(objectField(lab, "player"), "username"),
    `${username}_lab`,
    "email bootstrap should create lab username suffix",
  );

  const signin = await postJson(
    `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
    { email, password },
    baseHeaders(),
  );
  const signinState = await getJson(
    `${SUPABASE_URL}/functions/v1/account/state`,
    {
      ...baseHeaders(),
      authorization: `Bearer ${stringField(signin, "access_token")}`,
    },
  );
  assertEq(
    stringField(objectField(signinState, "player"), "username"),
    username,
    "email signin should recover normal save",
  );

  const registeredBattle = await postJson(
    `${SUPABASE_URL}/functions/v1/battle/request`,
    {
      request_id: crypto.randomUUID(),
      mode: "FIRST_SLICE_SIM",
    },
    {
      ...baseHeaders(),
      authorization: `Bearer ${stringField(signin, "access_token")}`,
    },
  );
  const registeredBattleLog = objectField(registeredBattle, "battle_log");
  emailBattleId = stringField(registeredBattleLog, "battle_id");
  assert(
    emailBattleId !== "",
    "registered email account should be able to request battle",
  );
  assertEq(
    stringField(registeredBattleLog, "schema_version"),
    "battle_log_v1",
    "registered email battle should return a battle log",
  );

  if (RUN_MODE) {
    modeSessionId = await proveRemoteModeFlow(
      stringField(signin, "access_token"),
    );
  }
  if (RUN_ARENA) {
    arenaAttemptId = await proveRemoteArenaFlow(
      stringField(signin, "access_token"),
    );
  }
}

console.log("[internal-alpha-remote-smoke] OK", {
  url: SUPABASE_URL,
  healthcheck: healthcheck.ok,
  anon_auth: RUN_ANON_AUTH || RUN_ACCOUNT_STATE ? "checked" : "skipped",
  account_state: RUN_ACCOUNT_STATE ? "checked" : "skipped",
  email_auth: RUN_EMAIL_AUTH ? "checked" : "skipped",
  mode: RUN_MODE ? "checked" : "skipped",
  arena: RUN_ARENA ? "checked" : "skipped",
  release_manifest: releaseManifestChecked ? "checked" : "skipped",
  auth_user: authUser,
  player_id: playerId,
  email_user: emailUser,
  email_player_id: emailPlayerId,
  lab_player_id: labPlayerId,
  email_battle_id: emailBattleId,
  mode_session_id: modeSessionId,
  arena_attempt_id: arenaAttemptId,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
    "x-draxos-api-version": "1",
  };
}

async function assertCorsPreflights(
  targets: Array<{ url: string; method: string }>,
): Promise<void> {
  for (const target of targets) {
    await assertCorsPreflight(target.url, target.method);
  }
}

async function assertCorsPreflight(url: string, method: string): Promise<void> {
  const response = await fetch(url, {
    method: "OPTIONS",
    headers: {
      apikey: PUBLISHABLE_KEY,
      origin: CORS_ORIGIN,
      "access-control-request-method": method,
      "access-control-request-headers":
        "authorization,apikey,content-type,x-draxos-api-version,x-draxos-save-type,x-draxos-request-id,x-draxos-request-hash",
    },
  });
  assert(
    response.ok,
    `CORS preflight should pass for ${url}; status ${response.status}`,
  );
  const allowHeaders = response.headers.get("access-control-allow-headers") ??
    "";
  const allowOrigin = response.headers.get("access-control-allow-origin");
  if (url.includes("/auth/v1/")) {
    assert(
      allowOrigin === CORS_ORIGIN || allowOrigin === "*",
      `Auth CORS preflight should allow ${CORS_ORIGIN} or * for ${url}; got ${allowOrigin}`,
    );
  } else {
    assertEq(
      allowOrigin,
      CORS_ORIGIN,
      `CORS preflight should echo ${CORS_ORIGIN} for ${url}`,
    );
  }
  assertIncludes(
    allowHeaders.toLowerCase(),
    "x-draxos-api-version",
    `CORS preflight should allow x-draxos-api-version for ${url}`,
  );
  assertIncludes(
    allowHeaders.toLowerCase(),
    "x-draxos-request-id",
    `CORS preflight should allow x-draxos-request-id for ${url}`,
  );
  assertIncludes(
    allowHeaders.toLowerCase(),
    "x-draxos-request-hash",
    `CORS preflight should allow x-draxos-request-hash for ${url}`,
  );
}

function modeHeaders(
  accessToken: string,
  saveType: "normal" | "progression_lab" = "normal",
): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
    "x-draxos-api-version": "1",
    "x-draxos-save-type": saveType,
  };
}

async function proveRemoteModeFlow(accessToken: string): Promise<string> {
  const headers = modeHeaders(accessToken);
  const registry = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/registry`,
    headers,
  );
  assertEq(
    stringField(
      findObjectByField(arrayField(registry, "modes"), "mode_id", MODE_MODE_ID),
      "mode_id",
    ),
    MODE_MODE_ID,
    "remote mode registry should expose openworld",
  );
  assertEq(
    stringField(
      findObjectByField(arrayField(registry, "rulesets"), "ruleset_id", MODE_RULESET_ID),
      "ruleset_id",
    ),
    MODE_RULESET_ID,
    "remote mode registry should expose the forest ruleset",
  );

  const state = await getJson(
    `${SUPABASE_URL}/functions/v1/modes/state?mode_id=${MODE_MODE_ID}`,
    headers,
  );
  assertEq(
    stringField(findObjectByField(arrayField(state, "modes"), "mode_id", MODE_MODE_ID), "mode_id"),
    MODE_MODE_ID,
    "remote mode state should be scoped to openworld",
  );

  const startBody = {
    request_id: crypto.randomUUID(),
    mode_id: MODE_MODE_ID,
    slice_id: MODE_SLICE_ID,
  };
  const started = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    startBody,
    headers,
  );
  const repeatedStart = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    startBody,
    headers,
  );
  const sessionId = stringField(objectField(started, "session"), "id");
  let revision = numberField(objectField(started, "session"), "snapshot_revision");
  assert(
    sessionId !== "",
    "remote mode session/start should return session.id",
  );
  assertEq(
    sessionId,
    stringField(objectField(repeatedStart, "session"), "id"),
    "remote mode session/start should be idempotent",
  );

  const heartbeatBody = {
    request_id: crypto.randomUUID(),
    session_id: sessionId,
    mode_id: MODE_MODE_ID,
    slice_id: MODE_SLICE_ID,
    event_type: "move_heartbeat",
    expected_revision: revision,
    event_payload: { session_seconds: 7 },
  };
  const firstHeartbeat = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/event`,
    heartbeatBody,
    headers,
  );
  const repeatedHeartbeat = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/event`,
    heartbeatBody,
    headers,
  );
  assertEq(
    stableResponseString(firstHeartbeat),
    stableResponseString(repeatedHeartbeat),
    "remote mode session/event should be idempotent",
  );
  revision = numberField(objectField(firstHeartbeat, "event"), "revision_after");

  for (
    const node of [
      { node_id: "node_galho_01", item_id: "galho" },
      { node_id: "node_folha_01", item_id: "folha" },
      { node_id: "node_madeira_01", item_id: "madeira" },
      { node_id: "node_pedra_pequena_01", item_id: "pedra_pequena" },
      { node_id: "node_pedra_01", item_id: "pedra" },
      { node_id: "node_cogumelo_01", item_id: "cogumelo" },
      { node_id: "node_fungo_01", item_id: "fungo" },
      { node_id: "node_inseto_01", item_id: "inseto" },
      { node_id: "node_resina_01", item_id: "resina" },
      { node_id: "node_folha_seca_01", item_id: "folha_seca" },
      { node_id: "node_cinzas_preview_01", item_id: "cinzas_preview" },
      { node_id: "node_ossos_preview_01", item_id: "ossos_preview" },
      { node_id: "node_po_osso_preview_01", item_id: "po_osso_preview" },
    ]
  ) {
    revision = await recordModeEvent(headers, sessionId, revision, "collect_start", {
      node_id: node.node_id,
      item_id: node.item_id,
      session_seconds: 119,
    });
    revision = await recordModeEvent(headers, sessionId, revision, "collect_complete", {
      ...node,
      session_seconds: 120,
    });
  }
  revision = await recordModeEvent(headers, sessionId, revision, "deposit_all", {
    session_seconds: 120,
  });

  const completeBody = {
    request_id: crypto.randomUUID(),
    result: {
      session_id: sessionId,
      ruleset_id: MODE_RULESET_ID,
      ruleset_version: MODE_RULESET_VERSION,
      expected_revision: revision,
    },
  };
  const completed = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completeBody,
    headers,
  );
  const repeatedComplete = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    completeBody,
    headers,
  );
  assertEq(
    stableResponseString(completed),
    stableResponseString(repeatedComplete),
    "remote mode session/complete should be idempotent",
  );
  const resourceDelta = objectField(
    objectField(completed, "reward"),
    "resource_delta",
  );
  const reward = objectField(completed, "reward");
  const limits = objectField(completed, "limits");
  assert(
    ["applied", "no_reward", "cap_zero"].includes(stringField(completed, "reward_status")),
    "remote mode completion should expose a known reward_status",
  );
  assert(
    typeof completed.cap_zero === "boolean",
    "remote mode completion should expose cap_zero boolean",
  );
  assert(
    stringField(completed, "period_key") !== "",
    "remote mode completion should expose period_key",
  );
  assert(
    stringField(completed, "message") !== "",
    "remote mode completion should expose a player-facing message",
  );
  assertEq(
    stringField(reward, "reward_status"),
    stringField(completed, "reward_status"),
    "remote mode reward payload should mirror reward_status",
  );
  assertEq(
    stringField(limits, "period_key"),
    stringField(completed, "period_key"),
    "remote mode limits should include the same period_key",
  );
  assertEq(
    numberField(resourceDelta, "energia") >= 1,
    true,
    "remote mode energy reward should come from the server snapshot",
  );
  assertEq(
    numberField(resourceDelta, "ossos") >= 0,
    true,
    "remote mode bones reward should be server-derived",
  );
  assertEq(
    numberField(resourceDelta, "xp") >= 0,
    true,
    "remote mode XP reward should be server-derived",
  );

  const labStarted = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/start`,
    {
      request_id: crypto.randomUUID(),
      mode_id: MODE_MODE_ID,
      slice_id: MODE_SLICE_ID,
    },
    modeHeaders(accessToken, "progression_lab"),
  );
  const labBlocked = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/complete`,
    {
      request_id: crypto.randomUUID(),
      result: {
        session_id: stringField(objectField(labStarted, "session"), "id"),
        ruleset_id: MODE_RULESET_ID,
        ruleset_version: MODE_RULESET_VERSION,
        expected_revision: 0,
      },
    },
    modeHeaders(accessToken, "progression_lab"),
    false,
  );
  assertEq(
    stringField(objectField(labBlocked, "error"), "code"),
    "MODE_REWARD_BLOCKED_FOR_LAB",
    "remote progression_lab mode completion should not award real resources",
  );

  return sessionId;
}

async function proveRemoteArenaFlow(accessToken: string): Promise<string> {
  const headers = modeHeaders(accessToken);
  const state = await getJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/state`,
    headers,
  );
  assertEq(
    stringField(state, "api_version"),
    "app_responsiveness_v1",
    "remote arena state should use the responsiveness envelope",
  );
  assert(
    arrayField(state, "arenas").length > 0,
    "remote arena state should expose at least one arena",
  );

  const start = await postJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/start`,
    {
      request_id: crypto.randomUUID(),
      arena_id: "arena_tutorial_cinzas",
      difficulty_id: "s1_d00_intro",
      difficulty_tier: 0,
    },
    headers,
  );
  const attemptValue = isObject(start.active_attempt) ? start.active_attempt : start.attempt;
  assert(isObject(attemptValue), "remote arena start should return active_attempt or attempt");
  const attempt = attemptValue;
  const attemptId = stringField(attempt, "id");
  assert(attemptId !== "", "remote arena start should return active_attempt.id");

  const duel = await postJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/duel/request`,
    {
      request_id: crypto.randomUUID(),
      attempt_id: attemptId,
    },
    headers,
  );
  const step = objectField(duel, "step");
  const battleLog = objectField(step, "battle_log");
  const metadata = objectField(battleLog, "metadata");
  const arena = objectField(battleLog, "arena");
  assertEq(
    stringField(metadata, "mode"),
    "PVE_ARENA_V1",
    "remote arena battle log metadata should mark PVE_ARENA_V1",
  );
  assertEq(
    numberField(metadata, "duel_index"),
    1,
    "remote arena battle log metadata should expose duel_index",
  );
  assertEq(
    numberField(metadata, "duel_count"),
    1,
    "remote tutorial arena should expose duel_count 1",
  );
  assertEq(
    stringField(arena, "mode"),
    "PVE_ARENA_V1",
    "remote arena battle log arena block should mark PVE_ARENA_V1",
  );

  const tutorialClaim = await postJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/claim`,
    {
      request_id: crypto.randomUUID(),
      attempt_id: attemptId,
    },
    headers,
  );
  assertEq(
    stringField(tutorialClaim, "schema_version"),
    "arena_claim_response_v1",
    "remote tutorial claim should be summary-only",
  );
  assertEq(
    tutorialClaim.mutates_economy,
    false,
    "remote tutorial claim should not mutate economy",
  );

  const postTutorialState = await getJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/state`,
    headers,
  );
  assert(
    firstUnlockedDifficulty(
      postTutorialState,
      "arena_cinzas_curta",
      "s1_d00_intro",
    ),
    "remote tutorial clear should unlock first real Arena difficulty",
  );

  const firstRealStart = await postJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/start`,
    {
      request_id: crypto.randomUUID(),
      arena_id: "arena_cinzas_curta",
      difficulty_id: "s1_d00_intro",
      difficulty_tier: 0,
    },
    headers,
  );
  const firstRealAttemptValue = isObject(firstRealStart.active_attempt)
    ? firstRealStart.active_attempt
    : firstRealStart.attempt;
  assert(
    isObject(firstRealAttemptValue),
    "remote first real Arena start should return active_attempt or attempt",
  );
  const firstRealAttempt = firstRealAttemptValue;
  const firstRealAttemptId = stringField(firstRealAttempt, "id");
  assert(firstRealAttemptId !== "", "remote first real Arena should return attempt.id");
  assertEq(
    stringField(firstRealAttempt, "difficulty_id"),
    "s1_d00_intro",
    "remote first real Arena should start requested difficulty",
  );
  assertEq(
    numberField(firstRealAttempt, "max_steps"),
    3,
    "remote first real Arena should be 3 duels",
  );

  const blockedStart = await postJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/start`,
    {
      request_id: crypto.randomUUID(),
      arena_id: "arena_cinzas_curta",
      difficulty_id: "s1_d00_intro",
      difficulty_tier: 0,
    },
    headers,
    false,
  );
  assertEq(
    stringField(objectField(blockedStart, "error"), "code"),
    "ARENA_ATTEMPT_ALREADY_ACTIVE",
    "remote Arena should block starting a second attempt while one is active",
  );

  for (let stepIndex = 1; stepIndex <= 3; stepIndex += 1) {
    const duelResult = await postJson(
      `${SUPABASE_URL}/functions/v1/arena/pve/duel/request`,
      {
        request_id: crypto.randomUUID(),
        attempt_id: firstRealAttemptId,
      },
      headers,
    );
    const realStep = objectField(duelResult, "step");
    const realBattleLog = objectField(realStep, "battle_log");
    const realMetadata = objectField(realBattleLog, "metadata");
    assertEq(
      numberField(realMetadata, "duel_count"),
      3,
      "remote first real Arena battle log should expose 3-duel count",
    );
    assertEq(
      numberField(realMetadata, "duel_index"),
      stepIndex,
      "remote first real Arena battle log should expose current duel index",
    );
    if (stepIndex < 3) {
      const options = arrayField(realStep, "buff_options");
      assert(options.length > 0, "remote first real Arena win should offer a buff before next duel");
      const pendingState = await getJson(
        `${SUPABASE_URL}/functions/v1/arena/pve/state`,
        headers,
      );
      const activeAttempt = objectField(pendingState, "active_attempt");
      assertEq(
        stringField(activeAttempt, "state"),
        "awaiting_buff",
        "remote Arena state should preserve pending buff on active attempt",
      );
      assert(
        arrayField(objectField(activeAttempt, "buff_offer"), "choices").length > 0,
        "remote Arena state active attempt should expose buff_offer choices",
      );
      const firstBuff = options.find(isObject);
      assert(isObject(firstBuff), "remote buff options should include object choices");
      await postJson(
        `${SUPABASE_URL}/functions/v1/arena/pve/buff/select`,
        {
          request_id: crypto.randomUUID(),
          attempt_id: firstRealAttemptId,
          step_index: stepIndex,
          buff_id: stringField(firstBuff, "id"),
        },
        headers,
      );
    } else {
      const rewardPayload = objectField(realStep, "reward_payload");
      const completion = objectField(rewardPayload, "completion");
      assertEq(
        completion.completed,
        true,
        "remote first real Arena final duel should mark completion",
      );
      assertEq(
        stringField(completion, "arena_id"),
        "arena_cinzas_curta",
        "remote first real Arena completion should preserve arena_id",
      );
    }
  }

  const firstRealClaim = await postJson(
    `${SUPABASE_URL}/functions/v1/arena/pve/claim`,
    {
      request_id: crypto.randomUUID(),
      attempt_id: firstRealAttemptId,
    },
    headers,
  );
  assertEq(
    firstRealClaim.mutates_economy,
    false,
    "remote first real Arena claim should remain summary-only",
  );

  return firstRealAttemptId;
}

function firstUnlockedDifficulty(
  state: JsonObject,
  arenaId: string,
  difficultyId: string,
): boolean {
  const arena = findObjectByField(arrayField(state, "arenas"), "id", arenaId);
  const difficulty = findObjectByField(
    arrayField(arena, "difficulties"),
    "difficulty_id",
    difficultyId,
  );
  return difficulty.unlocked === true;
}

async function recordModeEvent(
  headers: Record<string, string>,
  sessionId: string,
  expectedRevision: number,
  eventType: string,
  eventPayload: JsonObject,
): Promise<number> {
  const response = await postJson(
    `${SUPABASE_URL}/functions/v1/modes/session/event`,
    {
      request_id: crypto.randomUUID(),
      session_id: sessionId,
      mode_id: MODE_MODE_ID,
      slice_id: MODE_SLICE_ID,
      event_type: eventType,
      expected_revision: expectedRevision,
      event_payload: eventPayload,
    },
    headers,
  );
  return numberField(objectField(response, "event"), "revision_after");
}

async function getJson(
  url: string,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response, requireOk);
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
    assert(
      payload.ok === true || stringField(payload, "access_token") !== "",
      `response should be ok/auth: ${text}`,
    );
  }
  return payload;
}

function requiredEnv(key: string): string {
  const value = Deno.env.get(key)?.trim() ?? "";
  if (value === "") {
    throw new Error(`${key} is required for remote smoke`);
  }
  return value;
}

function assertRemoteUrl(url: string): void {
  assert(
    url.startsWith("https://"),
    "remote smoke requires an https Supabase project URL",
  );
  assert(
    !url.includes("localhost") && !url.includes("127.0.0.1"),
    "remote smoke refuses local Supabase URLs",
  );
}

function assertClientKey(key: string): void {
  const normalized = key.toLowerCase();
  assert(
    !normalized.includes("service_role") &&
      !normalized.includes("secret") &&
      !normalized.startsWith("sb_secret_") &&
      !normalized.startsWith("sb_service_"),
    "remote smoke must use a publishable/client key, never service role",
  );
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

function findObjectByField(items: unknown[], key: string, expected: string): JsonObject {
  for (const item of items) {
    if (isObject(item) && item[key] === expected) {
      return item;
    }
  }
  throw new Error(`Missing object with ${key}=${expected}`);
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  assert(typeof value === "number", `${key} should be a number`);
  return value;
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

function assertIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}. Got: ${haystack}`);
  }
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map((item) => stableStringify(item)).join(",")}]`;
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

function stableResponseString(value: unknown): string {
  return stableStringify(stripVolatileEnvelopeFields(value));
}

function stripVolatileEnvelopeFields(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => stripVolatileEnvelopeFields(item));
  }
  if (!isObject(value)) {
    return value;
  }
  const result: Record<string, unknown> = {};
  for (const key of Object.keys(value).sort()) {
    if (key === "cache" || key === "server_timing") {
      continue;
    }
    result[key] = stripVolatileEnvelopeFields(value[key]);
  }
  return result;
}
