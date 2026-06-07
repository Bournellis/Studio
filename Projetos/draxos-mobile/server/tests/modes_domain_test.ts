import {
  canonicalCompletionPayload,
  completionResultFromBody,
  modeStatePayload,
  modeCheckpointAckPayload,
  modeEventAckPayload,
  normalizeDepositedItems,
  OPENWORLD_MODE_ID,
  OPENWORLD_RULESET_ID,
  OPENWORLD_RULESET_VERSION,
  OPENWORLD_SLICE_ID,
  sessionCheckpointFromBody,
  sessionEventFromBody,
} from "../functions/_shared/mode_domain.ts";

Deno.test("openworld completion payload accepts only the v1 ruleset and expected revision", () => {
  const result = completionResultFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    expected_revision: 4,
    deposited_items: { galho: 2, dragon_gold: 99 },
    ruleset_id: OPENWORLD_RULESET_ID,
    ruleset_version: OPENWORLD_RULESET_VERSION,
  });

  assert(result !== null, "valid openworld result should parse");
  assertEq(result.ruleset_id, OPENWORLD_RULESET_ID, "ruleset should be canonical");
  assertEq(result.expected_revision, 4, "complete should preserve the snapshot revision gate");
});

Deno.test("openworld deposited items reject unknown resources and excessive quantities", () => {
  assertEq(normalizeDepositedItems({ galho: 1 })?.galho, 1, "known item should pass");
  assertEq(normalizeDepositedItems({ dragon_gold: 1 }), null, "unknown item should fail");
  assertEq(normalizeDepositedItems({ galho: 1000 }), null, "over-limit quantity should fail");
  assertEq(normalizeDepositedItems({ galho: -1 }), null, "negative quantity should fail");
});

Deno.test("openworld canonical completion payload excludes client-side rewards", () => {
  const result = completionResultFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    expected_revision: 7,
    deposited_items: { pedra: 1, galho: 2, dragon_gold: 900 },
    activity_score: 999,
    ruleset_id: OPENWORLD_RULESET_ID,
    ruleset_version: OPENWORLD_RULESET_VERSION,
  });
  assert(result !== null, "valid result should parse before canonicalization");

  const canonical = canonicalCompletionPayload(result);
  assertEq(canonical.mode_id, OPENWORLD_MODE_ID, "canonical payload should include mode");
  assertEq(canonical.slice_id, OPENWORLD_SLICE_ID, "canonical payload should include slice");
  assertEq(canonical.expected_revision, 7, "canonical payload should include revision");
  assertEq(
    "deposited_items" in canonical,
    false,
    "client deposited_items should not affect rewards",
  );
  assertEq("activity_score" in canonical, false, "client activity_score should not affect rewards");
});

Deno.test("openworld session event payload validates event type and revision", () => {
  const event = sessionEventFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    mode_id: OPENWORLD_MODE_ID,
    slice_id: OPENWORLD_SLICE_ID,
    event_type: "collect_complete",
    expected_revision: 3,
    event_payload: { node_id: "node_galho_01", item_id: "galho" },
  });
  assert(event !== null, "valid event should parse");
  assertEq(event.event_type, "collect_complete", "event type should be preserved");
  assertEq(event.expected_revision, 3, "event should preserve the revision gate");
  assertEq(
    sessionEventFromBody({
      session_id: "00000000-0000-4000-8000-000000000101",
      event_type: "spawn_dragon",
      expected_revision: 3,
      event_payload: {},
    }),
    null,
    "unknown events should be rejected",
  );
});

Deno.test("openworld session event payload accepts batched collection", () => {
  const event = sessionEventFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    mode_id: OPENWORLD_MODE_ID,
    slice_id: OPENWORLD_SLICE_ID,
    event_type: "collect_batch",
    expected_revision: 3,
    event_payload: {
      nodes: [
        { node_id: "node_galho_01", item_id: "galho", session_seconds: 42 },
        { node_id: "node_folha_01", item_id: "folha", session_seconds: 43 },
      ],
      position: { x: 220, y: 250 },
      session_seconds: 43,
    },
  });

  assert(event !== null, "collect_batch event should parse");
  assertEq(event.event_type, "collect_batch", "batched event type should be preserved");
  assertEq(event.expected_revision, 3, "batched event should preserve the revision gate");
});

Deno.test("openworld checkpoint payload validates compact offline-first snapshot", () => {
  const checkpoint = sessionCheckpointFromBody({
    request_id: "00000000-0000-4000-8000-000000000104",
    session_id: "00000000-0000-4000-8000-000000000101",
    mode_id: OPENWORLD_MODE_ID,
    slice_id: OPENWORLD_SLICE_ID,
    ruleset_id: OPENWORLD_RULESET_ID,
    ruleset_version: OPENWORLD_RULESET_VERSION,
    checkpoint_id: "checkpoint-001",
    base_revision: 4,
    client_sequence: 7,
    snapshot_payload: {
      ruleset_id: OPENWORLD_RULESET_ID,
      ruleset_version: OPENWORLD_RULESET_VERSION,
      pocket: { galho: 1 },
      chest: { folha: 2 },
      collected_nodes: { node_galho_01: true, node_folha_01: true },
      upgrades: {},
    },
    client_summary: { collected_count: 2 },
  });

  assert(checkpoint !== null, "valid checkpoint should parse");
  assertEq(checkpoint.checkpoint_id, "checkpoint-001", "checkpoint id should be preserved");
  assertEq(checkpoint.base_revision, 4, "base revision should be preserved");
  assertEq(checkpoint.client_sequence, 7, "client sequence should be preserved");
  assertEq(
    sessionCheckpointFromBody({
      session_id: "00000000-0000-4000-8000-000000000101",
      checkpoint_id: "checkpoint-002",
      base_revision: 0,
      client_sequence: 1,
      ruleset_id: OPENWORLD_RULESET_ID,
      ruleset_version: OPENWORLD_RULESET_VERSION,
      snapshot_payload: {},
    }),
    null,
    "empty checkpoint snapshots should be rejected",
  );
});

Deno.test("openworld mode state does not resume expired started sessions", () => {
  const now = new Date();
  const payload = modeStatePayload({
    gameSave: {},
    registry: [],
    rulesets: [],
    progress: null,
    sessions: [{
      id: "00000000-0000-4000-8000-000000000201",
      game_save_id: "00000000-0000-4000-8000-000000000301",
      mode_id: OPENWORLD_MODE_ID,
      slice_id: OPENWORLD_SLICE_ID,
      ruleset_id: OPENWORLD_RULESET_ID,
      ruleset_version: OPENWORLD_RULESET_VERSION,
      status: "started",
      server_seed: "seed-expired",
      session_seconds: 72,
      activity_score: 3,
      deposited_items: {},
      result_payload: {},
      reward_payload: {},
      started_at: new Date(now.getTime() - 7200_000).toISOString(),
      expires_at: new Date(now.getTime() - 1000).toISOString(),
      snapshot_payload: { collected_nodes: { node_galho_01: true } },
      snapshot_revision: 7,
      last_event_at: null,
    }],
    claims: [],
    resources: null,
    serverTime: now,
  });
  const sessions = payload.sessions as Record<string, unknown>[];

  assertEq(payload.active_session, null, "expired session should not be projected as active");
  assertEq(sessions.length, 1, "history can still include expired sessions");
  assertEq(sessions[0].status, "expired", "expired started session should be labeled explicitly");
});

Deno.test("openworld checkpoint ACK exposes metadata without visual rollback fields", () => {
  const ack = modeCheckpointAckPayload({
    request_id: "00000000-0000-4000-8000-000000000105",
    request_hash: "sha256:test-checkpoint",
    session_id: "00000000-0000-4000-8000-000000000101",
    checkpoint_id: "checkpoint-001",
    accepted_checkpoint_id: "checkpoint-001",
    snapshot_revision: 8,
    complete_ready: true,
    accepted_snapshot_summary: { collected_count: 2 },
    session: {
      id: "00000000-0000-4000-8000-000000000101",
      snapshot_payload: {
        player_position: { x: 220, y: 330 },
        active_collection: { node_id: "node_galho_01" },
        checkpoint: { accepted_checkpoint_id: "checkpoint-001" },
        revision: 8,
        session_seconds: 42,
        activity_score: 12,
      },
    },
  });
  const session = ack.session as Record<string, unknown>;
  const snapshot = session.snapshot_payload as Record<string, unknown>;
  const visualAuthority = ack.visual_authority as Record<string, unknown>;

  assertEq(ack.type, "mode_checkpoint_ack", "checkpoint ACK should identify metadata-only semantics");
  assertEq(ack.complete_ready, true, "accepted checkpoint should allow completion");
  assertEq("player_position" in snapshot, false, "checkpoint ACK must not carry player_position");
  assertEq("active_collection" in snapshot, false, "checkpoint ACK must not clear active collection");
  assertEq(
    visualAuthority.checkpoint_ack,
    "metadata_only_during_active_play",
    "checkpoint ACK should not own active visual state",
  );
});

Deno.test("openworld guidance update event validates lightweight guidance state", () => {
  const event = sessionEventFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    mode_id: OPENWORLD_MODE_ID,
    slice_id: OPENWORLD_SLICE_ID,
    event_type: "guidance_update",
    expected_revision: 5,
    event_payload: {
      guidance: {
        version: 1,
        current_step: "depositar_bau",
        completed_steps: ["coletar_galho"],
        dismissed: false,
        last_seen_at: "2026-06-04T12:00:00Z",
      },
    },
  });

  assert(event !== null, "guidance_update should parse as an Openworld event");
  assertEq(event.event_type, "guidance_update", "guidance update event type should be preserved");
  assertEq(event.expected_revision, 5, "guidance update should preserve the revision gate");
});

Deno.test("openworld mode event ACK exposes patch authority without visual rollback fields", () => {
  const ack = modeEventAckPayload({
    request_id: "00000000-0000-4000-8000-000000000102",
    request_hash: "sha256:test",
    event: {
      event_type: "collect_complete",
      expected_revision: 3,
      revision_after: 4,
      message: "+1 Galho no bolso.",
    },
    session: {
      id: "00000000-0000-4000-8000-000000000101",
      mode_id: OPENWORLD_MODE_ID,
      slice_id: OPENWORLD_SLICE_ID,
      snapshot_revision: 4,
      snapshot_payload: {
        player_position: { x: 220, y: 330 },
        active_collection: { item_id: "galho" },
        pocket: { galho: 1 },
        chest: {},
        upgrades: {},
        collected_nodes: { node_galho_01: true },
        last_message: "+1 Galho no bolso.",
      },
    },
  });
  const patch = ack.snapshot_patch as Record<string, unknown>;
  const ackSession = ack.session as Record<string, unknown>;
  const ackSnapshot = ackSession.snapshot_payload as Record<string, unknown>;
  const visualAuthority = ack.visual_authority as Record<string, unknown>;
  assertEq(ack.type, "mode_event_ack", "event response should identify ACK semantics");
  assertEq(ack.revision_after, 4, "ACK should expose revision_after at top level");
  assertEq(
    (patch.pocket as Record<string, unknown>).galho,
    1,
    "ACK patch should include authoritative pocket",
  );
  assertEq("player_position" in patch, false, "ACK patch must not carry player_position");
  assertEq("active_collection" in patch, false, "ACK patch must not clear active collection");
  assertEq(
    "player_position" in ackSnapshot,
    false,
    "ACK session snapshot must not carry player_position",
  );
  assertEq(
    "active_collection" in ackSnapshot,
    false,
    "ACK session snapshot must not carry active_collection",
  );
  assertEq(
    (ackSnapshot.pocket as Record<string, unknown>).galho,
    1,
    "ACK session snapshot should preserve authoritative non-visual state",
  );
  assertEq(
    visualAuthority.player_position,
    "client_during_active_play",
    "position remains client-authoritative while the mode is active",
  );
});

Deno.test("openworld mode event ACK includes guidance in authoritative patches", () => {
  const ack = modeEventAckPayload({
    request_id: "00000000-0000-4000-8000-000000000103",
    request_hash: "sha256:test-guidance",
    event: {
      event_type: "guidance_update",
      expected_revision: 4,
      revision_after: 5,
      message: "Orientacao atualizada.",
    },
    session: {
      id: "00000000-0000-4000-8000-000000000101",
      mode_id: OPENWORLD_MODE_ID,
      slice_id: OPENWORLD_SLICE_ID,
      snapshot_revision: 5,
      snapshot_payload: {
        guidance: {
          version: 1,
          current_step: "depositar_bau",
          completed_steps: ["coletar_galho"],
          dismissed: false,
          last_seen_at: "2026-06-04T12:00:00Z",
        },
      },
    },
  });
  const patch = ack.snapshot_patch as Record<string, unknown>;
  const guidance = patch.guidance as Record<string, unknown>;

  assertEq(ack.event_type, "guidance_update", "ACK should expose the guidance event type");
  assertEq(guidance.current_step, "depositar_bau", "ACK patch should include guidance state");
  assert(
    (ack.authoritative_fields as string[]).includes("guidance"),
    "guidance should be marked as authoritative in the event patch",
  );
});

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Actual=${String(actual)} Expected=${String(expected)}`);
  }
}
