import { stateEnvelope } from "../functions/_shared/response_envelope.ts";

const PROJECT_PREFIX = "Projetos/draxos-mobile";
const SERVER_API_VERSION_PATH = "server/functions/_shared/api_version.ts";
const SUPABASE_API_VERSION_PATH = "supabase/functions/_shared/api_version.ts";
const SERVER_HTTP_PATH = "server/functions/_shared/http.ts";
const SUPABASE_HTTP_PATH = "supabase/functions/_shared/http.ts";
const SERVER_RESPONSE_ENVELOPE_PATH = "server/functions/_shared/response_envelope.ts";
const SUPABASE_RESPONSE_ENVELOPE_PATH = "supabase/functions/_shared/response_envelope.ts";
const EDGE_FUNCTIONS = [
  "account",
  "base",
  "battle",
  "build",
  "crafting",
  "monetization",
  "progression-lab",
  "social",
];

Deno.test("api version helper and cors are mirrored", async () => {
  const serverApiVersion = await readProjectText(SERVER_API_VERSION_PATH);
  const supabaseApiVersion = await readProjectText(SUPABASE_API_VERSION_PATH);
  const serverHttp = await readProjectText(SERVER_HTTP_PATH);
  const supabaseHttp = await readProjectText(SUPABASE_HTTP_PATH);
  const serverEnvelope = await readProjectText(SERVER_RESPONSE_ENVELOPE_PATH);
  const supabaseEnvelope = await readProjectText(SUPABASE_RESPONSE_ENVELOPE_PATH);

  assertEq(
    normalizeNewlines(serverApiVersion),
    normalizeNewlines(supabaseApiVersion),
    "api version helper should mirror between server and supabase",
  );
  assertEq(
    normalizeNewlines(serverHttp),
    normalizeNewlines(supabaseHttp),
    "http helper should mirror between server and supabase",
  );
  assertEq(
    normalizeNewlines(serverEnvelope),
    normalizeNewlines(supabaseEnvelope),
    "response envelope helper should mirror between server and supabase",
  );
  assertIncludes(
    serverApiVersion,
    'DRAXOS_API_VERSION_HEADER = "x-draxos-api-version"',
    "api version helper should define official header",
  );
  assertIncludes(
    serverApiVersion,
    'DRAXOS_API_VERSION = "1"',
    "api version helper should pin v1",
  );
  assertIncludes(
    serverApiVersion,
    "UNSUPPORTED_API_VERSION",
    "api version helper should reject unsupported explicit versions",
  );
  assertIncludes(
    serverHttp,
    "x-draxos-api-version",
    "CORS should allow the API version header",
  );
});

Deno.test("state envelope preserves payload and adds timing metadata", () => {
  const payload = stateEnvelope(
    {
      ok: true,
      save_type: "normal",
      base: { structures: [] },
    },
    {
      surface: "base",
      saveType: "normal",
      schemaVersion: "base_state_v1",
      startedAtMs: performance.now(),
      generatedAt: new Date("2026-06-02T12:00:00.000Z"),
    },
  );

  assertEq(payload.ok, true, "state envelope should preserve ok");
  assertEq(payload.schema_version, "base_state_v1", "state envelope should expose schema version");
  assertEq(payload.api_version, "app_responsiveness_v1", "state envelope should expose API version");
  assertEq(payload.cache.generated_at, "2026-06-02T12:00:00.000Z", "state envelope should expose cache timestamp");
  assertEq(payload.cache.surface, "base", "state envelope should expose surface");
  assertEq(
    String((payload.save as Record<string, unknown>).save_type),
    "normal",
    "state envelope should expose save metadata",
  );
  if (payload.server_timing.duration_ms < 0) {
    throw new Error("state envelope duration should be non-negative");
  }
});

Deno.test("versioned edge functions enforce api version after preflight", async () => {
  for (const functionName of EDGE_FUNCTIONS) {
    for (const root of ["server/functions", "supabase/functions"]) {
      const source = await readProjectText(`${root}/${functionName}/index.ts`);
      assertIncludes(
        source,
        "validateApiVersion",
        `${root}/${functionName} should import the API version guard`,
      );
      assertIncludes(
        source,
        "const apiVersionError = validateApiVersion(request);",
        `${root}/${functionName} should evaluate the API version guard`,
      );
      assertRegex(
        source,
        /if \(request\.method === "OPTIONS"\)[\s\S]+?validateApiVersion\(request\)/,
        `${root}/${functionName} should keep OPTIONS preflight before version enforcement`,
      );
    }
  }
});

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(projectFile(relativePath));
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `${PROJECT_PREFIX}/${relativePath}`;
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(
  haystack: string,
  needle: string,
  message: string,
): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assertRegex(
  haystack: string,
  pattern: RegExp,
  message: string,
): void {
  if (!pattern.test(haystack)) {
    throw new Error(`${message}. Pattern: ${pattern}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
