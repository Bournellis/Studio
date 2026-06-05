const SERVER_AUTH_HELPER = "server/functions/_shared/auth_context.ts";
const SUPABASE_AUTH_HELPER = "supabase/functions/_shared/auth_context.ts";
const MIGRATED_ENDPOINTS = [
  "server/functions/account/index.ts",
  "server/functions/arena/index.ts",
  "server/functions/base/index.ts",
  "server/functions/battle/index.ts",
  "server/functions/build/index.ts",
  "server/functions/competition/index.ts",
  "server/functions/content/index.ts",
  "server/functions/crafting/index.ts",
  "server/functions/lab-runner/index.ts",
  "server/functions/monetization/index.ts",
  "server/functions/modes/mode_handler.ts",
  "server/functions/progression-lab/index.ts",
  "server/functions/release/index.ts",
  "server/functions/social/index.ts",
  "server/functions/telemetry/index.ts",
] as const;

import { decodeBearerSubject } from "../functions/_shared/auth_context.ts";

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

Deno.test("shared auth helper accepts canonical Supabase UUID subjects", () => {
  const subject = "11111111-1111-4111-8111-111111111111";
  const result = decodeBearerSubject(fakeJwt({ sub: subject, is_anonymous: true }));
  if (result.error !== null) {
    throw new Error(`Expected valid UUID subject, got ${result.error.message}`);
  }
  assertEq(result.value.sub, subject, "decoded subject should match");
  assertEq(result.value.isAnonymous, true, "decoded anonymous flag should match");
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

function fakeJwt(payload: Record<string, unknown>): string {
  return [
    encodeBase64Url({ alg: "none", typ: "JWT" }),
    encodeBase64Url(payload),
    "signature",
  ].join(".");
}

function encodeBase64Url(payload: Record<string, unknown>): string {
  return btoa(JSON.stringify(payload)).replaceAll("+", "-").replaceAll("/", "_").replaceAll(
    "=",
    "",
  );
}
