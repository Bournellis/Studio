import { arenaOpponentCombatantFromBot } from "../functions/_shared/pve_arena_combatants.ts";
import {
  arenaTierById,
  pveEnemyDefinition,
} from "../functions/_shared/pve_arena_catalog.ts";
import { simulateFirstSliceBattle } from "../functions/_shared/battle_simulator.ts";
import type {
  BattleBotBuildRow,
  CombatantBuild,
} from "../functions/_shared/battle_combatants.ts";

const SERVER_COMBATANTS_MODULE =
  "server/functions/_shared/pve_arena_combatants.ts";
const SUPABASE_COMBATANTS_MODULE =
  "supabase/functions/_shared/pve_arena_combatants.ts";
const SERVER_ARENA_FUNCTION = "server/functions/arena/index.ts";

Deno.test("arena PVE combatant tuning module is mirrored", async () => {
  const serverModule = await readProjectText(SERVER_COMBATANTS_MODULE);
  const supabaseModule = await readProjectText(SUPABASE_COMBATANTS_MODULE);

  assertEq(
    normalizeNewlines(serverModule),
    normalizeNewlines(supabaseModule),
    "server and supabase PVE Arena combatant tuning should stay mirrored",
  );
});

Deno.test("fresh post-tutorial player clears first real Arena runway sequence", async () => {
  const tier = arenaTierById("arena_cinzas_curta", "s1_d00_intro");
  if (tier === null) {
    throw new Error("first real Arena tier should exist");
  }

  const bots = await botBuildsById();
  const player = postTutorialPlayerCombatant();
  for (const [index, enemyId] of tier.enemy_sequence.entries()) {
    const enemy = pveEnemyDefinition(enemyId);
    if (enemy === null) {
      throw new Error(`enemy ${enemyId} should exist`);
    }
    const bot = bots.get(enemy.source_bot_build_id);
    if (bot === undefined) {
      throw new Error(`bot ${enemy.source_bot_build_id} should exist`);
    }

    const opponent = arenaOpponentCombatantFromBot(
      bot,
      enemyId,
      tier,
      tier.duel_power_targets[index] ?? null,
    );
    const result = simulateFirstSliceBattle({
      battleId: `arena-sequence-${index + 1}`,
      seed: `arena-sequence-test-${index + 1}`,
      player,
      opponent,
    });

    assertEq(
      result.battleLog.result.winner,
      "player",
      `fresh post-tutorial player should clear duel ${
        index + 1
      } against ${enemyId}`,
    );
  }
});

Deno.test("first real Arena guard is a readable pre-familiar opponent", async () => {
  const tier = arenaTierById("arena_cinzas_curta", "s1_d00_intro");
  const enemy = pveEnemyDefinition("pve_guardiao_barreira");
  if (tier === null || enemy === null) {
    throw new Error("first real guard setup should exist");
  }
  const bots = await botBuildsById();
  const bot = bots.get(enemy.source_bot_build_id);
  if (bot === undefined) {
    throw new Error(`bot ${enemy.source_bot_build_id} should exist`);
  }

  const opponent = arenaOpponentCombatantFromBot(bot, enemy.id, tier, 158);
  assertEq(opponent.displayName, enemy.display_name);
  assertEq(opponent.level, 2);
  assertEq(opponent.weaponLevel, 1);
  assertEq(opponent.weaponQualityTier, 0);
  assertEq(opponent.passiveId, undefined);
  assertEq(opponent.petId, undefined);
  assertEq(opponent.spellIds.length, 1);
});

Deno.test("rank zero real Arena first clear is not reduced as tutorial repeat", async () => {
  const edgeFunction = await readProjectText(SERVER_ARENA_FUNCTION);
  assertIncludes(
    edgeFunction,
    "hasCompletedTier(progress, attempt.arena_id, attempt.difficulty_id)",
    "repeat reward should still detect already completed exact tiers",
  );
  assertIncludes(
    edgeFunction,
    'attempt.arena_id === "arena_tutorial_cinzas"',
    "tutorial repeats may still use the tutorial completion marker",
  );
  assertNotIncludes(
    edgeFunction,
    "attempt.difficulty_rank <= 0",
    "rank zero alone must not reduce the first real Arena reward",
  );
});

function postTutorialPlayerCombatant(): CombatantBuild {
  return {
    id: "player-post-tutorial",
    displayName: "Draxos",
    level: 3,
    weaponId: "varinha_cinzas",
    weaponLevel: 1,
    weaponQualityTier: 0,
    spellIds: ["sussurro_medo"],
    spellLevels: { sussurro_medo: 3 },
  };
}

async function botBuildsById(): Promise<Map<string, BattleBotBuildRow>> {
  const payload = JSON.parse(
    await readProjectText("data/definitions/bot_builds.json"),
  );
  if (!isObject(payload) || !Array.isArray(payload.items)) {
    throw new Error("bot builds payload should contain items");
  }
  const output = new Map<string, BattleBotBuildRow>();
  for (const item of payload.items) {
    if (!isObject(item) || typeof item.id !== "string") {
      continue;
    }
    output.set(item.id, { id: item.id, build_data: item });
  }
  return output;
}

async function readProjectText(relativePath: string): Promise<string> {
  return await Deno.readTextFile(
    new URL(`../../${relativePath}`, import.meta.url),
  );
}

function normalizeNewlines(value: string): string {
  return value.replaceAll("\r\n", "\n");
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assertEq<T>(actual: T, expected: T, message?: string): void {
  if (actual !== expected) {
    throw new Error(
      message ?? `Expected ${String(expected)}, got ${String(actual)}`,
    );
  }
}

function assertIncludes(
  source: string,
  expected: string,
  message?: string,
): void {
  if (!source.includes(expected)) {
    throw new Error(message ?? `Expected source to include ${expected}`);
  }
}

function assertNotIncludes(
  source: string,
  expected: string,
  message?: string,
): void {
  if (source.includes(expected)) {
    throw new Error(message ?? `Expected source not to include ${expected}`);
  }
}
