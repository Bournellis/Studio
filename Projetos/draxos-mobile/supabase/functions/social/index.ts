import { emptyResponse, jsonResponse } from "../_shared/http.ts";
import {
  SAVE_TYPE_NORMAL,
  type SaveType,
  saveTypeFromRequest,
  saveTypeQuery,
} from "../_shared/save_context.ts";

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

interface IdempotencyRow {
  response_payload: unknown;
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
const CHAT_RATE_LIMIT_SECONDS = 2;

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return emptyResponse();
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
});

async function handleState(auth: AuthContext, config: EdgeConfig): Promise<Response> {
  const context = await loadSocialContext(auth, config);
  if (context.error !== null) {
    return errorResponse(context.error.code, context.error.message, context.error.status);
  }
  return jsonResponse(await socialStatePayload(config, context.value));
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
  const existing = await loadIdempotency(config, player.id, "friends/add", requestId);
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) return jsonResponse(existing.value);

  const targetResult = await restRequest<PlayerRow[]>(
    config,
    `players?username=eq.${
      encodeURIComponent(username)
    }&select=id,auth_user_id,username,save_type,level,power&limit=1`,
    { method: "GET" },
  );
  if (targetResult.error !== null) {
    return errorResponse("FRIEND_ADD_FAILED", "Unable to find player.", 500);
  }
  const target = targetResult.value[0] ?? null;
  if (target === null) {
    return errorResponse("USER_NOT_FOUND", "Friend username was not found.", 404);
  }
  const targetSocial = await loadCanonicalSocialPlayer(config, target);
  if (targetSocial.error !== null) {
    return errorResponse(
      targetSocial.error.code,
      targetSocial.error.message,
      targetSocial.error.status,
    );
  }
  if (targetSocial.value.auth_user_id === player.auth_user_id) {
    return errorResponse("INVALID_FRIEND", "Cannot add yourself.", 400);
  }

  for (
    const edge of [
      { player_id: player.id, friend_id: targetSocial.value.id, status: "accepted" },
      { player_id: targetSocial.value.id, friend_id: player.id, status: "accepted" },
    ]
  ) {
    const insert = await restRequest<unknown>(config, "friendships", {
      method: "POST",
      headers: { prefer: "resolution=merge-duplicates,return=minimal" },
      body: JSON.stringify(edge),
    });
    if (insert.error !== null) {
      return errorResponse("FRIEND_ADD_FAILED", "Unable to add friend.", 500);
    }
  }

  const payload = await socialStatePayload(config, context.value);
  await insertIdempotency(config, player.id, "friends/add", requestId, payload);
  return jsonResponse(payload);
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
  const existing = await loadIdempotency(config, player.id, "guild/create", requestId);
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) return jsonResponse(existing.value);

  const currentGuild = await loadGuildMembership(config, player.id);
  if (currentGuild.error !== null) {
    return errorResponse(
      currentGuild.error.code,
      currentGuild.error.message,
      currentGuild.error.status,
    );
  }
  if (currentGuild.value !== null) {
    return errorResponse("GUILD_ALREADY_JOINED", "Player already belongs to a guild.", 409);
  }

  const guildInsert = await restRequest<GuildRow[]>(config, "guilds?select=*", {
    method: "POST",
    headers: { prefer: "return=representation" },
    body: JSON.stringify({ name: guildName, owner_id: player.id }),
  });
  if (guildInsert.error !== null) {
    return errorResponse("GUILD_CREATE_FAILED", "Unable to create guild.", 409);
  }
  const guild = guildInsert.value[0];
  await restRequest<unknown>(config, "guild_members", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({ guild_id: guild.id, player_id: player.id, role: "owner" }),
  });
  for (const structureId of GUILD_STRUCTURES) {
    await restRequest<unknown>(config, "guild_structures", {
      method: "POST",
      headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
      body: JSON.stringify({ guild_id: guild.id, structure_id: structureId, level: 1 }),
    });
  }
  await restRequest<unknown>(config, "chat_channels", {
    method: "POST",
    headers: { prefer: "resolution=ignore-duplicates,return=minimal" },
    body: JSON.stringify({ channel_type: "guild", guild_id: guild.id }),
  });

  const payload = await socialStatePayload(config, context.value);
  await insertIdempotency(config, player.id, "guild/create", requestId, payload);
  return jsonResponse(payload);
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
  const existing = await loadIdempotency(config, player.id, "guild/join", requestId);
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) return jsonResponse(existing.value);

  const guildResult = await restRequest<GuildRow[]>(
    config,
    `guilds?name=ilike.${encodeURIComponent(guildName)}&select=*&limit=1`,
    { method: "GET" },
  );
  if (guildResult.error !== null) {
    return errorResponse("GUILD_JOIN_FAILED", "Unable to find guild.", 500);
  }
  const targetGuild = guildResult.value[0] ?? null;
  if (targetGuild === null) {
    return errorResponse("GUILD_NOT_FOUND", "Guild name was not found.", 404);
  }

  const currentGuild = await loadGuildMembership(config, player.id);
  if (currentGuild.error !== null) {
    return errorResponse(
      currentGuild.error.code,
      currentGuild.error.message,
      currentGuild.error.status,
    );
  }
  if (currentGuild.value !== null && currentGuild.value.guild_id !== targetGuild.id) {
    return errorResponse("GUILD_ALREADY_JOINED", "Player already belongs to a guild.", 409);
  }
  if (currentGuild.value === null && targetGuild.member_count >= 50) {
    return errorResponse("GUILD_FULL", "Guild member limit reached.", 409);
  }

  if (currentGuild.value === null) {
    const insert = await restRequest<unknown>(config, "guild_members", {
      method: "POST",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({ guild_id: targetGuild.id, player_id: player.id, role: "member" }),
    });
    if (insert.error !== null) {
      return errorResponse("GUILD_JOIN_FAILED", "Unable to join guild.", 500);
    }
    await restRequest<unknown>(config, `guilds?id=eq.${encodeURIComponent(targetGuild.id)}`, {
      method: "PATCH",
      headers: { prefer: "return=minimal" },
      body: JSON.stringify({
        member_count: targetGuild.member_count + 1,
        updated_at: new Date().toISOString(),
      }),
    });
  }

  const payload = await socialStatePayload(config, context.value);
  await insertIdempotency(config, player.id, "guild/join", requestId, payload);
  return jsonResponse(payload);
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
  const existing = await loadIdempotency(config, player.id, "chat/send", requestId);
  if (existing.error !== null) {
    return errorResponse(existing.error.code, existing.error.message, existing.error.status);
  }
  if (existing.value !== null) return jsonResponse(existing.value);

  const membership = await loadGuildMembership(config, player.id);
  if (membership.error !== null) {
    return errorResponse(membership.error.code, membership.error.message, membership.error.status);
  }
  if (membership.value === null) {
    return errorResponse("GUILD_REQUIRED", "Join a guild before using guild chat.", 409);
  }

  const channelResult = await restRequest<ChatChannelRow[]>(
    config,
    `chat_channels?channel_type=eq.guild&guild_id=eq.${
      encodeURIComponent(membership.value.guild_id)
    }&select=id,channel_type,guild_id&limit=1`,
    { method: "GET" },
  );
  if (channelResult.error !== null || channelResult.value[0] === undefined) {
    return errorResponse("CHAT_SEND_FAILED", "Guild chat channel is unavailable.", 500);
  }
  const channel = channelResult.value[0];
  const since = new Date(Date.now() - CHAT_RATE_LIMIT_SECONDS * 1000).toISOString();
  const recentMessages = await restRequest<ChatMessageRow[]>(
    config,
    `chat_messages?channel_id=eq.${encodeURIComponent(channel.id)}&sender_id=eq.${
      encodeURIComponent(player.id)
    }&deleted_at=is.null&created_at=gte.${
      encodeURIComponent(since)
    }&select=id,channel_id,sender_id,content,created_at&limit=1`,
    { method: "GET" },
  );
  if (recentMessages.error !== null) {
    return errorResponse("CHAT_SEND_FAILED", "Unable to check chat rate limit.", 500);
  }
  if ((recentMessages.value ?? []).length > 0) {
    return errorResponse(
      "CHAT_RATE_LIMITED",
      "Wait a few seconds before sending another message.",
      429,
    );
  }

  const messageInsert = await restRequest<ChatMessageRow[]>(config, "chat_messages?select=*", {
    method: "POST",
    headers: { prefer: "return=representation" },
    body: JSON.stringify({
      channel_id: channel.id,
      sender_id: player.id,
      content,
    }),
  });
  if (messageInsert.error !== null) {
    return errorResponse("CHAT_SEND_FAILED", "Unable to send chat message.", 500);
  }

  const payload = {
    ...(await socialStatePayload(config, context.value)),
    message: messageInsert.value[0],
  };
  await insertIdempotency(config, player.id, "chat/send", requestId, payload);
  return jsonResponse(payload);
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

async function loadCanonicalSocialPlayer(
  config: EdgeConfig,
  player: PlayerRow,
): Promise<{ value: PlayerRow; error: null } | { value: null; error: RestError }> {
  if (player.save_type === SAVE_TYPE_NORMAL) return { value: player, error: null };
  const normalPlayer = await loadPlayerBySaveType(config, player.auth_user_id, SAVE_TYPE_NORMAL);
  if (normalPlayer.error !== null) return { value: null, error: normalPlayer.error };
  return { value: normalPlayer.value ?? player, error: null };
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

async function loadIdempotency(
  config: EdgeConfig,
  playerId: string,
  endpoint: string,
  requestId: string,
) {
  const result = await restRequest<IdempotencyRow[]>(
    config,
    `idempotency_keys?player_id=eq.${encodeURIComponent(playerId)}&endpoint=eq.${
      encodeURIComponent(endpoint)
    }&request_id=eq.${encodeURIComponent(requestId)}&select=response_payload&limit=1`,
    { method: "GET" },
  );
  if (result.error !== null) return { value: null, error: stateReadError() };
  return { value: result.value[0]?.response_payload ?? null, error: null };
}

async function insertIdempotency(
  config: EdgeConfig,
  playerId: string,
  endpoint: string,
  requestId: string,
  responsePayload: unknown,
): Promise<void> {
  await restRequest<unknown>(config, "idempotency_keys", {
    method: "POST",
    headers: { prefer: "return=minimal" },
    body: JSON.stringify({
      player_id: playerId,
      endpoint,
      request_id: requestId,
      response_payload: responsePayload,
    }),
  });
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
