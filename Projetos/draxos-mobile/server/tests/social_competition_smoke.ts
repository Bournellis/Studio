const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "http://127.0.0.1:54321";
const PUBLISHABLE_KEY = Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ??
  "sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH";

interface JsonObject {
  [key: string]: unknown;
}

const auth = await postJson(
  `${SUPABASE_URL}/auth/v1/signup`,
  { data: { provider: "guest" } },
  baseHeaders(),
  false,
);
const accessToken = stringField(auth, "access_token");
assert(accessToken !== "", "anonymous auth should return access_token");

const headers = {
  ...baseHeaders(),
  authorization: `Bearer ${accessToken}`,
};

const unauthenticatedSocial = await getJson(
  `${SUPABASE_URL}/functions/v1/social/state`,
  baseHeaders(),
  false,
);
assertEq(
  errorCode(unauthenticatedSocial),
  "UNAUTHENTICATED",
  "social/state should require auth",
);

await postJson(`${SUPABASE_URL}/functions/v1/account/guest`, {
  invite_code: "ALPHA-TEST",
  device_label: "deno-social-smoke",
  request_id: crypto.randomUUID(),
}, headers);

const socialState = await getJson(
  `${SUPABASE_URL}/functions/v1/social/state`,
  headers,
);
assert(
  isObject(objectField(socialState, "social")),
  "social state should exist",
);

const guildRequestId = crypto.randomUUID();
const guildName = `Conclave ${guildRequestId.slice(0, 8)}`;
const firstGuild = await postJson(
  `${SUPABASE_URL}/functions/v1/social/guild/create`,
  { request_id: guildRequestId, name: guildName },
  headers,
);
const secondGuild = await postJson(
  `${SUPABASE_URL}/functions/v1/social/guild/create`,
  { request_id: guildRequestId, name: guildName },
  headers,
);
const guild = objectField(objectField(firstGuild, "social"), "guild");
const repeatedGuild = objectField(objectField(secondGuild, "social"), "guild");
assertEq(guild.id, repeatedGuild.id, "guild/create should be idempotent");
assertEq(guild.name, guildName, "guild name should match request");
assertEq(
  arrayField(objectField(firstGuild, "social"), "guild_structures").length,
  4,
  "guild should initialize four structures",
);

const chatRequestId = crypto.randomUUID();
const firstChat = await postJson(
  `${SUPABASE_URL}/functions/v1/social/chat/send`,
  { request_id: chatRequestId, content: "Primeiro pulso social." },
  headers,
);
const secondChat = await postJson(
  `${SUPABASE_URL}/functions/v1/social/chat/send`,
  { request_id: chatRequestId, content: "Primeiro pulso social." },
  headers,
);
assertEq(
  objectField(firstChat, "message").id,
  objectField(secondChat, "message").id,
  "chat/send should be idempotent",
);

const matchmaking = await getJson(
  `${SUPABASE_URL}/functions/v1/competition/matchmaking/preview`,
  headers,
);
const selectedOpponent = objectField(
  objectField(matchmaking, "matchmaking"),
  "selected_opponent",
);
assertEq(
  selectedOpponent.is_bot,
  true,
  "matchmaking should fall back to bot pool",
);
assertEq(selectedOpponent.is_ranked, false, "bot should not be ranked");

const ranking = await getJson(
  `${SUPABASE_URL}/functions/v1/competition/ranking/current`,
  headers,
);
assertEq(
  objectField(ranking, "ranking").bots_included,
  false,
  "ranking should exclude bots",
);
assert(
  isObject(objectField(objectField(ranking, "ranking"), "self")),
  "ranking should include self row",
);

const directGuildInsert = await postJson(
  `${SUPABASE_URL}/rest/v1/guilds`,
  {
    name: `Forbidden ${crypto.randomUUID().slice(0, 6)}`,
    owner_id: guild.owner_id,
  },
  headers,
  false,
);
assert(
  !Boolean(directGuildInsert.ok),
  "direct anon insert into guilds should be blocked by RLS",
);

console.log("[social-competition-smoke] OK", {
  guild_id: guild.id,
  opponent: selectedOpponent.id,
  ranking_points:
    objectField(objectField(ranking, "ranking"), "self").arena_points,
});

function baseHeaders(): Record<string, string> {
  return {
    apikey: PUBLISHABLE_KEY,
    "content-type": "application/json",
  };
}

async function postJson(
  url: string,
  body: JsonObject,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, {
    method: "POST",
    headers,
    body: JSON.stringify(body),
  });
  return await parseResponse(response, requireOk);
}

async function getJson(
  url: string,
  headers: Record<string, string>,
  requireOk = true,
): Promise<JsonObject> {
  const response = await fetch(url, { method: "GET", headers });
  return await parseResponse(response, requireOk);
}

async function parseResponse(
  response: Response,
  requireOk: boolean,
): Promise<JsonObject> {
  const text = await response.text();
  const payload = parseJson(text);
  assert(isObject(payload), `response should be a JSON object: ${text}`);
  if (requireOk) {
    assert(
      response.ok,
      `request failed with status ${response.status}: ${text}`,
    );
    assert(payload.ok === true, `response ok should be true: ${text}`);
  }
  return payload;
}

function objectField(payload: JsonObject, key: string): JsonObject {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function arrayField(payload: JsonObject, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: JsonObject, key: string): string {
  const value = payload[key];
  return typeof value === "string" ? value : "";
}

function errorCode(payload: JsonObject): string {
  return stringField(objectField(payload, "error"), "code");
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
