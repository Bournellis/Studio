import type {
  BattleBotBuildRow,
  BattleBuildRow,
  BattleConsumableRow,
  BattlePotionSlotRow,
  BattleSpellBehaviorRow,
} from "../_shared/battle_combatants.ts";
import type { SaveType } from "../_shared/save_context.ts";
import type { FoundationGameSaveRow } from "../_shared/transactional_mutation.ts";

export type { FoundationGameSaveRow };

export type Route = "list" | "start" | "duel/request" | "buff/choose" | "claim" | "abandon";

export type BuffStat =
  | "max_hp"
  | "ritual_power"
  | "guard"
  | "max_mana"
  | "mana_regen"
  | "ritual_haste"
  | "will"
  | "ritual_control";

export interface EdgeConfig {
  supabaseUrl: string;
  serviceRoleKey: string;
}

export interface AuthContext {
  userId: string;
  saveType: SaveType;
}

export interface RestError {
  code: string;
  message: string;
  status: number;
}

export interface JwtPayload {
  sub?: unknown;
}

export interface PlayerRow {
  id: string;
  username?: string | null;
  save_type?: SaveType;
  level?: number;
  xp?: number;
  power?: number;
}

export interface ResourceRow {
  almas: string | number;
  energia: string | number;
  sangue: string | number;
  cristais: string | number;
  ossos: string | number;
  po_osso: string | number;
  diamante: string | number;
}

export interface BuildRow extends BattleBuildRow {
  weapon_type: string;
  weapon_quality: string;
  weapon_level: number;
  spell_slots: unknown;
  spells_unlocked: unknown;
  pet_id: string | null;
  pet_level: number;
  passive_id: string | null;
  passive_level: number;
}

export interface ConsumableRow extends BattleConsumableRow {
  player_id: string;
  updated_at: string;
}

export interface PotionSlotRow extends BattlePotionSlotRow {
  player_id: string;
  updated_at: string;
}

export interface SpellBehaviorRow extends BattleSpellBehaviorRow {
  player_id: string;
  updated_at: string;
}

export interface BotBuildRow extends BattleBotBuildRow {
  id: string;
  power: number;
  power_band: string;
  build_data: unknown;
  is_active: boolean;
}

export interface PlayerState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
  resources: ResourceRow;
  build: BuildRow;
  inventory: ConsumableRow[];
  potionSlots: PotionSlotRow[];
  spellBehaviors: SpellBehaviorRow[];
}

export interface ArenaListState {
  player: PlayerRow;
  gameSave: FoundationGameSaveRow;
}

export interface ArenaProgressRow {
  game_save_id: string;
  player_id: string;
  tutorial_completed: boolean;
  best_completed_difficulty: number;
  best_completed_length: number;
  best_attempt_step: number;
  total_attempts: number;
  total_clears: number;
  last_attempt_id: string | null;
  metadata: unknown;
  created_at: string;
  updated_at: string;
}

export interface ArenaAttemptRow {
  id: string;
  game_save_id: string;
  player_id: string;
  arena_id: string;
  difficulty_id: string;
  difficulty_rank: number;
  max_steps: number;
  current_step_index: number;
  status: "active" | "completed" | "failed" | "abandoned";
  seed: string;
  enemy_sequence: unknown;
  loadout_snapshot: unknown;
  active_buffs: unknown;
  reward_payload: unknown;
  started_at: string;
  completed_at: string | null;
  abandoned_at: string | null;
  updated_at: string;
}

export interface ArenaStepRow {
  id: string;
  attempt_id: string;
  step_index: number;
  step_type: string;
  status: string;
  opponent_bot_id: string | null;
  seed: string | null;
  battle_log: unknown;
  result: unknown;
  reward_payload: unknown;
  buff_options: unknown;
  selected_buff: unknown;
  created_at: string;
  completed_at: string | null;
}

export interface BuffOption {
  id: string;
  label: string;
  stat: BuffStat;
  amount_percent: number;
  stat_modifiers: { stat: BuffStat; operation: "add_percent"; value: number }[];
}
