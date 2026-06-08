const SUPABASE_URL = requiredEnv("SUPABASE_URL").replace(/\/+$/, "");
const PUBLISHABLE_KEY = requiredEnv("SUPABASE_PUBLISHABLE_KEY");
const MIN_DOWNLOAD_BYTES = Number(
  Deno.env.get("DRAXOS_RELEASE_DOWNLOAD_MIN_BYTES") ?? "1000000",
);
const ALLOW_CLOUDFLARE_ACCESS =
  Deno.env.get("DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS") === "1";
const FULL_HASH_DOWNLOAD = Deno.env.get("DRAXOS_RELEASE_FULL_HASH") === "1";
const EXPECTED_RELEASE_ROOT = requiredEnv("DRAXOS_EXPECTED_RELEASE_ROOT");
const EXPECTED_PORTAL_URL =
  (Deno.env.get("DRAXOS_EXPECTED_PORTAL_URL") ??
    "https://draxos-mobile-internal-alpha.pages.dev/").trim();
const EXPECTED_WEB_URL =
  (Deno.env.get("DRAXOS_EXPECTED_WEB_URL") ??
    "https://draxos-mobile-internal-alpha.pages.dev/web/index.html").trim();

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
  13,
  "release manifest should expose the current version code",
);
assertEq(
  numberField(manifest, "minimum_supported_version_code"),
  13,
  "release manifest should force-update builds before the Openworld operations v2 contract",
);

const portalUrl = httpsField(manifest, "portal_url");
const artifacts = objectField(manifest, "artifacts");
const android = objectField(artifacts, "android");
const pcWindows = objectField(artifacts, "pc_windows");
const web = objectField(artifacts, "web");

const androidUrl = httpsField(android, "url");
const pcUrl = httpsField(pcWindows, "url");
const webUrl = httpsField(web, "url");
const androidAuthRequired = booleanishField(android, "auth_required");
const pcAuthRequired = booleanishField(pcWindows, "auth_required");

assertStableManifestUrl(portalUrl, EXPECTED_PORTAL_URL, "manifest portal_url");
assertStableManifestUrl(webUrl, EXPECTED_WEB_URL, "manifest Web artifact URL");
assertArtifactUrlMatchesContract(
  androidUrl,
  androidAuthRequired,
  "android",
  "Android APK",
);
assertArtifactUrlMatchesContract(
  pcUrl,
  pcAuthRequired,
  "pc_windows",
  "PC ZIP",
);

const androidSha256 = stringField(android, "sha256").toLowerCase();
const pcSha256 = stringField(pcWindows, "sha256").toLowerCase();

assert(
  androidSha256.length === 64,
  "Android artifact should expose a SHA256 hash",
);
assert(
  pcSha256.length === 64,
  "PC artifact should expose a SHA256 hash",
);

if (!androidAuthRequired) {
  await assertDownloadReachable(
    androidUrl,
    "Android APK",
    MIN_DOWNLOAD_BYTES,
    androidSha256,
  );
}
if (!pcAuthRequired) {
  await assertDownloadReachable(pcUrl, "PC ZIP", MIN_DOWNLOAD_BYTES, pcSha256);
}
await assertPageContains(portalUrl, "Portal", "DraxosMobile");
await assertPortalWebLink(portalUrl, webUrl);
const webHtml = await assertPageContains(webUrl, "Web build", "GODOT_CONFIG");
if (webHtml !== null) {
  assert(
    webHtml.includes(EXPECTED_RELEASE_ROOT),
    `Web build should embed expected release root ${EXPECTED_RELEASE_ROOT}`,
  );
}

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
  expectedSha256: string,
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
  if (FULL_HASH_DOWNLOAD) {
    await assertDownloadHash(url, label, expectedSha256);
  }
}

async function assertDownloadHash(
  url: string,
  label: string,
  expectedSha256: string,
): Promise<void> {
  const response = await fetch(url, { method: "GET", headers: baseHeaders() });
  assert(
    response.ok,
    `${label} full download failed with status ${response.status}: ${url}`,
  );
  const bytes = new Uint8Array(await response.arrayBuffer());
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  const actualSha256 = Array.from(new Uint8Array(digest))
    .map((value) => value.toString(16).padStart(2, "0"))
    .join("");
  assertEq(
    actualSha256,
    expectedSha256,
    `${label} SHA256 should match manifest`,
  );
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
): Promise<string | null> {
  const response = await fetch(url, { method: "GET" });
  const text = await response.text();
  assert(
    response.ok,
    `${label} GET failed with status ${response.status}: ${url}`,
  );
  if (
    !text.includes(expectedText) && ALLOW_CLOUDFLARE_ACCESS &&
    isCloudflareAccessPage(text)
  ) {
    console.warn(
      `[release-artifacts-remote-smoke] ${label} is protected by Cloudflare Access: ${url}`,
    );
    return null;
  }
  assert(
    text.includes(expectedText),
    `${label} does not contain ${expectedText}`,
  );
  return text;
}

async function assertPortalWebLink(portalUrl: string, webUrl: string): Promise<void> {
  const response = await fetch(portalUrl, { method: "GET" });
  const text = await response.text();
  assert(response.ok, `Portal GET failed with status ${response.status}: ${portalUrl}`);
  if (ALLOW_CLOUDFLARE_ACCESS && isCloudflareAccessPage(text)) {
    return;
  }
  for (
    const placeholder of [
      "WEB_GAME_URL_PENDING_T03_P17",
      "STATIC_HOST_PENDING_T03_P17",
      "STATIC_HOST_PLACEHOLDER",
    ]
  ) {
    assert(!text.includes(placeholder), `Portal still contains ${placeholder}`);
  }
  const normalizedWebUrl = webUrl.replace(/\/index\.html$/, "");
  assert(
    text.includes(webUrl) || text.includes(normalizedWebUrl) ||
      text.includes("/web/index.html") || text.includes("/web"),
    `Portal should link to the Web build URL: ${webUrl}`,
  );
}

function isCloudflareAccessPage(text: string): boolean {
  const normalized = text.toLowerCase();
  return normalized.includes("cloudflare access") ||
    (normalized.includes("cloudflare") && normalized.includes("sign in"));
}

function assertStableManifestUrl(url: string, expectedUrl: string, label: string): void {
  assert(
    !isCloudflarePagesHashUrl(url),
    `${label} must use the stable production Pages domain, not a hash deployment URL: ${url}`,
  );
  assertEq(
    normalizeUrl(url),
    normalizeUrl(expectedUrl),
    `${label} should match the canonical stable URL`,
  );
}

function assertArtifactUrlMatchesContract(
  url: string,
  authRequired: boolean,
  artifact: string,
  label: string,
): void {
  if (authRequired) {
    assert(
      url.includes("/functions/v1/release/download") &&
        url.includes(`artifact=${artifact}`),
      `${label} protected URL should use release/download?artifact=${artifact}: ${url}`,
    );
    return;
  }
  assert(
    url.includes(EXPECTED_RELEASE_ROOT),
    `${label} URL should include expected release root ${EXPECTED_RELEASE_ROOT}: ${url}`,
  );
}

function isCloudflarePagesHashUrl(url: string): boolean {
  try {
    const host = new URL(url).hostname;
    return /^[0-9a-f]{6,}\.draxos-mobile-internal-alpha\.pages\.dev$/i.test(host);
  } catch {
    return false;
  }
}

function normalizeUrl(url: string): string {
  return url.replace(/\/+$/, "");
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

function booleanishField(payload: JsonObject, key: string): boolean {
  const value = payload[key];
  return value === true || value === "true";
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
