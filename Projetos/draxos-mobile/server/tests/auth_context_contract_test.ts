const SERVER_AUTH_HELPER = "server/functions/_shared/auth_context.ts";
const SUPABASE_AUTH_HELPER = "supabase/functions/_shared/auth_context.ts";
const MIGRATED_ENDPOINTS = [
  "server/functions/account/index.ts",
  "server/functions/progression-lab/index.ts",
  "server/functions/telemetry/index.ts",
] as const;

Deno.test("shared auth context helper verifies bearer tokens through Supabase Auth", async () => {
  const serverHelper = await Deno.readTextFile(SERVER_AUTH_HELPER);
  const supabaseHelper = await Deno.readTextFile(SUPABASE_AUTH_HELPER);
  assertEq(
    normalize(serverHelper),
    normalize(supabaseHelper),
    "auth context helper should be mirrored",
  );

  for (const needle of [
    "export async function verifiedAuthContext",
    "/auth/v1/user",
    "Bearer token could not be verified by Supabase Auth.",
    "Bearer token subject mismatch.",
    "SAVE_TYPE_HEADER",
    "requireExplicitSaveType",
    "requireEmailAccount",
    "AUTH_REQUIRES_EMAIL",
    "emailAccountRequiredMessage",
    "serviceRoleKey",
  ]) {
    assertIncludes(serverHelper, needle, `${SERVER_AUTH_HELPER} should contain ${needle}`);
  }
});

Deno.test("migrated endpoints use verified auth context", async () => {
  for (const endpoint of MIGRATED_ENDPOINTS) {
    const source = await Deno.readTextFile(endpoint);
    assertIncludes(
      source,
      'verifiedAuthContext(request, {',
      `${endpoint} should verify bearer tokens with shared auth context`,
    );
    assertIncludes(
      source,
      "../_shared/auth_context.ts",
      `${endpoint} should import shared auth context`,
    );
    for (const forbidden of [
      "function decodeAuthContext",
      "function decodeJwtPayload",
      "interface JwtPayload",
    ]) {
      assertNotIncludes(
        source,
        forbidden,
        `${endpoint} should not keep local auth decoding after migration`,
      );
    }
  }
});

function normalize(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function assertIncludes(haystack: string, needle: string, message: string): void {
  if (!haystack.includes(needle)) {
    throw new Error(`${message}. Missing: ${needle}`);
  }
}

function assertNotIncludes(haystack: string, needle: string, message: string): void {
  if (haystack.includes(needle)) {
    throw new Error(`${message}. Forbidden: ${needle}`);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${JSON.stringify(actual)}`,
    );
  }
}
