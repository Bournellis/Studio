const PROJECT_PREFIX = "Projetos/draxos-mobile";
const MIGRATION_PATH = "supabase/migrations/202606010001_modes_platform_v1.sql";
const SERVER_MIRROR_PATH = "server/schema/migrations/202606010001_modes_platform_v1.sql";
const ADMIN_MIGRATION_PATH = "supabase/migrations/202606010002_modes_admin_audit_hardening.sql";
const ADMIN_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606010002_modes_admin_audit_hardening.sql";
const HARDENING_V2_MIGRATION_PATH = "supabase/migrations/202606010003_foundation_hardening_v2.sql";
const HARDENING_V2_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606010003_foundation_hardening_v2.sql";
const BOSQUE_HARDENING_MIGRATION_PATH =
  "supabase/migrations/202606020001_openworld_bosque_hardening_v1.sql";
const BOSQUE_HARDENING_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606020001_openworld_bosque_hardening_v1.sql";
const BOSQUE_POLICY_ACTIVE_COMPAT_PATH =
  "supabase/migrations/202606020002_openworld_bosque_policy_active_compat.sql";
const BOSQUE_POLICY_ACTIVE_COMPAT_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606020002_openworld_bosque_policy_active_compat.sql";
const OPENWORLD_SESSION_CONTRACTS_PATH =
  "supabase/migrations/202606030003_openworld_session_contracts_v1.sql";
const OPENWORLD_SESSION_CONTRACTS_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606030003_openworld_session_contracts_v1.sql";
const OPENWORLD_GUIDANCE_PERSISTENCE_PATH =
  "supabase/migrations/202606040001_openworld_guidance_persistence_v1.sql";
const OPENWORLD_GUIDANCE_PERSISTENCE_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606040001_openworld_guidance_persistence_v1.sql";
const OPENWORLD_CHECKPOINT_PATH =
  "supabase/migrations/202606060001_openworld_bosque_checkpoint_v1.sql";
const OPENWORLD_CHECKPOINT_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606060001_openworld_bosque_checkpoint_v1.sql";
const OPENWORLD_DURABLE_PROGRESS_PATH =
  "supabase/migrations/202606060002_openworld_bosque_durable_progress_v1.sql";
const OPENWORLD_DURABLE_PROGRESS_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606060002_openworld_bosque_durable_progress_v1.sql";
const OPENWORLD_PERSISTENCE_REBASE_PATH =
  "supabase/migrations/202606080001_openworld_bosque_persistence_rebase_v1.sql";
const OPENWORLD_PERSISTENCE_REBASE_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606080001_openworld_bosque_persistence_rebase_v1.sql";
const OPENWORLD_JSONB_OBJECT_LENGTH_HOTFIX_PATH =
  "supabase/migrations/202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql";
const OPENWORLD_JSONB_OBJECT_LENGTH_HOTFIX_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql";
const ADMIN_COMPENSATE_HASH_MIGRATION_PATH =
  "supabase/migrations/202606020003_admin_compensate_request_hash.sql";
const ADMIN_COMPENSATE_HASH_SERVER_MIRROR_PATH =
  "server/schema/migrations/202606020003_admin_compensate_request_hash.sql";
const EDGE_PATH = "server/functions/modes/index.ts";
const SUPABASE_EDGE_PATH = "supabase/functions/modes/index.ts";
const HANDLER_PATH = "server/functions/modes/mode_handler.ts";
const SUPABASE_HANDLER_PATH = "supabase/functions/modes/mode_handler.ts";
const SUPPORT_PATH = "server/functions/modes/mode_support.ts";
const SUPABASE_SUPPORT_PATH = "supabase/functions/modes/mode_support.ts";
const OPENWORLD_SCREEN_PATH = "modes/openworld/openworld_forest_screen.gd";
const OPENWORLD_BRIDGE_PATH = "modes/openworld/openworld_integrated_session_bridge.gd";
const OPENWORLD_MODEL_PATH = "modes/openworld/openworld_forest_model.gd";
const OPENWORLD_INTERACTION_PATH = "modes/openworld/openworld_forest_interaction_controller.gd";
const OPENWORLD_HUD_PATH = "modes/openworld/openworld_forest_hud_controller.gd";

Deno.test("mode platform migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(MIGRATION_PATH);
  const serverMirror = await readProjectText(SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema migration should mirror supabase migration exactly",
  );
});

Deno.test("mode admin audit hardening migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(ADMIN_MIGRATION_PATH);
  const serverMirror = await readProjectText(ADMIN_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema admin hardening migration should mirror supabase migration exactly",
  );
});

Deno.test("foundation hardening v2 migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(HARDENING_V2_MIGRATION_PATH);
  const serverMirror = await readProjectText(HARDENING_V2_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema hardening v2 migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld bosque hardening migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(BOSQUE_HARDENING_MIGRATION_PATH);
  const serverMirror = await readProjectText(BOSQUE_HARDENING_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema bosque hardening migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld bosque policy active compat migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(BOSQUE_POLICY_ACTIVE_COMPAT_PATH);
  const serverMirror = await readProjectText(BOSQUE_POLICY_ACTIVE_COMPAT_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema bosque policy active compat migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld session contracts migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(OPENWORLD_SESSION_CONTRACTS_PATH);
  const serverMirror = await readProjectText(OPENWORLD_SESSION_CONTRACTS_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema openworld session contracts migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld guidance persistence migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(OPENWORLD_GUIDANCE_PERSISTENCE_PATH);
  const serverMirror = await readProjectText(OPENWORLD_GUIDANCE_PERSISTENCE_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema openworld guidance persistence migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld checkpoint migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(OPENWORLD_CHECKPOINT_PATH);
  const serverMirror = await readProjectText(OPENWORLD_CHECKPOINT_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema openworld checkpoint migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld durable progress migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(OPENWORLD_DURABLE_PROGRESS_PATH);
  const serverMirror = await readProjectText(OPENWORLD_DURABLE_PROGRESS_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema openworld durable progress migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld persistence rebase migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(OPENWORLD_PERSISTENCE_REBASE_PATH);
  const serverMirror = await readProjectText(OPENWORLD_PERSISTENCE_REBASE_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema openworld persistence rebase migration should mirror supabase migration exactly",
  );
});

Deno.test("openworld jsonb object length hotfix migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(OPENWORLD_JSONB_OBJECT_LENGTH_HOTFIX_PATH);
  const serverMirror = await readProjectText(OPENWORLD_JSONB_OBJECT_LENGTH_HOTFIX_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema openworld jsonb object length hotfix should mirror supabase migration exactly",
  );
  assertIncludes(
    supabaseMigration,
    "create or replace function public.jsonb_object_length(p_value jsonb)",
    "hotfix should provide the jsonb_object_length compatibility shim",
  );
  assertIncludes(
    supabaseMigration,
    "notify pgrst, 'reload schema'",
    "hotfix should reload PostgREST schema cache after adding the shim",
  );
});

Deno.test("admin compensate request hash migration is mirrored in server schema", async () => {
  const supabaseMigration = await readProjectText(ADMIN_COMPENSATE_HASH_MIGRATION_PATH);
  const serverMirror = await readProjectText(ADMIN_COMPENSATE_HASH_SERVER_MIRROR_PATH);

  assertEq(
    normalizeNewlines(serverMirror),
    normalizeNewlines(supabaseMigration),
    "server/schema admin compensate hash migration should mirror supabase migration exactly",
  );
});

Deno.test("mode platform declares registry, sessions, progress and reward claims", async () => {
  const migration = await migrationText();

  for (
    const tableName of [
      "mode_registry",
      "mode_ruleset_registry",
      "mode_progress",
      "mode_sessions",
      "mode_reward_claims",
    ]
  ) {
    assertIncludes(
      migration,
      `create table if not exists public.${tableName}`,
      `migration should create ${tableName}`,
    );
    assertIncludes(
      migration,
      `alter table public.${tableName} enable row level security`,
      `${tableName} should enable RLS`,
    );
  }

  assertIncludes(migration, "'openworld'", "registry should seed openworld");
  for (
    const modeId of [
      "'basebuilder'",
      "'autobattler'",
      "'towerdefense'",
      "'cardgame'",
      "'openworld'",
    ]
  ) {
    assertIncludes(migration, modeId, `registry should seed ${modeId}`);
  }
  assertIncludes(
    migration,
    "'openworld_forest_ruleset_v0'",
    "ruleset registry should seed the forest ruleset",
  );
  assertIncludes(
    migration,
    "open_mode_shell:openworld",
    "registry metadata should point to the mode shell action",
  );
  assertIncludes(
    migration,
    "create table if not exists public.mode_limit_policies",
    "migration should declare mode limit policies",
  );
  assertIncludes(
    migration,
    "create table if not exists public.admin_roles",
    "migration should declare admin roles for mode ops",
  );
});

Deno.test("mode reward bridge is service-role, idempotent and ledgers resources", async () => {
  const migration = await migrationText();

  const hardeningV2Migration = normalizeSql(await readProjectText(HARDENING_V2_MIGRATION_PATH));

  for (
    const [functionName, source] of [
      ["mode_session_start_v1", migration],
      ["mode_session_complete_v1", migration],
      ["mode_session_abandon_v1", hardeningV2Migration],
    ] as const
  ) {
    assertIncludes(
      source,
      `create or replace function public.${functionName}`,
      `migration should declare ${functionName}`,
    );
    assertRegex(
      source,
      new RegExp(
        `revoke all on function public\\.${functionName}\\([^;]+\\) from public, anon, authenticated;`,
        "s",
      ),
      `${functionName} should be revoked from public roles`,
    );
    assertRegex(
      source,
      new RegExp(
        `grant execute on function public\\.${functionName}\\([^;]+\\) to service_role;`,
        "s",
      ),
      `${functionName} should be granted to service_role only`,
    );
  }

  assertIncludes(migration, "modes/session/start", "start should reserve idempotency");
  assertIncludes(migration, "modes/session/complete", "complete should reserve idempotency");
  assertIncludes(
    hardeningV2Migration,
    "modes/session/abandon",
    "abandon should reserve idempotency",
  );
  assertIncludes(
    hardeningV2Migration,
    "public.reserve_idempotency",
    "abandon should reject reused request_id with a different hash through reserve_idempotency",
  );
  assertIncludes(
    migration,
    "insert into public.resource_transactions",
    "reward completion should write the economy ledger",
  );
  assertIncludes(
    migration,
    "mode_reward_blocked_for_lab",
    "progression lab saves should not receive Base/Account rewards",
  );
  assertIncludes(
    migration,
    "mode_result_rejected",
    "tampered or implausible results should be rejected",
  );
});

Deno.test("mode edge function mirror exposes all v1 routes", async () => {
  const edge = await readProjectText(EDGE_PATH);
  const supabaseEdge = await readProjectText(SUPABASE_EDGE_PATH);
  const handler = await readProjectText(HANDLER_PATH);
  const supabaseHandler = await readProjectText(SUPABASE_HANDLER_PATH);
  const support = await readProjectText(SUPPORT_PATH);
  const supabaseSupport = await readProjectText(SUPABASE_SUPPORT_PATH);

  assertEq(
    normalizeNewlines(edge),
    normalizeNewlines(supabaseEdge),
    "server and supabase mode entrypoints should match exactly",
  );
  assertEq(
    normalizeNewlines(handler),
    normalizeNewlines(supabaseHandler),
    "server and supabase mode handlers should match exactly",
  );
  assertEq(
    normalizeNewlines(support),
    normalizeNewlines(supabaseSupport),
    "server and supabase mode support modules should match exactly",
  );
  assertIncludes(
    edge,
    "mode_handler.ts",
    "edge entrypoint should delegate to ModeHandler",
  );
  assertIncludes(
    handler.toLowerCase(),
    "export class ModeHandler",
    "mode handler should be internally modularized",
  );
  assertIncludes(
    handler.toLowerCase(),
    'from "./mode_support.ts"',
    "mode handler should delegate shared support concerns to mode_support",
  );
  for (
    const route of [
      "registry",
      "state",
      "session_start",
      "session_event",
      "session_checkpoint",
      "session_complete",
      "session_abandon",
      "analytics_summary",
      "admin_disable",
      "admin_enable",
      "admin_session_expire",
      "admin_session_invalidate",
      "admin_reconcile",
      "admin_compensate",
      "validateApiVersion",
      "verifiedAuthContext",
      "requireExplicitSaveType",
      "request_hash",
    ]
  ) {
    assertIncludes(
      handler.toLowerCase(),
      route,
      `mode handler should include ${route}`,
    );
  }
  for (
    const supportSymbol of [
      "export function resolveRoute",
      "export async function loadModeState",
      "export function loadConfig",
      "export async function restRequest",
      "export function mapModeDatabaseError",
    ]
  ) {
    assertIncludes(
      support.toLowerCase(),
      supportSymbol,
      `mode support should expose ${supportSymbol}`,
    );
  }
  assertLessOrEq(
    lineCount(handler),
    725,
    "mode_handler.ts should stay below the checkpoint route/facade budget",
  );
  assertLessOrEq(
    lineCount(support),
    700,
    "mode_support.ts should stay below the V2 support budget",
  );
});

Deno.test("openworld bosque hardening declares snapshot, event and server-authoritative reward contracts", async () => {
  const migration = normalizeSql(await readProjectText(BOSQUE_HARDENING_MIGRATION_PATH));
  const sessionContracts = normalizeSql(await readProjectText(OPENWORLD_SESSION_CONTRACTS_PATH));
  const guidancePersistence = normalizeSql(
    await readProjectText(OPENWORLD_GUIDANCE_PERSISTENCE_PATH),
  );
  const checkpointMigration = normalizeSql(await readProjectText(OPENWORLD_CHECKPOINT_PATH));
  const durableProgress = normalizeSql(await readProjectText(OPENWORLD_DURABLE_PROGRESS_PATH));
  const persistenceRebase = normalizeSql(await readProjectText(OPENWORLD_PERSISTENCE_REBASE_PATH));
  const handler = normalizeCode(await readProjectText(HANDLER_PATH));
  const support = normalizeCode(await readProjectText(SUPPORT_PATH));

  for (
    const fragment of [
      "add column if not exists snapshot_payload",
      "add column if not exists snapshot_revision",
      "add column if not exists last_event_at",
      "create table if not exists public.mode_session_events",
      "create or replace function public.mode_session_event_v1",
      "add column if not exists active boolean not null default true",
      "openworld_forest_ruleset_v1",
      "openworld_forest_initial_snapshot_v1",
      "openworld_forest_apply_event_v1",
      "mode_session_revision_stale",
      "openworld_node_already_collected",
      "deposited_items_payload := coalesce(session_row.snapshot_payload",
      "'authority', 'server_snapshot'",
    ]
  ) {
    assertIncludes(migration, fragment, `bosque hardening should include ${fragment}`);
  }
  for (
    const fragment of [
      "'reward_status', reward_status",
      "'cap_zero', cap_zero",
      "'period_key', reward_period_key",
      "'message', reward_message",
      "'per_session', jsonb_build_object('energia', 12, 'ossos', 2, 'xp', 8)",
      "public.foundation_level_for_xp_v1(coalesce(xp, 0) + greatest(0, reward_xp), 40)",
      "level = greatest(",
      "Limite diario UTC do Bosque ja foi usado",
    ]
  ) {
    assertIncludes(
      sessionContracts,
      fragment,
      `openworld session contracts should include ${fragment}`,
    );
  }
  assertIncludes(handler, "mode_endpoint_session_event", "handler should hash event mutations");
  assertIncludes(handler, "rpc/mode_session_event_v1", "handler should call the event RPC");
  assertIncludes(
    handler,
    "mode_endpoint_session_checkpoint",
    "handler should hash checkpoint mutations",
  );
  assertIncludes(
    handler,
    "rpc/mode_session_checkpoint_v1",
    "handler should call the checkpoint RPC",
  );
  assertIncludes(
    checkpointMigration,
    "mode_session_checkpoint_v1",
    "checkpoint migration should declare the checkpoint RPC",
  );
  assertIncludes(
    checkpointMigration,
    "mode_checkpoint_required",
    "completion wrapper should require an accepted checkpoint",
  );
  for (
    const fragment of [
      "openworld_forest_progress_v1",
      "openworld_forest_validate_checkpoint_v2",
      "durable_base",
      "openworld_forest_inventory_delta_above_v1",
      "openworld_forest_mark_checkpoint_progress_v1",
      "openworld_forest_mark_completed_progress_v1",
      "progress_payload = durable_progress",
      "progress_payload = durable_progress_after",
    ]
  ) {
    assertIncludes(
      durableProgress,
      fragment,
      `openworld durable progress migration should include ${fragment}`,
    );
  }
  for (
    const fragment of [
      "openworld_forest_progress_v2",
      "openworld_forest_apply_operations_v1",
      "node_state",
      "next_spawn_at",
      "openworld_node_on_cooldown",
      "applied_ops",
      "progress_revision",
    ]
  ) {
    assertIncludes(
      persistenceRebase,
      fragment,
      `openworld persistence rebase migration should include ${fragment}`,
    );
  }
  for (
    const fragment of [
      "guidance_update",
      "openworld_forest_normalize_guidance_v1",
      "openworld_forest_save_guidance_snapshot_v1",
      "{openworld,forest,guidance}",
      "save_row.save_type = 'normal'",
      "snapshot = public.openworld_forest_save_guidance_snapshot_v1",
    ]
  ) {
    assertIncludes(
      guidancePersistence,
      fragment,
      `openworld guidance persistence should include ${fragment}`,
    );
  }
  assertNotIncludes(
    guidancePersistence,
    "insert into public.resource_transactions",
    "guidance persistence must not touch economy ledger",
  );
  assertNotIncludes(
    guidancePersistence,
    "insert into public.mode_reward_claims",
    "guidance persistence must not create reward claims",
  );
  const eventHandler = codeSection(
    handler,
    "async function handleSessionEvent",
    "async function handleSessionComplete",
  );
  assertIncludes(
    eventHandler,
    "modeeventackpayload(rpc.value)",
    "session/event should return an explicit mode event ACK inside the common envelope",
  );
  assertIncludes(
    handler,
    "modeeventackpayload",
    "handler should import the mode event ACK builder",
  );
  assertIncludes(
    eventHandler,
    'surface: "mode"',
    "session/event envelope should be scoped to mode",
  );
  assertIncludes(support, "session_event", "support should resolve the event route");
  assertIncludes(support, "session_checkpoint", "support should resolve the checkpoint route");
  assertIncludes(support, "mode_session_revision_stale", "support should map stale revisions");
  assertIncludes(
    support,
    "mode_checkpoint_rejected",
    "support should map rejected checkpoint payloads",
  );
  assertIncludes(
    support,
    "mode_session_already_active",
    "support should map active-session conflicts",
  );
  assertIncludes(
    support,
    "mode_session_start_cooldown",
    "support should map start cooldown conflicts",
  );
  assertIncludes(
    support,
    "openworld_node_already_collected",
    "support should map duplicate node collection",
  );
  assertIncludes(
    support,
    "openworld_node_on_cooldown",
    "support should map cooldown conflicts",
  );
  assertIncludes(support, "invalid_mode_event", "support should map invalid event payloads");
  const modeDatabaseCodes = codeSection(
    support,
    "const codes = [",
    "for (const code of codes)",
  );
  assertLessThan(
    modeDatabaseCodes.indexOf('"invalid_mode_event"'),
    modeDatabaseCodes.indexOf('"invalid_mode"'),
    "specific INVALID_MODE_EVENT mapping should be checked before INVALID_MODE",
  );
  assertLessThan(
    modeDatabaseCodes.indexOf('"invalid_mode_status"'),
    modeDatabaseCodes.indexOf('"invalid_mode"'),
    "specific INVALID_MODE_STATUS mapping should be checked before INVALID_MODE",
  );
});

Deno.test("openworld client uses ACK-backed operation checkpoints during active Bosque play", async () => {
  const screen = normalizeCode(await readProjectText(OPENWORLD_SCREEN_PATH));
  const bridge = normalizeCode(await readProjectText(OPENWORLD_BRIDGE_PATH));
  const model = normalizeCode(await readProjectText(OPENWORLD_MODEL_PATH));
  const interaction = normalizeCode(await readOptionalProjectText(OPENWORLD_INTERACTION_PATH));
  const hud = normalizeCode(await readOptionalProjectText(OPENWORLD_HUD_PATH));
  const screenOrInteraction = `${screen}\n${interaction}`;
  const screenOrHud = `${screen}\n${hud}`;

  for (
    const required of [
      "var _checkpoint_dirty := false",
      "func flush_checkpoint",
      "await supabase_client.checkpoint_mode_session",
      "_snapshot_revision",
      "_apply_checkpoint_ack(body, sent_sequence, sent_operation_ids)",
      "var _pending_operations",
      "openworld_pending_ops_cache_v1",
      "func has_pending_events()",
    ]
  ) {
    assertIncludes(bridge, required, `openworld checkpoint bridge should include ${required}`);
  }
  const checkpointSection = codeSection(
    bridge,
    "func flush_checkpoint",
    "func _apply_checkpoint_ack",
  );
  assertNotIncludes(
    checkpointSection,
    "hydrate_session(",
    "checkpoint ACKs should not hydrate the full session snapshot during active play",
  );
  assertIncludes(
    bridge,
    "func _build_checkpoint_payload",
    "openworld should serialize operations into checkpoint requests",
  );
  assertIncludes(
    bridge,
    "func _save_local_checkpoint_state",
    "openworld should persist local Bosque state independently from remote ACKs",
  );
  for (
    const required of [
      "model.advance_collection(delta, false, distance, true)",
    ]
  ) {
    assertIncludes(
      screenOrInteraction,
      required,
      `openworld interaction path should include ${required}`,
    );
  }
  assertIncludes(
    `${screenOrInteraction}\n${bridge}`,
    "remember_pending_collected_node(node_id)",
    "openworld should remember local collected nodes before checkpoint ACK",
  );
  assertIncludes(
    `${screenOrInteraction}\n${bridge}`,
    "has_pending_collected_node",
    "openworld should guard pending collected nodes before checkpoint ACK",
  );
  assertIncludes(
    screenOrHud,
    "deposit_disabled",
    "openworld UI should still compute local deposit disabled state",
  );
  assertIncludes(
    screen,
    "func _has_pending_integrated_events()",
    "openworld screen should expose pending checkpoint state",
  );
  assertNotIncludes(
    screen,
    'call_deferred("_record_integrated_event"',
    "openworld should not fire concurrent microevent mutations",
  );
  assertNotIncludes(
    screen,
    "record_heartbeat_if_due",
    "openworld should not send movement heartbeat mutations during active play",
  );
  assertNotIncludes(
    bridge,
    "await supabase_client.record_mode_session_event",
    "new Openworld bridge should not send gameplay microevents during active play",
  );
  assertIncludes(
    model,
    "commit_to_pocket: bool = true",
    "model should support local collection completion",
  );
  assertIncludes(
    model,
    "func apply_authoritative_patch",
    "model should keep a recovery patch path for explicit resync",
  );
});

Deno.test("openworld start endpoint resumes active sessions instead of blocking the shell", async () => {
  const handler = normalizeCode(await readProjectText("server/functions/modes/mode_handler.ts"));
  const supabaseHandler = normalizeCode(
    await readProjectText("supabase/functions/modes/mode_handler.ts"),
  );
  const support = normalizeCode(await readProjectText("server/functions/modes/mode_support.ts"));
  const supabaseSupport = normalizeCode(
    await readProjectText("supabase/functions/modes/mode_support.ts"),
  );
  for (const source of [handler, supabaseHandler]) {
    assertIncludes(
      source,
      'mapped.code === "MODE_SESSION_ALREADY_ACTIVE"',
      "start handler should special-case active Bosque sessions",
    );
    assertIncludes(
      source,
      "loadOpenworldActiveSessionStartPayload",
      "start handler should delegate active-session resume payload construction",
    );
  }
  for (const source of [support, supabaseSupport]) {
    assertIncludes(
      source,
      "resumed_existing: true",
      "start handler should expose active-session resume semantics",
    );
    assertIncludes(
      source,
      "session: activeSession",
      "start handler should return the active session in normal start payload shape",
    );
    assertIncludes(
      source,
      "durable_progress: durableProgress",
      "start handler should return durable progress with resumed sessions",
    );
  }
});

Deno.test("mode session abandon is RPC-backed and hash guarded", async () => {
  const migration = normalizeSql(await readProjectText(HARDENING_V2_MIGRATION_PATH));
  const handler = normalizeCode(await readProjectText(HANDLER_PATH));
  const abandonSection = codeSection(
    handler,
    "async function handleSessionAbandon",
    "async function handleAnalyticsSummary",
  );

  assertIncludes(
    migration,
    "create or replace function public.mode_session_abandon_v1",
    "hardening v2 should declare mode_session_abandon_v1",
  );
  assertIncludes(
    migration,
    "public.reserve_idempotency",
    "abandon RPC should reserve idempotency",
  );
  assertIncludes(
    migration,
    "public.complete_idempotency",
    "abandon RPC should complete idempotency",
  );
  assertIncludes(
    migration,
    "p_request_hash text",
    "abandon RPC should require p_request_hash",
  );
  assertIncludes(
    handler,
    "mode_endpoint_session_abandon",
    "handler should compute canonical abandon request hash",
  );
  assertIncludes(
    abandonSection,
    "rpc/mode_session_abandon_v1",
    "abandon handler should call the service-role RPC",
  );
  assertNotIncludes(
    abandonSection,
    'method: "patch"',
    "abandon handler should not PATCH mode_sessions directly",
  );
});

Deno.test("mode admin RPCs are audited, service-role only and hash guarded", async () => {
  const migration = normalizeSql(await readProjectText(ADMIN_MIGRATION_PATH));
  const handler = normalizeCode(await readProjectText(HANDLER_PATH));
  const adminFunctions = [
    "admin_set_mode_status_v1",
    "admin_expire_mode_session_v1",
    "admin_invalidate_mode_session_v1",
  ];

  for (const functionName of adminFunctions) {
    assertIncludes(
      migration,
      `create or replace function public.${functionName}`,
      `migration should declare ${functionName}`,
    );
    assertIncludes(
      migration,
      `where action = '${functionName}'`,
      `${functionName} should dedupe by admin audit action/request_id`,
    );
    assertIncludes(
      migration,
      "metadata->>'request_hash'",
      `${functionName} should compare request hashes on retries`,
    );
    assertIncludes(
      migration,
      "'idempotency_hash_mismatch'",
      `${functionName} should reject reused request_id with a different hash`,
    );
    assertRegex(
      migration,
      new RegExp(
        `revoke all on function public\\.${functionName}\\([^;]+\\) from public, anon, authenticated;`,
        "s",
      ),
      `${functionName} should be revoked from public roles`,
    );
    assertRegex(
      migration,
      new RegExp(
        `grant execute on function public\\.${functionName}\\([^;]+\\) to service_role;`,
        "s",
      ),
      `${functionName} should be granted to service_role only`,
    );
    assertIncludes(
      handler,
      `rpc/${functionName}`,
      `/modes/admin/* should call audited RPC ${functionName}`,
    );
  }

  const adminMutationSection = codeSection(
    handler,
    "async function handleAdminModeStatus",
    "async function handleAdminReconcile",
  );
  assertNotIncludes(
    adminMutationSection,
    'method: "patch"',
    "admin mode/session handlers should not PATCH mode tables directly",
  );
});

Deno.test("mode admin compensate is audited, service-role only and hash guarded", async () => {
  const migration = normalizeSql(await readProjectText(ADMIN_COMPENSATE_HASH_MIGRATION_PATH));
  const handler = normalizeCode(await readProjectText(HANDLER_PATH));

  assertIncludes(
    migration,
    "create or replace function public.admin_adjust_resource_balance_v1",
    "admin compensate hardening should replace admin_adjust_resource_balance_v1",
  );
  assertIncludes(
    migration,
    "p_request_hash text",
    "admin compensate RPC should require p_request_hash",
  );
  assertIncludes(
    migration,
    "metadata->>'request_hash'",
    "admin compensate RPC should compare request hashes on retries",
  );
  assertIncludes(
    migration,
    "'idempotency_hash_mismatch'",
    "admin compensate RPC should reject reused request_id with a different hash",
  );
  assertIncludes(
    migration,
    "'request_hash', p_request_hash",
    "admin compensate RPC should store request_hash in audit metadata",
  );
  assertIncludes(
    migration,
    "revoke all on function public.admin_adjust_resource_balance_v1(uuid, jsonb, text, uuid, uuid) from public, anon, authenticated, service_role;",
    "old admin compensate signature should no longer be executable through service_role",
  );
  assertRegex(
    migration,
    /revoke all on function public\.admin_adjust_resource_balance_v1\(uuid, jsonb, text, uuid, text, uuid\) from public, anon, authenticated;/s,
    "new admin compensate signature should be revoked from public roles",
  );
  assertRegex(
    migration,
    /grant execute on function public\.admin_adjust_resource_balance_v1\(uuid, jsonb, text, uuid, text, uuid\) to service_role;/s,
    "new admin compensate signature should be granted to service_role only",
  );
  assertIncludes(
    handler,
    "modes/admin/compensate",
    "admin compensate handler should compute a route-specific request hash",
  );
  assertIncludes(
    handler,
    "rpc/admin_adjust_resource_balance_v1",
    "admin compensate handler should call the audited RPC",
  );
  assertIncludes(
    handler,
    "p_request_hash: requesthash",
    "admin compensate handler should send p_request_hash to the RPC",
  );
});

async function migrationText(): Promise<string> {
  return normalizeSql(await readProjectText(MIGRATION_PATH));
}

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(projectFile(relativePath));
}

async function readOptionalProjectText(relativePath: string): Promise<string> {
  try {
    return await readProjectText(relativePath);
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return "";
    throw error;
  }
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `${PROJECT_PREFIX}/${relativePath}`;
}

function normalizeSql(value: string): string {
  return normalizeNewlines(value).toLowerCase();
}

function normalizeCode(value: string): string {
  return normalizeNewlines(value).toLowerCase();
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (!haystack.includes(needle.toLowerCase())) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assertNotIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (haystack.includes(needle.toLowerCase())) {
    throw new Error(`${message}. Unexpected: ${needle}`);
  }
}

function codeSection(haystack: string, start: string, end: string): string {
  const startIndex = haystack.indexOf(start.toLowerCase());
  const endIndex = haystack.indexOf(end.toLowerCase());
  if (startIndex < 0 || endIndex <= startIndex) {
    throw new Error(`missing code section ${start} -> ${end}`);
  }
  return haystack.slice(startIndex, endIndex);
}

function assertRegex(haystack: string, pattern: RegExp, message: string): void {
  if (!pattern.test(haystack)) {
    throw new Error(`${message}. Pattern: ${pattern}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(message);
  }
}

function assertLessOrEq(actual: number, expected: number, message: string): void {
  if (actual > expected) {
    throw new Error(`${message}. Actual=${actual} Expected<=${expected}`);
  }
}

function assertLessThan(actual: number, expected: number, message: string): void {
  if (actual < 0 || expected < 0 || actual >= expected) {
    throw new Error(`${message}. Actual=${actual} ExpectedGreater=${expected}`);
  }
}

function lineCount(value: string): number {
  return normalizeNewlines(value).split("\n").length;
}
