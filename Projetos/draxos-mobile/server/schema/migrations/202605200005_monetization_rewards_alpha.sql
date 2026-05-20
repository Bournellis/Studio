-- DraxosMobile T00-P13 monetization, rewards and alpha purchase foundation.
-- Purchases and reward claims are server-authoritative and idempotent.

create table if not exists public.battle_passes (
	id text primary key,
	season_id text not null references public.seasons(id) on delete cascade,
	pass_index integer not null check (pass_index > 0),
	display_name text not null,
	starts_at timestamptz not null,
	ends_at timestamptz not null,
	free_rewards jsonb not null default '{}'::jsonb,
	premium_rewards jsonb not null default '{}'::jsonb,
	is_active boolean not null default true,
	created_at timestamptz not null default now(),
	unique (season_id, pass_index)
);

create table if not exists public.battle_pass_progress (
	player_id uuid not null references public.players(id) on delete cascade,
	pass_id text not null references public.battle_passes(id) on delete cascade,
	pass_xp integer not null default 0 check (pass_xp >= 0),
	premium_unlocked boolean not null default false,
	updated_at timestamptz not null default now(),
	primary key (player_id, pass_id)
);

create table if not exists public.reward_claims (
	id uuid primary key default gen_random_uuid(),
	player_id uuid not null references public.players(id) on delete cascade,
	source text not null check (source in ('daily', 'weekly', 'battle_pass')),
	reward_id text not null,
	period_key text not null,
	request_id uuid not null,
	reward_payload jsonb not null,
	created_at timestamptz not null default now(),
	unique (player_id, source, reward_id, period_key)
);

create table if not exists public.alpha_purchases (
	id uuid primary key default gen_random_uuid(),
	player_id uuid not null references public.players(id) on delete cascade,
	product_id text not null,
	request_id uuid not null,
	purchase_payload jsonb not null,
	created_at timestamptz not null default now(),
	unique (player_id, request_id)
);

create index if not exists battle_passes_active_idx
	on public.battle_passes (is_active, starts_at desc);

create index if not exists reward_claims_player_created_idx
	on public.reward_claims (player_id, created_at desc);

create index if not exists alpha_purchases_player_created_idx
	on public.alpha_purchases (player_id, created_at desc);

alter table public.battle_passes enable row level security;
alter table public.battle_pass_progress enable row level security;
alter table public.reward_claims enable row level security;
alter table public.alpha_purchases enable row level security;

create policy "battle_passes_select_active"
	on public.battle_passes for select
	using (is_active = true);

create policy "battle_pass_progress_select_own"
	on public.battle_pass_progress for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "reward_claims_select_own"
	on public.reward_claims for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "alpha_purchases_select_own"
	on public.alpha_purchases for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

insert into public.battle_passes (
	id,
	season_id,
	pass_index,
	display_name,
	starts_at,
	ends_at,
	free_rewards,
	premium_rewards,
	is_active
)
values (
	'bp_s1_01',
	'season_001',
	1,
	'Battle Pass Alpha 01',
	'2026-05-20T00:00:00Z',
	'2026-07-19T00:00:00Z',
	'{
		"tiers": 30,
		"totals": {
			"xp": 4800,
			"almas": 480,
			"energia": 480,
			"sangue": 180,
			"cristais": 120,
			"ossos": 60,
			"diamante": 15
		},
		"sample_rewards": [
			{
				"reward_id": "bp_free_tier_1",
				"tier": 1,
				"xp": 160,
				"resources": {
					"almas": 16,
					"energia": 16,
					"sangue": 6,
					"cristais": 4,
					"ossos": 2,
					"diamante": 1
				}
			}
		]
	}'::jsonb,
	'{
		"tiers": 30,
		"totals": {
			"xp": 9000,
			"almas": 900,
			"energia": 900,
			"sangue": 420,
			"cristais": 240,
			"ossos": 120,
			"diamante": 30
		},
		"sample_rewards": [
			{
				"reward_id": "bp_premium_tier_1",
				"tier": 1,
				"xp": 300,
				"resources": {
					"almas": 30,
					"energia": 30,
					"sangue": 14,
					"cristais": 8,
					"ossos": 4,
					"diamante": 1
				}
			}
		]
	}'::jsonb,
	true
)
on conflict (id) do update set
	season_id = excluded.season_id,
	pass_index = excluded.pass_index,
	display_name = excluded.display_name,
	starts_at = excluded.starts_at,
	ends_at = excluded.ends_at,
	free_rewards = excluded.free_rewards,
	premium_rewards = excluded.premium_rewards,
	is_active = excluded.is_active;
