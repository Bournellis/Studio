import { emptyResponse, jsonResponse, withCorsResponse } from "../_shared/http.ts";
import { validateApiVersion } from "../_shared/api_version.ts";
import {
  SAVE_TYPE_NORMAL,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";
import {
  type FoundationGameSaveRow,
  loadFoundationGameSave,
  mapFoundationDatabaseError,
  mutationRequestHash,
} from "../_shared/transactional_mutation.ts";
import { stateEnvelope } from "../_shared/response_envelope.ts";

type Route = "state" | "friend_add" | "guild_create" | "guild_join" | "chat_send";

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
  auth_user_id: string;
  username: string | null;
  save_type: SaveType;
  level: number;
  power: number;
}

interface SocialContext {
  activePlayer: PlayerRow;
  socialPlayer: PlayerRow;
  saveType: SaveType;
  fallbackToActiveSave: boolean;
}

interface FriendshipRow {
  player_id: string;
  friend_id: string;
  status: string;
  created_at: string;
}

interface GuildRow {
  id: string;
  name: string;
  owner_id: string;
  level: number;
  member_count: number;
  created_at: string;
  updated_at: string;
}

interface GuildMemberRow {
  guild_id: string;
  player_id: string;
  role: string;
  joined_at: string;
}

interface GuildStructureRow {
  guild_id: string;
  structure_id: string;
  level: number;
  updated_at: string;
}

interface ChatChannelRow {
  id: string;
  channel_type: string;
  guild_id: string | null;
}

interface ChatMessageRow {
  id: string;
  channel_id: string;
  sender_id: string;
  content: string;
  created_at: string;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const GUILD_STRUCTURES = [
  "oficina_ritual",
  "condensador_astral",
  "arquivo_de_dominio",
  "cofre_abissal",
];

Deno.serve(async (request: Request) => {
  return withCorsResponse(request, await handleCorsRequest(request));
});

async function handleCorsRequest(request: Request): Promise<Response> {
  if (request.method === "OPTIONS") {
    return emptyResponse();
  }

  const apiVersionError = validateApiVersion(request);
  if (apiVersionError !== null) {
    return apiVersionError;
  }

  try {
    const route = resolveRoute(new URL(request.url).pathname);
    if (route === null) {
      return errorResponse("NOT_FOUND", "Unknown social endpoint.", 404);
    }
    if (route === "state" && request.method !== "GET") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use GET /social/state.", 405);
    }
    if (route !== "state" && request.method !== "POST") {
      return errorResponse("METHOD_NOT_ALLOWED", "Use POST for social mutations.", 405);
    }

    const auth = decodeAuthContext(request);
    if (auth.error !== null) {
      return errorResponse(auth.error.code, auth.error.message, auth.error.status);
    }
    const config = loadConfig();
    if (config.error !== null) {
      return errorResponse(config.error.code, config.error.message, config.error.status);
    }

    if (route === "state") return await handleState(auth.value, config.value);
    if (route === "friend_add") return await handleFriendAdd(request, auth.value, config.value);
    if (route === "guild_create") return await handleGuildCreate(request, auth.value, config.value);
    if (route === "guild_join") return await handleGuildJoin(request, auth.value, config.value);
    return await handleChatSend(request, auth.value, config.value);
  } catch (error) {
    console.error(error);
    return errorResponse("INTERNAL_ERROR", "Unexpected social service error.", 500);
  }

}

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const startedAtMs = performance.now();
  const context = await loadSocialContext(auth, config);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }
  return jsonResponse(stateEnvelope(await socialStatePayload(config, context.value), {
    surface: "social",
    saveType: auth.saveType,
    startedAtMs,
  }));
}

async function handleFriendAdd(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const username = stringField(body, "username");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (username === "") return errorResponse("INVALID_USERNAME", "username is required.", 400);

  const context = await loadSocialContext(auth, config);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }
  const player = context.value.socialPlayer;
  const gameSave = await loadSocialGameSave(config, context.value, player);
  if (gameSave.error !== null) {
    return errorResponse(gameSave.error.code, gameSave.error.message, gameSave.error.status);
  }
  const requestHash = await mutationRequestHash("social/friends/add", body, {
    request_id: requestId,
    username,
  });
  const rpc = await restRequest<unknown>(config, "rpc/social_friend_add_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: gameSave.value.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        username,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "FRIEND_ADD_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const payload = await socialStatePayload(config, context.value);
  return jsonResponse(stateEnvelope(payload, {
    surface: "social",
    saveType: auth.saveType,
  }));
}

async function handleGuildCreate(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const guildName = stringField(body, "name");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (guildName.length < 3 || guildName.length > 32) {
    return errorResponse("INVALID_GUILD_NAME", "Guild name must be 3-32 characters.", 400);
  }

  const context = await loadSocialContext(auth, config);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }
  const player = context.value.socialPlayer;
  const gameSave = await loadSocialGameSave(config, context.value, player);
  if (gameSave.error !== null) {
    return errorResponse(gameSave.error.code, gameSave.error.message, gameSave.error.status);
  }
  const requestHash = await mutationRequestHash("guild/create", body, {
    request_id: requestId,
    save_type: player.save_type,
    name: guildName,
    structures: GUILD_STRUCTURES,
  });
  const rpc = await restRequest<unknown>(config, "rpc/guild_create_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: gameSave.value.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        name: guildName,
        structures: GUILD_STRUCTURES,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "GUILD_CREATE_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const payload = await socialStatePayload(config, context.value);
  return jsonResponse(stateEnvelope(payload, {
    surface: "social",
    saveType: auth.saveType,
  }));
}

async function handleGuildJoin(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const guildName = stringField(body, "name");
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (guildName.length < 3 || guildName.length > 32) {
    return errorResponse("INVALID_GUILD_NAME", "Guild name must be 3-32 characters.", 400);
  }

  const context = await loadSocialContext(auth, config);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }
  const player = context.value.socialPlayer;
  const gameSave = await loadSocialGameSave(config, context.value, player);
  if (gameSave.error !== null) {
    return errorResponse(gameSave.error.code, gameSave.error.message, gameSave.error.status);
  }
  const requestHash = await mutationRequestHash("guild/join", body, {
    request_id: requestId,
    save_type: player.save_type,
    name: guildName,
  });
  const rpc = await restRequest<unknown>(config, "rpc/guild_join_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: gameSave.value.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        name: guildName,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "GUILD_JOIN_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const payload = await socialStatePayload(config, context.value);
  return jsonResponse(stateEnvelope(payload, {
    surface: "social",
    saveType: auth.saveType,
  }));
}

async function loadSocialGameSave(
  config: EdgeConfig,
  context: SocialContext,
  player: PlayerRow,
): Promise<
  { value: FoundationGameSaveRow; error: null } | { value: null; error: RestError }
> {
  return await loadFoundationGameSave(
    config,
    restRequest,
    player.auth_user_id,
    context.fallbackToActiveSave ? context.saveType : player.save_type,
    player.id,
  );
}

async function handleChatSend(
  request: Request,
  auth: AuthContext,
  config: EdgeConfig,
): Promise<Response> {
  const body = await readJsonObject(request);
  if (body === null) {
    return errorResponse("INVALID_JSON", "Request body must be a JSON object.", 400);
  }
  const requestId = stringField(body, "request_id");
  const content = stringField(body, "content").slice(0, 280);
  if (!UUID_PATTERN.test(requestId)) {
    return errorResponse("INVALID_REQUEST_ID", "request_id must be a UUID.", 400);
  }
  if (content === "") return errorResponse("EMPTY_MESSAGE", "Chat message cannot be empty.", 400);

  const context = await loadSocialContext(auth, config);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }
  const player = context.value.socialPlayer;
  const gameSave = await loadSocialGameSave(config, context.value, player);
  if (gameSave.error !== null) {
    return errorResponse(gameSave.error.code, gameSave.error.message, gameSave.error.status);
  }
  const requestHash = await mutationRequestHash("social/chat/send", body, {
    request_id: requestId,
    content,
  });
  const rpc = await restRequest<unknown>(config, "rpc/social_chat_send_v1", {
    method: "POST",
    body: JSON.stringify({
      p_game_save_id: gameSave.value.id,
      p_request_id: requestId,
      p_request_hash: requestHash,
      p_request_payload: {
        request_id: requestId,
        content,
      },
    }),
  });
  if (rpc.error !== null) {
    const mapped = mapFoundationDatabaseError(rpc.error, "CHAT_SEND_FAILED");
    return errorResponse(mapped.code, mapped.message, mapped.status);
  }

  const payload = await socialStatePayload(config, context.value);
  return jsonResponse(stateEnvelope(payload, {
    surface: "social",
    saveType: auth.saveType,
  }));
}

async function socialStatePayload(config: EdgeConfig, context: SocialContext) {
  const player = context.socialPlayer;
  const friends = await restRequest<FriendshipRow[]>(
    config,
    `friendships?player_id=eq.${
      encodeURIComponent(player.id)
    }&select=player_id,friend_id,status,created_at&order=created_at.desc`,
    { method: "GET" },
  );
  if (friends.error !== null) throw new Error("Unable to load friends.");
  const membership = await loadGuildMembership(config, player.id);
  if (membership.error !== null) throw new Error("Unable to load guild membership.");
  let guild: GuildRow | null = null;
  let members: GuildMemberRow[] = [];
  let structures: GuildStructureRow[] = [];
  let messages: ChatMessageRow[] = [];
  if (membership.value !== null) {
    const guildId = encodeURIComponent(membership.value.guild_id);
    const [guildResult, memberResult, structureResult, channelResult] = await Promise.all([
      restRequest<GuildRow[]>(config, `guilds?id=eq.${guildId}&select=*&limit=1`, {
        method: "GET",
      }),
      restRequest<GuildMemberRow[]>(config, `guild_members?guild_id=eq.${guildId}&select=*`, {
        method: "GET",
      }),
      restRequest<GuildStructureRow[]>(config, `guild_structures?guild_id=eq.${guildId}&select=*`, {
        method: "GET",
      }),
      restRequest<ChatChannelRow[]>(
        config,
        `chat_channels?channel_type=eq.guild&guild_id=eq.${guildId}&select=id,channel_type,guild_id&limit=1`,
        { method: "GET" },
      ),
    ]);
    if (
      guildResult.error !== null ||
      memberResult.error !== null ||
      structureResult.error !== null ||
      channelResult.error !== null
    ) {
      throw new Error("Unable to load guild state.");
    }
    guild = guildResult.value[0] ?? null;
    members = memberResult.value;
    structures = structureResult.value;
    const channel = channelResult.value[0] ?? null;
    if (channel !== null) {
      const messageResult = await restRequest<ChatMessageRow[]>(
        config,
        `chat_messages?channel_id=eq.${
          encodeURIComponent(channel.id)
        }&deleted_at=is.null&select=id,channel_id,sender_id,content,created_at&order=created_at.desc&limit=20`,
        { method: "GET" },
      );
      if (messageResult.error !== null) throw new Error("Unable to load guild chat.");
      messages = messageResult.value;
    }
  }
  const profiles = await loadPlayerProfilesByIds(config, [
    ...(friends.value ?? []).map((friend) => friend.friend_id),
    ...members.map((member) => member.player_id),
    ...messages.map((message) => message.sender_id),
  ]);
  const friendPayloads = (friends.value ?? []).map((friend) => ({
    ...friend,
    friend: profiles.get(friend.friend_id) ?? null,
  }));
  const memberPayloads = members.map((member) => ({
    ...member,
    player: profiles.get(member.player_id) ?? null,
  }));
  const chatPayloads = messages.map((message) => {
    const sender = profiles.get(message.sender_id) ?? null;
    return {
      ...message,
      sender,
      sender_username: sender?.["username"] ?? "desconhecido",
      sender_save_badge: sender?.["save_badge"] ?? "normal",
    };
  });
  return {
    ok: true,
    social: {
      identity: {
        scope: "account",
        viewer_save_type: context.saveType,
        viewer_badge: context.saveType === "progression_lab" ? "lab" : "normal",
        fallback_to_active_save: context.fallbackToActiveSave,
      },
      player: playerProfile(player),
      active_player: playerProfile(context.activePlayer),
      friends: friendPayloads,
      guild,
      guild_members: memberPayloads,
      guild_structures: structures,
      guild_chat: chatPayloads,
    },
  };
}

async function loadSocialContext(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: SocialContext; error: null } | { value: null; error: RestError }> {
  const activePlayer = await loadPlayer(auth, config);
  if (activePlayer.error !== null) {
    return { value: null, error: activePlayer.error };
  }
  if (auth.saveType === SAVE_TYPE_NORMAL) {
    return {
      value: {
        activePlayer: activePlayer.value,
        socialPlayer: activePlayer.value,
        saveType: auth.saveType,
        fallbackToActiveSave: false,
      },
      error: null,
    };
  }

  const normalPlayer = await loadPlayerBySaveType(config, auth.userId, SAVE_TYPE_NORMAL);
  if (normalPlayer.error !== null) {
    return { value: null, error: normalPlayer.error };
  }
  return {
    value: {
      activePlayer: activePlayer.value,
      socialPlayer: normalPlayer.value ?? activePlayer.value,
      saveType: auth.saveType,
      fallbackToActiveSave: normalPlayer.value === null,
    },
    error: null,
  };
}

async function loadPlayer(
  auth: AuthContext,
  config: EdgeConfig,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  const player = await loadPlayerBySaveType(config, auth.userId, auth.saveType);
  if (player.error !== null) return { value: null, error: player.error };
  if (player.value === null) {
    return {
      value: null,
      error: {
        code: "PLAYER_NOT_FOUND",
        message: "Guest account was not created yet.",
        status: 404,
      },
    };
  }
  return { value: player.value, error: null };
}

async function loadPlayerBySaveType(
  config: EdgeConfig,
  authUserId: string,
  saveType: SaveType,
): Promise<{ value: PlayerRow | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?auth_user_id=eq.${encodeURIComponent(authUserId)}&${
      saveTypeQuery(saveType)
    }&select=id,auth_user_id,username,save_type,level,power&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  const player = result.value[0] ?? null;
  return { value: player, error: null };
}

async function loadPlayerProfilesByIds(
  config: EdgeConfig,
  playerIds: string[],
): Promise<Map<string, Record<string, unknown>>> {
  const uniqueIds = [...new Set(playerIds.filter((playerId) => UUID_PATTERN.test(playerId)))];
  if (uniqueIds.length === 0) return new Map();
  const result = await restRequest<PlayerRow[]>(
    config,
    `players?id=in.(${
      uniqueIds.map((playerId) => encodeURIComponent(playerId)).join(",")
    })&select=id,auth_user_id,username,save_type,level,power`,
    { method: "GET" },
  );
  if (result.error !== null) throw new Error("Unable to load social profiles.");
  const profiles = new Map<string, Record<string, unknown>>();
  for (const player of result.value) {
    profiles.set(player.id, playerProfile(player));
  }
  return profiles;
}

function playerProfile(player: PlayerRow): Record<string, unknown> {
  const saveBadge = player.save_type === "progression_lab" ? "lab" : "normal";
  return {
    id: player.id,
    username: player.username,
    save_type: player.save_type,
    save_badge: saveBadge,
    is_lab_save: saveBadge === "lab",
    level: player.level,
    power: player.power,
  };
}

async function loadGuildMembership(
  config: EdgeConfig,
  playerId: string,
): Promise<{ value: GuildMemberRow | null; error: null } | { value: null; error: RestError }> {
  const result = await restRequest<GuildMemberRow[]>(
    config,
    `guild_members?player_id=eq.${encodeURIComponent(playerId)}&select=*&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0] ?? null, error: null };
}

function resolveRoute(pathname: string): Route | null {
  if (pathname.endsWith("/state")) return "state";
  if (pathname.endsWith("/friends/add")) return "friend_add";
  if (pathname.endsWith("/guild/create")) return "guild_create";
  if (pathname.endsWith("/guild/join")) return "guild_join";
  if (pathname.endsWith("/chat/send")) return "chat_send";
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
        message: "Social function is missing Supabase runtime configuration.",
        status: 500,
      },
    };
  }
  return { value: { supabaseUrl: supabaseUrl.replace(/\/$/, ""), serviceRoleKey }, error: null };
}

async function readJsonObject(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const payload: unknown = await request.json();
    return isObject(payload) ? payload : null;
  } catch {
    return null;
  }
}

async function restRequest<T>(
  config: EdgeConfig,
  path: string,
  init: RequestInit,
): Promise<{ value: T; error: null } | { value: null; error: RestError }> {
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
      value: null,
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
  return { code: "STATE_READ_FAILED", message: "Unable to load social state.", status: 500 };
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

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value.trim() : "";
}

function stringValue(value: unknown, fallback: string): string {
  return typeof value === "string" && value !== "" ? value : fallback;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}
