-- Openworld Bosque offline-first checkpoint v1.
-- Runtime play is client-owned; rewards remain server-owned through
-- compact, idempotent checkpoints.

alter table public.mode_session_events
	drop constraint if exists mode_session_events_event_type_check;

alter table public.mode_session_events
	add constraint mode_session_events_event_type_check check (
		event_type in (
			'move_heartbeat',
			'collect_start',
			'collect_cancel',
			'collect_complete',
			'collect_batch',
			'deposit_all',
			'craft',
			'guidance_update',
			'checkpoint',
			'complete_requested',
			'abandon_requested'
		)
	);

create or replace function public.openworld_forest_clean_inventory_v1(p_inventory jsonb)
returns jsonb
language plpgsql
immutable
as $$
declare
	item_record record;
	item_weight numeric;
	item_quantity integer;
	result jsonb := '{}'::jsonb;
begin
	if jsonb_typeof(coalesce(p_inventory, '{}'::jsonb)) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;

	for item_record in select * from jsonb_each(coalesce(p_inventory, '{}'::jsonb))
	loop
		item_weight := public.openworld_forest_item_weight_v1(item_record.key);
		if item_weight is null then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;

		begin
			item_quantity := floor((trim(both '"' from item_record.value::text))::numeric)::integer;
		exception when others then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end;
		if item_quantity < 0 or item_quantity > 999 then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		if item_quantity > 0 then
			result := jsonb_set(result, array[item_record.key], to_jsonb(item_quantity), true);
		end if;
	end loop;

	return result;
end;
$$;

create or replace function public.openworld_forest_validate_checkpoint_v1(
	p_snapshot jsonb,
	p_checkpoint_id text,
	p_client_sequence integer,
	p_base_revision integer
)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := coalesce(p_snapshot, '{}'::jsonb);
	clean_snapshot jsonb := '{}'::jsonb;
	clean_pocket jsonb;
	clean_chest jsonb;
	clean_upgrades jsonb := '{}'::jsonb;
	clean_nodes jsonb := '{}'::jsonb;
	collected_counts jsonb := '{}'::jsonb;
	recipe_costs jsonb := '{}'::jsonb;
	recipe_outputs jsonb := '{}'::jsonb;
	all_item_keys jsonb := '{}'::jsonb;
	node_record record;
	upgrade_record record;
	item_record record;
	expected_item_id text;
	current_quantity integer;
	item_quantity integer;
	available_quantity integer;
	needed_quantity integer;
	cost_payload jsonb;
	output_payload jsonb;
	session_seconds integer;
	position_payload jsonb;
	guidance_payload jsonb;
	capacity numeric;
	pocket_weight numeric;
begin
	if jsonb_typeof(source) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_checkpoint_id, '')), '') is null or p_client_sequence < 0 or p_base_revision < 0 then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(source->>'ruleset_id', '')), '') <> 'openworld_forest_ruleset_v1' or coalesce((source->>'ruleset_version')::integer, 0) <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;

	clean_pocket := public.openworld_forest_clean_inventory_v1(coalesce(source->'pocket', '{}'::jsonb));
	clean_chest := public.openworld_forest_clean_inventory_v1(coalesce(source->'chest', '{}'::jsonb));

	if jsonb_typeof(coalesce(source->'collected_nodes', '{}'::jsonb)) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	for node_record in select * from jsonb_each(coalesce(source->'collected_nodes', '{}'::jsonb))
	loop
		if jsonb_typeof(node_record.value) <> 'boolean' then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		if node_record.value::text = 'true' then
			expected_item_id := public.openworld_forest_node_item_v1(node_record.key);
			if expected_item_id is null then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;
			current_quantity := public.openworld_forest_inventory_quantity_v1(collected_counts, expected_item_id);
			collected_counts := jsonb_set(collected_counts, array[expected_item_id], to_jsonb(current_quantity + 1), true);
			clean_nodes := jsonb_set(clean_nodes, array[node_record.key], to_jsonb(true), true);
			all_item_keys := jsonb_set(all_item_keys, array[expected_item_id], to_jsonb(true), true);
		end if;
	end loop;

	if jsonb_typeof(coalesce(source->'upgrades', '{}'::jsonb)) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	for upgrade_record in select * from jsonb_each(coalesce(source->'upgrades', '{}'::jsonb))
	loop
		if jsonb_typeof(upgrade_record.value) <> 'boolean' then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		if upgrade_record.value::text = 'true' then
			cost_payload := public.openworld_forest_recipe_cost_v1(upgrade_record.key);
			if cost_payload is null then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;
			clean_upgrades := jsonb_set(clean_upgrades, array[upgrade_record.key], to_jsonb(true), true);
			for item_record in select * from jsonb_each_text(cost_payload)
			loop
				current_quantity := public.openworld_forest_inventory_quantity_v1(recipe_costs, item_record.key);
				recipe_costs := jsonb_set(recipe_costs, array[item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
				all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
			end loop;
			output_payload := coalesce(public.openworld_forest_recipe_output_v1(upgrade_record.key), '{}'::jsonb);
			for item_record in select * from jsonb_each_text(output_payload)
			loop
				current_quantity := public.openworld_forest_inventory_quantity_v1(recipe_outputs, item_record.key);
				recipe_outputs := jsonb_set(recipe_outputs, array[item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
				all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
			end loop;
		end if;
	end loop;

	for item_record in select * from jsonb_each_text(clean_pocket)
	loop
		all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
	end loop;
	for item_record in select * from jsonb_each_text(clean_chest)
	loop
		all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
	end loop;

	for item_record in select * from jsonb_each_text(all_item_keys)
	loop
		available_quantity := public.openworld_forest_inventory_quantity_v1(collected_counts, item_record.key)
			+ public.openworld_forest_inventory_quantity_v1(recipe_outputs, item_record.key);
		needed_quantity := public.openworld_forest_inventory_quantity_v1(clean_pocket, item_record.key)
			+ public.openworld_forest_inventory_quantity_v1(clean_chest, item_record.key)
			+ public.openworld_forest_inventory_quantity_v1(recipe_costs, item_record.key);
		if needed_quantity > available_quantity then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
	end loop;

	session_seconds := greatest(0, least(7200, coalesce((source->>'session_seconds')::integer, 0)));
	clean_snapshot := jsonb_build_object(
		'schema_version', 'openworld_forest_snapshot_v1',
		'mode_id', 'openworld',
		'slice_id', 'forest',
		'ruleset_id', 'openworld_forest_ruleset_v1',
		'ruleset_version', 1,
		'session_seconds', session_seconds,
		'pocket', clean_pocket,
		'chest', clean_chest,
		'upgrades', clean_upgrades,
		'collected_nodes', clean_nodes,
		'last_message', coalesce(nullif(trim(source->>'last_message'), ''), 'Bosque salvo no servidor.')
	);

	position_payload := coalesce(source->'player_position', source->'position', '{}'::jsonb);
	if jsonb_typeof(position_payload) = 'object' then
		clean_snapshot := jsonb_set(
			clean_snapshot,
			'{player_position}',
			jsonb_build_object(
				'x', least(932, greatest(28, coalesce((position_payload->>'x')::numeric, 220))),
				'y', least(1372, greatest(28, coalesce((position_payload->>'y')::numeric, 330)))
			),
			true
		);
	end if;

	guidance_payload := case
		when jsonb_typeof(source->'guidance') = 'object' then source->'guidance'
		else '{}'::jsonb
	end;
	if jsonb_typeof(guidance_payload) = 'object' then
		clean_snapshot := jsonb_set(
			clean_snapshot,
			'{guidance}',
			public.openworld_forest_normalize_guidance_v1(guidance_payload),
			true
		);
	end if;

	clean_snapshot := public.openworld_forest_recompute_snapshot_v1(clean_snapshot);
	capacity := coalesce((clean_snapshot->>'capacity')::numeric, 20);
	pocket_weight := coalesce((clean_snapshot->>'pocket_weight')::numeric, 0);
	if pocket_weight > capacity + 0.001 then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;

	return clean_snapshot;
end;
$$;

create or replace function public.mode_session_checkpoint_v1(
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
	accepted_summary jsonb;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_ruleset_id text := nullif(trim(coalesce(p_request_payload->>'ruleset_id', '')), '');
	payload_ruleset_version integer := coalesce((p_request_payload->>'ruleset_version')::integer, 0);
	payload_checkpoint_id text := nullif(trim(coalesce(p_request_payload->>'checkpoint_id', '')), '');
	payload_base_revision integer := coalesce((p_request_payload->>'base_revision')::integer, -1);
	payload_client_sequence integer := coalesce((p_request_payload->>'client_sequence')::integer, -1);
	payload_snapshot jsonb := coalesce(p_request_payload->'snapshot_payload', '{}'::jsonb);
	payload_client_summary jsonb := coalesce(p_request_payload->'client_summary', '{}'::jsonb);
	current_client_sequence integer;
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
	if payload_ruleset_id <> 'openworld_forest_ruleset_v1' or payload_ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;
	if payload_checkpoint_id is null or payload_base_revision < 0 or payload_client_sequence < 0 then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
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
		'modes/session/checkpoint',
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

	current_client_sequence := greatest(0, coalesce(nullif(session_row.snapshot_payload#>>'{checkpoint,client_sequence}', '')::integer, 0));
	if payload_client_sequence < current_client_sequence then
		raise exception 'MODE_CHECKPOINT_STALE' using errcode = 'P0001';
	end if;

	next_snapshot := public.openworld_forest_validate_checkpoint_v1(
		payload_snapshot,
		payload_checkpoint_id,
		payload_client_sequence,
		payload_base_revision
	);
	revision_after := session_row.snapshot_revision + 1;
	next_snapshot := jsonb_set(next_snapshot, '{revision}', to_jsonb(revision_after), true);
	next_snapshot := jsonb_set(
		next_snapshot,
		'{checkpoint}',
		jsonb_build_object(
			'accepted_checkpoint_id', payload_checkpoint_id,
			'checkpoint_id', payload_checkpoint_id,
			'base_revision', payload_base_revision,
			'client_sequence', payload_client_sequence,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'accepted_at', now()
		),
		true
	);

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

	accepted_summary := jsonb_build_object(
		'checkpoint_id', payload_checkpoint_id,
		'client_sequence', payload_client_sequence,
		'base_revision', payload_base_revision,
		'snapshot_revision', revision_after,
		'collected_count', jsonb_object_length(coalesce(next_snapshot->'collected_nodes', '{}'::jsonb)),
		'pocket', coalesce(next_snapshot->'pocket', '{}'::jsonb),
		'chest', coalesce(next_snapshot->'chest', '{}'::jsonb),
		'upgrades', coalesce(next_snapshot->'upgrades', '{}'::jsonb),
		'activity_score', coalesce((next_snapshot->>'activity_score')::integer, 0)
	);

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
		'checkpoint',
		payload_base_revision,
		revision_after,
		jsonb_build_object(
			'checkpoint_id', payload_checkpoint_id,
			'client_sequence', payload_client_sequence,
			'base_revision', payload_base_revision,
			'client_summary', payload_client_summary
		),
		next_snapshot
	);

	response_payload := jsonb_build_object(
		'ok', true,
		'type', 'mode_checkpoint_ack',
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode_id', payload_mode_id,
		'slice_id', payload_slice_id,
		'session_id', session_row.id,
		'checkpoint_id', payload_checkpoint_id,
		'accepted_checkpoint_id', payload_checkpoint_id,
		'base_revision', payload_base_revision,
		'snapshot_revision', revision_after,
		'accepted_snapshot_summary', accepted_summary,
		'complete_ready', true,
		'session', public.openworld_forest_session_payload_v1(session_row),
		'server_time', now()
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/checkpoint',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

alter function if exists public.mode_session_complete_v1(uuid, uuid, text, jsonb)
	rename to mode_session_complete_legacy_v1;

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
	session_row public.mode_sessions%rowtype;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
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
	if session_row.status <> 'completed'
		and nullif(session_row.snapshot_payload#>>'{checkpoint,accepted_checkpoint_id}', '') is null then
		raise exception 'MODE_CHECKPOINT_REQUIRED' using errcode = 'P0001';
	end if;

	return public.mode_session_complete_legacy_v1(
		p_game_save_id,
		p_request_id,
		p_request_hash,
		p_request_payload
	);
end;
$$;

revoke all on function public.openworld_forest_clean_inventory_v1(jsonb) from public;
grant execute on function public.openworld_forest_clean_inventory_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_validate_checkpoint_v1(jsonb, text, integer, integer) from public;
grant execute on function public.openworld_forest_validate_checkpoint_v1(jsonb, text, integer, integer) to service_role;

revoke all on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) to service_role;
