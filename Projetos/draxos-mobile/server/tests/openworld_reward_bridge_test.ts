import {
  canonicalCompletionPayload,
  completionResultFromBody,
  OPENWORLD_MODE_ID,
  OPENWORLD_RULESET_ID,
  OPENWORLD_RULESET_VERSION,
} from "../functions/_shared/mode_domain.ts";

Deno.test("openworld reward bridge canonicalizes only Openworld Forest results", () => {
  const result = completionResultFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    session_seconds: 37.7,
    activity_score: 44.2,
    deposited_items: { folha: 3, ossos_preview: 1 },
    ruleset_id: OPENWORLD_RULESET_ID,
    ruleset_version: OPENWORLD_RULESET_VERSION,
  });
  if (result === null) throw new Error("valid Openworld completion should parse");
  const canonical = canonicalCompletionPayload(result);
  assertEq(canonical.mode_id, OPENWORLD_MODE_ID, "canonical mode should be openworld");
  assertEq(canonical.ruleset_id, OPENWORLD_RULESET_ID, "canonical ruleset should match");
  assertEq(JSON.stringify(canonical.deposited_items), '{"folha":3,"ossos_preview":1}', "items should be sorted");
});

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Expected ${String(expected)}, got ${String(actual)}`);
  }
}
