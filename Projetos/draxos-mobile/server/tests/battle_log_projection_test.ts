import {
  type BattleLogBattleRow,
  battleLogFromRow,
  historyEntryFromRow,
  rulesetMetadata,
  rulesetMetadataFromRow,
} from "../functions/_shared/battle_log_projection.ts";
import {
  battleLogFromRow as supabaseBattleLogFromRow,
  historyEntryFromRow as supabaseHistoryEntryFromRow,
  rulesetMetadata as supabaseRulesetMetadata,
  rulesetMetadataFromRow as supabaseRulesetMetadataFromRow,
} from "../../supabase/functions/_shared/battle_log_projection.ts";

const SERVER_MODULE_PATH = "server/functions/_shared/battle_log_projection.ts";
const SUPABASE_MODULE_PATH =
  "supabase/functions/_shared/battle_log_projection.ts";

Deno.test("battle log projection module is mirrored and simulator-free", async () => {
  const serverModule = await Deno.readTextFile(SERVER_MODULE_PATH);
  const supabaseModule = await Deno.readTextFile(SUPABASE_MODULE_PATH);

  assertEq(
    normalizeNewlines(serverModule),
    normalizeNewlines(supabaseModule),
    "server and supabase battle log projection modules should mirror exactly",
  );
  assertNotIncludes(
    serverModule,
    "simulateFirstSliceBattle",
    "projection module must not depend on current simulator code",
  );
  assertNotIncludes(
    serverModule,
    "Deno.serve",
    "projection module must stay out of the Edge HTTP adapter",
  );
});

Deno.test("battle log projection returns saved log metadata without resimulation", () => {
  const player = { id: "player-1" };
  const battle = sampleBattleRow({
    ruleset_id: "published_ruleset",
    ruleset_version: "7",
  });

  const serverLog = battleLogFromRow(player, battle);
  const supabaseLog = supabaseBattleLogFromRow(player, battle);

  assertEq(
    stableStringify(serverLog),
    stableStringify(supabaseLog),
    "server and supabase projection should match",
  );
  assertEq(stringField(serverLog, "schema_version"), "battle_log_v1");
  assertEq(stringField(serverLog, "battle_id"), "battle-1");
  assertEq(stringField(serverLog, "seed"), "seed-1");
  assertEq(stringField(serverLog, "mode"), "FIRST_SLICE_SIM");
  assertEq(numberField(serverLog, "duration"), 3.75);
  assertEq(arrayField(serverLog, "events").length, 2);

  const ruleset = objectField(serverLog, "ruleset");
  assertEq(stringField(ruleset, "ruleset_id"), "published_ruleset");
  assertEq(stringField(ruleset, "ruleset_version"), "7");

  const participants = objectField(serverLog, "participants");
  const opponent = objectField(participants, "opponent");
  assertEq(
    stringField(opponent, "display_name"),
    "Treinador da Primeira Ruina",
  );
});

Deno.test("history projection summarizes saved rewards and falls back to foundation ruleset", () => {
  const battle = sampleBattleRow({
    reward_payload: {
      type: "MVP_ONLY",
      resources: { xp: 5, ossos: 100 },
    },
    event_log: [],
    ruleset_id: null,
    ruleset_version: null,
  });

  const serverEntry = historyEntryFromRow(battle);
  const supabaseEntry = supabaseHistoryEntryFromRow(battle);

  assertEq(
    stableStringify(serverEntry),
    stableStringify(supabaseEntry),
    "server and supabase history projection should match",
  );
  assertEq(stringField(serverEntry, "mode"), "MVP_ONLY");
  assertEq(numberField(serverEntry, "duration"), 4.2);
  assertEq(numberField(serverEntry, "event_count"), 0);

  const rewards = objectField(serverEntry, "rewards");
  const resources = objectField(rewards, "resources");
  assertEq(numberField(resources, "xp"), 5);
  assertEq(numberField(resources, "ossos"), 100);

  const fallbackRuleset = rulesetMetadataFromRow(battle);
  assertEq(
    stableStringify(fallbackRuleset),
    stableStringify(rulesetMetadata()),
    "missing row ruleset should fall back to current foundation ruleset",
  );
  assertEq(
    stableStringify(supabaseRulesetMetadataFromRow(battle)),
    stableStringify(supabaseRulesetMetadata()),
    "supabase mirror should use the same fallback",
  );
});

function sampleBattleRow(
  overrides: Partial<BattleLogBattleRow> = {},
): BattleLogBattleRow {
  return {
    id: "battle-1",
    schema_version: "battle_log_v1",
    ruleset_id: "foundation_ruleset_v0",
    ruleset_version: 1,
    seed: "seed-1",
    defender_id: "bot_effect_trainer_01",
    defender_is_bot: true,
    result: { winner: "player", reason: "hp_depleted" },
    event_log: [
      { t: 1.25, seq: 1, type: "hit" },
      { t: 3.75, seq: 2, type: "victory" },
    ],
    reward_payload: {
      type: "FIRST_SLICE_SIM",
      resources: { xp: 30, almas: 2.4 },
    },
    created_at: "2026-05-30T00:00:00.000Z",
    ...overrides,
  };
}

function normalizeNewlines(value: string): string {
  return value.replace(/\r\n/g, "\n");
}

function stableStringify(value: unknown): string {
  if (Array.isArray(value)) {
    return `[${value.map(stableStringify).join(",")}]`;
  }
  if (isObject(value)) {
    return `{${
      Object.keys(value).sort().map((key) =>
        `${JSON.stringify(key)}:${stableStringify(value[key])}`
      ).join(",")
    }}`;
  }
  return JSON.stringify(value);
}

function objectField(
  payload: Record<string, unknown>,
  key: string,
): Record<string, unknown> {
  const value = payload[key];
  assert(isObject(value), `${key} should be an object`);
  return value;
}

function arrayField(payload: Record<string, unknown>, key: string): unknown[] {
  const value = payload[key];
  assert(Array.isArray(value), `${key} should be an array`);
  return value;
}

function stringField(payload: Record<string, unknown>, key: string): string {
  const value = payload[key];
  if (typeof value === "number") return String(value);
  return typeof value === "string" ? value : "";
}

function numberField(payload: Record<string, unknown>, key: string): number {
  const value = payload[key];
  if (typeof value === "number") return value;
  if (typeof value === "string") return Number(value);
  throw new Error(`${key} should be numeric, got ${JSON.stringify(value)}`);
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function assertEq(actual: unknown, expected: unknown, message?: string): void {
  if (actual !== expected) {
    throw new Error(
      `${message ?? "values should match"}. Expected ${
        JSON.stringify(expected)
      }, got ${JSON.stringify(actual)}`,
    );
  }
}

function assertNotIncludes(
  actual: string,
  search: string,
  message: string,
): void {
  if (actual.includes(search)) {
    throw new Error(`${message}. Unexpected ${search}.`);
  }
}
