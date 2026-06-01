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
  assertEq(
    JSON.stringify(canonical.deposited_items),
    '{"folha":3,"ossos_preview":1}',
    "items should be sorted",
  );
});

Deno.test("openworld reward bridge rejects unapproved local items", () => {
  const result = completionResultFromBody({
    session_id: "00000000-0000-4000-8000-000000000101",
    session_seconds: 37,
    activity_score: 44,
    deposited_items: { folha: 3, unknown_item: 1 },
    ruleset_id: OPENWORLD_RULESET_ID,
    ruleset_version: OPENWORLD_RULESET_VERSION,
  });
  assertEq(result, null, "unknown local items should not enter the reward bridge");
});

Deno.test("reward bridge contract documents idempotency and admin boundaries", async () => {
  const contract = await Deno.readTextFile(projectFile("docs/contracts/reward-bridge-v1.md"));
  for (
    const fragment of [
      "request_id",
      "request_hash",
      "IDEMPOTENCY_HASH_MISMATCH",
      "mode_reward_claims",
      "resource_transactions",
      "progression_lab",
      "admin_set_mode_status_v1",
      "admin_expire_mode_session_v1",
      "admin_invalidate_mode_session_v1",
    ]
  ) {
    if (!contract.includes(fragment)) {
      throw new Error(`reward bridge contract should include ${fragment}`);
    }
  }
});

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `Projetos/draxos-mobile/${relativePath}`;
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Expected ${String(expected)}, got ${String(actual)}`);
  }
}
