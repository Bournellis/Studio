import { assertEquals, assertStringIncludes } from "jsr:@std/assert";
import { handleLabRunnerRequest } from "../functions/lab-runner/index.ts";

Deno.test("lab runner rejects unauthenticated direct calls", async () => {
  const response = await handleLabRunnerRequest(
    new Request("https://example.test/lab-runner/battle", {
      method: "POST",
      body: "{}",
    }),
  );
  const body = await response.json();
  assertEquals(response.status, 401);
  assertEquals(body.error.code, "UNAUTHENTICATED");
});

Deno.test("lab runner rejects anonymous auth before runtime config is needed", async () => {
  const response = await handleLabRunnerRequest(
    new Request("https://example.test/lab-runner/progression", {
      method: "POST",
      headers: {
        authorization: `Bearer ${fakeJwt({
          sub: "11111111-1111-4111-8111-111111111111",
          is_anonymous: true,
        })}`,
      },
      body: "{}",
    }),
  );
  const body = await response.json();
  assertEquals(response.status, 403);
  assertEquals(body.error.code, "AUTH_REQUIRES_EMAIL");
});

Deno.test("lab runner is scoped to registered Internal Alpha access", async () => {
  const source = await Deno.readTextFile("server/functions/lab-runner/index.ts");
  assertStringIncludes(source, "save_type=eq.normal");
  assertStringIncludes(source, "account_type=eq.registered");
  assertStringIncludes(
    source,
    "Lab Runner requires the same Supabase email/password Internal Alpha account used by the game.",
  );
});

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
