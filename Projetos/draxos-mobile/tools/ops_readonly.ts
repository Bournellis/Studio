export type OpsTarget =
  | "manifest"
  | "modes"
  | "status"
  | "audit"
  | "rewards"
  | "sessions";

export interface OpsConfig {
  supabaseUrl: string;
  publishableKey: string;
  accessToken: string;
  saveType: "normal" | "progression_lab";
  modeId: string;
  targets: OpsTarget[];
  limit: number;
  format: "json" | "pretty";
}

export interface OpsSummary {
  generated_at: string;
  supabase_url: string;
  mode_id: string;
  read_only: true;
  service_role_allowed: false;
  summaries: Record<string, unknown>;
}

interface FetchLike {
  (input: string | URL, init?: RequestInit): Promise<Response>;
}

interface JsonObject {
  [key: string]: unknown;
}

interface FetchJsonResult {
  ok: boolean;
  status: number;
  url: string;
  payload: JsonObject;
}

const DEFAULT_TARGETS: OpsTarget[] = [
  "manifest",
  "modes",
  "status",
  "audit",
  "rewards",
  "sessions",
];

const PROTECTED_TARGETS = new Set<OpsTarget>([
  "modes",
  "status",
  "audit",
  "rewards",
  "sessions",
]);

if (import.meta.main) {
  try {
    const config = parseOpsArgs(Deno.args, Deno.env.toObject());
    const summary = await runOpsReadOnly(config, fetch);
    if (config.format === "json") {
      console.log(JSON.stringify(summary, null, 2));
    } else {
      console.log(formatPretty(summary));
    }
  } catch (error) {
    console.error(error instanceof Error ? error.message : String(error));
    Deno.exit(1);
  }
}

export function parseOpsArgs(
  args: string[],
  env: Record<string, string>,
): OpsConfig {
  const values = new Map<string, string>();
  for (let index = 0; index < args.length; index += 1) {
    const arg = args[index];
    if (arg === "--help" || arg === "-h") {
      throw new Error(helpText());
    }
    if (!arg.startsWith("--")) {
      throw new Error(`Unexpected argument: ${arg}`);
    }
    const inline = arg.indexOf("=");
    if (inline >= 0) {
      values.set(arg.slice(2, inline), arg.slice(inline + 1));
      continue;
    }
    const key = arg.slice(2);
    const next = args[index + 1] ?? "";
    if (next === "" || next.startsWith("--")) {
      values.set(key, "true");
    } else {
      values.set(key, next);
      index += 1;
    }
  }

  const supabaseUrl = option(values, env, "supabase-url", [
    "DRAXOS_MOBILE_SUPABASE_URL",
    "SUPABASE_URL",
  ]).replace(/\/+$/, "");
  const publishableKey = option(values, env, "publishable-key", [
    "DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY",
    "SUPABASE_PUBLISHABLE_KEY",
  ]);
  const accessToken = option(values, env, "access-token", [
    "DRAXOS_OPS_ACCESS_TOKEN",
    "DRAXOS_MOBILE_OPS_ACCESS_TOKEN",
  ], false);
  const saveType =
    option(values, env, "save-type", ["DRAXOS_OPS_SAVE_TYPE"], false) ||
    "normal";
  if (saveType !== "normal" && saveType !== "progression_lab") {
    throw new Error("--save-type must be normal or progression_lab");
  }
  const modeId =
    option(values, env, "mode-id", ["DRAXOS_OPS_MODE_ID"], false) ||
    "openworld";
  const format = option(values, env, "format", ["DRAXOS_OPS_FORMAT"], false) ||
    "pretty";
  if (format !== "json" && format !== "pretty") {
    throw new Error("--format must be json or pretty");
  }
  const limitText = option(values, env, "limit", ["DRAXOS_OPS_LIMIT"], false) ||
    "20";
  const limit = Number(limitText);
  if (!Number.isInteger(limit) || limit <= 0 || limit > 100) {
    throw new Error("--limit must be an integer between 1 and 100");
  }

  if (supabaseUrl === "") {
    throw new Error("SUPABASE_URL or --supabase-url is required");
  }
  if (publishableKey === "") {
    throw new Error(
      "SUPABASE_PUBLISHABLE_KEY or --publishable-key is required",
    );
  }
  assertNoServiceCredential(publishableKey, "publishable key");
  if (accessToken !== "") {
    assertNoServiceCredential(accessToken, "ops access token");
  }

  return {
    supabaseUrl,
    publishableKey,
    accessToken,
    saveType,
    modeId,
    targets: parseTargets(
      option(values, env, "target", ["DRAXOS_OPS_TARGET"], false) || "all",
    ),
    limit,
    format,
  };
}

export async function runOpsReadOnly(
  config: OpsConfig,
  fetcher: FetchLike = fetch,
): Promise<OpsSummary> {
  const summaries: Record<string, unknown> = {};
  let stateResult: FetchJsonResult | null = null;

  for (const target of config.targets) {
    if (target === "manifest") {
      const manifest = await fetchJson(
        urlFor(config, "/functions/v1/release/manifest"),
        publicHeaders(config),
        fetcher,
      );
      summaries.manifest = summarizeManifest(manifest);
      continue;
    }

    if (PROTECTED_TARGETS.has(target) && config.accessToken === "") {
      summaries[target] = skipped(
        `${target} requires DRAXOS_OPS_ACCESS_TOKEN user JWT`,
      );
      continue;
    }

    if (target === "modes") {
      const registry = await fetchJson(
        urlFor(config, "/functions/v1/modes/registry"),
        protectedHeaders(config),
        fetcher,
      );
      summaries.modes = summarizeModes(registry);
      continue;
    }

    if (target === "status" || target === "rewards" || target === "sessions") {
      if (stateResult === null) {
        stateResult = await fetchJson(
          urlFor(
            config,
            `/functions/v1/modes/state?mode_id=${
              encodeURIComponent(config.modeId)
            }`,
          ),
          protectedHeaders(config),
          fetcher,
        );
      }
      if (target === "status") summaries.status = summarizeStatus(stateResult);
      if (target === "rewards") {
        summaries.rewards = summarizeRewards(stateResult);
      }
      if (target === "sessions") {
        summaries.sessions = summarizeSessions(stateResult);
      }
      continue;
    }

    if (target === "audit") {
      const admin = await fetchJson(
        urlFor(config, "/functions/v1/modes/admin/me"),
        protectedHeaders(config),
        fetcher,
      );
      const audit = await fetchJson(
        urlFor(
          config,
          `/rest/v1/admin_audit_log?select=id,action,reason,request_id,created_at&order=created_at.desc&limit=${config.limit}`,
        ),
        protectedHeaders(config),
        fetcher,
      );
      summaries.audit = summarizeAudit(admin, audit);
    }
  }

  return {
    generated_at: new Date().toISOString(),
    supabase_url: config.supabaseUrl,
    mode_id: config.modeId,
    read_only: true,
    service_role_allowed: false,
    summaries,
  };
}

export function assertNoServiceCredential(value: string, label: string): void {
  const normalized = value.trim().toLowerCase();
  if (
    normalized.includes("service_role") ||
    normalized.includes("sb_secret_") ||
    normalized.includes("sb_service_") ||
    normalized.startsWith("secret")
  ) {
    throw new Error(
      `${label} must be publishable/user scoped, never service role`,
    );
  }
  const payload = decodeJwtPayload(value);
  if (payload !== null) {
    const role = typeof payload.role === "string"
      ? payload.role.toLowerCase()
      : "";
    if (role === "service_role" || role === "supabase_admin") {
      throw new Error(
        `${label} JWT role is ${role}; read-only ops refuses admin credentials`,
      );
    }
  }
}

function summarizeManifest(result: FetchJsonResult): JsonObject {
  if (!result.ok) return failed(result);
  const manifest = result.payload;
  const artifacts = objectValue(manifest.artifacts);
  return {
    status: "ok",
    schema_version: stringValue(manifest.schema_version),
    channel: stringValue(manifest.channel),
    latest_version: stringValue(manifest.latest_version),
    latest_version_code: numberValue(manifest.latest_version_code),
    minimum_supported_version_code: numberValue(
      manifest.minimum_supported_version_code,
    ),
    requires_save_reset: manifest.requires_save_reset === true,
    released_at: stringValue(manifest.released_at),
    portal_url: stringValue(manifest.portal_url),
    artifact_keys: Object.keys(artifacts).sort(),
    android_known_issue_debug_fallback: arrayValue(manifest.known_issues).some((
      item,
    ) => String(item).toLowerCase().includes("debug_fallback")),
  };
}

function summarizeModes(result: FetchJsonResult): JsonObject {
  if (!result.ok) return failed(result);
  const modes = arrayValue(result.payload.modes);
  const rulesets = arrayValue(result.payload.rulesets);
  return {
    status: "ok",
    schema_version: stringValue(result.payload.schema_version),
    mode_count: modes.length,
    ruleset_count: rulesets.length,
    modes: modes.map((item) => {
      const mode = objectValue(item);
      return {
        mode_id: stringValue(mode.mode_id),
        status: stringValue(mode.status),
        release_channel: stringValue(mode.release_channel),
        active_ruleset_id: stringValue(mode.active_ruleset_id),
        active_ruleset_version: numberValue(mode.active_ruleset_version),
      };
    }),
  };
}

function summarizeStatus(result: FetchJsonResult): JsonObject {
  if (!result.ok) return failed(result);
  const modes = arrayValue(result.payload.modes);
  const progress = objectValue(result.payload.progress);
  const resources = objectValue(result.payload.resources);
  return {
    status: "ok",
    mode_id: firstString(modes, "mode_id"),
    mode_status: firstString(modes, "status"),
    progress_updated_at: stringValue(progress.updated_at),
    totals_keys: Object.keys(objectValue(progress.totals_payload)).sort(),
    resources,
  };
}

function summarizeSessions(result: FetchJsonResult): JsonObject {
  if (!result.ok) return failed(result);
  const sessions = arrayValue(result.payload.sessions).map(objectValue);
  const byStatus: Record<string, number> = {};
  for (const session of sessions) {
    const status = stringValue(session.status) || "unknown";
    byStatus[status] = (byStatus[status] ?? 0) + 1;
  }
  return {
    status: "ok",
    count: sessions.length,
    by_status: byStatus,
    recent: sessions.slice(0, 5).map((session) => ({
      id: stringValue(session.id),
      status: stringValue(session.status),
      started_at: stringValue(session.started_at),
      completed_at: stringValue(session.completed_at),
      invalidated_at: stringValue(session.invalidated_at),
    })),
  };
}

function summarizeRewards(result: FetchJsonResult): JsonObject {
  if (!result.ok) return failed(result);
  const rewards = arrayValue(result.payload.rewards).map(objectValue);
  const totals: Record<string, number> = {};
  let xp = 0;
  for (const reward of rewards) {
    xp += numberValue(reward.xp_delta);
    const delta = objectValue(reward.resource_delta);
    for (const [key, value] of Object.entries(delta)) {
      const amount = typeof value === "number" ? value : Number(value);
      if (Number.isFinite(amount)) totals[key] = (totals[key] ?? 0) + amount;
    }
  }
  return {
    status: "ok",
    count: rewards.length,
    xp_delta_total: xp,
    resource_delta_totals: totals,
    recent: rewards.slice(0, 5).map((reward) => ({
      id: stringValue(reward.id),
      session_id: stringValue(reward.session_id),
      period_key: stringValue(reward.period_key),
      created_at: stringValue(reward.created_at),
    })),
  };
}

function summarizeAudit(
  admin: FetchJsonResult,
  audit: FetchJsonResult,
): JsonObject {
  const adminPayload = admin.ok ? admin.payload : {};
  const adminRole = objectValue(adminPayload.admin);
  if (!audit.ok) {
    return {
      status: "blocked_or_empty",
      admin_status: admin.status,
      admin_role: stringValue(adminRole.role),
      audit_status: audit.status,
      reason:
        "admin_audit_log direct REST read is RLS-gated; this CLI did not use service role or mutation.",
    };
  }
  const rows = Array.isArray(audit.payload)
    ? audit.payload.map(objectValue)
    : [];
  return {
    status: "ok",
    admin_status: admin.status,
    admin_role: stringValue(adminRole.role),
    count: rows.length,
    recent: rows.slice(0, 10).map((row) => ({
      id: stringValue(row.id),
      action: stringValue(row.action),
      request_id: stringValue(row.request_id),
      created_at: stringValue(row.created_at),
    })),
  };
}

async function fetchJson(
  url: string,
  headers: Record<string, string>,
  fetcher: FetchLike,
): Promise<FetchJsonResult> {
  const response = await fetcher(url, { method: "GET", headers });
  const text = await response.text();
  const parsed = parseJson(text);
  return {
    ok: response.ok,
    status: response.status,
    url,
    payload: isObject(parsed) || Array.isArray(parsed)
      ? parsed as JsonObject
      : {},
  };
}

function publicHeaders(config: OpsConfig): Record<string, string> {
  return {
    apikey: config.publishableKey,
    accept: "application/json",
    "content-type": "application/json",
  };
}

function protectedHeaders(config: OpsConfig): Record<string, string> {
  return {
    ...publicHeaders(config),
    authorization: `Bearer ${config.accessToken}`,
    "x-draxos-api-version": "1",
    "x-draxos-save-type": config.saveType,
  };
}

function urlFor(config: OpsConfig, path: string): string {
  return `${config.supabaseUrl}${path}`;
}

function parseTargets(value: string): OpsTarget[] {
  const parts = value.split(",").map((part) => part.trim()).filter((part) =>
    part !== ""
  );
  const names = parts.includes("all") ? DEFAULT_TARGETS : parts;
  const unique: OpsTarget[] = [];
  for (const name of names) {
    if (!DEFAULT_TARGETS.includes(name as OpsTarget)) {
      throw new Error(`Unknown ops target: ${name}`);
    }
    if (!unique.includes(name as OpsTarget)) {
      unique.push(name as OpsTarget);
    }
  }
  return unique;
}

function option(
  values: Map<string, string>,
  env: Record<string, string>,
  key: string,
  envKeys: string[],
  required = true,
): string {
  const cli = values.get(key)?.trim() ?? "";
  if (cli !== "") return cli;
  for (const envKey of envKeys) {
    const value = env[envKey]?.trim() ?? "";
    if (value !== "") return value;
  }
  return required ? "" : "";
}

function failed(result: FetchJsonResult): JsonObject {
  const error = objectValue(result.payload.error);
  return {
    status: "failed",
    http_status: result.status,
    error_code: stringValue(error.code),
    message: stringValue(error.message),
  };
}

function skipped(reason: string): JsonObject {
  return { status: "skipped", reason };
}

function objectValue(value: unknown): JsonObject {
  return isObject(value) ? value : {};
}

function arrayValue(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function numberValue(value: unknown): number {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function firstString(items: unknown[], key: string): string {
  const first = objectValue(items[0]);
  return stringValue(first[key]);
}

function isObject(value: unknown): value is JsonObject {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function decodeJwtPayload(token: string): JsonObject | null {
  const parts = token.split(".");
  if (parts.length < 2) return null;
  try {
    const normalized = parts[1].replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(
      atob(padded),
      (character) => character.charCodeAt(0),
    );
    const payload = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

function formatPretty(summary: OpsSummary): string {
  const lines = [
    "DraxosMobile ops read-only summary",
    `Generated: ${summary.generated_at}`,
    `Supabase: ${summary.supabase_url}`,
    `Mode: ${summary.mode_id}`,
    "Service role: refused",
    "",
  ];
  for (const [target, value] of Object.entries(summary.summaries)) {
    lines.push(`[${target}]`);
    lines.push(JSON.stringify(value, null, 2));
    lines.push("");
  }
  return lines.join("\n").trimEnd();
}

function helpText(): string {
  return [
    "DraxosMobile ops read-only CLI",
    "",
    "Usage:",
    "  deno run --allow-net --allow-env tools/ops_readonly.ts --target manifest,modes,status,audit,rewards,sessions",
    "",
    "Required env/options:",
    "  --supabase-url or SUPABASE_URL",
    "  --publishable-key or SUPABASE_PUBLISHABLE_KEY",
    "",
    "Protected mode/status/audit/reward/session reads also need:",
    "  --access-token or DRAXOS_OPS_ACCESS_TOKEN (Supabase user JWT, never service role)",
    "",
    "Options:",
    "  --target all|manifest,modes,status,audit,rewards,sessions",
    "  --mode-id openworld",
    "  --save-type normal|progression_lab",
    "  --limit 20",
    "  --format pretty|json",
  ].join("\n");
}
