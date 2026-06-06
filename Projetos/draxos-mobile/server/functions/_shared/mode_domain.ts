import openworldForestRuleset from "../../../data/definitions/openworld/forest_ruleset_v1.json" with {
  type: "json",
};

export const MODE_PLATFORM_SCHEMA_VERSION = "mode_platform_v1";
export const BASEBUILDER_MODE_ID = "basebuilder";
export const AUTOBATTLER_MODE_ID = "autobattler";
export const TOWERDEFENSE_MODE_ID = "towerdefense";
export const CARDGAME_MODE_ID = "cardgame";
export const OPENWORLD_MODE_ID = "openworld";
export const OPENWORLD_SLICE_ID = "forest";
const OPENWORLD_RULESET_DEFINITION = openworldForestRuleset as Record<string, unknown>;
export const OPENWORLD_RULESET_ID = stringValue(
  OPENWORLD_RULESET_DEFINITION.ruleset_id,
  "openworld_forest_ruleset_v1",
);
export const OPENWORLD_RULESET_VERSION = numberValue(
  OPENWORLD_RULESET_DEFINITION.ruleset_version,
  1,
);
export const OPENWORLD_RELEASE_CHANNEL = "internal_alpha";

export const MODE_ENDPOINT_SESSION_START = "modes/session/start";
export const MODE_ENDPOINT_SESSION_EVENT = "modes/session/event";
export const MODE_ENDPOINT_SESSION_COMPLETE = "modes/session/complete";
export const MODE_ENDPOINT_SESSION_ABANDON = "modes/session/abandon";

export interface ModeRegistryRow {
  mode_id: string;
  display_name: string;
  status: string;
  release_channel: string;
  default_slice_id: string;
  active_ruleset_id: string;
  active_ruleset_version: number | string;
  metadata: unknown;
  updated_at?: string;
}

export interface ModeRulesetRow {
  ruleset_id: string;
  ruleset_version: number | string;
  mode_id: string;
  slice_id: string;
  status: string;
  release_channel: string;
  reward_limits: unknown;
  result_limits: unknown;
  ruleset_payload: unknown;
  updated_at?: string;
}

export interface ModeProgressRow {
  game_save_id: string;
  mode_id: string;
  local_schema_version: string;
  progress_payload: unknown;
  totals_payload: unknown;
  last_session_id?: string | null;
  updated_at?: string;
}

export interface ModeSessionRow {
  id: string;
  game_save_id: string;
  mode_id: string;
  slice_id: string;
  ruleset_id: string;
  ruleset_version: number | string;
  status: string;
  server_seed: string;
  session_seconds: number | string | null;
  activity_score: number | string | null;
  deposited_items: unknown;
  result_payload: unknown;
  reward_payload: unknown;
  started_at?: string;
  completed_at?: string | null;
  expires_at?: string | null;
  abandoned_at?: string | null;
  invalidated_at?: string | null;
  invalidated_reason?: string | null;
  snapshot_payload?: unknown;
  snapshot_revision?: number | string | null;
  last_event_at?: string | null;
}

export interface ModeRewardClaimRow {
  id: string;
  game_save_id: string;
  player_id: string;
  mode_id: string;
  session_id: string;
  period_key: string;
  reward_payload: unknown;
  resource_delta: unknown;
  xp_delta: number | string;
  created_at?: string;
}

export interface ModeResourcesRow {
  almas: number | string;
  energia: number | string;
  sangue: number | string;
  cristais: number | string;
  ossos: number | string;
  po_osso?: number | string;
  diamante: number | string;
}

export interface ModeStateProjection {
  gameSave?: {
    snapshot?: unknown;
  };
  registry: ModeRegistryRow[];
  rulesets: ModeRulesetRow[];
  progress: ModeProgressRow | null;
  sessions: ModeSessionRow[];
  claims: ModeRewardClaimRow[];
  resources: ModeResourcesRow | null;
  serverTime: Date;
}

export interface OpenworldCompletionResult {
  session_id: string;
  expected_revision: number;
  ruleset_id: string;
  ruleset_version: number;
}

export interface OpenworldSessionEvent {
  session_id: string;
  mode_id: string;
  slice_id: string;
  event_type: string;
  expected_revision: number;
  event_payload: Record<string, unknown>;
}

const OPENWORLD_LOCAL_ITEM_IDS = new Set(
  arrayValue(OPENWORLD_RULESET_DEFINITION.items)
    .map((item) => stringValue(objectValue(item).item_id, ""))
    .filter((itemId) => itemId !== ""),
);

const OPENWORLD_EVENT_TYPES = new Set([
  "move_heartbeat",
  "collect_start",
  "collect_cancel",
  "collect_complete",
  "collect_batch",
  "deposit_all",
  "craft",
  "guidance_update",
  "complete_requested",
  "abandon_requested",
]);

export function modeStatePayload(
  state: ModeStateProjection,
): Record<string, unknown> {
  const activeSession = state.sessions.find(isActiveSession) ?? null;
  const activeSessionPayload = activeSession === null ? null : sessionPayload(activeSession);
  return {
    ok: true,
    schema_version: MODE_PLATFORM_SCHEMA_VERSION,
    modes: state.registry.map((row) => ({
      mode_id: row.mode_id,
      display_name: row.display_name,
      status: row.status,
      release_channel: row.release_channel,
      default_slice_id: row.default_slice_id,
      active_ruleset_id: row.active_ruleset_id,
      active_ruleset_version: numberValue(row.active_ruleset_version, 1),
      metadata: objectValue(row.metadata),
    })),
    rulesets: state.rulesets.map((row) => ({
      ruleset_id: row.ruleset_id,
      ruleset_version: numberValue(row.ruleset_version, 1),
      mode_id: row.mode_id,
      slice_id: row.slice_id,
      status: row.status,
      release_channel: row.release_channel,
      reward_limits: objectValue(row.reward_limits),
      result_limits: objectValue(row.result_limits),
      ruleset_payload: objectValue(row.ruleset_payload),
    })),
    progress: progressPayload(state.progress),
    sessions: state.sessions.map(sessionPayload),
    active_session: activeSessionPayload,
    guidance: openworldGuidancePayload(state.gameSave?.snapshot, activeSessionPayload),
    rewards: state.claims.map(rewardClaimPayload),
    resources: resourcePayload(state.resources),
    server_time: state.serverTime.toISOString(),
  };
}

export function modeRegistryPayload(
  registry: ModeRegistryRow[],
  rulesets: ModeRulesetRow[],
  serverTime: Date,
): Record<string, unknown> {
  return {
    ok: true,
    schema_version: MODE_PLATFORM_SCHEMA_VERSION,
    modes: registry.map((row) => ({
      mode_id: row.mode_id,
      display_name: row.display_name,
      status: row.status,
      release_channel: row.release_channel,
      default_slice_id: row.default_slice_id,
      active_ruleset_id: row.active_ruleset_id,
      active_ruleset_version: numberValue(row.active_ruleset_version, 1),
      metadata: objectValue(row.metadata),
    })),
    rulesets: rulesets.map((row) => ({
      ruleset_id: row.ruleset_id,
      ruleset_version: numberValue(row.ruleset_version, 1),
      mode_id: row.mode_id,
      slice_id: row.slice_id,
      status: row.status,
      release_channel: row.release_channel,
      reward_limits: objectValue(row.reward_limits),
      result_limits: objectValue(row.result_limits),
      ruleset_payload: objectValue(row.ruleset_payload),
    })),
    server_time: serverTime.toISOString(),
  };
}

export function modeEventAckPayload(value: unknown): Record<string, unknown> {
  const payload = objectValue(value);
  const event = objectValue(payload.event);
  const session = objectValue(payload.session);
  const snapshot = objectValue(session.snapshot_payload);
  const snapshotPatch = openworldEventSnapshotPatch(snapshot);
  const sanitizedSession = {
    ...session,
    snapshot_payload: openworldEventAckSnapshot(snapshot),
  };
  return {
    ...payload,
    ok: true,
    type: "mode_event_ack",
    schema_version: MODE_PLATFORM_SCHEMA_VERSION,
    session: sanitizedSession,
    mode_id: stringValue(session.mode_id, OPENWORLD_MODE_ID),
    slice_id: stringValue(session.slice_id, OPENWORLD_SLICE_ID),
    session_id: stringValue(session.id, ""),
    event_type: stringValue(event.event_type, ""),
    request_id: stringValue(payload.request_id, ""),
    request_hash: stringValue(payload.request_hash, ""),
    expected_revision: Math.floor(numberValue(event.expected_revision, -1)),
    revision_after: Math.floor(
      numberValue(event.revision_after, numberValue(session.snapshot_revision, 0)),
    ),
    applied: true,
    resync_required: false,
    snapshot_patch: snapshotPatch,
    authoritative_fields: Object.keys(snapshotPatch).sort(),
    user_message: stringValue(event.message, stringValue(snapshot.last_message, "")),
    visual_authority: {
      player_position: "client_during_active_play",
      active_collection: "client_until_resume_or_resync",
    },
  };
}

export function completionResultFromBody(
  body: Record<string, unknown>,
): OpenworldCompletionResult | null {
  const source = isObject(body.result) ? body.result : body;
  const sessionId = stringValue(source.session_id, "");
  const rulesetId = stringValue(source.ruleset_id, "");
  const rulesetVersion = numberValue(source.ruleset_version, 0);
  const expectedRevision = numberValue(source.expected_revision, -1);
  if (
    sessionId === "" ||
    rulesetId !== OPENWORLD_RULESET_ID ||
    rulesetVersion !== OPENWORLD_RULESET_VERSION ||
    expectedRevision < 0
  ) {
    return null;
  }
  return {
    session_id: sessionId,
    expected_revision: Math.floor(expectedRevision),
    ruleset_id: rulesetId,
    ruleset_version: rulesetVersion,
  };
}

export function sessionEventFromBody(
  body: Record<string, unknown>,
): OpenworldSessionEvent | null {
  const sessionId = stringValue(body.session_id, "");
  const modeId = stringValue(body.mode_id, OPENWORLD_MODE_ID);
  const sliceId = stringValue(body.slice_id, OPENWORLD_SLICE_ID);
  const eventType = stringValue(body.event_type, "");
  const expectedRevision = numberValue(body.expected_revision, -1);
  const eventPayload = objectValue(body.event_payload);
  if (
    sessionId === "" ||
    modeId !== OPENWORLD_MODE_ID ||
    sliceId !== OPENWORLD_SLICE_ID ||
    !OPENWORLD_EVENT_TYPES.has(eventType) ||
    expectedRevision < 0
  ) {
    return null;
  }
  return {
    session_id: sessionId,
    mode_id: modeId,
    slice_id: sliceId,
    event_type: eventType,
    expected_revision: Math.floor(expectedRevision),
    event_payload: eventPayload,
  };
}

export function normalizeDepositedItems(value: unknown): Record<string, number> | null {
  if (!isObject(value)) return {};
  const result: Record<string, number> = {};
  for (const [key, rawQuantity] of Object.entries(value)) {
    if (!OPENWORLD_LOCAL_ITEM_IDS.has(key)) return null;
    const quantity = numberValue(rawQuantity, Number.NaN);
    if (!Number.isFinite(quantity) || quantity < 0 || quantity > 999) return null;
    if (quantity > 0) {
      result[key] = Math.floor(quantity);
    }
  }
  return result;
}

export function canonicalCompletionPayload(
  result: OpenworldCompletionResult,
): Record<string, unknown> {
  return {
    session_id: result.session_id,
    mode_id: OPENWORLD_MODE_ID,
    slice_id: OPENWORLD_SLICE_ID,
    ruleset_id: result.ruleset_id,
    ruleset_version: result.ruleset_version,
    expected_revision: result.expected_revision,
  };
}

function progressPayload(row: ModeProgressRow | null): Record<string, unknown> {
  if (row === null) {
    return {
      mode_id: OPENWORLD_MODE_ID,
      local_schema_version: "openworld_forest_snapshot_v1",
      progress_payload: {},
      totals_payload: {},
      last_session_id: null,
      updated_at: null,
    };
  }
  return {
    mode_id: row.mode_id,
    local_schema_version: row.local_schema_version,
    progress_payload: objectValue(row.progress_payload),
    totals_payload: objectValue(row.totals_payload),
    last_session_id: row.last_session_id ?? null,
    updated_at: row.updated_at ?? null,
  };
}

function sessionPayload(row: ModeSessionRow): Record<string, unknown> {
  return {
    id: row.id,
    mode_id: row.mode_id,
    slice_id: row.slice_id,
    ruleset_id: row.ruleset_id,
    ruleset_version: numberValue(row.ruleset_version, 1),
    status: row.status,
    session_seconds: nullableNumber(row.session_seconds),
    activity_score: nullableNumber(row.activity_score),
    deposited_items: objectValue(row.deposited_items),
    result_payload: objectValue(row.result_payload),
    reward_payload: objectValue(row.reward_payload),
    started_at: row.started_at ?? null,
    completed_at: row.completed_at ?? null,
    expires_at: row.expires_at ?? null,
    abandoned_at: row.abandoned_at ?? null,
    invalidated_at: row.invalidated_at ?? null,
    invalidated_reason: row.invalidated_reason ?? "",
    snapshot_payload: objectValue(row.snapshot_payload),
    snapshot_revision: nullableNumber(row.snapshot_revision) ?? 0,
    last_event_at: row.last_event_at ?? null,
  };
}

function openworldEventSnapshotPatch(snapshot: Record<string, unknown>): Record<string, unknown> {
  const result: Record<string, unknown> = {};
  const allowedFields = [
    "pocket",
    "chest",
    "upgrades",
    "collected_nodes",
    "guidance",
    "reward_payload",
    "session_seconds",
    "activity_score",
    "capacity",
    "pocket_weight",
    "current_speed",
    "last_message",
  ];
  for (const field of allowedFields) {
    if (field in snapshot) {
      result[field] = snapshot[field];
    }
  }
  return result;
}

function openworldEventAckSnapshot(snapshot: Record<string, unknown>): Record<string, unknown> {
  const result = { ...snapshot };
  delete result.player_position;
  delete result.active_collection;
  return result;
}

function openworldGuidancePayload(
  saveSnapshot: unknown,
  activeSessionPayload: Record<string, unknown> | null,
): Record<string, unknown> {
  const activeSnapshot = objectValue(activeSessionPayload?.snapshot_payload);
  const activeGuidance = objectValue(activeSnapshot.guidance);
  if (Object.keys(activeGuidance).length > 0) {
    return normalizeGuidance(activeGuidance);
  }
  const saveGuidance =
    objectValue(objectValue(objectValue(saveSnapshot).openworld).forest).guidance;
  return normalizeGuidance(objectValue(saveGuidance));
}

function normalizeGuidance(value: Record<string, unknown>): Record<string, unknown> {
  const completedSteps = arrayValue(value.completed_steps)
    .map((step) => stringValue(step, ""))
    .filter((step) => step !== "");
  return {
    version: 1,
    current_step: stringValue(value.current_step, ""),
    completed_steps: Array.from(new Set(completedSteps)).slice(0, 50),
    dismissed: value.dismissed === true,
    last_seen_at: typeof value.last_seen_at === "string" && value.last_seen_at.trim() !== ""
      ? value.last_seen_at.trim()
      : null,
  };
}

function isActiveSession(row: ModeSessionRow): boolean {
  if (row.status !== "started") return false;
  if (row.expires_at === null || row.expires_at === undefined) return true;
  return new Date(row.expires_at).getTime() > Date.now();
}

function rewardClaimPayload(row: ModeRewardClaimRow): Record<string, unknown> {
  return {
    id: row.id,
    mode_id: row.mode_id,
    session_id: row.session_id,
    period_key: row.period_key,
    reward_payload: objectValue(row.reward_payload),
    resource_delta: objectValue(row.resource_delta),
    xp_delta: numberValue(row.xp_delta, 0),
    created_at: row.created_at ?? null,
  };
}

function resourcePayload(row: ModeResourcesRow | null): Record<string, number> {
  return {
    almas: numberValue(row?.almas, 0),
    energia: numberValue(row?.energia, 0),
    sangue: numberValue(row?.sangue, 0),
    cristais: numberValue(row?.cristais, 0),
    ossos: numberValue(row?.ossos, 0),
    po_osso: numberValue(row?.po_osso, 0),
    diamante: numberValue(row?.diamante, 0),
  };
}

function sortRecord(record: Record<string, number>): Record<string, number> {
  const result: Record<string, number> = {};
  for (const key of Object.keys(record).sort()) {
    result[key] = record[key];
  }
  return result;
}

function objectValue(value: unknown): Record<string, unknown> {
  return isObject(value) ? value : {};
}

function arrayValue(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function nullableNumber(value: unknown): number | null {
  if (value === null || value === undefined) return null;
  return numberValue(value, 0);
}

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value.trim() !== "" ? value.trim() : fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
