import { assert, assertEquals } from "jsr:@std/assert";

const releaseSources = [
  "server/functions/release/index.ts",
  "supabase/functions/release/index.ts",
];

Deno.test("release download validates bearer tokens with Supabase Auth before service-role access", async () => {
  for (const path of releaseSources) {
    const source = await Deno.readTextFile(path);
    assert(
      source.includes("../_shared/auth_context.ts") &&
        source.includes("verifiedAuthContext(request, {"),
      `${path} should delegate download bearer verification to shared auth context`,
    );
    assert(
      source.includes("SUPABASE_PUBLISHABLE_KEY") && source.includes("SUPABASE_ANON_KEY") &&
        source.includes("publishableKey: config.value.publishableKey"),
      `${path} should use publishable/anon key material for Auth user verification`,
    );
    assert(
      source.includes("requireEmailAccount: true"),
      `${path} should require email/password alpha accounts before download access checks`,
    );
    assert(
      source.includes("Internal Alpha downloads require an email/password alpha account."),
      `${path} should expose the release-specific email account error message`,
    );
    assert(
      source.indexOf("const auth = await verifiedAuthContext") <
        source.indexOf("const access = await assertAlphaAccess"),
      `${path} should verify Auth user before querying alpha access with service role`,
    );
    for (const forbidden of [
      "function decodeVerifiedSubject",
      "function decodeJwtPayload",
      "interface JwtPayload",
      "function bearerTokenFromRequest",
      "function fetchAuthUser",
    ]) {
      assert(
        !source.includes(forbidden),
        `${path} should not keep local auth verification helper ${forbidden}`,
      );
    }
  }
});

Deno.test("release manifest code fallback points at the current published package root", async () => {
  for (const path of releaseSources) {
    const source = await Deno.readTextFile(path);
    assert(
      source.includes("internal-alpha/v0-technical-hardening-20260605-8e54a1f"),
      `${path} should fall back to Technical Hardening, the current published package`,
    );
    assertEquals(
      source.includes("internal-alpha/v0-foundation-solidification-20260602-906101b"),
      false,
      `${path} must not fall back to old Foundation Solidification package roots`,
    );
    assertEquals(
      source.includes("internal-alpha/v0-openworld-node2d-qol"),
      false,
      `${path} must not fall back to legacy Openworld package roots`,
    );
  }
});

Deno.test("release route contract returns NOT_FOUND for unknown subpaths", async () => {
  for (const path of releaseSources) {
    const source = await Deno.readTextFile(path);
    assert(
      source.includes('type Route = "manifest" | "config" | "download" | "unknown"'),
      `${path} should classify unknown release subpaths separately`,
    );
    assert(
      source.includes('errorResponse("NOT_FOUND", "Unknown release endpoint.", 404)'),
      `${path} should return NOT_FOUND for unknown release subpaths`,
    );
  }
});
