-- Minigame Platform V1: official DraxosMobile modes registry, Openworld migration, sessions and reward bridge.
-- V1 compatibility/migration prelude.
-- Keeps historical v0 objects intact while promoting official mode ids and /modes RPCs.

alter table public.mode_sessions add column if not exists expires_at timestamptz;
alter table public.mode_sessions add column if not exists abandoned_at timestamptz;
alter table public.mode_sessions add column if not exists invalidated_at timestamptz;
alter table public.mode_sessions add column if not exists invalidated_reason text;

create table if not exists public.mode_limit_policies (
	mode_id text not null,
	slice_id text not null default 'default',
	ruleset_id text not null default 'default',
	max_active_sessions integer not null default 1,
	start_cooldown_seconds integer not null default 10,
	session_expiry_seconds integer not null default 7200,
	daily_start_limit integer not null default 100,
	reward_cap_payload jsonb not null default '{}'::jsonb,
	status text not null default 'active',
	updated_at timestamptz not null default now(),
	primary key (mode_id, slice_id, ruleset_id)
);

create table if not exists public.admin_roles (
	auth_user_id uuid not null,
	role text not null,
	active boolean not null default true,
	reason text not null default '',
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	primary key (auth_user_id, role)
);

alter table public.mode_limit_policies enable row level security;
alter table public.admin_roles enable row level security;

insert into public.mode_registry (
	mode_id,
	display_name,
	status,
	release_channel,
	default_slice_id,
	active_ruleset_id,
	active_ruleset_version,
	metadata,
	created_at,
	updated_at
)
select
	'openworld',
	'Openworld',
	'internal_alpha',
	'internal_alpha',
	'forest',
	'openworld_forest_ruleset_v0',
	active_ruleset_version,
	replace(metadata::text, 'rpgsuave', 'openworld')::jsonb,
	created_at,
	now()
from public.mode_registry
where mode_id = 'rpgsuave'
on conflict (mode_id) do update set
	display_name = excluded.display_name,
	status = excluded.status,
	release_channel = excluded.release_channel,
	default_slice_id = excluded.default_slice_id,
	active_ruleset_id = excluded.active_ruleset_id,
	active_ruleset_version = excluded.active_ruleset_version,
	metadata = excluded.metadata,
	updated_at = now();

update public.mode_ruleset_registry
set ruleset_id = 'openworld_forest_ruleset_v0',
	mode_id = 'openworld',
	status = 'active',
	release_channel = 'internal_alpha',
	reward_limits = replace(reward_limits::text, 'rpgsuave', 'openworld')::jsonb,
	result_limits = replace(result_limits::text, 'rpgsuave', 'openworld')::jsonb,
	ruleset_payload = replace(ruleset_payload::text, 'rpgsuave', 'openworld')::jsonb,
	updated_at = now()
where (mode_id = 'rpgsuave' or ruleset_id = 'rpgsuave_forest_ruleset_v0')
	and not exists (
		select 1
		from public.mode_ruleset_registry existing_ruleset
		where existing_ruleset.ruleset_id = 'openworld_forest_ruleset_v0'
			and existing_ruleset.ruleset_version = public.mode_ruleset_registry.ruleset_version
			and existing_ruleset.release_channel = 'internal_alpha'
	);

delete from public.mode_ruleset_registry
where mode_id = 'rpgsuave' or ruleset_id = 'rpgsuave_forest_ruleset_v0';

update public.mode_progress
set mode_id = 'openworld',
	local_schema_version = 'openworld_forest_local_v0',
	progress_payload = replace(progress_payload::text, 'rpgsuave', 'openworld')::jsonb,
	totals_payload = replace(totals_payload::text, 'rpgsuave', 'openworld')::jsonb,
	updated_at = now()
where (mode_id = 'rpgsuave' or local_schema_version = 'rpgsuave_forest_local_v0')
	and not exists (
		select 1
		from public.mode_progress existing_progress
		where existing_progress.game_save_id = public.mode_progress.game_save_id
			and existing_progress.mode_id = 'openworld'
	);

delete from public.mode_progress
where mode_id = 'rpgsuave' or local_schema_version = 'rpgsuave_forest_local_v0';

update public.mode_sessions
set mode_id = 'openworld',
	ruleset_id = 'openworld_forest_ruleset_v0',
	result_payload = replace(result_payload::text, 'rpgsuave', 'openworld')::jsonb,
	reward_payload = replace(reward_payload::text, 'rpgsuave', 'openworld')::jsonb
where mode_id = 'rpgsuave' or ruleset_id = 'rpgsuave_forest_ruleset_v0';

update public.mode_reward_claims
set mode_id = 'openworld',
	reward_payload = replace(reward_payload::text, 'rpgsuave', 'openworld')::jsonb
where mode_id = 'rpgsuave';

delete from public.mode_registry
where mode_id = 'rpgsuave';

do $mode_v1_prelude$
begin
	if exists (
		select 1 from information_schema.columns
		where table_schema = 'public' and table_name = 'resource_transactions' and column_name = 'source'
	) then
		execute 'update public.resource_transactions set source = replace(source, ''rpgsuave'', ''openworld'') where source like ''%rpgsuave%''';
	end if;
	if exists (
		select 1 from information_schema.columns
		where table_schema = 'public' and table_name = 'resource_transactions' and column_name = 'metadata'
	) then
		execute 'update public.resource_transactions set metadata = replace(metadata::text, ''rpgsuave'', ''openworld'')::jsonb where metadata::text like ''%rpgsuave%''';
	end if;
end $mode_v1_prelude$;

create extension if not exists "pgcrypto";

create table if not exists public.mode_registry (
	mode_id text primary key,
	display_name text not null,
	status text not null default 'dev_only' check (status in ('active', 'dev_only', 'internal_alpha', 'planned_disabled', 'paused', 'retired')),
	release_channel text not null default 'dev_only' check (release_channel in ('dev_only', 'internal_alpha', 'closed_alpha', 'staged')),
	default_slice_id text not null,
	active_ruleset_id text not null,
	active_ruleset_version integer not null default 1 check (active_ruleset_version > 0),
	metadata jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create table if not exists public.mode_ruleset_registry (
	publication_id uuid primary key default gen_random_uuid(),
	ruleset_id text not null,
	ruleset_version integer not null check (ruleset_version > 0),
	mode_id text not null references public.mode_registry(mode_id) on delete cascade,
	slice_id text not null,
	status text not null default 'active' check (status in ('draft', 'active', 'deprecated', 'retired')),
	release_channel text not null default 'internal_alpha' check (release_channel in ('dev_only', 'internal_alpha', 'closed_alpha', 'staged')),
	result_limits jsonb not null default '{}'::jsonb,
	reward_limits jsonb not null default '{}'::jsonb,
	ruleset_payload jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	unique (ruleset_id, ruleset_version, release_channel)
);

create table if not exists public.mode_progress (
	game_save_id uuid not null references public.game_saves(id) on delete cascade,
	mode_id text not null references public.mode_registry(mode_id) on delete cascade,
	local_schema_version text not null default 'openworld_forest_local_v0',
	progress_payload jsonb not null default '{}'::jsonb,
	totals_payload jsonb not null default '{}'::jsonb,
	last_session_id uuid,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	primary key (game_save_id, mode_id)
);

create table if not exists public.mode_sessions (
	id uuid primary key default gen_random_uuid(),
	game_save_id uuid not null references public.game_saves(id) on delete cascade,
	mode_id text not null references public.mode_registry(mode_id) on delete restrict,
	slice_id text not null,
	ruleset_id text not null,
	ruleset_version integer not null check (ruleset_version > 0),
	status text not null default 'started' check (status in ('started', 'completed', 'abandoned', 'expired', 'invalidated', 'rejected')),
	server_seed text not null default encode(extensions.gen_random_bytes(16), 'hex'),
	start_request_id uuid not null,
	complete_request_id uuid,
	session_seconds integer check (session_seconds is null or session_seconds >= 0),
	activity_score integer check (activity_score is null or activity_score >= 0),
	deposited_items jsonb not null default '{}'::jsonb,
	result_payload jsonb not null default '{}'::jsonb,
	reward_payload jsonb not null default '{}'::jsonb,
	started_at timestamptz not null default now(),
	completed_at timestamptz,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	unique (game_save_id, start_request_id),
	unique (game_save_id, complete_request_id)
);

create table if not exists public.mode_reward_claims (
	id uuid primary key default gen_random_uuid(),
	game_save_id uuid not null references public.game_saves(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	mode_id text not null references public.mode_registry(mode_id) on delete restrict,
	session_id uuid not null references public.mode_sessions(id) on delete cascade,
	request_id uuid not null,
	request_hash text not null,
	period_key text not null,
	reward_payload jsonb not null default '{}'::jsonb,
	resource_delta jsonb not null default '{}'::jsonb,
	xp_delta integer not null default 0 check (xp_delta >= 0),
	created_at timestamptz not null default now(),
	unique (player_id, session_id),
	unique (player_id, request_id)
);

create index if not exists mode_ruleset_registry_mode_active_idx
	on public.mode_ruleset_registry (mode_id, slice_id, status, release_channel);

create index if not exists mode_sessions_save_mode_started_idx
	on public.mode_sessions (game_save_id, mode_id, started_at desc);

create index if not exists mode_reward_claims_player_period_idx
	on public.mode_reward_claims (player_id, mode_id, period_key, created_at desc);

alter table public.mode_registry drop constraint if exists mode_registry_status_check;
alter table public.mode_registry add constraint mode_registry_status_check
	check (status in ('active', 'dev_only', 'internal_alpha', 'planned_disabled', 'paused', 'retired'));
alter table public.mode_registry drop constraint if exists mode_registry_release_channel_check;
alter table public.mode_registry add constraint mode_registry_release_channel_check
	check (release_channel in ('dev_only', 'internal_alpha', 'closed_alpha', 'staged'));

alter table public.mode_ruleset_registry drop constraint if exists mode_ruleset_registry_release_channel_check;
alter table public.mode_ruleset_registry add constraint mode_ruleset_registry_release_channel_check
	check (release_channel in ('dev_only', 'internal_alpha', 'closed_alpha', 'staged'));

alter table public.mode_sessions drop constraint if exists mode_sessions_status_check;
alter table public.mode_sessions add constraint mode_sessions_status_check
	check (status in ('started', 'completed', 'abandoned', 'expired', 'invalidated', 'rejected'));

alter table public.mode_registry enable row level security;
alter table public.mode_ruleset_registry enable row level security;
alter table public.mode_progress enable row level security;
alter table public.mode_sessions enable row level security;
alter table public.mode_reward_claims enable row level security;

drop policy if exists "mode_registry_select_authenticated" on public.mode_registry;
create policy "mode_registry_select_authenticated"
	on public.mode_registry for select
	to authenticated
	using (status in ('active', 'dev_only', 'internal_alpha', 'planned_disabled'));

drop policy if exists "mode_ruleset_registry_select_authenticated" on public.mode_ruleset_registry;
create policy "mode_ruleset_registry_select_authenticated"
	on public.mode_ruleset_registry for select
	to authenticated
	using (status in ('active', 'draft', 'deprecated'));

drop policy if exists "mode_progress_select_own" on public.mode_progress;
create policy "mode_progress_select_own"
	on public.mode_progress for select
	to authenticated
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

drop policy if exists "mode_sessions_select_own" on public.mode_sessions;
create policy "mode_sessions_select_own"
	on public.mode_sessions for select
	to authenticated
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

drop policy if exists "mode_reward_claims_select_own" on public.mode_reward_claims;
create policy "mode_reward_claims_select_own"
	on public.mode_reward_claims for select
	to authenticated
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

insert into public.mode_registry (
	mode_id,
	display_name,
	status,
	release_channel,
	default_slice_id,
	active_ruleset_id,
	active_ruleset_version,
	metadata
)
values (
	'basebuilder',
	'Basebuilder',
	'active',
	'internal_alpha',
	'refugio',
	'basebuilder_refugio_ruleset_v1',
	1,
	'{"entry_action":"show_base","public_cta":true,"build_owner":"basebuilder","surface":"refuge"}'::jsonb
),
(
	'autobattler',
	'Autobattler',
	'active',
	'internal_alpha',
	'pve_arena',
	'autobattler_pve_arena_ruleset_v1',
	1,
	'{"entry_action":"open_arena","public_cta":true,"build_owner":"autobattler","surface":"arena_pve"}'::jsonb
),
(
	'openworld',
	'Openworld',
	'internal_alpha',
	'internal_alpha',
	'forest',
	'openworld_forest_ruleset_v0',
	1,
	'{"entry_action":"open_mode_shell:openworld","public_cta":true,"client_default":"integrated_alpha","surface":"fullscreen"}'::jsonb
),
(
	'towerdefense',
	'Towerdefense',
	'planned_disabled',
	'staged',
	'tbd',
	'towerdefense_tbd_ruleset_v1',
	1,
	'{"public_cta":false,"concept":"central_static_tower_mage_hordes","surface":"mode_hub_disabled"}'::jsonb
),
(
	'cardgame',
	'Cardgame',
	'planned_disabled',
	'staged',
	'tbd',
	'cardgame_tbd_ruleset_v1',
	1,
	'{"public_cta":false,"concept":"draxos_mobile_cardgame_lore_only","surface":"mode_hub_disabled"}'::jsonb
)
on conflict (mode_id) do update
set
	display_name = excluded.display_name,
	status = excluded.status,
	release_channel = excluded.release_channel,
	default_slice_id = excluded.default_slice_id,
	active_ruleset_id = excluded.active_ruleset_id,
	active_ruleset_version = excluded.active_ruleset_version,
	metadata = excluded.metadata,
	updated_at = now();

insert into public.mode_ruleset_registry (
	ruleset_id,
	ruleset_version,
	mode_id,
	slice_id,
	status,
	release_channel,
	result_limits,
	reward_limits,
	ruleset_payload
)
values (
	'basebuilder_refugio_ruleset_v1',
	1,
	'basebuilder',
	'refugio',
	'active',
	'internal_alpha',
	'{"sessionless":true}'::jsonb,
	'{"source":"basebuilder:refugio"}'::jsonb,
	'{"schema_version":"basebuilder_refugio_ruleset_v1","session_model":"core_base_endpoints","build_owner":"basebuilder"}'::jsonb
),
(
	'autobattler_pve_arena_ruleset_v1',
	1,
	'autobattler',
	'pve_arena',
	'active',
	'internal_alpha',
	'{"session_model":"arena_pve"}'::jsonb,
	'{"source":"autobattler:pve_arena"}'::jsonb,
	'{"schema_version":"autobattler_pve_arena_ruleset_v1","session_model":"arena_pve_endpoints","build_owner":"autobattler"}'::jsonb
),
(
	'openworld_forest_ruleset_v0',
	1,
	'openworld',
	'forest',
	'active',
	'internal_alpha',
	'{"session_seconds_min":5,"session_seconds_max":1800,"activity_score_max":500,"item_quantity_max":999,"plausible_score_max":240}'::jsonb,
	'{"daily":{"energia":30,"ossos":6,"xp":24},"per_session":{"energia":12,"ossos":2,"xp":8},"source":"mode:openworld:forest"}'::jsonb,
	'{"schema_version":"openworld_forest_ruleset_v0","local_items":["madeira","galho","folha","folha_seca","pedra","pedra_pequena","cogumelo","fungo","inseto","resina","cinzas_preview","ossos_preview","po_osso_preview"],"reward_bridge":"server_authoritative_v0"}'::jsonb
),
(
	'towerdefense_tbd_ruleset_v1',
	1,
	'towerdefense',
	'tbd',
	'draft',
	'staged',
	'{"disabled":true}'::jsonb,
	'{"disabled":true}'::jsonb,
	'{"schema_version":"towerdefense_tbd_ruleset_v1","concept":"central_static_tower_mage_hordes","disabled":true}'::jsonb
),
(
	'cardgame_tbd_ruleset_v1',
	1,
	'cardgame',
	'tbd',
	'draft',
	'staged',
	'{"disabled":true}'::jsonb,
	'{"disabled":true}'::jsonb,
	'{"schema_version":"cardgame_tbd_ruleset_v1","concept":"draxos_mobile_cardgame_lore_only","disabled":true}'::jsonb
)
on conflict (ruleset_id, ruleset_version, release_channel) do update
set
	mode_id = excluded.mode_id,
	slice_id = excluded.slice_id,
	status = excluded.status,
	result_limits = excluded.result_limits,
	reward_limits = excluded.reward_limits,
	ruleset_payload = excluded.ruleset_payload,
	updated_at = now();

insert into public.mode_limit_policies (
	mode_id,
	slice_id,
	ruleset_id,
	max_active_sessions,
	start_cooldown_seconds,
	session_expiry_seconds,
	daily_start_limit,
	reward_cap_payload,
	status
)
values
	('openworld', 'forest', 'openworld_forest_ruleset_v0', 1, 10, 7200, 100, '{"daily":{"energia":30,"ossos":6,"xp":24}}'::jsonb, 'active'),
	('towerdefense', 'tbd', 'towerdefense_tbd_ruleset_v1', 1, 10, 7200, 100, '{}'::jsonb, 'disabled'),
	('cardgame', 'tbd', 'cardgame_tbd_ruleset_v1', 1, 10, 7200, 100, '{}'::jsonb, 'disabled')
on conflict (mode_id, slice_id, ruleset_id) do update
set
	max_active_sessions = excluded.max_active_sessions,
	start_cooldown_seconds = excluded.start_cooldown_seconds,
	session_expiry_seconds = excluded.session_expiry_seconds,
	daily_start_limit = excluded.daily_start_limit,
	reward_cap_payload = excluded.reward_cap_payload,
	status = excluded.status,
	updated_at = now();

create or replace function public.mode_session_start_v1(
	p_game_save_id uuid,
	p_request_id uuid,
	p_request_hash text,
	p_request_payload jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	save_row public.game_saves%rowtype;
	registry_row public.mode_registry%rowtype;
	ruleset_row public.mode_ruleset_registry%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	session_row public.mode_sessions%rowtype;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_ruleset_id text := nullif(trim(coalesce(p_request_payload->>'ruleset_id', '')), '');
	payload_ruleset_version integer := coalesce((p_request_payload->>'ruleset_version')::integer, 0);
	scope_id text;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	if payload_mode_id <> 'openworld' or payload_slice_id <> 'forest' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where id = p_game_save_id
		and lifecycle_status = 'active'
	for update;

	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;

	if save_row.legacy_player_id is null then
		raise exception 'GAME_SAVE_WITHOUT_LEGACY_PLAYER' using errcode = 'P0001';
	end if;

	select *
	into registry_row
	from public.mode_registry
	where mode_id = payload_mode_id;

	if registry_row.mode_id is null then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;

	select *
	into ruleset_row
	from public.mode_ruleset_registry
	where ruleset_id = payload_ruleset_id
		and ruleset_version = payload_ruleset_version
		and mode_id = payload_mode_id
		and slice_id = payload_slice_id
		and status = 'active'
		and release_channel = 'internal_alpha'
	limit 1;

	if ruleset_row.publication_id is null then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;

	scope_id := 'mode:' || payload_mode_id || ':' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'modes/session/start',
		p_request_id,
		p_request_hash,
		scope_id
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	insert into public.mode_progress as progress_row (
		game_save_id,
		mode_id,
		local_schema_version,
		progress_payload,
		totals_payload,
		updated_at
	)
	values (
		save_row.id,
		payload_mode_id,
		'openworld_forest_local_v0',
		'{}'::jsonb,
		'{"sessions_started":1,"sessions_completed":0,"activity_score":0}'::jsonb,
		now()
	)
	on conflict (game_save_id, mode_id) do update
	set
		totals_payload = jsonb_set(
			progress_row.totals_payload,
			'{sessions_started}',
			to_jsonb(coalesce(nullif(progress_row.totals_payload->>'sessions_started', '')::integer, 0) + 1),
			true
		),
		updated_at = now();

	insert into public.mode_sessions (
		game_save_id,
		mode_id,
		slice_id,
		ruleset_id,
		ruleset_version,
		status,
		start_request_id,
		expires_at
	)
	values (
		save_row.id,
		payload_mode_id,
		payload_slice_id,
		payload_ruleset_id,
		payload_ruleset_version,
		'started',
		p_request_id,
		now() + interval '2 hours'
	)
	returning * into session_row;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode', jsonb_build_object(
			'mode_id', payload_mode_id,
			'slice_id', payload_slice_id,
			'ruleset_id', payload_ruleset_id,
			'ruleset_version', payload_ruleset_version,
			'release_channel', registry_row.release_channel
		),
		'session', jsonb_build_object(
			'id', session_row.id,
			'status', session_row.status,
			'server_seed', session_row.server_seed,
			'started_at', session_row.started_at
		),
		'limits', ruleset_row.result_limits,
		'server_time', now()
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/start',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

create or replace function public.mode_session_complete_v1(
	p_game_save_id uuid,
	p_request_id uuid,
	p_request_hash text,
	p_request_payload jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	save_row public.game_saves%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	session_row public.mode_sessions%rowtype;
	ruleset_row public.mode_ruleset_registry%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	reward_payload_value jsonb;
	resource_delta_value jsonb;
	deposited_items_payload jsonb := coalesce(p_request_payload->'deposited_items', '{}'::jsonb);
	item_record record;
	item_quantity numeric;
	total_deposited numeric := 0;
	preview_ossos numeric := 0;
	preview_po_osso numeric := 0;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_ruleset_id text := nullif(trim(coalesce(p_request_payload->>'ruleset_id', '')), '');
	payload_ruleset_version integer := coalesce((p_request_payload->>'ruleset_version')::integer, 0);
	payload_session_seconds integer;
	payload_activity_score integer;
	plausible_score integer;
	base_energia integer;
	base_ossos integer;
	base_xp integer;
	daily_energia numeric := 0;
	daily_ossos numeric := 0;
	daily_xp numeric := 0;
	reward_energia integer := 0;
	reward_ossos integer := 0;
	reward_xp integer := 0;
	reward_period_key text := to_char(now() at time zone 'UTC', 'YYYY-MM-DD');
	scope_id text;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	if payload_mode_id <> 'openworld' or payload_slice_id <> 'forest' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;

	if payload_ruleset_id <> 'openworld_forest_ruleset_v0' or payload_ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;

	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
		payload_session_seconds := (p_request_payload->>'session_seconds')::integer;
		payload_activity_score := (p_request_payload->>'activity_score')::integer;
	exception when others then
		raise exception 'INVALID_RESULT' using errcode = 'P0001';
	end;

	if payload_session_seconds < 5 or payload_session_seconds > 1800 then
		raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
	end if;

	if payload_activity_score < 0 or payload_activity_score > 500 then
		raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
	end if;

	if jsonb_typeof(deposited_items_payload) <> 'object' then
		raise exception 'INVALID_RESULT' using errcode = 'P0001';
	end if;

	for item_record in select * from jsonb_each_text(deposited_items_payload)
	loop
		if item_record.key not in (
			'madeira',
			'galho',
			'folha',
			'folha_seca',
			'pedra',
			'pedra_pequena',
			'cogumelo',
			'fungo',
			'inseto',
			'resina',
			'cinzas_preview',
			'ossos_preview',
			'po_osso_preview'
		) then
			raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
		end if;

		begin
			item_quantity := item_record.value::numeric;
		exception when others then
			raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
		end;

		if item_quantity < 0 or item_quantity > 999 then
			raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
		end if;

		total_deposited := total_deposited + item_quantity;
		if item_record.key = 'ossos_preview' then
			preview_ossos := preview_ossos + item_quantity;
		elsif item_record.key = 'po_osso_preview' then
			preview_po_osso := preview_po_osso + item_quantity;
		end if;
	end loop;

	select *
	into save_row
	from public.game_saves
	where id = p_game_save_id
		and lifecycle_status = 'active'
	for update;

	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;

	if save_row.legacy_player_id is null then
		raise exception 'GAME_SAVE_WITHOUT_LEGACY_PLAYER' using errcode = 'P0001';
	end if;

	if save_row.save_type = 'progression_lab' then
		raise exception 'MODE_REWARD_BLOCKED_FOR_LAB' using errcode = 'P0001';
	end if;

	select *
	into ruleset_row
	from public.mode_ruleset_registry
	where ruleset_id = payload_ruleset_id
		and ruleset_version = payload_ruleset_version
		and mode_id = payload_mode_id
		and slice_id = payload_slice_id
		and status = 'active'
		and release_channel = 'internal_alpha'
	limit 1;

	if ruleset_row.publication_id is null then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;

	scope_id := 'mode:' || payload_mode_id || ':' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'modes/session/complete',
		p_request_id,
		p_request_hash,
		scope_id
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into session_row
	from public.mode_sessions
	where id = payload_session_id
		and game_save_id = save_row.id
		and mode_id = payload_mode_id
		and slice_id = payload_slice_id
	for update;

	if session_row.id is null then
		raise exception 'MODE_SESSION_NOT_FOUND' using errcode = 'P0001';
	end if;

	if session_row.status = 'completed' then
		return public.complete_idempotency(
			save_row.legacy_player_id,
			'modes/session/complete',
			p_request_id,
			coalesce(session_row.reward_payload, '{}'::jsonb),
			p_request_hash
		);
	end if;

	if session_row.status <> 'started' then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
	end if;

	select *
	into player_row
	from public.players
	where id = save_row.legacy_player_id
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into resource_row
	from public.resources
	where player_id = save_row.legacy_player_id
	for update;

	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	plausible_score := floor(least(
		payload_activity_score,
		total_deposited * 12 + payload_session_seconds / 3.0,
		240
	))::integer;
	base_energia := least(12, floor(plausible_score / 8.0)::integer);
	base_ossos := least(2, floor((preview_ossos + preview_po_osso) / 3.0)::integer);
	base_xp := least(8, floor(plausible_score / 20.0)::integer);

	select
		coalesce(sum(coalesce(nullif(mode_reward_claims.resource_delta->>'energia', '')::numeric, 0)), 0),
		coalesce(sum(coalesce(nullif(mode_reward_claims.resource_delta->>'ossos', '')::numeric, 0)), 0),
		coalesce(sum(mode_reward_claims.xp_delta), 0)
	into daily_energia, daily_ossos, daily_xp
	from public.mode_reward_claims
	where player_id = save_row.legacy_player_id
		and mode_id = payload_mode_id
		and period_key = reward_period_key;

	reward_energia := greatest(0, least(base_energia::numeric, 30 - daily_energia))::integer;
	reward_ossos := greatest(0, least(base_ossos::numeric, 6 - daily_ossos))::integer;
	reward_xp := greatest(0, least(base_xp::numeric, 24 - daily_xp))::integer;
	resource_delta_value := jsonb_build_object(
		'energia', reward_energia,
		'ossos', reward_ossos,
		'xp', reward_xp
	);

	update public.resources
	set
		energia = energia + reward_energia,
		ossos = ossos + reward_ossos,
		updated_at = now()
	where player_id = save_row.legacy_player_id
	returning * into resource_row;

	update public.players
	set
		xp = xp + reward_xp,
		updated_at = now()
	where id = save_row.legacy_player_id
	returning * into player_row;

	insert into public.resource_transactions (
		player_id,
		source,
		request_id,
		delta
	)
	values (
		save_row.legacy_player_id,
		'mode:openworld:forest',
		p_request_id,
		resource_delta_value
	);

	reward_payload_value := jsonb_build_object(
		'schema_version', 'openworld_reward_bridge_v1',
		'mode_id', payload_mode_id,
		'slice_id', payload_slice_id,
		'ruleset_id', payload_ruleset_id,
		'ruleset_version', payload_ruleset_version,
		'session_id', session_row.id,
		'period_key', reward_period_key,
		'activity_score', payload_activity_score,
		'validated_score', plausible_score,
		'resource_delta', resource_delta_value,
		'local_items_accepted', deposited_items_payload,
		'source', 'mode:openworld:forest'
	);

	insert into public.mode_reward_claims (
		game_save_id,
		player_id,
		mode_id,
		session_id,
		request_id,
		request_hash,
		period_key,
		reward_payload,
		resource_delta,
		xp_delta
	)
	values (
		save_row.id,
		save_row.legacy_player_id,
		payload_mode_id,
		session_row.id,
		p_request_id,
		p_request_hash,
		reward_period_key,
		reward_payload_value,
		resource_delta_value,
		reward_xp
	);

	update public.mode_sessions
	set
		status = 'completed',
		complete_request_id = p_request_id,
		session_seconds = payload_session_seconds,
		activity_score = payload_activity_score,
		deposited_items = deposited_items_payload,
		result_payload = p_request_payload,
		reward_payload = reward_payload_value,
		completed_at = now(),
		updated_at = now()
	where id = session_row.id
	returning * into session_row;

	insert into public.mode_progress as progress_row (
		game_save_id,
		mode_id,
		local_schema_version,
		progress_payload,
		totals_payload,
		last_session_id,
		updated_at
	)
	values (
		save_row.id,
		payload_mode_id,
		'openworld_forest_local_v0',
		jsonb_build_object('last_completed_session_id', session_row.id),
		jsonb_build_object(
			'sessions_started', 1,
			'sessions_completed', 1,
			'activity_score', payload_activity_score,
			'validated_score', plausible_score
		),
		session_row.id,
		now()
	)
	on conflict (game_save_id, mode_id) do update
	set
		progress_payload = jsonb_build_object('last_completed_session_id', session_row.id),
		totals_payload = jsonb_build_object(
			'sessions_started',
			coalesce(nullif(progress_row.totals_payload->>'sessions_started', '')::integer, 0),
			'sessions_completed',
			coalesce(nullif(progress_row.totals_payload->>'sessions_completed', '')::integer, 0) + 1,
			'activity_score',
			coalesce(nullif(progress_row.totals_payload->>'activity_score', '')::integer, 0) + payload_activity_score,
			'validated_score',
			coalesce(nullif(progress_row.totals_payload->>'validated_score', '')::integer, 0) + plausible_score
		),
		last_session_id = session_row.id,
		updated_at = now();

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode', jsonb_build_object(
			'mode_id', payload_mode_id,
			'slice_id', payload_slice_id,
			'ruleset_id', payload_ruleset_id,
			'ruleset_version', payload_ruleset_version,
			'release_channel', 'internal_alpha'
		),
		'session', jsonb_build_object(
			'id', session_row.id,
			'status', session_row.status,
			'session_seconds', payload_session_seconds,
			'activity_score', payload_activity_score,
			'validated_score', plausible_score,
			'completed_at', session_row.completed_at
		),
		'reward', reward_payload_value,
		'resources', jsonb_build_object(
			'energia', resource_row.energia,
			'ossos', resource_row.ossos,
			'xp', player_row.xp
		),
		'limits', jsonb_build_object(
			'daily', jsonb_build_object('energia', 30, 'ossos', 6, 'xp', 24),
			'used_today_before', jsonb_build_object('energia', daily_energia, 'ossos', daily_ossos, 'xp', daily_xp),
			'applied', resource_delta_value,
			'period_key', reward_period_key
		),
		'server_time', now()
	);

	update public.mode_sessions
	set reward_payload = response_payload
	where id = session_row.id;

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/complete',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

revoke all on function public.mode_session_start_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_start_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) to service_role;
