alter table public.mode_sessions
	add column if not exists snapshot_payload jsonb not null default '{}'::jsonb,
	add column if not exists snapshot_revision integer not null default 0 check (snapshot_revision >= 0),
	add column if not exists last_event_at timestamptz;

create table if not exists public.mode_session_events (
	id uuid primary key default gen_random_uuid(),
	game_save_id uuid not null references public.game_saves(id) on delete cascade,
	session_id uuid not null references public.mode_sessions(id) on delete cascade,
	mode_id text not null,
	slice_id text not null,
	request_id uuid not null,
	request_hash text not null,
	event_type text not null check (
		event_type in (
			'move_heartbeat',
			'collect_start',
			'collect_cancel',
			'collect_complete',
			'deposit_all',
			'craft',
			'complete_requested',
			'abandon_requested'
		)
	),
	expected_revision integer not null check (expected_revision >= 0),
	revision_after integer not null check (revision_after >= 0),
	event_payload jsonb not null default '{}'::jsonb,
	snapshot_payload jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	unique (session_id, request_id)
);

create index if not exists mode_session_events_session_revision_idx
	on public.mode_session_events (session_id, revision_after, created_at desc);

alter table public.mode_session_events enable row level security;

drop policy if exists "mode_session_events_select_own" on public.mode_session_events;
create policy "mode_session_events_select_own"
	on public.mode_session_events for select
	to authenticated
	using (
		game_save_id in (
			select gs.id
			from public.game_saves gs
			join public.account_profiles ap on ap.id = gs.account_profile_id
			where ap.auth_user_id = auth.uid()
		)
	);

update public.mode_registry
set
	status = 'active',
	release_channel = 'internal_alpha',
	default_slice_id = 'forest',
	active_ruleset_id = 'openworld_forest_ruleset_v1',
	active_ruleset_version = 1,
	metadata = jsonb_build_object(
		'summary', 'Bosque aprovado em internal alpha como modo oficial tecnico com snapshot remoto autoritativo.',
		'official_internal_alpha', true,
		'expansion_decision_id', 'DMOB-D071',
		'public_release', false
	),
	updated_at = now()
where mode_id = 'openworld';

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
	'openworld_forest_ruleset_v1',
	1,
	'openworld',
	'forest',
	'active',
	'internal_alpha',
	'{"session_seconds_min":5,"session_seconds_max":1800,"activity_score_max":500,"snapshot_revision_required":true}'::jsonb,
	'{"daily":{"energia":30,"ossos":6,"xp":24},"per_session":{"energia":12,"ossos":2,"xp":8}}'::jsonb,
	'{"schema_version":"openworld_forest_ruleset_v1","definition_path":"data/definitions/openworld/forest_ruleset_v1.json","server_authoritative_snapshot":true,"offline_preview_reward":false}'::jsonb
)
on conflict (ruleset_id, ruleset_version, release_channel) do update
set
	status = excluded.status,
	result_limits = excluded.result_limits,
	reward_limits = excluded.reward_limits,
	ruleset_payload = excluded.ruleset_payload,
	updated_at = now();

update public.mode_ruleset_registry
set status = 'deprecated', updated_at = now()
where ruleset_id = 'openworld_forest_ruleset_v0'
	and ruleset_version = 1
	and release_channel = 'internal_alpha';

alter table public.mode_limit_policies
	add column if not exists ruleset_version integer not null default 1 check (ruleset_version > 0),
	add column if not exists reward_daily_caps jsonb not null default '{}'::jsonb,
	add column if not exists result_limits jsonb not null default '{}'::jsonb;

do $mode_limit_policies_compat$
begin
	if exists (
		select 1
		from information_schema.columns
		where table_schema = 'public'
			and table_name = 'mode_limit_policies'
			and column_name = 'reward_cap_payload'
	) then
		update public.mode_limit_policies
		set reward_daily_caps = reward_cap_payload
		where reward_daily_caps = '{}'::jsonb
			and reward_cap_payload <> '{}'::jsonb;
	end if;
end $mode_limit_policies_compat$;

create unique index if not exists mode_limit_policies_ruleset_version_uidx
	on public.mode_limit_policies (mode_id, slice_id, ruleset_id, ruleset_version);

insert into public.mode_limit_policies (
	mode_id,
	slice_id,
	ruleset_id,
	ruleset_version,
	max_active_sessions,
	start_cooldown_seconds,
	session_expiry_seconds,
	daily_start_limit,
	reward_daily_caps,
	result_limits
)
values (
	'openworld',
	'forest',
	'openworld_forest_ruleset_v1',
	1,
	1,
	10,
	7200,
	100,
	'{"energia":30,"ossos":6,"xp":24}'::jsonb,
	'{"session_seconds_min":5,"session_seconds_max":1800,"activity_score_max":500}'::jsonb
)
on conflict (mode_id, slice_id, ruleset_id, ruleset_version) do update
set
	max_active_sessions = excluded.max_active_sessions,
	start_cooldown_seconds = excluded.start_cooldown_seconds,
	session_expiry_seconds = excluded.session_expiry_seconds,
	daily_start_limit = excluded.daily_start_limit,
	reward_daily_caps = excluded.reward_daily_caps,
	result_limits = excluded.result_limits,
	updated_at = now();

create or replace function public.openworld_forest_item_weight_v1(p_item_id text)
returns numeric
language sql
immutable
as $$
	select case p_item_id
		when 'madeira' then 2.0
		when 'galho' then 0.8
		when 'folha' then 0.2
		when 'folha_seca' then 0.2
		when 'pedra' then 2.5
		when 'pedra_pequena' then 1.0
		when 'cogumelo' then 0.4
		when 'fungo' then 0.4
		when 'inseto' then 0.2
		when 'resina' then 0.5
		when 'cinzas_preview' then 0.3
		when 'ossos_preview' then 1.2
		when 'po_osso_preview' then 0.5
		else null
	end
$$;

create or replace function public.openworld_forest_node_item_v1(p_node_id text)
returns text
language sql
immutable
as $$
	select case p_node_id
		when 'node_galho_01' then 'galho'
		when 'node_folha_01' then 'folha'
		when 'node_madeira_01' then 'madeira'
		when 'node_pedra_pequena_01' then 'pedra_pequena'
		when 'node_pedra_01' then 'pedra'
		when 'node_cogumelo_01' then 'cogumelo'
		when 'node_fungo_01' then 'fungo'
		when 'node_inseto_01' then 'inseto'
		when 'node_resina_01' then 'resina'
		when 'node_folha_seca_01' then 'folha_seca'
		when 'node_cinzas_preview_01' then 'cinzas_preview'
		when 'node_ossos_preview_01' then 'ossos_preview'
		when 'node_po_osso_preview_01' then 'po_osso_preview'
		else null
	end
$$;

create or replace function public.openworld_forest_inventory_quantity_v1(
	p_inventory jsonb,
	p_item_id text
)
returns integer
language sql
immutable
as $$
	select greatest(0, coalesce(nullif(p_inventory->>p_item_id, '')::integer, 0))
$$;

create or replace function public.openworld_forest_inventory_weight_v1(p_inventory jsonb)
returns numeric
language plpgsql
immutable
as $$
declare
	item_record record;
	item_weight numeric;
	total_weight numeric := 0;
begin
	if jsonb_typeof(coalesce(p_inventory, '{}'::jsonb)) <> 'object' then
		return 0;
	end if;

	for item_record in select * from jsonb_each_text(coalesce(p_inventory, '{}'::jsonb))
	loop
		item_weight := public.openworld_forest_item_weight_v1(item_record.key);
		if item_weight is not null then
			total_weight := total_weight + item_weight * greatest(0, item_record.value::numeric);
		end if;
	end loop;

	return total_weight;
end;
$$;

create or replace function public.openworld_forest_activity_score_v1(p_snapshot jsonb)
returns integer
language plpgsql
immutable
as $$
declare
	item_record record;
	upgrade_record record;
	item_weight numeric;
	score integer := 0;
begin
	for item_record in select * from jsonb_each_text(coalesce(p_snapshot->'chest', '{}'::jsonb))
	loop
		item_weight := public.openworld_forest_item_weight_v1(item_record.key);
		if item_weight is not null then
			score := score + greatest(0, item_record.value::integer) * greatest(1, round(item_weight)::integer);
		end if;
	end loop;

	for upgrade_record in select * from jsonb_each_text(coalesce(p_snapshot->'upgrades', '{}'::jsonb))
	loop
		if upgrade_record.value::boolean then
			score := score + 5;
		end if;
	end loop;

	return greatest(0, least(score, 500));
end;
$$;

create or replace function public.openworld_forest_recompute_snapshot_v1(p_snapshot jsonb)
returns jsonb
language plpgsql
immutable
as $$
declare
	result jsonb := coalesce(p_snapshot, '{}'::jsonb);
	capacity numeric;
	pocket_weight numeric;
	min_speed numeric;
	load_ratio numeric;
	current_speed numeric;
	activity_score integer;
begin
	capacity := 20 + case when coalesce((result#>>'{upgrades,bolsa_simples_1}')::boolean, false) then 5 else 0 end;
	pocket_weight := public.openworld_forest_inventory_weight_v1(result->'pocket');
	min_speed := case when coalesce((result#>>'{upgrades,trilha_aberta_1}')::boolean, false) then 95 else 80 end;
	load_ratio := case when capacity <= 0 then 0 else pocket_weight / capacity end;
	current_speed := case
		when load_ratio <= 0.6 then 160
		else 160 - ((160 - min_speed) * least(1, greatest(0, (load_ratio - 0.6) / 0.4)))
	end;
	activity_score := public.openworld_forest_activity_score_v1(result);

	result := jsonb_set(result, '{schema_version}', to_jsonb('openworld_forest_snapshot_v1'::text), true);
	result := jsonb_set(result, '{mode_id}', to_jsonb('openworld'::text), true);
	result := jsonb_set(result, '{slice_id}', to_jsonb('forest'::text), true);
	result := jsonb_set(result, '{ruleset_id}', to_jsonb('openworld_forest_ruleset_v1'::text), true);
	result := jsonb_set(result, '{ruleset_version}', to_jsonb(1), true);
	result := jsonb_set(result, '{pocket}', coalesce(result->'pocket', '{}'::jsonb), true);
	result := jsonb_set(result, '{chest}', coalesce(result->'chest', '{}'::jsonb), true);
	result := jsonb_set(result, '{upgrades}', coalesce(result->'upgrades', '{}'::jsonb), true);
	result := jsonb_set(result, '{collected_nodes}', coalesce(result->'collected_nodes', '{}'::jsonb), true);
	result := jsonb_set(result, '{capacity}', to_jsonb(capacity), true);
	result := jsonb_set(result, '{pocket_weight}', to_jsonb(pocket_weight), true);
	result := jsonb_set(result, '{current_speed}', to_jsonb(current_speed), true);
	result := jsonb_set(result, '{activity_score}', to_jsonb(activity_score), true);
	result := jsonb_set(
		result,
		'{reward_payload}',
		jsonb_build_object(
			'deposited_items', coalesce(result->'chest', '{}'::jsonb),
			'activity_score', activity_score
		),
		true
	);
	result := result - 'active_collection';
	return result;
end;
$$;

create or replace function public.openworld_forest_initial_snapshot_v1()
returns jsonb
language sql
immutable
as $$
	select public.openworld_forest_recompute_snapshot_v1(
		'{
			"schema_version":"openworld_forest_snapshot_v1",
			"mode_id":"openworld",
			"slice_id":"forest",
			"ruleset_id":"openworld_forest_ruleset_v1",
			"ruleset_version":1,
			"revision":0,
			"player_position":{"x":220,"y":330},
			"session_seconds":0,
			"pocket":{},
			"chest":{},
			"upgrades":{},
			"collected_nodes":{},
			"last_message":"Bosque pronto."
		}'::jsonb
	)
$$;

create or replace function public.openworld_forest_recipe_cost_v1(p_recipe_id text)
returns jsonb
language sql
immutable
as $$
	select case p_recipe_id
		when 'bolsa_simples_1' then '{"galho":4,"folha":3,"resina":1}'::jsonb
		when 'maos_rituais_1' then '{"madeira":2,"pedra_pequena":2,"fungo":1}'::jsonb
		when 'trilha_aberta_1' then '{"pedra":2,"galho":3,"inseto":2}'::jsonb
		when 'fogueira_estavel_1' then '{"galho":2,"folha_seca":2,"pedra_pequena":1}'::jsonb
		else null
	end
$$;

create or replace function public.openworld_forest_recipe_output_v1(p_recipe_id text)
returns jsonb
language sql
immutable
as $$
	select case p_recipe_id
		when 'fogueira_estavel_1' then '{"cinzas_preview":2}'::jsonb
		else '{}'::jsonb
	end
$$;

create or replace function public.openworld_forest_apply_event_v1(
	p_snapshot jsonb,
	p_event_type text,
	p_event_payload jsonb
)
returns jsonb
language plpgsql
as $$
declare
	result jsonb := public.openworld_forest_recompute_snapshot_v1(p_snapshot);
	node_id text := nullif(trim(coalesce(p_event_payload->>'node_id', '')), '');
	item_id text := nullif(trim(coalesce(p_event_payload->>'item_id', '')), '');
	expected_item_id text;
	recipe_id text := nullif(trim(coalesce(p_event_payload->>'recipe_id', '')), '');
	cost_payload jsonb;
	output_payload jsonb;
	item_record record;
	current_quantity integer;
	next_quantity integer;
	capacity numeric;
	pocket_weight numeric;
	item_weight numeric;
	session_seconds integer;
	position_payload jsonb;
begin
	session_seconds := greatest(0, least(7200, coalesce((p_event_payload->>'session_seconds')::integer, coalesce((result->>'session_seconds')::integer, 0))));
	result := jsonb_set(result, '{session_seconds}', to_jsonb(session_seconds), true);

	position_payload := coalesce(p_event_payload->'position', result->'player_position', '{"x":220,"y":330}'::jsonb);
	if jsonb_typeof(position_payload) = 'object' then
		result := jsonb_set(
			result,
			'{player_position}',
			jsonb_build_object(
				'x', least(932, greatest(28, coalesce((position_payload->>'x')::numeric, 220))),
				'y', least(1372, greatest(28, coalesce((position_payload->>'y')::numeric, 330)))
			),
			true
		);
	end if;

	if p_event_type = 'move_heartbeat' then
		result := jsonb_set(result, '{last_message}', to_jsonb('Explorando o bosque.'::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type = 'collect_start' then
		expected_item_id := public.openworld_forest_node_item_v1(node_id);
		if expected_item_id is null or expected_item_id <> item_id then
			raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
		end if;
		result := jsonb_set(result, '{last_message}', to_jsonb(('Coletando ' || item_id || '.')::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type = 'collect_cancel' then
		result := jsonb_set(result, '{last_message}', to_jsonb('Coleta cancelada.'::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type = 'collect_complete' then
		expected_item_id := public.openworld_forest_node_item_v1(node_id);
		if expected_item_id is null or expected_item_id <> item_id then
			raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
		end if;
		if coalesce((result#>>array['collected_nodes', node_id])::boolean, false) then
			raise exception 'OPENWORLD_NODE_ALREADY_COLLECTED' using errcode = 'P0001';
		end if;
		item_weight := public.openworld_forest_item_weight_v1(item_id);
		if item_weight is null then
			raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
		end if;
		capacity := coalesce((result->>'capacity')::numeric, 20);
		pocket_weight := public.openworld_forest_inventory_weight_v1(result->'pocket');
		if pocket_weight + item_weight > capacity + 0.001 then
			raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
		end if;
		current_quantity := public.openworld_forest_inventory_quantity_v1(result->'pocket', item_id);
		result := jsonb_set(result, array['pocket', item_id], to_jsonb(current_quantity + 1), true);
		result := jsonb_set(result, array['collected_nodes', node_id], to_jsonb(true), true);
		result := jsonb_set(result, '{last_message}', to_jsonb(('+1 ' || item_id || ' no bolso.')::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type = 'deposit_all' then
		for item_record in select * from jsonb_each_text(coalesce(result->'pocket', '{}'::jsonb))
		loop
			current_quantity := public.openworld_forest_inventory_quantity_v1(result->'chest', item_record.key);
			next_quantity := current_quantity + greatest(0, item_record.value::integer);
			if next_quantity > 0 then
				result := jsonb_set(result, array['chest', item_record.key], to_jsonb(next_quantity), true);
			end if;
		end loop;
		result := jsonb_set(result, '{pocket}', '{}'::jsonb, true);
		result := jsonb_set(result, '{last_message}', to_jsonb('Bau atualizado.'::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type = 'craft' then
		cost_payload := public.openworld_forest_recipe_cost_v1(recipe_id);
		if cost_payload is null or coalesce((result#>>array['upgrades', recipe_id])::boolean, false) then
			raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
		end if;
		for item_record in select * from jsonb_each_text(cost_payload)
		loop
			if public.openworld_forest_inventory_quantity_v1(result->'chest', item_record.key) < item_record.value::integer then
				raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
			end if;
		end loop;
		for item_record in select * from jsonb_each_text(cost_payload)
		loop
			current_quantity := public.openworld_forest_inventory_quantity_v1(result->'chest', item_record.key);
			result := jsonb_set(result, array['chest', item_record.key], to_jsonb(greatest(0, current_quantity - item_record.value::integer)), true);
		end loop;
		result := jsonb_set(result, array['upgrades', recipe_id], to_jsonb(true), true);
		output_payload := public.openworld_forest_recipe_output_v1(recipe_id);
		for item_record in select * from jsonb_each_text(output_payload)
		loop
			current_quantity := public.openworld_forest_inventory_quantity_v1(result->'chest', item_record.key);
			result := jsonb_set(result, array['chest', item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
		end loop;
		result := jsonb_set(result, '{last_message}', to_jsonb(('Craft concluido: ' || recipe_id || '.')::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type in ('complete_requested', 'abandon_requested') then
		return public.openworld_forest_recompute_snapshot_v1(result);
	end if;

	raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
end;
$$;

create or replace function public.openworld_forest_session_payload_v1(p_session public.mode_sessions)
returns jsonb
language sql
stable
as $$
	select jsonb_build_object(
		'id', p_session.id,
		'status', p_session.status,
		'server_seed', p_session.server_seed,
		'started_at', p_session.started_at,
		'completed_at', p_session.completed_at,
		'expires_at', p_session.expires_at,
		'abandoned_at', p_session.abandoned_at,
		'session_seconds', p_session.session_seconds,
		'activity_score', p_session.activity_score,
		'deposited_items', p_session.deposited_items,
		'snapshot_payload', p_session.snapshot_payload,
		'snapshot_revision', p_session.snapshot_revision,
		'last_event_at', p_session.last_event_at
	)
$$;

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
	policy_row public.mode_limit_policies%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	session_row public.mode_sessions%rowtype;
	initial_snapshot jsonb;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_ruleset_id text := nullif(trim(coalesce(p_request_payload->>'ruleset_id', '')), '');
	payload_ruleset_version integer := coalesce((p_request_payload->>'ruleset_version')::integer, 0);
	scope_id text;
	active_count integer;
	daily_start_count integer;
	last_started_at timestamptz;
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
	if payload_ruleset_id <> 'openworld_forest_ruleset_v1' or payload_ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
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

	select * into registry_row from public.mode_registry where mode_id = payload_mode_id for update;
	if registry_row.mode_id is null or registry_row.status <> 'active' or registry_row.release_channel <> 'internal_alpha' then
		raise exception 'MODE_DISABLED' using errcode = 'P0001';
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

	select *
	into policy_row
	from public.mode_limit_policies
	where mode_id = payload_mode_id
		and slice_id = payload_slice_id
		and ruleset_id = payload_ruleset_id
		and ruleset_version = payload_ruleset_version
		and active = true
	limit 1;
	if policy_row.mode_id is null then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;

	update public.mode_sessions
	set status = 'expired', updated_at = now()
	where game_save_id = save_row.id
		and mode_id = payload_mode_id
		and status = 'started'
		and expires_at <= now();

	select count(*)
	into active_count
	from public.mode_sessions
	where game_save_id = save_row.id
		and mode_id = payload_mode_id
		and status = 'started'
		and expires_at > now();
	if active_count >= policy_row.max_active_sessions then
		raise exception 'MODE_SESSION_ALREADY_ACTIVE' using errcode = 'P0001';
	end if;

	select max(started_at)
	into last_started_at
	from public.mode_sessions
	where game_save_id = save_row.id
		and mode_id = payload_mode_id;
	if last_started_at is not null and last_started_at > now() - make_interval(secs => policy_row.start_cooldown_seconds) then
		raise exception 'MODE_SESSION_START_COOLDOWN' using errcode = 'P0001';
	end if;

	select count(*)
	into daily_start_count
	from public.mode_sessions
	where game_save_id = save_row.id
		and mode_id = payload_mode_id
		and started_at >= date_trunc('day', now() at time zone 'UTC');
	if daily_start_count >= policy_row.daily_start_limit then
		raise exception 'MODE_SESSION_DAILY_LIMIT' using errcode = 'P0001';
	end if;

	initial_snapshot := public.openworld_forest_initial_snapshot_v1();

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
		'openworld_forest_snapshot_v1',
		'{}'::jsonb,
		'{"sessions_started":1,"sessions_completed":0,"activity_score":0}'::jsonb,
		now()
	)
	on conflict (game_save_id, mode_id) do update
	set
		local_schema_version = 'openworld_forest_snapshot_v1',
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
		expires_at,
		snapshot_payload,
		snapshot_revision,
		last_event_at
	)
	values (
		save_row.id,
		payload_mode_id,
		payload_slice_id,
		payload_ruleset_id,
		payload_ruleset_version,
		'started',
		p_request_id,
		now() + make_interval(secs => policy_row.session_expiry_seconds),
		initial_snapshot,
		0,
		now()
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
		'session', public.openworld_forest_session_payload_v1(session_row),
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

create or replace function public.mode_session_event_v1(
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
	session_row public.mode_sessions%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	next_snapshot jsonb;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_event_type text := nullif(trim(coalesce(p_request_payload->>'event_type', '')), '');
	payload_expected_revision integer := coalesce((p_request_payload->>'expected_revision')::integer, -1);
	payload_event jsonb := coalesce(p_request_payload->'event_payload', '{}'::jsonb);
	revision_after integer;
	scope_id text;
begin
	if p_game_save_id is null or p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if payload_mode_id <> 'openworld' or payload_slice_id <> 'forest' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;
	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
	end;

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

	scope_id := 'mode:' || payload_mode_id || ':' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'modes/session/event',
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
	if session_row.status <> 'started' then
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.expires_at <= now() then
		update public.mode_sessions set status = 'expired', updated_at = now() where id = session_row.id;
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.ruleset_id <> 'openworld_forest_ruleset_v1' or session_row.ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;
	if payload_expected_revision <> session_row.snapshot_revision then
		raise exception 'MODE_SESSION_REVISION_STALE' using errcode = 'P0001';
	end if;

	next_snapshot := public.openworld_forest_apply_event_v1(
		session_row.snapshot_payload,
		payload_event_type,
		payload_event
	);
	revision_after := session_row.snapshot_revision + 1;
	next_snapshot := jsonb_set(next_snapshot, '{revision}', to_jsonb(revision_after), true);

	update public.mode_sessions
	set
		snapshot_payload = next_snapshot,
		snapshot_revision = revision_after,
		last_event_at = now(),
		session_seconds = coalesce((next_snapshot->>'session_seconds')::integer, session_seconds),
		activity_score = coalesce((next_snapshot->>'activity_score')::integer, activity_score),
		deposited_items = coalesce(next_snapshot#>'{reward_payload,deposited_items}', '{}'::jsonb),
		updated_at = now()
	where id = session_row.id
	returning * into session_row;

	insert into public.mode_session_events (
		game_save_id,
		session_id,
		mode_id,
		slice_id,
		request_id,
		request_hash,
		event_type,
		expected_revision,
		revision_after,
		event_payload,
		snapshot_payload
	)
	values (
		save_row.id,
		session_row.id,
		payload_mode_id,
		payload_slice_id,
		p_request_id,
		p_request_hash,
		payload_event_type,
		payload_expected_revision,
		revision_after,
		payload_event,
		next_snapshot
	);

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'event', jsonb_build_object(
			'event_type', payload_event_type,
			'expected_revision', payload_expected_revision,
			'revision_after', revision_after,
			'message', coalesce(next_snapshot->>'last_message', '')
		),
		'session', public.openworld_forest_session_payload_v1(session_row),
		'server_time', now()
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/event',
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
	reservation_payload jsonb;
	response_payload jsonb;
	reward_payload_value jsonb;
	resource_delta_value jsonb;
	deposited_items_payload jsonb;
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
	payload_expected_revision integer := coalesce((p_request_payload->>'expected_revision')::integer, -1);
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
	if p_game_save_id is null or p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if payload_mode_id <> 'openworld' or payload_slice_id <> 'forest' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;
	if payload_ruleset_id <> 'openworld_forest_ruleset_v1' or payload_ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;
	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_RESULT' using errcode = 'P0001';
	end;

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
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.expires_at <= now() then
		update public.mode_sessions set status = 'expired', updated_at = now() where id = session_row.id;
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if payload_expected_revision <> session_row.snapshot_revision then
		raise exception 'MODE_SESSION_REVISION_STALE' using errcode = 'P0001';
	end if;

	deposited_items_payload := coalesce(session_row.snapshot_payload#>'{reward_payload,deposited_items}', session_row.snapshot_payload->'chest', '{}'::jsonb);
	payload_session_seconds := greatest(5, least(1800, coalesce((session_row.snapshot_payload->>'session_seconds')::integer, 5)));
	payload_activity_score := greatest(0, least(500, coalesce((session_row.snapshot_payload->>'activity_score')::integer, 0)));

	for item_record in select * from jsonb_each_text(coalesce(deposited_items_payload, '{}'::jsonb))
	loop
		item_quantity := greatest(0, item_record.value::numeric);
		total_deposited := total_deposited + item_quantity;
		if item_record.key = 'ossos_preview' then
			preview_ossos := preview_ossos + item_quantity;
		elsif item_record.key = 'po_osso_preview' then
			preview_po_osso := preview_po_osso + item_quantity;
		end if;
	end loop;

	select * into player_row from public.players where id = save_row.legacy_player_id for update;
	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;
	select * into resource_row from public.resources where player_id = save_row.legacy_player_id for update;
	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	plausible_score := floor(least(payload_activity_score, total_deposited * 12 + payload_session_seconds / 3.0, 240))::integer;
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
	resource_delta_value := jsonb_build_object('energia', reward_energia, 'ossos', reward_ossos, 'xp', reward_xp);

	update public.resources
	set energia = energia + reward_energia, ossos = ossos + reward_ossos, updated_at = now()
	where player_id = save_row.legacy_player_id
	returning * into resource_row;

	update public.players
	set xp = xp + reward_xp, updated_at = now()
	where id = save_row.legacy_player_id
	returning * into player_row;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (save_row.legacy_player_id, 'mode:openworld:forest', p_request_id, resource_delta_value);

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
		'source', 'mode:openworld:forest',
		'authority', 'server_snapshot'
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
		'openworld_forest_snapshot_v1',
		jsonb_build_object('last_completed_session_id', session_row.id),
		jsonb_build_object('sessions_started', 1, 'sessions_completed', 1, 'activity_score', payload_activity_score, 'validated_score', plausible_score),
		session_row.id,
		now()
	)
	on conflict (game_save_id, mode_id) do update
	set
		local_schema_version = 'openworld_forest_snapshot_v1',
		progress_payload = jsonb_build_object('last_completed_session_id', session_row.id),
		totals_payload = jsonb_build_object(
			'sessions_started', coalesce(nullif(progress_row.totals_payload->>'sessions_started', '')::integer, 0),
			'sessions_completed', coalesce(nullif(progress_row.totals_payload->>'sessions_completed', '')::integer, 0) + 1,
			'activity_score', coalesce(nullif(progress_row.totals_payload->>'activity_score', '')::integer, 0) + payload_activity_score,
			'validated_score', coalesce(nullif(progress_row.totals_payload->>'validated_score', '')::integer, 0) + plausible_score
		),
		last_session_id = session_row.id,
		updated_at = now();

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode', jsonb_build_object('mode_id', payload_mode_id, 'slice_id', payload_slice_id, 'ruleset_id', payload_ruleset_id, 'ruleset_version', payload_ruleset_version, 'release_channel', 'internal_alpha'),
		'session', public.openworld_forest_session_payload_v1(session_row),
		'reward', reward_payload_value,
		'resources', jsonb_build_object('energia', resource_row.energia, 'ossos', resource_row.ossos, 'xp', player_row.xp),
		'limits', jsonb_build_object('daily', jsonb_build_object('energia', 30, 'ossos', 6, 'xp', 24), 'used_today_before', jsonb_build_object('energia', daily_energia, 'ossos', daily_ossos, 'xp', daily_xp), 'applied', resource_delta_value, 'period_key', reward_period_key),
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

create or replace function public.mode_session_abandon_v1(
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
	session_row public.mode_sessions%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), 'openworld');
	payload_reason text := nullif(trim(coalesce(p_request_payload->>'reason', '')), '');
	scope_id text;
begin
	if p_game_save_id is null or p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
	end;
	if payload_mode_id is null or payload_mode_id = '' then
		payload_mode_id := 'openworld';
	end if;
	if payload_mode_id <> 'openworld' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;

	select * into save_row from public.game_saves where id = p_game_save_id and lifecycle_status = 'active' for update;
	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;
	if save_row.legacy_player_id is null then
		raise exception 'GAME_SAVE_WITHOUT_LEGACY_PLAYER' using errcode = 'P0001';
	end if;

	scope_id := 'mode:' || payload_mode_id || ':' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'modes/session/abandon',
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
		and slice_id = 'forest'
	for update;
	if session_row.id is null then
		raise exception 'MODE_SESSION_NOT_FOUND' using errcode = 'P0001';
	end if;

	if session_row.status = 'started' then
		update public.mode_sessions
		set
			status = 'abandoned',
			abandoned_at = now(),
			result_payload = jsonb_build_object('abandon_reason', coalesce(payload_reason, 'player_exit'), 'snapshot_revision', snapshot_revision),
			updated_at = now()
		where id = session_row.id
		returning * into session_row;
	end if;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode', jsonb_build_object('mode_id', payload_mode_id, 'slice_id', 'forest', 'ruleset_id', session_row.ruleset_id, 'ruleset_version', session_row.ruleset_version, 'release_channel', 'internal_alpha'),
		'session', public.openworld_forest_session_payload_v1(session_row),
		'abandoned', session_row.status = 'abandoned',
		'server_time', now()
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/abandon',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

revoke all on function public.mode_session_start_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_start_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_event_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_event_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_abandon_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_abandon_v1(uuid, uuid, text, jsonb) to service_role;
