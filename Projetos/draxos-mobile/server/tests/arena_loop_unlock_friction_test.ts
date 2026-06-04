import { arenaTierUnlockState } from "../functions/_shared/pve_arena_catalog.ts";

const SERVER_MIGRATION =
  "server/schema/migrations/202605310004_arena_loop_unlock_friction.sql";
const SUPABASE_MIGRATION =
  "supabase/migrations/202605310004_arena_loop_unlock_friction.sql";

Deno.test("arena loop unlock migration is mirrored and updates level with arena XP", async () => {
  const serverMigration = await Deno.readTextFile(
    projectFile(SERVER_MIGRATION),
  );
  const supabaseMigration = await Deno.readTextFile(
    projectFile(SUPABASE_MIGRATION),
  );
  assertEq(serverMigration, supabaseMigration, "Track 21 migration mirrors");

  for (
    const required of [
      "create or replace function public.foundation_level_for_xp_v1",
      "level = greatest(",
      "public.foundation_level_for_xp_v1(coalesce(xp, 0) + greatest(0, xp_delta), 40)",
      "return coalesce(reservation_payload->'response_payload', '{}'::jsonb);",
      "'ARENA_PVE_DOES_NOT_RANK'",
    ]
  ) {
    assertIncludes(serverMigration, required);
  }
});

Deno.test("tutorial first clear XP reaches first real Arena unlock level", async () => {
  const rewardsPayload = await readJson("data/definitions/arena_rewards.json");
  const firstClearXp = firstClearXpFor(
    rewardById(rewardsPayload, "reward_s1_1d_d00"),
  );
  assert(
    firstClearXp >= xpForLevel(3),
    "tutorial first clear should reach level 3",
  );
  assert(
    firstClearXp < xpForLevel(4),
    "tutorial first clear should not skip level 4",
  );
  assertEq(levelForXp(firstClearXp), 3);

  const unlocks = arenaTierUnlockState(
    {
      tutorial_completed: true,
      best_completed_difficulty: 0,
      best_completed_length: 1,
      metadata: {
        completed_tiers: { "arena_tutorial_cinzas:s1_d00_intro": true },
        completed_arenas: { arena_tutorial_cinzas: true },
      },
    },
    { level: levelForXp(firstClearXp), power: 90 },
    "arena_cinzas_curta",
    "s1_d00_intro",
  );
  assertEq(unlocks.length, 1);
  assertEq(
    unlocks[0].unlocked,
    true,
    "first real Arena should unlock after tutorial",
  );
});

Deno.test("first real Arena first clear XP reaches next difficulty unlock level", async () => {
  const rewardsPayload = await readJson("data/definitions/arena_rewards.json");
  const tutorialXp = firstClearXpFor(
    rewardById(rewardsPayload, "reward_s1_1d_d00"),
  );
  const firstRealXp = firstClearXpFor(
    rewardById(rewardsPayload, "reward_s1_3d_d00"),
  );
  const totalXp = tutorialXp + firstRealXp;

  assertEq(levelForXp(tutorialXp), 3);
  assertEq(levelForXp(totalXp), 5);

  const unlocks = arenaTierUnlockState(
    {
      tutorial_completed: true,
      best_completed_difficulty: 0,
      best_completed_length: 3,
      metadata: {
        completed_tiers: {
          "arena_tutorial_cinzas:s1_d00_intro": true,
          "arena_cinzas_curta:s1_d00_intro": true,
        },
        completed_arenas: {
          arena_tutorial_cinzas: true,
          arena_cinzas_curta: true,
        },
      },
    },
    { level: levelForXp(totalXp), power: 180 },
    "arena_cinzas_curta",
    "s1_d01_aprendiz",
  );
  assertEq(unlocks.length, 1);
  assertEq(
    unlocks[0].unlocked,
    true,
    "next Arena difficulty should unlock after first real clear",
  );
});

Deno.test("client Arena loop removes loadout click and continues inside Arena", async () => {
  const lifecycle = await Deno.readTextFile(
    projectFile("modes/boot/flows/arena_lifecycle_flow.gd"),
  );
  const presenter = await Deno.readTextFile(
    projectFile("modes/boot/surfaces/arena_surface_presenter.gd"),
  );

  assertIncludes(
    lifecycle,
    'await _complete_arena_mutation(host, mutation, result, AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, "Arena iniciada. Loadout travado.")',
  );
  assertIncludes(
    lifecycle,
    'host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)',
  );
  assertNotIncludes(lifecycle, "_refresh_arena_selection");
  assertIncludes(lifecycle, "SupabaseClient.fetch_arena_state");
  assertIncludes(presenter, '"Continuar na Arena"');
  assertIncludes(presenter, '"Proximo desafio"');
  assertNotIncludes(presenter, '"Confirmar resumo"');
});

Deno.test("arena claim returns selection delta for post-claim responsiveness", async () => {
  const serverFunction = await Deno.readTextFile(
    projectFile("server/functions/arena/index.ts"),
  );
  const supabaseFunction = await Deno.readTextFile(
    projectFile("supabase/functions/arena/index.ts"),
  );

  assertEq(serverFunction, supabaseFunction, "Arena function mirrors");
  assertIncludes(serverFunction, "arenaStateDeltaPayload");
  assertIncludes(serverFunction, "arena_state: arenaState.value");
  assertIncludes(serverFunction, 'schema_version: "pve_arena_state_v1"');
});

function xpForLevel(level: number): number {
  return Math.max(0, 3 * (level ** 3 - 6 * level ** 2 + 17 * level - 12));
}

function levelForXp(xp: number, cap = 40): number {
  let level = 1;
  for (let candidate = 1; candidate <= cap; candidate += 1) {
    if (xpForLevel(candidate) <= xp) level = candidate;
    else break;
  }
  return level;
}

function rewardById(
  rewardsPayload: Record<string, unknown>,
  rewardId: string,
): Record<string, unknown> {
  const reward = objectItems(rewardsPayload).find((item) =>
    stringField(item, "id") === rewardId
  );
  if (reward === undefined) {
    throw new Error(`${rewardId} should exist`);
  }
  return reward;
}

function firstClearXpFor(reward: Record<string, unknown>): number {
  const resources = objectField(reward, "resources");
  return Math.round(
    numberField(resources, "xp") *
      numberField(reward, "first_clear_multiplier"),
  );
}

async function readJson(
  relativePath: string,
): Promise<Record<string, unknown>> {
  const payload = JSON.parse(
    await Deno.readTextFile(projectFile(relativePath)),
  );
  return assertObject(payload);
}

function projectFile(relativePath: string): string {
  const cwd = Deno.cwd().replaceAll("\\", "/");
  if (cwd.endsWith("/draxos-mobile")) {
    return relativePath;
  }
  return `Projetos/draxos-mobile/${relativePath}`;
}

function objectItems(
  payload: Record<string, unknown>,
): Record<string, unknown>[] {
  return arrayField(payload, "items").map((item) => assertObject(item));
}

function objectField(
  payload: Record<string, unknown>,
  key: string,
): Record<string, unknown> {
  return assertObject(payload[key], `field ${key} should be an object`);
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(`field ${key} should be a non-empty string`);
  }
  return value;
}

function numberField(payload: Record<string, unknown>, key: string): number {
  const value = payload[key];
  if (typeof value !== "number" || Number.isNaN(value)) {
    throw new Error(`field ${key} should be a number`);
  }
  return value;
}

function arrayField(payload: Record<string, unknown>, key: string): unknown[] {
  const value = payload[key];
  if (!Array.isArray(value)) {
    throw new Error(`field ${key} should be an array`);
  }
  return value;
}

function assertObject(
  value: unknown,
  message = "value should be an object",
): Record<string, unknown> {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    throw new Error(message);
  }
  return value as Record<string, unknown>;
}

function assertIncludes(value: string, expected: string): void {
  if (!value.includes(expected)) {
    throw new Error(`expected text to include ${expected}`);
  }
}

function assertNotIncludes(value: string, expected: string): void {
  if (value.includes(expected)) {
    throw new Error(`expected text not to include ${expected}`);
  }
}

function assertEq(
  actual: unknown,
  expected: unknown,
  message = "values should match",
): void {
  if (actual !== expected) {
    throw new Error(
      `${message}. Expected ${JSON.stringify(expected)}, got ${
        JSON.stringify(actual)
      }`,
    );
  }
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}
