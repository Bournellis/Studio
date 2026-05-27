import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import {
  isProgressionLabSave,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";

type Route = "matchmaking_preview" | "ranking_current";

interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

interface AuthContext {
  userId: string;
  saveType: SaveType;
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
  save_type: SaveType;
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

interface RankedEntry extends RankingRow {
  rank: number;
  username: string;
  player: {
    id: string;
    username: string;
    save_type: SaveType;
    save_badge: "normal" | "lab";
    level: number;
    power: number;
  };
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const RANKING_TOP_LIMIT = 10;
const RANKING_QUERY_LIMIT = 500;
const ARENA_SCORING_MODEL = "alpha_v0_power_adjusted";

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
      candidate_count: bots.length,
      bots_included_in_leaderboard: false,
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
  if (isProgressionLabSave(auth.saveType)) {
    return jsonResponse({
      ok: true,
      ranking: {
        season: season.value,
        entries: [],
        self: null,
        bots_included: false,
        top_limit: RANKING_TOP_LIMIT,
        total_ranked: 0,
        self_in_top: false,
        excluded_reason: "PROGRESSION_LAB_DOES_NOT_RANK",
        scoring_model: ARENA_SCORING_MODEL,
      },
    });
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
    }&select=season_id,player_id,arena_points,wins,losses,updated_at&order=arena_points.desc&order=updated_at.asc&limit=${RANKING_QUERY_LIMIT}`,
    { method: "GET" },
  );
  if (rankingResult.error !== null) {
    return errorResponse("RANKING_READ_FAILED", "Unable to load ranking.", 500);
  }
  const profiles = await loadPlayerProfiles(
    config,
    rankingResult.value.map((row) => row.player_id),
  );
  if (profiles.error !== null) {
    return errorResponse(profiles.error.code, profiles.error.message, profiles.error.status);
  }
  const rankedEntries = rankingResult.value.map((row, index) =>
    rankedEntry(row, index + 1, profiles.value.get(row.player_id))
  );
  const self = rankedEntries.find((entry) => entry.player_id === player.value.id) ?? null;
  const entries = rankedEntries.slice(0, RANKING_TOP_LIMIT);
  return jsonResponse({
    ok: true,
    ranking: {
      season: season.value,
      entries,
      self,
      bots_included: false,
      top_limit: RANKING_TOP_LIMIT,
      total_ranked: rankedEntries.length,
      self_in_top: self !== null && self.rank <= RANKING_TOP_LIMIT,
      scoring_model: ARENA_SCORING_MODEL,
    },
  });
}

async function loadPlayer(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(auth.userId)}&${
      saveTypeQuery(auth.saveType)
    }&select=id,username,save_type,level,power&limit=1`,
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

async function loadPlayerProfiles(
  config: EdgeConfig,
  playerIds: string[],
): Promise<{ value: Map<string, PlayerRow>; error: null } | { value: null; error: RestError }> {
  const uniqueIds = [...new Set(playerIds)].filter((id) => UUID_PATTERN.test(id));
  if (uniqueIds.length === 0) {
    return { value: new Map(), error: null };
  }

  const result = await restRequest<PlayerRow[]>(
    config,
    `players?id=in.(${
      uniqueIds.map((id) => encodeURIComponent(id)).join(",")
    })&select=id,username,save_type,level,power`,
    { method: "GET" },
  );
  if (result.error !== null) {
    return { value: null, error: stateReadError() };
  }

  return {
    value: new Map(result.value.map((profile) => [profile.id, profile])),
    error: null,
  };
}

function rankedEntry(row: RankingRow, rank: number, profile: PlayerRow | undefined): RankedEntry {
  const username = profile?.username ?? `player_${row.player_id.slice(0, 8)}`;
  const saveType = profile?.save_type ?? "normal";
  return {
    ...row,
    rank,
    username,
    player: {
      id: row.player_id,
      username,
      save_type: saveType,
      save_badge: saveType === "progression_lab" ? "lab" : "normal",
      level: numberValue(profile?.level, 1),
      power: numberValue(profile?.power, 0),
    },
  };
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
  const saveType = saveTypeFromRequest(request);
  if (saveType === null) {
    return {
      value: null,
      error: {
        code: "INVALID_SAVE_TYPE",
        message: "Save type must be normal or progression_lab.",
        status: 400,
      },
    };
  }
  return { value: { userId: payload.sub, saveType }, error: null };
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
