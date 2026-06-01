import {
  canonicalCompletionPayload,
  completionResultFromBody,
  normalizeDepositedItems,
  RPGSUAVE_MODE_ID,
  RPGSUAVE_RULESET_ID,
  RPGSUAVE_RULESET_VERSION,
  RPGSUAVE_SLICE_ID,
} from "../functions/_shared/minigame_domain.ts";

Deno.test("rpgsuave completion payload accepts only the v0 ruleset and local items", () => {
  const result = completionResultFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    session_seconds: 40,
    deposited_items: { galho: 2, ossos_preview: 3 },
    activity_score: 24,
    ruleset_id: RPGSUAVE_RULESET_ID,
    ruleset_version: RPGSUAVE_RULESET_VERSION,
  });

  assert(result !== null, "valid rpgsuave result should parse");
  assertEq(result.ruleset_id, RPGSUAVE_RULESET_ID, "ruleset should be canonical");
  assertEq(result.deposited_items.galho, 2, "deposited items should be normalized");
});

Deno.test("rpgsuave deposited items reject unknown resources and excessive quantities", () => {
  assertEq(normalizeDepositedItems({ galho: 1 })?.galho, 1, "known item should pass");
  assertEq(normalizeDepositedItems({ dragon_gold: 1 }), null, "unknown item should fail");
  assertEq(normalizeDepositedItems({ galho: 1000 }), null, "over-limit quantity should fail");
  assertEq(normalizeDepositedItems({ galho: -1 }), null, "negative quantity should fail");
});

Deno.test("rpgsuave canonical completion payload is sorted and stable", () => {
  const result = completionResultFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    session_seconds: 40.9,
    deposited_items: { pedra: 1, galho: 2 },
    activity_score: 24.9,
    ruleset_id: RPGSUAVE_RULESET_ID,
    ruleset_version: RPGSUAVE_RULESET_VERSION,
  });
  assert(result !== null, "valid result should parse before canonicalization");

  const canonical = canonicalCompletionPayload(result);
  assertEq(canonical.mode_id, RPGSUAVE_MODE_ID, "canonical payload should include mode");
  assertEq(canonical.slice_id, RPGSUAVE_SLICE_ID, "canonical payload should include slice");
  assertEq(canonical.session_seconds, 40, "seconds should be integerized");
  assertEq(canonical.activity_score, 24, "score should be integerized");
  assertEq(
    JSON.stringify(canonical.deposited_items),
    '{"galho":2,"pedra":1}',
    "deposited items should be sorted for request_hash stability",
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
