import {
  canonicalCompletionPayload,
  completionResultFromBody,
  modeEventAckPayload,
  normalizeDepositedItems,
  OPENWORLD_MODE_ID,
  OPENWORLD_RULESET_ID,
  OPENWORLD_RULESET_VERSION,
  OPENWORLD_SLICE_ID,
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
  assertEq("deposited_items" in canonical, false, "client deposited_items should not affect rewards");
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
  const visualAuthority = ack.visual_authority as Record<string, unknown>;
  assertEq(ack.type, "mode_event_ack", "event response should identify ACK semantics");
  assertEq(ack.revision_after, 4, "ACK should expose revision_after at top level");
  assertEq((patch.pocket as Record<string, unknown>).galho, 1, "ACK patch should include authoritative pocket");
  assertEq("player_position" in patch, false, "ACK patch must not carry player_position");
  assertEq("active_collection" in patch, false, "ACK patch must not clear active collection");
  assertEq(
    visualAuthority.player_position,
    "client_during_active_play",
    "position remains client-authoritative while the mode is active",
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
