const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_TLjdd9X4MlzD740dtVCXNg_YTl9IMAi";
const INVITE_CODE = Deno.env.get("DRAXOS_REMOTE_INVITE_CODE") ?? "ALPHA-TEST";
const CHECK_SIGNED_HEAD = (Deno.env.get("DRAXOS_RELEASE_DOWNLOAD_SMOKE_HEAD") ?? "") === "1";

interface JsonObject {
  [key: string]: unknown;
}

const baseUrl = SUPABASE_URL.replace(/\/+$/, "");
const runId = crypto.randomUUID().replaceAll("-", "").slice(0, 12);
const email = `draxosdownload${runId}@gmail.com`;
const password = `alpha-${runId}`;
const username = `down_${runId.slice(0, 10)}`;

const signup = await postJson(
  `${baseUrl}/auth/v1/signup`,
  { email, password },
  baseHeaders(),
);
const accessToken = stringField(signup, "access_token");
assert(accessToken !== "", "email signup should return an access token");

await postJson(
  `${baseUrl}/functions/v1/account/bootstrap`,
  {
    invite_code: INVITE_CODE,
    username,
    device_label: "deno-release-download-smoke",
    request_id: crypto.randomUUID(),
  },
  authHeaders(accessToken),
);

await assertProtectedDownload("android", "draxos-mobile-alpha.apk", accessToken);
await assertProtectedDownload("pc_windows", "draxos-mobile-alpha.zip", accessToken);
await assertForgedJwtRejected(accessToken);

console.log("[release-download-smoke] OK", {
  url: baseUrl,
  signed_head_checked: CHECK_SIGNED_HEAD,
});

async function assertProtectedDownload(
  artifact: string,
  filename: string,
  accessToken: string,
): Promise<void> {
  const payload = await getJson(
    `${baseUrl}/functions/v1/release/download?artifact=${artifact}`,
    authHeaders(accessToken),
  );
  assertEq(payload.ok, true, `${artifact} download should return ok`);
  assertEq(stringField(payload, "artifact"), artifact, `${artifact} should echo artifact id`);
  const url = stringField(payload, "url");
  assert(
    url.startsWith(`${baseUrl}/storage/v1/object/sign/`),
    `${artifact} signed URL should use Supabase Storage route: ${url}`,
  );
  assert(url.includes(filename), `${artifact} signed URL should include file name: ${url}`);
  assert(url.includes("token="), `${artifact} signed URL should include token: ${url}`);

  if (CHECK_SIGNED_HEAD) {
    const response = await fetch(url, { method: "HEAD" });
    assert(
      response.status >= 200 && response.status < 300,
      `${artifact} signed URL HEAD failed with ${response.status}`,
    );
  }
}

async function assertForgedJwtRejected(accessToken: string): Promise<void> {
  const forgedToken = withForgedSubject(accessToken, crypto.randomUUID());
  const response = await fetch(
    `${baseUrl}/functions/v1/release/download?artifact=android`,
    { method: "GET", headers: authHeaders(forgedToken) },
  );
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `forged token response should be JSON: ${text}`);
  assert(
    response.status === 401 || response.status === 403,
    `forged JWT should be rejected before signed URL creation, got ${response.status}: ${text}`,
  );
  assertEq(payload.ok, false, "forged JWT response should return ok=false");
}

function withForgedSubject(accessToken: string, subject: string): string {
  const parts = accessToken.split(".");
  assert(parts.length >= 3, "access token should be a JWT");
  const payload = parseJson(base64UrlDecode(parts[1]));
  assert(isObject(payload), "access token payload should be a JSON object");
  payload.sub = subject;
  return `${parts[0]}.${base64UrlEncode(JSON.stringify(payload))}.${parts[2]}`;
}

function base64UrlDecode(value: string): string {
  const normalized = value.replaceAll("-", "+").replaceAll("_", "/");
  const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
  return new TextDecoder().decode(
    Uint8Array.from(atob(padded), (character) => character.charCodeAt(0)),
  );
}

function base64UrlEncode(value: string): string {
  const bytes = new TextEncoder().encode(value);
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

function authHeaders(accessToken: string): Record<string, string> {
  return {
    ...baseHeaders(),
    authorization: `Bearer ${accessToken}`,
  };
}

async function getJson(
  url: string,
  headers: Record<string, string>,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response);
}

async function postJson(
  url: string,
  body: JsonObject,
  headers: Record<string, string>,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });
  return await parseResponse(response);
}

async function parseResponse(response: Response): Promise<JsonObject> {
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  assert(response.ok, `request failed with status ${response.status}: ${text}`);
  return payload;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message: string): void {
  if (actual !== expected) {
    throw new Error(`${message}. Expected ${expected}, got ${actual}.`);
  }
}
