import { emptyResponse, jsonResponse } from "../_shared/http.ts";

type Route = "matchmaking_preview" | "ranking_current";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
}

interface RestError {
  code: string;
  message: string;
  status: number;
}

interface JwtPayload {
  sub?: unknown;
  is_anonymous?: unknown;
}

interface PlayerRow {
  id: string;
  username: string | null;
  level: number;
  power: number;
}

interface BotBuildRow {
  id: string;
  power: number;
  power_band: string;
  build_data: unknown;
  is_active: boolean;
}

interface SeasonRow {
  id: string;
  display_name: string;
  starts_at: string;
  ends_at: string;
}

interface RankingRow {
  season_id: string;
  player_id: string;
  arena_points: number;
  wins: number;
  losses: number;
  updated_at: string;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown competition endpoint.", 404);
    }
    if (request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET for competition endpoints.", 405);
    }
    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }
    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }
    if (route === "matchmaking_preview") {
      return await handleMatchmakingPreview(auth.value, config.value);
    }
    return await handleRankingCurrent(auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected competition service error.", 500);
  }
});

async function handleMatchmakingPreview(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const player = await loadPlayer(auth, config);
  if (player.error !== null) {
    return errorResponse(player.error.code, player.error.message, player.error.status);
  }
  const power = Math.max(50, numberValue(player.value.power, 0) || player.value.level * 50);
  const botResult = await restRequest<BotBuildRow[]>(
    config,
    "bot_builds?is_active=eq.true&select=id,power,power_band,build_data,is_active&order=power.asc",
    { method: "GET" },
  );
  if (botResult.error !== null) {
    return errorResponse("MATCHMAKING_READ_FAILED", "Unable to load matchmaking pool.", 500);
  }
  const bots = botResult.value.filter((bot) => !isRankedBot(bot));
  const selected =
    bots.toSorted((a, b) => Math.abs(a.power - power) - Math.abs(b.power - power))[0] ??
      null;
  return jsonResponse({
    ok: true,
    matchmaking: {
      player_power: power,
      tolerances: [
        { after_seconds: 0, max_difference_percent: 10 },
        { after_seconds: 5, max_difference_percent: 20 },
        { after_seconds: 15, max_difference_percent: 35 },
      ],
      selected_opponent: selected === null ? null : {
        id: selected.id,
        power: selected.power,
        power_band: selected.power_band,
        is_bot: true,
        is_ranked: false,
      },
      fallback_reason: selected === null ? "NO_BOT_AVAILABLE" : "BOT_ALPHA_POOL",
    },
  });
}

async function handleRankingCurrent(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const player = await loadPlayer(auth, config);
  if (player.error !== null) {
    return errorResponse(player.error.code, player.error.message, player.error.status);
  }
  const season = await activeSeason(config);
  if (season.error !== null) {
    return errorResponse(season.error.code, season.error.message, season.error.status);
  }
  await restRequest<unknown>(config, "ranking", {
    method: "POST",
    headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
    body: JSON.stringify({ season_id: season.value.id, player_id: player.value.id }),
  });
  const rankingResult = await restRequest<RankingRow[]>(
    config,
    `ranking?season_id=eq.${
      encodeURIComponent(season.value.id)
    }&select=season_id,player_id,arena_points,wins,losses,updated_at&order=arena_points.desc&order=updated_at.asc&limit=20`,
    { method: "GET" },
  );
  const selfResult = await restRequest<RankingRow[]>(
    config,
    `ranking?season_id=eq.${encodeURIComponent(season.value.id)}&player_id=eq.${
      encodeURIComponent(player.value.id)
    }&select=season_id,player_id,arena_points,wins,losses,updated_at&limit=1`,
    { method: "GET" },
  );
  if (rankingResult.error !== null || selfResult.error !== null) {
    return errorResponse("RANKING_READ_FAILED", "Unable to load ranking.", 500);
  }
  return jsonResponse({
    ok: true,
    ranking: {
      season: season.value,
      entries: rankingResult.value,
      self: selfResult.value[0] ?? null,
      bots_included: false,
    },
  });
}

async function loadPlayer(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${
      encodeURIComponent(auth.userId)
    }&select=id,username,level,power&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const player = result.value[0] ?? null;
  if (player === null) {
    return {
      value: null,
      error: {
        code: "PLAYER_NOT_FOUND",
        message: "Guest account was not created yet.",
        status: 404,
      },
    };
  }
  return { value: player, error: null };
}

async function activeSeason(
  config: EdgeConfig,
): Promise<{ value: SeasonRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<SeasonRow[]>(
    config,
    "seasons?status=eq.active&select=id,display_name,starts_at,ends_at&order=starts_at.desc&limit=1",
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const season = result.value[0] ?? null;
  if (season === null) {
    return {
      value: null,
      error: { code: "SEASON_NOT_FOUND", message: "No active season is configured.", status: 500 },
    };
  }
  return { value: season, error: null };
}

function isRankedBot(bot: BotBuildRow): boolean {
  return isObject(bot.build_data) && bot.build_data.is_ranked === true;
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/matchmaking/preview")) return "matchmaking_preview";
  if (pathname.endsWith("/ranking/current")) return "ranking_current";
  return null;
}

function decodeAuthContext(
  request: Request,
): { value: AuthContext; error: null } | { value: null; error: RestError } {
  const header = request.headers.get("authorization") ?? "";
  if (!header.startsWith("Bearer ")) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Bearer token is required.", status: 401 },
    };
  }
  const token = header.slice("Bearer ".length);
  const parts = token.split(".");
  if (parts.length < 2) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Invalid bearer token.", status: 401 },
    };
  }
  const payload = decodeJwtPayload(parts[1]);
  if (payload === null || typeof payload.sub !== "string" || !UUID_PATTERN.test(payload.sub)) {
    return {
      value: null,
      error: { code: "UNAUTHENTICATED", message: "Token subject is invalid.", status: 401 },
    };
  }
  if (payload.is_anonymous === false) {
    return {
      value: null,
      error: {
        code: "AUTH_NOT_ANONYMOUS",
        message: "Use an anonymous Supabase Auth session.",
        status: 403,
      },
    };
  }
  return { value: { userId: payload.sub }, error: null };
}

function decodeJwtPayload(encodedPayload: string): JwtPayload | null {
  try {
    const normalized = encodedPayload.replaceAll("-", "+").replaceAll("_", "/");
    const padded = normalized + "=".repeat((4 - normalized.length % 4) % 4);
    const bytes = Uint8Array.from(atob(padded), (character) => character.charCodeAt(0));
    const payload: unknown = JSON.parse(new TextDecoder().decode(bytes));
    return isObject(payload) ? payload as JwtPayload : null;
  } catch {
    return null;
  }
}

function loadConfig(): { value: EdgeConfig; error: null } | { value: null; error: RestError } {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
  if (supabaseUrl === "" || serviceRoleKey === "") {
    return {
      value: null,
      error: {
        code: "SERVER_MISCONFIGURED",
        message: "Competition function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

async function restRequest<T>(config: EdgeConfig, path: string, init: RequestInit) {
  const headers = new Headers(init.headers);
  headers.set("accept", "application/json");
  headers.set("apikey", config.serviceRoleKey);
  headers.set("authorization", `Bearer ${config.serviceRoleKey}`);
  if (init.body !== undefined) headers.set("content-type", "application/json");
  const response = await fetch(`${config.supabaseUrl}/rest/v1/${path}`, { ...init, headers });
  const text = await response.text();
  const data = text === "" ? null : parseJson(text);
  if (!response.ok) {
    const body = isObject(data) ? data : {};
    return {
      value: null as T,
      error: {
        code: stringValue(body.code, "REST_ERROR"),
        message: stringValue(body.message, response.statusText),
        status: response.status,
      },
    };
  }
  return { value: data as T, error: null };
}

function stateReadError(): RestError {
  return { code: "STATE_READ_FAILED", message: "Unable to load competition state.", status: 500 };
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ ok: false, error: { code, message } }, status);
}

function parseJson(text: string): unknown {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function numberValue(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  if (typeof value === "string" && value.trim() !== "") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  }
  return fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
