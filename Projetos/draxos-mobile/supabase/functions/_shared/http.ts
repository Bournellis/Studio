export const allowedCorsOrigins = [
  "https://68116729.draxos-mobile-internal-alpha.pages.dev",
  "https://4315dd54.draxos-mobile-internal-alpha.pages.dev",
  "https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev",
  "https://draxos-mobile-internal-alpha.pages.dev",
  "https://68452eed.draxos-mobile-internal-alpha.pages.dev",
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  "http://localhost:8788",
  "http://127.0.0.1:8788",
];

const defaultCorsOrigin = allowedCorsOrigins[0];

export const corsHeaders = {
  "access-control-allow-origin": defaultCorsOrigin,
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type, x-draxos-save-type, x-draxos-api-version",
  "access-control-allow-methods": "GET, POST, OPTIONS",
  "vary": "origin",
};

export function corsHeadersForRequest(request: Request): Record<string, string> {
  const origin = request.headers.get("origin");
  if (origin !== null && allowedCorsOrigins.includes(origin)) {
    return {
      ...corsHeaders,
      "access-control-allow-origin": origin,
    };
  }
  return corsHeaders;
}

export const jsonHeaders = {
  ...corsHeaders,
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
};

export function jsonResponse(
  body: unknown,
  status = 200,
  extraHeaders: Record<string, string> = {},
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...jsonHeaders,
      ...extraHeaders,
    },
  });
}

export function emptyResponse(status = 204): Response {
  return new Response(null, {
    status,
    headers: corsHeaders,
  });
}
