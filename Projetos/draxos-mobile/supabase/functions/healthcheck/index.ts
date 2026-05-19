import { jsonResponse } from "../_shared/http.ts";

Deno.serve((request: Request) => {
  if (request.method !== "GET") {
    return jsonResponse({
      ok: false,
      error: {
        code: "METHOD_NOT_ALLOWED",
        message: "Use GET /healthcheck.",
      },
    }, 405);
  }

  return jsonResponse({
    ok: true,
    service: "draxos-mobile",
    function: "healthcheck",
    track: "Track 00 - First Slice Foundation",
    schema_version: "mvp_foundation_v1",
  });
});
