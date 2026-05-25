-- DraxosMobile Track 00 MVP foundation.
-- Authoritative game mutations must go through Edge Functions.

create extension if not exists "pgcrypto";

create table if not exists public.players (
	id uuid primary key default gen_random_uuid(),
	auth_user_id uuid not null unique,
	username text unique,
	account_type text not null check (account_type in ('guest', 'registered', 'google')),
	level integer not null default 1 check (level >= 1),
	xp integer not null default 0 check (xp >= 0),
	power integer not null default 0 check (power >= 0),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table if not exists public.resources (
	player_id uuid primary key references public.players(id) on delete cascade,
	almas numeric(12, 2) not null default 0 check (almas >= 0),
	energia numeric(12, 2) not null default 0 check (energia >= 0),
	sangue numeric(12, 2) not null default 0 check (sangue >= 0),
	cristais numeric(12, 2) not null default 0 check (cristais >= 0),
	ossos numeric(12, 2) not null default 0 check (ossos >= 0),
	diamante integer not null default 0 check (diamante >= 0),
	updated_at timestamptz not null default now()
);

create table if not exists public.builds (
	player_id uuid primary key references public.players(id) on delete cascade,
	weapon_type text not null default 'varinha_cinzas',
	weapon_quality text not null default 'varinha_simples',
	weapon_level integer not null default 1 check (weapon_level >= 1),
	spell_slots jsonb not null default '[]'::jsonb,
	spells_unlocked jsonb not null default '[]'::jsonb,
	pet_id text,
	pet_level integer not null default 0 check (pet_level >= 0),
	passive_id text,
	passive_level integer not null default 0 check (passive_level >= 0),
	updated_at timestamptz not null default now()
);

create table if not exists public.bot_builds (
	id text primary key,
	power integer not null check (power >= 0),
	power_band text not null,
	build_data jsonb not null,
	is_active boolean not null default true,
	created_at timestamptz not null default now()
);

create table if not exists public.battles (
	id uuid primary key default gen_random_uuid(),
	attacker_id uuid not null references public.players(id) on delete cascade,
	defender_id text not null,
	defender_is_bot boolean not null default true,
	schema_version text not null,
	seed text not null,
	result jsonb not null,
	event_log jsonb not null,
	reward_payload jsonb not null,
	reward_applied boolean not null default false,
	request_id uuid not null,
	created_at timestamptz not null default now(),
	unique (attacker_id, request_id)
);

create table if not exists public.invite_codes (
	code text primary key,
	max_uses integer not null check (max_uses > 0),
	used_count integer not null default 0 check (used_count >= 0),
	expires_at timestamptz,
	is_active boolean not null default true,
	created_at timestamptz not null default now(),
	check (used_count <= max_uses)
);

create table if not exists public.idempotency_keys (
	player_id uuid not null references public.players(id) on delete cascade,
	endpoint text not null,
	request_id uuid not null,
	response_payload jsonb not null,
	created_at timestamptz not null default now(),
	primary key (player_id, endpoint, request_id)
);

create table if not exists public.resource_transactions (
	id uuid primary key default gen_random_uuid(),
	player_id uuid not null references public.players(id) on delete cascade,
	source text not null,
	request_id uuid,
	delta jsonb not null,
	created_at timestamptz not null default now()
);

create index if not exists battles_attacker_created_at_idx
	on public.battles (attacker_id, created_at desc);

create index if not exists bot_builds_power_band_idx
	on public.bot_builds (power_band, power)
	where is_active = true;

alter table public.players enable row level security;
alter table public.resources enable row level security;
alter table public.builds enable row level security;
alter table public.battles enable row level security;
alter table public.bot_builds enable row level security;
alter table public.invite_codes enable row level security;
alter table public.idempotency_keys enable row level security;
alter table public.resource_transactions enable row level security;

create policy "players_select_own"
	on public.players for select
	using (auth.uid() = auth_user_id);

create policy "resources_select_own"
	on public.resources for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "builds_select_own"
	on public.builds for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "battles_select_own"
	on public.battles for select
	using (
		attacker_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "bot_builds_select_active"
	on public.bot_builds for select
	using (is_active = true);

create policy "resource_transactions_select_own"
	on public.resource_transactions for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

insert into public.bot_builds (id, power, power_band, build_data, is_active)
values (
	'mvp_training_bot',
	50,
	'MVP_ONLY',
	'{"level": 1, "weapon_type": "varinha_cinzas", "spell_ids": []}'::jsonb,
	true
)
on conflict (id) do update set
	power = excluded.power,
	power_band = excluded.power_band,
	build_data = excluded.build_data,
	is_active = excluded.is_active;
