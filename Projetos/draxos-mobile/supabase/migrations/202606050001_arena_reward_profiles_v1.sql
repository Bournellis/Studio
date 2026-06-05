-- Arena reward profiles v1.
-- Seeds DB-side PVE Arena reward profiles from data/definitions/arena_rewards.json.

create table if not exists public.arena_reward_profiles (
	id text primary key,
	mode text not null default 'PVE_ARENA_V1',
	season_id text not null default 'season_001',
	version integer not null default 1,
	enabled boolean not null default true,
	display_name text not null,
	description text not null,
	tags text[] not null default '{}',
	resources jsonb not null default '{}'::jsonb,
	first_clear_multiplier numeric(8,3) not null default 1.0,
	completion_multiplier numeric(8,3) not null default 1.0,
	repeat_multiplier numeric(8,3) not null default 1.0,
	record_bonus jsonb not null default '{}'::jsonb,
	daily_bonus_key text,
	weekly_cap_key text,
	season_cap_key text,
	ledger_source text not null default 'arena_pve_v1',
	payload jsonb not null,
	source_collection text not null default 'arena_rewards',
	source_schema_version integer not null default 1,
	updated_at timestamptz not null default now(),
	constraint arena_reward_profiles_mode_check check (mode = 'PVE_ARENA_V1'),
	constraint arena_reward_profiles_version_check check (version > 0),
	constraint arena_reward_profiles_resources_object_check check (jsonb_typeof(resources) = 'object'),
	constraint arena_reward_profiles_record_bonus_object_check check (jsonb_typeof(record_bonus) = 'object'),
	constraint arena_reward_profiles_payload_object_check check (jsonb_typeof(payload) = 'object'),
	constraint arena_reward_profiles_ledger_source_check check (ledger_source = 'arena_pve_v1')
);

alter table public.arena_reward_profiles enable row level security;

drop policy if exists "arena_reward_profiles_select_authenticated" on public.arena_reward_profiles;
create policy "arena_reward_profiles_select_authenticated"
	on public.arena_reward_profiles for select
	to authenticated
	using (enabled = true and mode = 'PVE_ARENA_V1');

with seed_rows as (
	select raw.payload, seed.*
	from jsonb_array_elements($arena_reward_profiles_seed_v1$
[
  {
    "id": "arena_tutorial_clear",
    "display_name": "Clear Tutorial Arena",
    "description": "Recompensa calibravel da primeira arena tutorial de 1 duelo.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "reward",
      "tutorial",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 35,
      "almas": 2,
      "energia": 2,
      "ossos": 20
    },
    "first_clear_multiplier": 1.5,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 10
    },
    "daily_bonus_key": "arena_daily_first_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "arena_3_duel_clear_d1",
    "display_name": "Clear Arena 3 Duels D1",
    "description": "Recompensa calibravel para concluir a primeira arena real de 3 duelos.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "reward",
      "three_duels",
      "difficulty_1",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 90,
      "almas": 6,
      "energia": 4,
      "sangue": 1,
      "ossos": 60
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.35,
    "record_bonus": {
      "xp": 20,
      "almas": 1
    },
    "daily_bonus_key": "arena_daily_first_three_duel_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "arena_4_duel_clear_d2",
    "display_name": "Clear Arena 4 Duels D2",
    "description": "Recompensa calibravel para concluir uma arena de 4 duelos de dificuldade 2.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "reward",
      "four_duels",
      "difficulty_2",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 120,
      "almas": 8,
      "energia": 5,
      "sangue": 2,
      "ossos": 90
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.35,
    "record_bonus": {
      "xp": 25,
      "almas": 1
    },
    "daily_bonus_key": "arena_daily_first_three_duel_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "arena_5_duel_clear_d3",
    "display_name": "Clear Arena 5 Duels D3",
    "description": "Recompensa calibravel para a primeira arena longa de 5 duelos.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "reward",
      "five_duels",
      "difficulty_3",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 170,
      "almas": 11,
      "energia": 7,
      "sangue": 3,
      "cristais": 1,
      "ossos": 130
    },
    "first_clear_multiplier": 1.7,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 35,
      "almas": 2
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "arena_6_duel_clear_d4",
    "display_name": "Clear Arena 6 Duels D4",
    "description": "Recompensa calibravel para o cap inicial de 6 duelos.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "reward",
      "six_duels",
      "difficulty_4",
      "initial_cap",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 230,
      "almas": 15,
      "energia": 10,
      "sangue": 4,
      "cristais": 2,
      "ossos": 180
    },
    "first_clear_multiplier": 1.8,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 50,
      "almas": 3
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_1d_d00",
    "display_name": "Season 1 1D D00 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 1 duelo na dificuldade rank 0.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "tutorial",
      "difficulty_0",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 40,
      "almas": 2,
      "energia": 2,
      "ossos": 41
    },
    "first_clear_multiplier": 1.5,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 7,
      "almas": 0
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d00",
    "display_name": "Season 1 3D D00 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 0.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_0",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 90,
      "almas": 6,
      "energia": 3,
      "ossos": 104
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.35,
    "record_bonus": {
      "xp": 16,
      "almas": 0
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d01",
    "display_name": "Season 1 3D D01 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 1.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_1",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 120,
      "almas": 9,
      "energia": 5,
      "ossos": 131
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.35,
    "record_bonus": {
      "xp": 22,
      "almas": 1
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d02",
    "display_name": "Season 1 3D D02 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 2.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_2",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 160,
      "almas": 11,
      "energia": 6,
      "sangue": 1,
      "ossos": 165
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.35,
    "record_bonus": {
      "xp": 29,
      "almas": 1
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d03",
    "display_name": "Season 1 3D D03 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 3.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_3",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 210,
      "almas": 14,
      "energia": 7,
      "sangue": 1,
      "ossos": 206
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 38,
      "almas": 2
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d04",
    "display_name": "Season 1 3D D04 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 4.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_4",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 275,
      "almas": 17,
      "energia": 9,
      "sangue": 2,
      "ossos": 256,
      "po_osso": 1
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 50,
      "almas": 2
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d05",
    "display_name": "Season 1 3D D05 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 5.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_5",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 350,
      "almas": 20,
      "energia": 10,
      "sangue": 3,
      "ossos": 313,
      "po_osso": 2
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 63,
      "almas": 3
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d06",
    "display_name": "Season 1 3D D06 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 6.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_6",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 450,
      "almas": 22,
      "energia": 11,
      "sangue": 3,
      "cristais": 1,
      "ossos": 386,
      "po_osso": 3
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 81,
      "almas": 3
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d07",
    "display_name": "Season 1 3D D07 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 7.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_7",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 570,
      "almas": 25,
      "energia": 13,
      "sangue": 4,
      "cristais": 1,
      "ossos": 472,
      "po_osso": 4
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 103,
      "almas": 3
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_3d_d08",
    "display_name": "Season 1 3D D08 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 3 duelos na dificuldade rank 8.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "three_duels",
      "difficulty_8",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 710,
      "almas": 28,
      "energia": 14,
      "sangue": 5,
      "cristais": 2,
      "ossos": 571,
      "po_osso": 5
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 128,
      "almas": 4
    },
    "daily_bonus_key": "arena_daily_short_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d02",
    "display_name": "Season 1 4D D02 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 2.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_2",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 160,
      "almas": 15,
      "energia": 8,
      "sangue": 1,
      "ossos": 180
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.35,
    "record_bonus": {
      "xp": 29,
      "almas": 2
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d03",
    "display_name": "Season 1 4D D03 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 3.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_3",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 220,
      "almas": 19,
      "energia": 10,
      "sangue": 2,
      "ossos": 227
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 40,
      "almas": 2
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d04",
    "display_name": "Season 1 4D D04 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 4.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_4",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 295,
      "almas": 22,
      "energia": 12,
      "sangue": 3,
      "ossos": 284,
      "po_osso": 1
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 53,
      "almas": 3
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d05",
    "display_name": "Season 1 4D D05 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 5.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_5",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 400,
      "almas": 26,
      "energia": 13,
      "sangue": 4,
      "ossos": 360,
      "po_osso": 2
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 72,
      "almas": 3
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d06",
    "display_name": "Season 1 4D D06 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 6.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_6",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 530,
      "almas": 30,
      "energia": 15,
      "sangue": 5,
      "cristais": 1,
      "ossos": 453,
      "po_osso": 4
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 95,
      "almas": 4
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d07",
    "display_name": "Season 1 4D D07 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 7.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_7",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 690,
      "almas": 33,
      "energia": 17,
      "sangue": 6,
      "cristais": 2,
      "ossos": 565,
      "po_osso": 5
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 124,
      "almas": 4
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_4d_d08",
    "display_name": "Season 1 4D D08 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 4 duelos na dificuldade rank 8.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "four_duels",
      "difficulty_8",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 880,
      "almas": 37,
      "energia": 19,
      "sangue": 7,
      "cristais": 3,
      "ossos": 696,
      "po_osso": 6
    },
    "first_clear_multiplier": 1.6,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 158,
      "almas": 5
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_5d_d04",
    "display_name": "Season 1 5D D04 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 5 duelos na dificuldade rank 4.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "five_duels",
      "difficulty_4",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 300,
      "almas": 28,
      "energia": 15,
      "sangue": 3,
      "ossos": 302,
      "po_osso": 1
    },
    "first_clear_multiplier": 1.7,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 54,
      "almas": 4
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_5d_d05",
    "display_name": "Season 1 5D D05 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 5 duelos na dificuldade rank 5.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "five_duels",
      "difficulty_5",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 440,
      "almas": 33,
      "energia": 17,
      "sangue": 5,
      "cristais": 1,
      "ossos": 401,
      "po_osso": 3
    },
    "first_clear_multiplier": 1.7,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 79,
      "almas": 4
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_5d_d06",
    "display_name": "Season 1 5D D06 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 5 duelos na dificuldade rank 6.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "five_duels",
      "difficulty_6",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 620,
      "almas": 37,
      "energia": 19,
      "sangue": 6,
      "cristais": 2,
      "ossos": 526,
      "po_osso": 5
    },
    "first_clear_multiplier": 1.7,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 112,
      "almas": 5
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_5d_d07",
    "display_name": "Season 1 5D D07 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 5 duelos na dificuldade rank 7.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "five_duels",
      "difficulty_7",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 860,
      "almas": 42,
      "energia": 21,
      "sangue": 7,
      "cristais": 3,
      "ossos": 690,
      "po_osso": 6
    },
    "first_clear_multiplier": 1.7,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 155,
      "almas": 6
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_5d_d08",
    "display_name": "Season 1 5D D08 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 5 duelos na dificuldade rank 8.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "five_duels",
      "difficulty_8",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 1150,
      "almas": 46,
      "energia": 24,
      "sangue": 8,
      "cristais": 4,
      "ossos": 887,
      "po_osso": 8
    },
    "first_clear_multiplier": 1.7,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 207,
      "almas": 6
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_6d_d05",
    "display_name": "Season 1 6D D05 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 6 duelos na dificuldade rank 5.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "six_duels",
      "difficulty_5",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 480,
      "almas": 39,
      "energia": 20,
      "sangue": 6,
      "cristais": 1,
      "ossos": 442,
      "po_osso": 4
    },
    "first_clear_multiplier": 1.8,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.3,
    "record_bonus": {
      "xp": 86,
      "almas": 5
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_6d_d06",
    "display_name": "Season 1 6D D06 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 6 duelos na dificuldade rank 6.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "six_duels",
      "difficulty_6",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 740,
      "almas": 44,
      "energia": 23,
      "sangue": 7,
      "cristais": 2,
      "ossos": 619,
      "po_osso": 6
    },
    "first_clear_multiplier": 1.8,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 133,
      "almas": 6
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_6d_d07",
    "display_name": "Season 1 6D D07 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 6 duelos na dificuldade rank 7.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "six_duels",
      "difficulty_7",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 1060,
      "almas": 50,
      "energia": 26,
      "sangue": 9,
      "cristais": 3,
      "ossos": 835,
      "po_osso": 8
    },
    "first_clear_multiplier": 1.8,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 191,
      "almas": 7
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_6d_d08",
    "display_name": "Season 1 6D D08 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 6 duelos na dificuldade rank 8.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "six_duels",
      "difficulty_8",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 1460,
      "almas": 55,
      "energia": 28,
      "sangue": 10,
      "cristais": 4,
      "ossos": 1103,
      "po_osso": 10
    },
    "first_clear_multiplier": 1.8,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 263,
      "almas": 8
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "reward_s1_6d_d09",
    "display_name": "Season 1 6D D09 Clear",
    "description": "Perfil calibravel Season 1 para concluir arena PVE de 6 duelos na dificuldade rank 9.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "season_001",
      "reward",
      "six_duels",
      "difficulty_9",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 1930,
      "almas": 61,
      "energia": 31,
      "sangue": 12,
      "cristais": 6,
      "ossos": 1417,
      "po_osso": 12
    },
    "first_clear_multiplier": 1.8,
    "completion_multiplier": 1,
    "repeat_multiplier": 0.25,
    "record_bonus": {
      "xp": 347,
      "almas": 9
    },
    "daily_bonus_key": "arena_daily_longer_clear",
    "weekly_cap_key": "arena_weekly_mastery",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  },
  {
    "id": "arena_repeat_progress",
    "display_name": "Repeat Progress Reward",
    "description": "Perfil de recompensa reduzida para repeticao ou progresso parcial sem primeira clear.",
    "version": 1,
    "enabled": true,
    "tags": [
      "PVE_ARENA_V1",
      "reward",
      "repeat",
      "partial",
      "CALIBRAVEL_ALPHA"
    ],
    "mode": "PVE_ARENA_V1",
    "resources": {
      "xp": 20,
      "almas": 1,
      "energia": 1,
      "ossos": 10
    },
    "first_clear_multiplier": 1,
    "completion_multiplier": 0.5,
    "repeat_multiplier": 0.25,
    "record_bonus": {},
    "daily_bonus_key": "arena_daily_repeat_soft_cap",
    "weekly_cap_key": "arena_weekly_participation",
    "season_cap_key": "season_001_arena_pve",
    "ledger_source": "arena_pve_v1"
  }
]
$arena_reward_profiles_seed_v1$::jsonb) as raw(payload)
	cross join lateral jsonb_to_record(raw.payload) as seed(
		id text,
		display_name text,
		description text,
		version integer,
		enabled boolean,
		tags jsonb,
		mode text,
		resources jsonb,
		first_clear_multiplier numeric,
		completion_multiplier numeric,
		repeat_multiplier numeric,
		record_bonus jsonb,
		daily_bonus_key text,
		weekly_cap_key text,
		season_cap_key text,
		ledger_source text
	)
)
insert into public.arena_reward_profiles (
	id,
	mode,
	season_id,
	version,
	enabled,
	display_name,
	description,
	tags,
	resources,
	first_clear_multiplier,
	completion_multiplier,
	repeat_multiplier,
	record_bonus,
	daily_bonus_key,
	weekly_cap_key,
	season_cap_key,
	ledger_source,
	payload,
	source_collection,
	source_schema_version,
	updated_at
)
select
	seed_rows.id,
	coalesce(seed_rows.mode, 'PVE_ARENA_V1'),
	'season_001',
	coalesce(seed_rows.version, 1),
	coalesce(seed_rows.enabled, true),
	seed_rows.display_name,
	seed_rows.description,
	coalesce((select array_agg(tag.value order by tag.value) from jsonb_array_elements_text(coalesce(seed_rows.tags, '[]'::jsonb)) as tag(value)), '{}'),
	coalesce(seed_rows.resources, '{}'::jsonb),
	coalesce(seed_rows.first_clear_multiplier, 1.0),
	coalesce(seed_rows.completion_multiplier, 1.0),
	coalesce(seed_rows.repeat_multiplier, 1.0),
	coalesce(seed_rows.record_bonus, '{}'::jsonb),
	seed_rows.daily_bonus_key,
	seed_rows.weekly_cap_key,
	seed_rows.season_cap_key,
	coalesce(seed_rows.ledger_source, 'arena_pve_v1'),
	seed_rows.payload,
	'arena_rewards',
	1,
	now()
from seed_rows
on conflict (id) do update set
	mode = excluded.mode,
	season_id = excluded.season_id,
	version = excluded.version,
	enabled = excluded.enabled,
	display_name = excluded.display_name,
	description = excluded.description,
	tags = excluded.tags,
	resources = excluded.resources,
	first_clear_multiplier = excluded.first_clear_multiplier,
	completion_multiplier = excluded.completion_multiplier,
	repeat_multiplier = excluded.repeat_multiplier,
	record_bonus = excluded.record_bonus,
	daily_bonus_key = excluded.daily_bonus_key,
	weekly_cap_key = excluded.weekly_cap_key,
	season_cap_key = excluded.season_cap_key,
	ledger_source = excluded.ledger_source,
	payload = excluded.payload,
	source_collection = excluded.source_collection,
	source_schema_version = excluded.source_schema_version,
	updated_at = now();
