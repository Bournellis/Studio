import { FOUNDATION_RULESET } from "./foundation_ruleset.ts";

export type BattleLogMode = "MVP_ONLY" | "FIRST_SLICE_SIM";

export interface BattleLogPlayerRow {
  id: string;
}

export interface BattleLogBattleRow {
  id: string;
  schema_version: string;
  ruleset_publication_id?: string | null;
  ruleset_id?: string | null;
  ruleset_version?: number | string | null;
  ruleset_content_hash?: string | null;
  ruleset_simulator_hash?: string | null;
  ruleset_schema_version?: string | null;
  seed: string;
  defender_id: string;
  defender_is_bot: boolean;
  result: unknown;
  event_log: unknown;
  reward_payload: unknown;
  created_at?: string;
}

export function battleLogFromRow(
  player: BattleLogPlayerRow,
  battle: BattleLogBattleRow,
): Record<string, unknown> {
  const rewardPayload = isObject(battle.reward_payload) ? battle.reward_payload : {};
  const events = Array.isArray(battle.event_log) ? battle.event_log : [];
  const rewardType = stringValue(rewardPayload.type, "MVP_ONLY");
  const mode = rewardType === "FIRST_SLICE_SIM" ? "FIRST_SLICE_SIM" : "MVP_ONLY";

  return {
    schema_version: battle.schema_version,
    ruleset: rulesetMetadataFromRow(battle),
    battle_id: battle.id,
    seed: battle.seed,
    mode,
    duration: battleDuration(events),
    participants: {
      player: { id: player.id, display_name: "Draxos" },
      opponent: opponentSummaryFromRow(battle, mode),
    },
    result: battle.result,
    events,
  };
}

export function historyEntryFromRow(
  battle: BattleLogBattleRow,
): Record<string, unknown> {
  const rewardPayload = isObject(battle.reward_payload) ? battle.reward_payload : {};
  const events = Array.isArray(battle.event_log) ? battle.event_log : [];
  const rewardType = stringValue(rewardPayload.type, "MVP_ONLY");
  const mode = rewardType === "FIRST_SLICE_SIM" ? "FIRST_SLICE_SIM" : "MVP_ONLY";

  return {
    battle_id: battle.id,
    created_at: battle.created_at ?? null,
    schema_version: battle.schema_version,
    ruleset: rulesetMetadataFromRow(battle),
    mode,
    duration: battleDuration(events),
    event_count: events.length,
    opponent: opponentSummaryFromRow(battle, mode),
    result: battle.result,
    rewards: {
      type: rewardType,
      resources: isObject(rewardPayload.resources) ? rewardPayload.resources : {},
    },
  };
}

export function rulesetMetadata(): Record<string, unknown> {
  return {
    publication_id: null,
    ruleset_id: FOUNDATION_RULESET.ruleset_id,
    ruleset_version: FOUNDATION_RULESET.ruleset_version,
    content_hash: FOUNDATION_RULESET.content_hash,
    simulator_hash: FOUNDATION_RULESET.simulator_hash,
    schema_version: FOUNDATION_RULESET.schema_version,
  };
}

export function rulesetMetadataFromRow(
  battle: BattleLogBattleRow,
): Record<string, unknown> {
  return {
    publication_id: battle.ruleset_publication_id ?? null,
    ruleset_id: battle.ruleset_id ?? FOUNDATION_RULESET.ruleset_id,
    ruleset_version: battle.ruleset_version ?? FOUNDATION_RULESET.ruleset_version,
    content_hash: battle.ruleset_content_hash ?? FOUNDATION_RULESET.content_hash,
    simulator_hash: battle.ruleset_simulator_hash ?? FOUNDATION_RULESET.simulator_hash,
    schema_version: battle.ruleset_schema_version ?? FOUNDATION_RULESET.schema_version,
  };
}

function opponentSummaryFromRow(
  battle: BattleLogBattleRow,
  mode: BattleLogMode,
): Record<string, unknown> {
  return {
    id: battle.defender_id,
    display_name: mode === "FIRST_SLICE_SIM" ? "Treinador da Primeira Ruina" : "Bot de Treino",
    is_bot: battle.defender_is_bot,
  };
}

function battleDuration(events: unknown[]): number {
  const lastEvent = events.findLast((event) => isObject(event) && typeof event.t === "number");
  return isObject(lastEvent) ? numberValue(lastEvent.t, 4.2) : 4.2;
}

function isObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
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
