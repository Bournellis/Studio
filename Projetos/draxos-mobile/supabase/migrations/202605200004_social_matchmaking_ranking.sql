-- DraxosMobile T00-P12 social, matchmaking and ranking foundation.
-- Social and competitive mutations must go through Edge Functions.

create table if not exists public.seasons (
	id text primary key,
	display_name text not null,
	starts_at timestamptz not null,
	ends_at timestamptz not null,
	status text not null default 'active' check (status in ('active', 'ended')),
	created_at timestamptz not null default now()
);

create table if not exists public.friendships (
	player_id uuid not null references public.players(id) on delete cascade,
	friend_id uuid not null references public.players(id) on delete cascade,
	status text not null default 'accepted' check (status in ('pending', 'accepted', 'blocked')),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	primary key (player_id, friend_id),
	check (player_id <> friend_id)
);

create table if not exists public.guilds (
	id uuid primary key default gen_random_uuid(),
	name text not null unique check (char_length(name) between 3 and 32),
	owner_id uuid not null references public.players(id) on delete cascade,
	level integer not null default 1 check (level between 1 and 10),
	member_count integer not null default 1 check (member_count between 0 and 50),
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table if not exists public.guild_members (
	guild_id uuid not null references public.guilds(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	role text not null default 'member' check (role in ('owner', 'officer', 'member')),
	joined_at timestamptz not null default now(),
	primary key (guild_id, player_id),
	unique (player_id)
);

create table if not exists public.guild_structures (
	guild_id uuid not null references public.guilds(id) on delete cascade,
	structure_id text not null check (
		structure_id in (
			'oficina_ritual',
			'condensador_astral',
			'arquivo_de_dominio',
			'cofre_abissal'
		)
	),
	level integer not null default 1 check (level between 1 and 10),
	updated_at timestamptz not null default now(),
	primary key (guild_id, structure_id)
);

create table if not exists public.guild_contributions (
	id uuid primary key default gen_random_uuid(),
	guild_id uuid not null references public.guilds(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	source text not null default 'guild/contribute',
	request_id uuid,
	delta jsonb not null,
	created_at timestamptz not null default now()
);

create table if not exists public.construction_helps (
	id uuid primary key default gen_random_uuid(),
	construction_job_id uuid not null references public.construction_jobs(id) on delete cascade,
	helper_id uuid not null references public.players(id) on delete cascade,
	receiver_id uuid not null references public.players(id) on delete cascade,
	request_id uuid,
	created_at timestamptz not null default now(),
	unique (construction_job_id, helper_id)
);

create table if not exists public.chat_channels (
	id uuid primary key default gen_random_uuid(),
	channel_type text not null check (channel_type in ('guild', 'direct')),
	guild_id uuid references public.guilds(id) on delete cascade,
	direct_key text,
	created_at timestamptz not null default now(),
	unique (channel_type, guild_id),
	unique (channel_type, direct_key)
);

create table if not exists public.chat_messages (
	id uuid primary key default gen_random_uuid(),
	channel_id uuid not null references public.chat_channels(id) on delete cascade,
	sender_id uuid not null references public.players(id) on delete cascade,
	content text not null check (char_length(content) between 1 and 280),
	created_at timestamptz not null default now(),
	deleted_at timestamptz
);

create table if not exists public.ranking (
	season_id text not null references public.seasons(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	arena_points integer not null default 0 check (arena_points >= 0),
	wins integer not null default 0 check (wins >= 0),
	losses integer not null default 0 check (losses >= 0),
	updated_at timestamptz not null default now(),
	primary key (season_id, player_id)
);

create table if not exists public.telemetry_events (
	id uuid primary key default gen_random_uuid(),
	player_id uuid references public.players(id) on delete set null,
	battle_id uuid references public.battles(id) on delete set null,
	session_id uuid,
	event_type text not null,
	schema_version text not null,
	source text not null check (source in ('client', 'server', 'simulation_job')),
	payload jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now()
);

create index if not exists friendships_friend_idx on public.friendships (friend_id, status);
create index if not exists guild_members_player_idx on public.guild_members (player_id);
create index if not exists chat_messages_channel_created_idx on public.chat_messages (channel_id, created_at desc);
create index if not exists ranking_season_points_idx on public.ranking (season_id, arena_points desc, updated_at asc);
create index if not exists telemetry_events_type_idx on public.telemetry_events (event_type, created_at desc);

alter table public.seasons enable row level security;
alter table public.friendships enable row level security;
alter table public.guilds enable row level security;
alter table public.guild_members enable row level security;
alter table public.guild_structures enable row level security;
alter table public.guild_contributions enable row level security;
alter table public.construction_helps enable row level security;
alter table public.chat_channels enable row level security;
alter table public.chat_messages enable row level security;
alter table public.ranking enable row level security;
alter table public.telemetry_events enable row level security;

create policy "seasons_select_active"
	on public.seasons for select
	using (status = 'active');

create policy "friendships_select_own"
	on public.friendships for select
	using (
		player_id in (select id from public.players where auth_user_id = auth.uid())
		or friend_id in (select id from public.players where auth_user_id = auth.uid())
	);

create policy "guilds_select_member"
	on public.guilds for select
	using (
		id in (
			select guild_id from public.guild_members
			where player_id in (select id from public.players where auth_user_id = auth.uid())
		)
	);

create policy "guild_members_select_same_guild"
	on public.guild_members for select
	using (
		guild_id in (
			select guild_id from public.guild_members
			where player_id in (select id from public.players where auth_user_id = auth.uid())
		)
	);

create policy "guild_structures_select_member"
	on public.guild_structures for select
	using (
		guild_id in (
			select guild_id from public.guild_members
			where player_id in (select id from public.players where auth_user_id = auth.uid())
		)
	);

create policy "chat_channels_select_member"
	on public.chat_channels for select
	using (
		(guild_id is not null and guild_id in (
			select guild_id from public.guild_members
			where player_id in (select id from public.players where auth_user_id = auth.uid())
		))
	);

create policy "chat_messages_select_member"
	on public.chat_messages for select
	using (
		channel_id in (
			select id from public.chat_channels where guild_id in (
				select guild_id from public.guild_members
				where player_id in (select id from public.players where auth_user_id = auth.uid())
			)
		)
		and deleted_at is null
	);

create policy "ranking_select_active"
	on public.ranking for select
	using (season_id in (select id from public.seasons where status = 'active'));

insert into public.seasons (id, display_name, starts_at, ends_at, status)
values (
	'season_001',
	'Season 1 Alpha',
	'2026-05-20T00:00:00Z',
	'2026-09-17T00:00:00Z',
	'active'
)
on conflict (id) do update set
	display_name = excluded.display_name,
	starts_at = excluded.starts_at,
	ends_at = excluded.ends_at,
	status = excluded.status;
