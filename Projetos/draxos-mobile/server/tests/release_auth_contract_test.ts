import { assert, assertEquals } from "jsr:@std/assert";

const releaseSources = [
  "server/functions/release/index.ts",
  "supabase/functions/release/index.ts",
];

Deno.test("release download validates bearer tokens with Supabase Auth before service-role access", async () => {
  for (const path of releaseSources) {
    const source = await Deno.readTextFile(path);
    assert(
      source.includes("/auth/v1/user"),
      `${path} should validate download bearer tokens against Supabase Auth`,
    );
    assert(
      source.includes("SUPABASE_PUBLISHABLE_KEY") && source.includes("SUPABASE_ANON_KEY"),
      `${path} should use publishable/anon key material for Auth user verification`,
    );
    assert(
      source.includes("Bearer token subject mismatch"),
      `${path} should reject JWTs whose decoded sub differs from the Auth user id`,
    );
    assert(
      source.includes("AUTH_REQUIRES_EMAIL"),
      `${path} should reject anonymous or email-less users before alpha access checks`,
    );
    assert(
      source.indexOf("const auth = await validateDownloadAuth") <
        source.indexOf("const access = await assertAlphaAccess"),
      `${path} should verify Auth user before querying alpha access with service role`,
    );
  }
});

Deno.test("release manifest code fallback points at the latest safe package root", async () => {
  for (const path of releaseSources) {
    const source = await Deno.readTextFile(path);
    assert(
      source.includes("internal-alpha/v0-foundation-solidification-20260602-906101b"),
      `${path} should fall back to Foundation Solidification, the latest safe package`,
    );
    assertEquals(
      source.includes("internal-alpha/v0-openworld-node2d-qol"),
      false,
      `${path} must not fall back to old Openworld package roots`,
    );
  }
});
