export const allowedCorsOrigins = [
  "https://draxos-mobile-internal-alpha.pages.dev",
  "https://2fe9393e.draxos-mobile-internal-alpha.pages.dev",
  "https://aeec7403.draxos-mobile-internal-alpha.pages.dev",
  "https://2cca25db.draxos-mobile-internal-alpha.pages.dev",
  "https://95f403c5.draxos-mobile-internal-alpha.pages.dev",
  "https://ca946749.draxos-mobile-internal-alpha.pages.dev",
  "https://68116729.draxos-mobile-internal-alpha.pages.dev",
  "https://4315dd54.draxos-mobile-internal-alpha.pages.dev",
  "https://2cba1ff3.draxos-mobile-internal-alpha.pages.dev",
  "https://68452eed.draxos-mobile-internal-alpha.pages.dev",
  "http://localhost:5173",
  "http://127.0.0.1:5173",
  "http://localhost:8788",
  "http://127.0.0.1:8788",
];

const defaultCorsOrigin = allowedCorsOrigins[0];
const internalAlphaPreviewOriginPattern = /^https:\/\/[a-f0-9]+\.draxos-mobile-internal-alpha\.pages\.dev$/;

export const corsHeaders = {
  "access-control-allow-origin": defaultCorsOrigin,
  "access-control-allow-headers":
    "authorization, x-client-info, apikey, content-type, x-draxos-save-type, x-draxos-api-version, x-draxos-request-id, x-draxos-request-hash",
  "access-control-allow-methods": "GET, POST, OPTIONS",
  "vary": "origin",
};

export function corsHeadersForRequest(request: Request): Record<string, string> {
  const origin = request.headers.get("origin");
  if (origin !== null && (allowedCorsOrigins.includes(origin) || internalAlphaPreviewOriginPattern.test(origin))) {
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

export function withCorsResponse(request: Request, response: Response): Response {
  const headers = new Headers(response.headers);
  for (const [key, value] of Object.entries(corsHeadersForRequest(request))) {
    headers.set(key, value);
  }

  return new Response(response.body, {
    status: response.status,
    statusText: response.statusText,
    headers,
  });
}
