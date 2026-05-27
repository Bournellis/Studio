const SUPABASE_URL = requiredEnv("SUPABASE_URL").replace(/\/+$/, "");
const PUBLISHABLE_KEY = requiredEnv("SUPABASE_PUBLISHABLE_KEY");
const MIN_DOWNLOAD_BYTES = Number(
  Deno.env.get("DRAXOS_RELEASE_DOWNLOAD_MIN_BYTES") ?? "1000000",
);

assertRemoteUrl(SUPABASE_URL);
assertClientKey(PUBLISHABLE_KEY);

interface JsonObject {
  [key: string]: unknown;
}

const manifest = await getJson(
  `${SUPABASE_URL}/functions/v1/release/manifest`,
  baseHeaders(),
);

assertEq(
  stringField(manifest, "schema_version"),
  "internal_alpha_manifest_v1",
  "release manifest schema should match the Godot contract",
);
assertEq(
  stringField(manifest, "channel"),
  "internal_alpha",
  "release manifest should use the internal alpha channel",
);
assertEq(
  numberField(manifest, "latest_version_code"),
  1,
  "release manifest should expose the current version code",
);
assertEq(
  numberField(manifest, "minimum_supported_version_code"),
  1,
  "release manifest should not force-update the first alpha build",
);

const portalUrl = httpsField(manifest, "portal_url");
const artifacts = objectField(manifest, "artifacts");
const android = objectField(artifacts, "android");
const pcWindows = objectField(artifacts, "pc_windows");
const web = objectField(artifacts, "web");

const androidUrl = httpsField(android, "url");
const pcUrl = httpsField(pcWindows, "url");
const webUrl = httpsField(web, "url");

assert(
  stringField(android, "sha256").length === 64,
  "Android artifact should expose a SHA256 hash",
);
assert(
  stringField(pcWindows, "sha256").length === 64,
  "PC artifact should expose a SHA256 hash",
);

await assertDownloadReachable(androidUrl, "Android APK", MIN_DOWNLOAD_BYTES);
await assertDownloadReachable(pcUrl, "PC ZIP", MIN_DOWNLOAD_BYTES);
await assertPageContains(portalUrl, "Portal", "DraxosMobile");
await assertPageContains(webUrl, "Web build", "GODOT_CONFIG");

console.log("[release-artifacts-remote-smoke] OK", {
  manifest_url: `${SUPABASE_URL}/functions/v1/release/manifest`,
  portal_url: portalUrl,
  web_url: webUrl,
  android_url: androidUrl,
  pc_url: pcUrl,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

async function getJson(
  url: string,
  headers: Record<string, string>,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  const text = await response.text();
  assert(
    response.ok,
    `GET ${url} failed with status ${response.status}: ${text}`,
  );
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  return payload;
}

async function assertDownloadReachable(
  url: string,
  label: string,
  expectedMinimumBytes: number,
): Promise<void> {
  let response = await fetch(url, { method: "HEAD", headers: baseHeaders() });
  if (response.status === 405) {
    response = await fetch(url, {
      method: "GET",
      headers: { ...baseHeaders(), range: "bytes=0-0" },
    });
    await response.body?.cancel();
  }
  assert(
    response.ok,
    `${label} download probe failed with status ${response.status}: ${url}`,
  );
  const contentType = response.headers.get("content-type") ?? "";
  assert(
    !contentType.toLowerCase().includes("text/html"),
    `${label} should not return HTML content: ${contentType}`,
  );
  const totalBytes = contentRangeTotal(response.headers.get("content-range")) ??
    Number(response.headers.get("content-length") ?? "0");
  if (totalBytes > 0) {
    assert(
      totalBytes >= expectedMinimumBytes,
      `${label} content length is smaller than expected: ${totalBytes}`,
    );
  }
}

function contentRangeTotal(value: string | null): number | null {
  if (value === null) {
    return null;
  }
  const match = value.match(/\/(\d+)$/);
  return match ? Number(match[1]) : null;
}

async function assertPageContains(
  url: string,
  label: string,
  expectedText: string,
): Promise<void> {
  const response = await fetch(url, { method: "GET" });
  const text = await response.text();
  assert(
    response.ok,
    `${label} GET failed with status ${response.status}: ${url}`,
  );
  assert(
    text.includes(expectedText),
    `${label} does not contain ${expectedText}`,
  );
}

function requiredEnv(key: string): string {
  const value = Deno.env.get(key)?.trim() ?? "";
  if (value === "") {
    throw new Error(`${key} is required for release artifact remote smoke`);
  }
  return value;
}

function assertRemoteUrl(url: string): void {
  assert(
    url.startsWith("https://"),
    "release artifact remote smoke requires an https Supabase project URL",
  );
  assert(
    !url.includes("localhost") && !url.includes("127.0.0.1"),
    "release artifact remote smoke refuses local Supabase URLs",
  );
}

function assertClientKey(key: string): void {
  const normalized = key.toLowerCase();
  assert(
    !normalized.includes("service_role") &&
      !normalized.includes("secret") &&
      !normalized.startsWith("sb_secret_") &&
      !normalized.startsWith("sb_service_"),
    "release artifact remote smoke must use a publishable/client key, never service role",
  );
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function numberField(payload: JsonObject, key: string): number {
  const value = payload[key];
  return typeof value === "number" ? value : 0;
}

function httpsField(payload: JsonObject, key: string): string {
  const value = stringField(payload, key);
  assert(value.startsWith("https://"), `${key} should be an https URL`);
  return value;
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
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}
