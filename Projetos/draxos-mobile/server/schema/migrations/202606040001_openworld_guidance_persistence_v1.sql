-- Openworld Bosque V2 guidance persistence.
-- Adds lightweight guidance state to the normal save snapshot while keeping
-- reward, caps, ledger and completion authority unchanged.

alter table public.mode_session_events
	drop constraint if exists mode_session_events_event_type_check;

alter table public.mode_session_events
	add constraint mode_session_events_event_type_check check (
		event_type in (
			'move_heartbeat',
			'collect_start',
			'collect_cancel',
			'collect_complete',
			'deposit_all',
			'craft',
			'guidance_update',
			'complete_requested',
			'abandon_requested'
		)
	);

create or replace function public.openworld_forest_guidance_default_v1()
returns jsonb
language sql
immutable
as $$
	select '{"version":1,"current_step":"","completed_steps":[],"dismissed":false,"last_seen_at":null}'::jsonb
$$;

create or replace function public.openworld_forest_normalize_guidance_v1(p_guidance jsonb)
returns jsonb
language plpgsql
immutable
as $$
declare
	source jsonb := case
		when jsonb_typeof(coalesce(p_guidance, '{}'::jsonb)) = 'object' then coalesce(p_guidance, '{}'::jsonb)
		else '{}'::jsonb
	end;
	completed_steps jsonb := '[]'::jsonb;
	step_value text;
	current_step_value text := left(nullif(trim(coalesce(source->>'current_step', '')), ''), 80);
	dismissed_value boolean := false;
	last_seen_raw text := left(nullif(trim(coalesce(source->>'last_seen_at', '')), ''), 64);
begin
	if jsonb_typeof(source->'completed_steps') = 'array' then
		for step_value in
			select left(trim(completed.value), 80)
			from jsonb_array_elements_text(source->'completed_steps') as completed(value)
			where trim(completed.value) <> ''
			limit 50
		loop
			if not (completed_steps ? step_value) then
				completed_steps := completed_steps || jsonb_build_array(step_value);
			end if;
		end loop;
	end if;

	if jsonb_typeof(source->'dismissed') = 'boolean' then
		dismissed_value := (source->>'dismissed')::boolean;
	end if;

	return jsonb_build_object(
		'version', 1,
		'current_step', coalesce(current_step_value, ''),
		'completed_steps', completed_steps,
		'dismissed', dismissed_value,
		'last_seen_at', case when last_seen_raw is null then 'null'::jsonb else to_jsonb(last_seen_raw) end
	);
end;
$$;

create or replace function public.openworld_forest_save_guidance_snapshot_v1(
	p_save_snapshot jsonb,
	p_guidance jsonb
)
returns jsonb
language plpgsql
immutable
as $$
declare
	result jsonb := case
		when jsonb_typeof(coalesce(p_save_snapshot, '{}'::jsonb)) = 'object' then coalesce(p_save_snapshot, '{}'::jsonb)
		else '{}'::jsonb
	end;
begin
	if jsonb_typeof(result->'openworld') is distinct from 'object' then
		result := jsonb_set(result, '{openworld}', '{}'::jsonb, true);
	end if;
	if jsonb_typeof(result#>'{openworld,forest}') is distinct from 'object' then
		result := jsonb_set(result, '{openworld,forest}', '{}'::jsonb, true);
	end if;
	result := jsonb_set(
		result,
		'{openworld,forest,guidance}',
		public.openworld_forest_normalize_guidance_v1(p_guidance),
		true
	);
	return result;
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
	result := jsonb_set(
		result,
		'{guidance}',
		public.openworld_forest_normalize_guidance_v1(coalesce(result->'guidance', '{}'::jsonb)),
		true
	);
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
	guidance_payload jsonb;
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
	elsif p_event_type = 'guidance_update' then
		guidance_payload := case
			when jsonb_typeof(p_event_payload->'guidance') = 'object' then p_event_payload->'guidance'
			else p_event_payload
		end;
		result := jsonb_set(
			result,
			'{guidance}',
			public.openworld_forest_normalize_guidance_v1(guidance_payload),
			true
		);
		result := jsonb_set(result, '{last_message}', to_jsonb('Orientacao atualizada.'::text), true);
		return public.openworld_forest_recompute_snapshot_v1(result);
	elsif p_event_type in ('complete_requested', 'abandon_requested') then
		return public.openworld_forest_recompute_snapshot_v1(result);
	end if;

	raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
end;
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
	saved_guidance jsonb;
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
	saved_guidance := coalesce(save_row.snapshot#>'{openworld,forest,guidance}', '{}'::jsonb);
	initial_snapshot := jsonb_set(
		initial_snapshot,
		'{guidance}',
		public.openworld_forest_normalize_guidance_v1(saved_guidance),
		true
	);

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

	if payload_event_type = 'guidance_update' and save_row.save_type = 'normal' then
		update public.game_saves
		set
			snapshot = public.openworld_forest_save_guidance_snapshot_v1(snapshot, next_snapshot->'guidance'),
			updated_at = now()
		where id = save_row.id
		returning * into save_row;
	end if;

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

revoke all on function public.mode_session_start_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_start_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_event_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_event_v1(uuid, uuid, text, jsonb) to service_role;
