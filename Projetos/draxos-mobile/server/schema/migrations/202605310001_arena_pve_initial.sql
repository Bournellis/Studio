-- Adds the first server-authoritative Arena PVE attempt model and RPCs.

create table if not exists public.arena_progress (
	game_save_id uuid primary key references public.game_saves(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	tutorial_completed boolean not null default false,
	best_completed_difficulty integer not null default 0,
	best_completed_length integer not null default 0,
	best_attempt_step integer not null default 0,
	total_attempts integer not null default 0,
	total_clears integer not null default 0,
	last_attempt_id uuid,
	metadata jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	check (best_completed_difficulty >= 0),
	check (best_completed_length >= 0),
	check (best_attempt_step >= 0),
	check (total_attempts >= 0),
	check (total_clears >= 0)
);

create table if not exists public.arena_attempts (
	id uuid primary key default gen_random_uuid(),
	game_save_id uuid not null references public.game_saves(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	arena_id text not null,
	difficulty_id text not null,
	difficulty_rank integer not null default 0,
	max_steps integer not null,
	current_step_index integer not null default 0,
	status text not null default 'active' check (status in ('active', 'completed', 'failed', 'abandoned')),
	seed text not null,
	enemy_sequence jsonb not null default '[]'::jsonb,
	loadout_snapshot jsonb not null default '{}'::jsonb,
	active_buffs jsonb not null default '[]'::jsonb,
	reward_payload jsonb not null default '{}'::jsonb,
	start_request_id uuid not null,
	request_hash text not null,
	ruleset_id text not null default 'foundation_ruleset_v0',
	ruleset_version integer not null default 1,
	ruleset_publication_id uuid references public.ruleset_registry(publication_id),
	ruleset_content_hash text,
	ruleset_simulator_hash text,
	ruleset_schema_version text,
	started_at timestamptz not null default now(),
	completed_at timestamptz,
	abandoned_at timestamptz,
	updated_at timestamptz not null default now(),
	check (difficulty_rank >= 0),
	check (max_steps between 1 and 10),
	check (current_step_index between 0 and max_steps),
	check (jsonb_typeof(enemy_sequence) = 'array'),
	check (jsonb_typeof(loadout_snapshot) = 'object'),
	check (jsonb_typeof(active_buffs) = 'array'),
	check (jsonb_typeof(reward_payload) = 'object')
);

create table if not exists public.arena_attempt_steps (
	id uuid primary key default gen_random_uuid(),
	attempt_id uuid not null references public.arena_attempts(id) on delete cascade,
	game_save_id uuid not null references public.game_saves(id) on delete cascade,
	player_id uuid not null references public.players(id) on delete cascade,
	step_index integer not null,
	step_type text not null default 'duel' check (step_type in ('duel', 'buff')),
	status text not null default 'completed' check (status in ('pending', 'completed', 'skipped')),
	opponent_bot_id text,
	seed text,
	battle_log jsonb not null default '{}'::jsonb,
	result jsonb not null default '{}'::jsonb,
	reward_payload jsonb not null default '{}'::jsonb,
	buff_options jsonb not null default '[]'::jsonb,
	selected_buff jsonb,
	request_id uuid not null,
	request_hash text not null,
	created_at timestamptz not null default now(),
	completed_at timestamptz,
	updated_at timestamptz not null default now(),
	unique (attempt_id, step_index, step_type),
	check (step_index > 0),
	check (jsonb_typeof(battle_log) = 'object'),
	check (jsonb_typeof(result) = 'object'),
	check (jsonb_typeof(reward_payload) = 'object'),
	check (jsonb_typeof(buff_options) = 'array'),
	check (selected_buff is null or jsonb_typeof(selected_buff) = 'object')
);

create index if not exists arena_progress_player_idx
	on public.arena_progress (player_id);

create index if not exists arena_attempts_game_save_created_idx
	on public.arena_attempts (game_save_id, started_at desc);

create unique index if not exists arena_attempts_one_active_per_save_idx
	on public.arena_attempts (game_save_id)
	where status = 'active';

create index if not exists arena_attempt_steps_attempt_idx
	on public.arena_attempt_steps (attempt_id, step_index);

alter table public.arena_progress enable row level security;
alter table public.arena_attempts enable row level security;
alter table public.arena_attempt_steps enable row level security;

drop policy if exists "arena_progress_select_own" on public.arena_progress;
create policy "arena_progress_select_own"
	on public.arena_progress for select
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

drop policy if exists "arena_attempts_select_own" on public.arena_attempts;
create policy "arena_attempts_select_own"
	on public.arena_attempts for select
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

drop policy if exists "arena_attempt_steps_select_own" on public.arena_attempt_steps;
create policy "arena_attempt_steps_select_own"
	on public.arena_attempt_steps for select
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

create or replace function public.ensure_arena_progress_v1(
	p_game_save_id uuid
)
returns public.arena_progress
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	save_row public.game_saves%rowtype;
	progress_row public.arena_progress%rowtype;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where id = p_game_save_id
		and lifecycle_status = 'active';

	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;

	if save_row.legacy_player_id is null then
		raise exception 'GAME_SAVE_WITHOUT_LEGACY_PLAYER' using errcode = 'P0001';
	end if;

	insert into public.arena_progress (game_save_id, player_id)
	values (save_row.id, save_row.legacy_player_id)
	on conflict (game_save_id) do update set
		player_id = excluded.player_id,
		updated_at = now()
	returning * into progress_row;

	return progress_row;
end;
$$;

create or replace function public.arena_start_v1(
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
	ruleset_row public.ruleset_registry%rowtype;
	active_attempt public.arena_attempts%rowtype;
	attempt_row public.arena_attempts%rowtype;
	progress_row public.arena_progress%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	payload_arena_id text := nullif(trim(coalesce(p_request_payload->>'arena_id', '')), '');
	payload_difficulty_id text := nullif(trim(coalesce(p_request_payload->>'difficulty_id', '')), '');
	payload_seed text := nullif(trim(coalesce(p_request_payload->>'seed', '')), '');
	payload_max_steps integer := coalesce((p_request_payload->>'max_steps')::integer, 0);
	payload_difficulty_rank integer := greatest(0, coalesce((p_request_payload->>'difficulty_rank')::integer, 0));
	now_ts timestamptz := now();
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if payload_arena_id is null or payload_difficulty_id is null or payload_seed is null then
		raise exception 'INVALID_ARENA_PAYLOAD' using errcode = 'P0001';
	end if;
	if payload_max_steps < 1 or payload_max_steps > 10 then
		raise exception 'INVALID_ARENA_LENGTH' using errcode = 'P0001';
	end if;
	if jsonb_typeof(coalesce(p_request_payload->'enemy_sequence', '[]'::jsonb)) <> 'array' then
		raise exception 'INVALID_ARENA_PAYLOAD' using errcode = 'P0001';
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
	into ruleset_row
	from public.ruleset_registry
	where ruleset_id = save_row.ruleset_id
		and ruleset_version = save_row.ruleset_version;

	if ruleset_row.ruleset_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'arena/start',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into active_attempt
	from public.arena_attempts
	where game_save_id = save_row.id
		and status = 'active'
	for update;

	if active_attempt.id is not null then
		raise exception 'ARENA_ATTEMPT_ALREADY_ACTIVE' using errcode = 'P0001';
	end if;

	progress_row := public.ensure_arena_progress_v1(save_row.id);

	insert into public.arena_attempts (
		game_save_id,
		player_id,
		arena_id,
		difficulty_id,
		difficulty_rank,
		max_steps,
		seed,
		enemy_sequence,
		loadout_snapshot,
		active_buffs,
		start_request_id,
		request_hash,
		ruleset_id,
		ruleset_version,
		ruleset_publication_id,
		ruleset_content_hash,
		ruleset_simulator_hash,
		ruleset_schema_version,
		started_at,
		updated_at
	)
	values (
		save_row.id,
		save_row.legacy_player_id,
		payload_arena_id,
		payload_difficulty_id,
		payload_difficulty_rank,
		payload_max_steps,
		payload_seed,
		coalesce(p_request_payload->'enemy_sequence', '[]'::jsonb),
		coalesce(p_request_payload->'loadout_snapshot', '{}'::jsonb),
		'[]'::jsonb,
		p_request_id,
		normalized_hash,
		ruleset_row.ruleset_id,
		ruleset_row.ruleset_version,
		ruleset_row.publication_id,
		ruleset_row.content_hash,
		ruleset_row.simulator_hash,
		ruleset_row.schema_version,
		now_ts,
		now_ts
	)
	returning * into attempt_row;

	update public.arena_progress
	set
		total_attempts = total_attempts + 1,
		last_attempt_id = attempt_row.id,
		updated_at = now_ts
	where game_save_id = save_row.id
	returning * into progress_row;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'arena_start_response_v1',
		'endpoint', 'arena/start',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'attempt', to_jsonb(attempt_row),
		'progress', to_jsonb(progress_row),
		'ruleset', jsonb_build_object(
			'ruleset_id', ruleset_row.ruleset_id,
			'ruleset_version', ruleset_row.ruleset_version,
			'publication_id', ruleset_row.publication_id,
			'content_hash', ruleset_row.content_hash,
			'simulator_hash', ruleset_row.simulator_hash,
			'schema_version', ruleset_row.schema_version
		)
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'arena/start',
		p_request_id,
		response_payload,
		normalized_hash
	);
end;
$$;

create or replace function public.arena_record_duel_v1(
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
	attempt_row public.arena_attempts%rowtype;
	step_row public.arena_attempt_steps%rowtype;
	progress_row public.arena_progress%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	reward_delta jsonb := '{}'::jsonb;
	payload_attempt_id uuid;
	next_step_index integer;
	winner text;
	next_status text := 'active';
	next_action text := 'choose_buff';
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	now_ts timestamptz := now();
	xp_delta integer := 0;
	delta_almas numeric := 0;
	delta_energia numeric := 0;
	delta_sangue numeric := 0;
	delta_cristais numeric := 0;
	delta_ossos numeric := 0;
	delta_po_osso numeric := 0;
	delta_diamante integer := 0;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	payload_attempt_id := (p_request_payload->>'attempt_id')::uuid;
	if payload_attempt_id is null then
		raise exception 'INVALID_ARENA_ATTEMPT' using errcode = 'P0001';
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

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'arena/duel/request',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into attempt_row
	from public.arena_attempts
	where id = payload_attempt_id
		and game_save_id = save_row.id
		and status = 'active'
	for update;

	if attempt_row.id is null then
		raise exception 'ARENA_ATTEMPT_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	next_step_index := attempt_row.current_step_index + 1;
	if next_step_index > attempt_row.max_steps then
		raise exception 'ARENA_ATTEMPT_COMPLETE' using errcode = 'P0001';
	end if;
	if jsonb_typeof(coalesce(p_request_payload->'battle_log', '{}'::jsonb)) <> 'object' then
		raise exception 'INVALID_ARENA_PAYLOAD' using errcode = 'P0001';
	end if;

	winner := coalesce(p_request_payload#>>'{result,winner}', p_request_payload#>>'{battle_log,result,winner}', 'opponent');
	if winner <> 'player' then
		next_status := 'failed';
		next_action := 'failed';
	elsif next_step_index >= attempt_row.max_steps then
		next_status := 'completed';
		next_action := 'completed';
	else
		next_status := 'active';
		next_action := 'choose_buff';
	end if;

	insert into public.arena_attempt_steps (
		attempt_id,
		game_save_id,
		player_id,
		step_index,
		step_type,
		status,
		opponent_bot_id,
		seed,
		battle_log,
		result,
		reward_payload,
		buff_options,
		request_id,
		request_hash,
		completed_at,
		updated_at
	)
	values (
		attempt_row.id,
		save_row.id,
		save_row.legacy_player_id,
		next_step_index,
		'duel',
		'completed',
		nullif(trim(coalesce(p_request_payload->>'opponent_bot_id', '')), ''),
		coalesce(p_request_payload->>'seed', ''),
		coalesce(p_request_payload->'battle_log', '{}'::jsonb),
		coalesce(p_request_payload->'result', coalesce(p_request_payload#>'{battle_log,result}', '{}'::jsonb)),
		coalesce(p_request_payload->'reward_payload', '{}'::jsonb),
		coalesce(p_request_payload->'buff_options', '[]'::jsonb),
		p_request_id,
		normalized_hash,
		now_ts,
		now_ts
	)
	returning * into step_row;

	update public.arena_attempts
	set
		current_step_index = next_step_index,
		status = next_status,
		reward_payload = case when next_status = 'completed' then coalesce(p_request_payload->'reward_payload', '{}'::jsonb) else reward_payload end,
		completed_at = case when next_status in ('completed', 'failed') then now_ts else completed_at end,
		updated_at = now_ts
	where id = attempt_row.id
	returning * into attempt_row;

	progress_row := public.ensure_arena_progress_v1(save_row.id);

	if next_status = 'completed' then
		reward_delta := coalesce(
			p_request_payload->'reward_delta',
			p_request_payload#>'{reward_payload,economy_delta}',
			'{}'::jsonb
		);
		if jsonb_typeof(reward_delta) <> 'object' then
			raise exception 'INVALID_ARENA_REWARD' using errcode = 'P0001';
		end if;

		xp_delta := public.foundation_jsonb_integer_v1(reward_delta, 'xp');
		delta_almas := public.foundation_jsonb_numeric_v1(reward_delta, 'almas');
		delta_energia := public.foundation_jsonb_numeric_v1(reward_delta, 'energia');
		delta_sangue := public.foundation_jsonb_numeric_v1(reward_delta, 'sangue');
		delta_cristais := public.foundation_jsonb_numeric_v1(reward_delta, 'cristais');
		delta_ossos := public.foundation_jsonb_numeric_v1(reward_delta, 'ossos');
		delta_po_osso := public.foundation_jsonb_numeric_v1(reward_delta, 'po_osso');
		delta_diamante := public.foundation_jsonb_integer_v1(reward_delta, 'diamante');

		update public.players
		set
			xp = xp + greatest(0, xp_delta),
			updated_at = now_ts
		where id = save_row.legacy_player_id
		returning * into player_row;

		update public.resources
		set
			almas = almas + greatest(0, delta_almas),
			energia = energia + greatest(0, delta_energia),
			sangue = sangue + greatest(0, delta_sangue),
			cristais = cristais + greatest(0, delta_cristais),
			ossos = ossos + greatest(0, delta_ossos),
			po_osso = po_osso + greatest(0, delta_po_osso),
			diamante = diamante + greatest(0, delta_diamante),
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into resource_row;

		insert into public.resource_transactions (player_id, source, request_id, delta)
		values (save_row.legacy_player_id, 'arena_pve_v1', p_request_id, reward_delta);
	end if;

	update public.arena_progress
	set
		best_attempt_step = greatest(best_attempt_step, next_step_index),
		best_completed_difficulty = case
			when next_status = 'completed' then greatest(best_completed_difficulty, attempt_row.difficulty_rank)
			else best_completed_difficulty
		end,
		best_completed_length = case
			when next_status = 'completed' then greatest(best_completed_length, attempt_row.max_steps)
			else best_completed_length
		end,
		tutorial_completed = tutorial_completed or (next_status = 'completed' and attempt_row.arena_id = 'arena_tutorial_cinzas'),
		total_clears = total_clears + case when next_status = 'completed' then 1 else 0 end,
		last_attempt_id = attempt_row.id,
		updated_at = now_ts
	where game_save_id = save_row.id
	returning * into progress_row;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'arena_duel_response_v1',
		'endpoint', 'arena/duel/request',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'attempt', to_jsonb(attempt_row),
		'step', to_jsonb(step_row),
		'progress', to_jsonb(progress_row),
		'player', to_jsonb(player_row),
		'resources', to_jsonb(resource_row),
		'reward_delta', reward_delta,
		'next_action', next_action,
		'ranking', jsonb_build_object('mutated', false, 'reason', 'ARENA_PVE_DOES_NOT_RANK')
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'arena/duel/request',
		p_request_id,
		response_payload,
		normalized_hash
	);
end;
$$;

create or replace function public.arena_choose_buff_v1(
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
	attempt_row public.arena_attempts%rowtype;
	step_row public.arena_attempt_steps%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	selected_option jsonb;
	payload_attempt_id uuid;
	payload_step_index integer := coalesce((p_request_payload->>'step_index')::integer, 0);
	payload_buff_id text := nullif(trim(coalesce(p_request_payload->>'buff_id', '')), '');
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	now_ts timestamptz := now();
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	payload_attempt_id := (p_request_payload->>'attempt_id')::uuid;
	if payload_attempt_id is null or payload_step_index <= 0 or payload_buff_id is null then
		raise exception 'INVALID_ARENA_PAYLOAD' using errcode = 'P0001';
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

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'arena/buff/choose',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into attempt_row
	from public.arena_attempts
	where id = payload_attempt_id
		and game_save_id = save_row.id
		and status = 'active'
	for update;

	if attempt_row.id is null then
		raise exception 'ARENA_ATTEMPT_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	select *
	into step_row
	from public.arena_attempt_steps
	where attempt_id = attempt_row.id
		and step_index = payload_step_index
		and step_type = 'duel'
	for update;

	if step_row.id is null then
		raise exception 'ARENA_STEP_NOT_FOUND' using errcode = 'P0001';
	end if;

	if step_row.selected_buff is not null then
		if coalesce(step_row.selected_buff->>'id', '') = payload_buff_id then
			selected_option := step_row.selected_buff;
		else
			raise exception 'ARENA_BUFF_ALREADY_CHOSEN' using errcode = 'P0001';
		end if;
	else
		select option_value
		into selected_option
		from jsonb_array_elements(coalesce(step_row.buff_options, '[]'::jsonb)) as option_value
		where option_value->>'id' = payload_buff_id
		limit 1;

		if selected_option is null then
			raise exception 'ARENA_BUFF_NOT_AVAILABLE' using errcode = 'P0001';
		end if;

		update public.arena_attempt_steps
		set
			selected_buff = selected_option,
			updated_at = now_ts
		where id = step_row.id
		returning * into step_row;

		update public.arena_attempts
		set
			active_buffs = active_buffs || jsonb_build_array(selected_option),
			updated_at = now_ts
		where id = attempt_row.id
		returning * into attempt_row;
	end if;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'arena_buff_choose_response_v1',
		'endpoint', 'arena/buff/choose',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'attempt', to_jsonb(attempt_row),
		'step', to_jsonb(step_row),
		'selected_buff', selected_option
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'arena/buff/choose',
		p_request_id,
		response_payload,
		normalized_hash
	);
end;
$$;

create or replace function public.arena_abandon_v1(
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
	attempt_row public.arena_attempts%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	payload_attempt_id uuid;
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	now_ts timestamptz := now();
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	payload_attempt_id := (p_request_payload->>'attempt_id')::uuid;
	if payload_attempt_id is null then
		raise exception 'INVALID_ARENA_ATTEMPT' using errcode = 'P0001';
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

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'arena/abandon',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into attempt_row
	from public.arena_attempts
	where id = payload_attempt_id
		and game_save_id = save_row.id
		and status = 'active'
	for update;

	if attempt_row.id is null then
		raise exception 'ARENA_ATTEMPT_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	update public.arena_attempts
	set
		status = 'abandoned',
		abandoned_at = now_ts,
		updated_at = now_ts
	where id = attempt_row.id
	returning * into attempt_row;

	update public.arena_progress
	set
		last_attempt_id = attempt_row.id,
		updated_at = now_ts
	where game_save_id = save_row.id;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'arena_abandon_response_v1',
		'endpoint', 'arena/abandon',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'attempt', to_jsonb(attempt_row)
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'arena/abandon',
		p_request_id,
		response_payload,
		normalized_hash
	);
end;
$$;

revoke all on function public.ensure_arena_progress_v1(uuid) from public;
revoke all on function public.arena_start_v1(uuid, uuid, text, jsonb) from public;
revoke all on function public.arena_record_duel_v1(uuid, uuid, text, jsonb) from public;
revoke all on function public.arena_choose_buff_v1(uuid, uuid, text, jsonb) from public;
revoke all on function public.arena_abandon_v1(uuid, uuid, text, jsonb) from public;

grant execute on function public.ensure_arena_progress_v1(uuid) to service_role;
grant execute on function public.arena_start_v1(uuid, uuid, text, jsonb) to service_role;
grant execute on function public.arena_record_duel_v1(uuid, uuid, text, jsonb) to service_role;
grant execute on function public.arena_choose_buff_v1(uuid, uuid, text, jsonb) to service_role;
grant execute on function public.arena_abandon_v1(uuid, uuid, text, jsonb) to service_role;
