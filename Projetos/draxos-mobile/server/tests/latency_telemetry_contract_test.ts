const apiContract = await Deno.readTextFile("docs/contracts/api-endpoints.md");
const surfaceRefresh = await Deno.readTextFile("online/session/surface_refresh_slice.gd");
const statusController = await Deno.readTextFile("modes/boot/boot_runtime_status_controller.gd");
const actionDispatcher = await Deno.readTextFile("modes/boot/boot_runtime_action_dispatcher.gd");
const baselineTool = await Deno.readTextFile("tools/measure_latency_baseline.ps1");

Deno.test("latency telemetry contract lists the four client events", () => {
  for (
    const eventType of [
      "request_latency",
      "surface_refresh",
      "surface_cache_rendered",
      "action_latency",
    ]
  ) {
    assertIncludes(apiContract, eventType, `api contract should list ${eventType}`);
  }
});

Deno.test("local latency payloads keep required diagnostic dimensions", () => {
  for (
    const field of [
      '"endpoint"',
      '"method"',
      '"action_id"',
      '"scope_id"',
      '"duration_ms"',
      '"response_code"',
      '"ok"',
      '"fail"',
      '"used_cache"',
      '"rendered_from_cache"',
      '"server_timing"',
    ]
  ) {
    assertIncludes(surfaceRefresh, field, `request latency payload should include ${field}`);
    assertIncludes(statusController, field, `surface telemetry should include ${field}`);
  }

  for (
    const field of [
      'payload["endpoint"]',
      'payload["method"]',
      'payload["scope_id"]',
      'payload["duration_ms"]',
      'payload["response_code"]',
      'payload["ok"]',
      'payload["fail"]',
      'payload["used_cache"]',
      'payload["rendered_from_cache"]',
      'payload["server_timing"]',
    ]
  ) {
    assertIncludes(actionDispatcher, field, `action latency should include ${field}`);
  }
});

Deno.test("latency baseline tool writes before after diagnostics without secrets", () => {
  for (const marker of ["latency_baseline_v1", "build\\diagnostics", "-CompareWith", "access_token_configured"]) {
    assertIncludes(baselineTool, marker, `baseline tool should include ${marker}`);
  }
  assertNotIncludes(
    baselineTool,
    "SUPABASE_SERVICE_ROLE",
    "baseline tool must not use service role credentials",
  );
});

function assertIncludes(text: string, needle: string, message: string): void {
  if (!text.includes(needle)) {
    throw new Error(message);
  }
}

function assertNotIncludes(text: string, needle: string, message: string): void {
  if (text.includes(needle)) {
    throw new Error(message);
  }
}
