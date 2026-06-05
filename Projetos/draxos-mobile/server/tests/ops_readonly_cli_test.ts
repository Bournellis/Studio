import {
  assertNoServiceCredential,
  type OpsConfig,
  parseOpsArgs,
  runOpsReadOnly,
} from "../../tools/ops_readonly.ts";

Deno.test("ops read-only CLI rejects service-role-like credentials", () => {
  assertThrows(
    () => assertNoServiceCredential("sb_secret_abc", "publishable key"),
    "publishable key must be publishable/user scoped",
  );
  assertThrows(
    () =>
      assertNoServiceCredential(
        jwtWithRole("service_role"),
        "ops access token",
      ),
    "ops access token JWT role is service_role",
  );
});

Deno.test("ops read-only CLI parses all targets and env fallbacks", () => {
  const config = parseOpsArgs(["--target", "all", "--format=json"], {
    SUPABASE_URL: "https://example.supabase.co",
    SUPABASE_PUBLISHABLE_KEY: "sb_publishable_abc",
    DRAXOS_OPS_ACCESS_TOKEN: jwtWithRole("authenticated"),
  });
  assertEq(
    config.targets.join(","),
    "manifest,modes,status,audit,rewards,sessions",
  );
  assertEq(config.format, "json");
  assertEq(config.saveType, "normal");
});

Deno.test("ops read-only CLI uses GET-only summaries and handles audit RLS block", async () => {
  const calls: string[] = [];
  const config: OpsConfig = {
    supabaseUrl: "https://example.supabase.co",
    publishableKey: "sb_publishable_abc",
    accessToken: jwtWithRole("authenticated"),
    saveType: "normal",
    modeId: "openworld",
    targets: ["manifest", "modes", "status", "sessions", "rewards", "audit"],
    limit: 20,
    format: "json",
  };

  const summary = await runOpsReadOnly(config, async (input, init) => {
    const url = String(input);
    calls.push(`${init?.method ?? "GET"} ${url}`);
    assertEq(init?.method ?? "GET", "GET");
    if (url.includes("/release/manifest")) {
      return jsonResponse({
        schema_version: "internal_alpha_manifest_v1",
        channel: "internal_alpha",
        latest_version: "0.0.2-alpha.0",
        latest_version_code: 2,
        minimum_supported_version_code: 2,
        released_at: "2026-06-01T00:00:00Z",
        requires_save_reset: false,
        portal_url: "https://preview/portal/index.html",
        known_issues: [
          "APK uses debug_fallback until release keystore is configured.",
        ],
        artifacts: { android: {}, pc_windows: {}, web: {} },
      });
    }
    if (url.includes("/modes/registry")) {
      return jsonResponse({
        ok: true,
        schema_version: "mode_platform_v1",
        modes: [{
          mode_id: "openworld",
          status: "internal_alpha",
          release_channel: "internal_alpha",
        }],
        rulesets: [{ ruleset_id: "openworld_forest_ruleset_v0" }],
      });
    }
    if (url.includes("/modes/state")) {
      return jsonResponse({
        ok: true,
        modes: [{ mode_id: "openworld", status: "internal_alpha" }],
        progress: {
          updated_at: "2026-06-01T00:00:00Z",
          totals_payload: { sessions: 1 },
        },
        resources: { energia: 12 },
        sessions: [{
          id: "session-1",
          status: "completed",
          started_at: "2026-06-01T00:00:00Z",
        }],
        rewards: [{
          id: "reward-1",
          session_id: "session-1",
          period_key: "2026-06-01",
          resource_delta: { energia: 12 },
          xp_delta: 8,
          created_at: "2026-06-01T00:01:00Z",
        }],
      });
    }
    if (url.includes("/modes/admin/me")) {
      return jsonResponse({ ok: true, admin: { role: "ops" } });
    }
    if (url.includes("/admin_audit_log")) {
      return jsonResponse({
        error: { code: "42501", message: "permission denied" },
      }, 403);
    }
    return jsonResponse(
      { error: { code: "NOT_FOUND", message: "not found" } },
      404,
    );
  });

  assertEq(summary.service_role_allowed, false);
  assert(
    calls.every((call) => call.startsWith("GET ")),
    "ops calls must all use GET",
  );
  const manifest = summary.summaries.manifest as Record<string, unknown>;
  assertEq(manifest.android_known_issue_debug_fallback, true);
  const audit = summary.summaries.audit as Record<string, unknown>;
  assertEq(audit.status, "blocked_or_empty");
});

function jsonResponse(payload: unknown, status = 200): Response {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { "content-type": "application/json" },
  });
}

function jwtWithRole(role: string): string {
  const header = b64url(JSON.stringify({ alg: "none", typ: "JWT" }));
  const payload = b64url(JSON.stringify({
    sub: "00000000-0000-4000-8000-000000000001",
    role,
  }));
  return `${header}.${payload}.signature`;
}

function b64url(value: string): string {
  return btoa(value).replaceAll("+", "-").replaceAll("/", "_").replaceAll(
    "=",
    "",
  );
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

function assertEq(actual: unknown, expected: unknown): void {
  if (actual !== expected) {
    throw new Error(
      `Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}

function assertThrows(fn: () => void, expectedMessage: string): void {
  try {
    fn();
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (!message.includes(expectedMessage)) {
      throw new Error(
        `Expected error to include ${expectedMessage}, got ${message}`,
      );
    }
    return;
  }
  throw new Error("Expected function to throw");
}
