-- Bosque Persistence Rebase v1.
-- Server-authoritative durable operations, per-node cooldown state, and progress v2.

create or replace function public.openworld_forest_item_respawn_seconds_v1(p_item_id text)
returns integer
language sql
immutable
as $$
	select case public.openworld_forest_canonical_item_id_v1(p_item_id)
		when 'galho' then 300
		when 'folha' then 300
		when 'folha_seca' then 300
		when 'pedra_pequena' then 600
		when 'cogumelo' then 600
		when 'inseto' then 600
		when 'resina' then 600
		when 'madeira' then 900
		when 'pedra' then 900
		when 'fungo' then 900
		when 'cinzas_preview' then 1800
		when 'resto_ritual' then 1800
		when 'po_cinzento' then 1800
		else 300
	end
$$;

create or replace function public.openworld_forest_clean_node_state_v1(p_node_state jsonb)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := coalesce(p_node_state, '{}'::jsonb);
	result jsonb := '{}'::jsonb;
	node_record record;
	node_payload jsonb;
	last_collected_at timestamptz;
	next_spawn_at timestamptz;
	collected_count integer;
begin
	if jsonb_typeof(source) <> 'object' then
		return '{}'::jsonb;
	end if;

	for node_record in select * from jsonb_each(source)
	loop
		if public.openworld_forest_node_item_v1(node_record.key) is null then
			continue;
		end if;
		if jsonb_typeof(node_record.value) <> 'object' then
			continue;
		end if;
		node_payload := node_record.value;
		last_collected_at := null;
		next_spawn_at := null;
		begin
			if nullif(trim(coalesce(node_payload->>'last_collected_at', '')), '') is not null then
				last_collected_at := (node_payload->>'last_collected_at')::timestamptz;
			end if;
		exception when others then
			last_collected_at := null;
		end;
		begin
			if nullif(trim(coalesce(node_payload->>'next_spawn_at', '')), '') is not null then
				next_spawn_at := (node_payload->>'next_spawn_at')::timestamptz;
			end if;
		exception when others then
			next_spawn_at := null;
		end;
		begin
			collected_count := greatest(0, coalesce(nullif(node_payload->>'collected_count', '')::integer, 0));
		exception when others then
			collected_count := 0;
		end;

		if last_collected_at is null and next_spawn_at is null and collected_count <= 0 then
			continue;
		end if;
		result := jsonb_set(
			result,
			array[node_record.key],
			jsonb_strip_nulls(jsonb_build_object(
				'last_collected_at', last_collected_at,
				'next_spawn_at', next_spawn_at,
				'collected_count', collected_count
			)),
			true
		);
	end loop;

	return result;
end;
$$;

create or replace function public.openworld_forest_collected_nodes_from_node_state_v1(
	p_node_state jsonb,
	p_now timestamptz default now()
)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := public.openworld_forest_clean_node_state_v1(p_node_state);
	result jsonb := '{}'::jsonb;
	node_record record;
	next_spawn_at timestamptz;
begin
	for node_record in select * from jsonb_each(source)
	loop
		next_spawn_at := null;
		begin
			if nullif(trim(coalesce(node_record.value->>'next_spawn_at', '')), '') is not null then
				next_spawn_at := (node_record.value->>'next_spawn_at')::timestamptz;
			end if;
		exception when others then
			next_spawn_at := null;
		end;
		if next_spawn_at is not null and next_spawn_at > p_now then
			result := jsonb_set(result, array[node_record.key], to_jsonb(true), true);
		end if;
	end loop;
	return result;
end;
$$;

create or replace function public.openworld_forest_empty_progress_v1()
returns jsonb
language sql
immutable
as $$
	select jsonb_build_object(
		'schema_version', 'openworld_forest_progress_v2',
		'pocket', '{}'::jsonb,
		'chest', '{}'::jsonb,
		'upgrades', '{}'::jsonb,
		'structures', '{}'::jsonb,
		'guidance', public.openworld_forest_guidance_default_v1(),
		'node_state', '{}'::jsonb,
		'reward_ledger', jsonb_build_object('rewarded_chest', '{}'::jsonb),
		'applied_ops', '{}'::jsonb,
		'last_checkpoint_session_id', null,
		'last_completed_session_id', null,
		'progress_revision', 0
	);
$$;

create or replace function public.openworld_forest_canonical_progress_v1(p_progress jsonb)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := coalesce(p_progress, '{}'::jsonb);
	reward_ledger jsonb := case when jsonb_typeof(source->'reward_ledger') = 'object' then source->'reward_ledger' else '{}'::jsonb end;
	applied_ops jsonb := case when jsonb_typeof(source->'applied_ops') = 'object' then source->'applied_ops' else '{}'::jsonb end;
	clean_upgrades jsonb := public.openworld_forest_clean_upgrades_v1(coalesce(source->'upgrades', '{}'::jsonb));
	clean_structures jsonb := public.openworld_forest_clean_structures_v1(coalesce(source->'structures', '{}'::jsonb));
	result jsonb := public.openworld_forest_empty_progress_v1();
	progress_revision integer := greatest(0, coalesce(nullif(source->>'progress_revision', '')::integer, 0));
	last_checkpoint text := nullif(trim(coalesce(source->>'last_checkpoint_session_id', '')), '');
	last_completed text := nullif(trim(coalesce(source->>'last_completed_session_id', '')), '');
begin
	if coalesce((clean_upgrades->>'fogueira_estavel_1')::boolean, false)
		or coalesce((clean_structures->>'fogueira_estavel_1')::boolean, false) then
		clean_upgrades := jsonb_set(clean_upgrades, '{fogueira_estavel_1}', to_jsonb(true), true);
		clean_structures := jsonb_set(clean_structures, '{fogueira_estavel_1}', to_jsonb(true), true);
	end if;

	result := jsonb_set(result, '{pocket}', public.openworld_forest_clean_inventory_v1(coalesce(source->'pocket', '{}'::jsonb)), true);
	result := jsonb_set(result, '{chest}', public.openworld_forest_clean_inventory_v1(coalesce(source->'chest', '{}'::jsonb)), true);
	result := jsonb_set(result, '{upgrades}', clean_upgrades, true);
	result := jsonb_set(result, '{structures}', clean_structures, true);
	result := jsonb_set(result, '{guidance}', public.openworld_forest_normalize_guidance_v1(coalesce(source->'guidance', '{}'::jsonb)), true);
	result := jsonb_set(result, '{node_state}', public.openworld_forest_clean_node_state_v1(coalesce(source->'node_state', '{}'::jsonb)), true);
	result := jsonb_set(
		result,
		'{reward_ledger}',
		jsonb_build_object(
			'rewarded_chest',
			public.openworld_forest_clean_inventory_v1(coalesce(reward_ledger->'rewarded_chest', '{}'::jsonb))
		),
		true
	);
	result := jsonb_set(result, '{applied_ops}', applied_ops, true);
	result := jsonb_set(result, '{progress_revision}', to_jsonb(progress_revision), true);
	if last_checkpoint is not null then
		result := jsonb_set(result, '{last_checkpoint_session_id}', to_jsonb(last_checkpoint), true);
	end if;
	if last_completed is not null then
		result := jsonb_set(result, '{last_completed_session_id}', to_jsonb(last_completed), true);
	end if;
	return result;
end;
$$;

create or replace function public.openworld_forest_progress_from_snapshot_v1(
	p_progress jsonb,
	p_snapshot jsonb
)
returns jsonb
language plpgsql
as $$
declare
	result jsonb := public.openworld_forest_canonical_progress_v1(p_progress);
	source jsonb := coalesce(p_snapshot, '{}'::jsonb);
	clean_upgrades jsonb;
	clean_structures jsonb;
begin
	if jsonb_typeof(source) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;

	clean_upgrades := public.openworld_forest_clean_upgrades_v1(coalesce(source->'upgrades', '{}'::jsonb));
	clean_structures := public.openworld_forest_clean_structures_v1(coalesce(source->'structures', '{}'::jsonb));
	if coalesce((clean_upgrades->>'fogueira_estavel_1')::boolean, false)
		or coalesce((clean_structures->>'fogueira_estavel_1')::boolean, false) then
		clean_upgrades := jsonb_set(clean_upgrades, '{fogueira_estavel_1}', to_jsonb(true), true);
		clean_structures := jsonb_set(clean_structures, '{fogueira_estavel_1}', to_jsonb(true), true);
	end if;

	result := jsonb_set(result, '{pocket}', public.openworld_forest_clean_inventory_v1(coalesce(source->'pocket', '{}'::jsonb)), true);
	result := jsonb_set(result, '{chest}', public.openworld_forest_clean_inventory_v1(coalesce(source->'chest', '{}'::jsonb)), true);
	result := jsonb_set(result, '{upgrades}', clean_upgrades, true);
	result := jsonb_set(result, '{structures}', clean_structures, true);
	if jsonb_typeof(source->'guidance') = 'object' then
		result := jsonb_set(result, '{guidance}', public.openworld_forest_normalize_guidance_v1(source->'guidance'), true);
	end if;
	if jsonb_typeof(source->'node_state') = 'object' then
		result := jsonb_set(result, '{node_state}', public.openworld_forest_clean_node_state_v1(source->'node_state'), true);
	end if;
	return public.openworld_forest_canonical_progress_v1(result);
end;
$$;

create or replace function public.openworld_forest_snapshot_with_progress_v1(
	p_snapshot jsonb,
	p_progress jsonb
)
returns jsonb
language plpgsql
as $$
declare
	progress jsonb := public.openworld_forest_canonical_progress_v1(p_progress);
	result jsonb := public.openworld_forest_recompute_snapshot_v1(coalesce(p_snapshot, '{}'::jsonb));
begin
	result := jsonb_set(result, '{pocket}', coalesce(progress->'pocket', '{}'::jsonb), true);
	result := jsonb_set(result, '{chest}', coalesce(progress->'chest', '{}'::jsonb), true);
	result := jsonb_set(result, '{upgrades}', coalesce(progress->'upgrades', '{}'::jsonb), true);
	result := jsonb_set(result, '{structures}', coalesce(progress->'structures', '{}'::jsonb), true);
	result := jsonb_set(result, '{guidance}', coalesce(progress->'guidance', public.openworld_forest_guidance_default_v1()), true);
	result := jsonb_set(result, '{node_state}', coalesce(progress->'node_state', '{}'::jsonb), true);
	result := jsonb_set(
		result,
		'{collected_nodes}',
		public.openworld_forest_collected_nodes_from_node_state_v1(coalesce(progress->'node_state', '{}'::jsonb), now()),
		true
	);
	result := jsonb_set(result, '{durable_base}', progress, true);
	result := jsonb_set(result, '{last_message}', to_jsonb('Bosque pronto.'::text), true);
	return public.openworld_forest_recompute_snapshot_v1(result);
end;
$$;

create or replace function public.openworld_forest_apply_operations_v1(
	p_progress jsonb,
	p_operations jsonb,
	p_session_id uuid,
	p_now timestamptz default now()
)
returns jsonb
language plpgsql
as $$
declare
	operations jsonb := coalesce(p_operations, '[]'::jsonb);
	result jsonb := public.openworld_forest_canonical_progress_v1(p_progress);
	op_record record;
	op_payload jsonb;
	op_id text;
	op_type text;
	applied_ops jsonb := coalesce(result->'applied_ops', '{}'::jsonb);
	pocket jsonb;
	chest jsonb;
	node_state jsonb;
	node_payload jsonb;
	node_id text;
	expected_item_id text;
	payload_item_id text;
	next_spawn_at timestamptz;
	next_spawn_text text;
	collected_count integer;
	respawn_seconds integer;
	current_quantity integer;
	needed_quantity integer;
	capacity numeric;
	recipe_id text;
	cost_payload jsonb;
	output_payload jsonb;
	item_record record;
	upgrades jsonb;
	structures jsonb;
	guidance_payload jsonb;
	changed boolean := false;
	next_revision integer;
begin
	if jsonb_typeof(operations) <> 'array' or jsonb_array_length(operations) > 50 then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;

	for op_record in select value from jsonb_array_elements(operations) as operation(value)
	loop
		if jsonb_typeof(op_record.value) <> 'object' then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		op_payload := op_record.value;
		op_id := nullif(trim(coalesce(op_payload->>'op_id', '')), '');
		op_type := nullif(trim(coalesce(op_payload->>'type', '')), '');
		if op_id is null or left(op_id, 5) <> 'owop_' or length(op_id) > 80 then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		if applied_ops ? op_id then
			continue;
		end if;

		if op_type = 'collect_node' then
			node_id := nullif(trim(coalesce(op_payload->>'node_id', '')), '');
			expected_item_id := public.openworld_forest_node_item_v1(node_id);
			payload_item_id := public.openworld_forest_canonical_item_id_v1(nullif(trim(coalesce(op_payload->>'item_id', expected_item_id)), ''));
			if node_id is null or expected_item_id is null or payload_item_id is null or payload_item_id <> expected_item_id then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;

			node_state := public.openworld_forest_clean_node_state_v1(coalesce(result->'node_state', '{}'::jsonb));
			node_payload := case when jsonb_typeof(node_state->node_id) = 'object' then node_state->node_id else '{}'::jsonb end;
			next_spawn_at := null;
			next_spawn_text := nullif(trim(coalesce(node_payload->>'next_spawn_at', '')), '');
			if next_spawn_text is not null then
				next_spawn_at := next_spawn_text::timestamptz;
				if next_spawn_at > p_now then
					raise exception 'OPENWORLD_NODE_ON_COOLDOWN' using errcode = 'P0001';
				end if;
			end if;

			pocket := public.openworld_forest_clean_inventory_v1(coalesce(result->'pocket', '{}'::jsonb));
			current_quantity := public.openworld_forest_inventory_quantity_v1(pocket, expected_item_id);
			pocket := jsonb_set(pocket, array[expected_item_id], to_jsonb(current_quantity + 1), true);
			capacity := 20 + case when coalesce((result#>>'{upgrades,bolsa_simples_1}')::boolean, false) then 5 else 0 end;
			if public.openworld_forest_inventory_weight_v1(pocket) > capacity + 0.001 then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;

			respawn_seconds := public.openworld_forest_item_respawn_seconds_v1(expected_item_id);
			begin
				collected_count := greatest(0, coalesce(nullif(node_payload->>'collected_count', '')::integer, 0));
			exception when others then
				collected_count := 0;
			end;
			node_state := jsonb_set(
				node_state,
				array[node_id],
				jsonb_build_object(
					'last_collected_at', p_now,
					'next_spawn_at', p_now + make_interval(secs => respawn_seconds),
					'collected_count', collected_count + 1
				),
				true
			);
			result := jsonb_set(result, '{pocket}', pocket, true);
			result := jsonb_set(result, '{node_state}', node_state, true);
			changed := true;
		elsif op_type = 'deposit_all' then
			pocket := public.openworld_forest_clean_inventory_v1(coalesce(result->'pocket', '{}'::jsonb));
			chest := public.openworld_forest_clean_inventory_v1(coalesce(result->'chest', '{}'::jsonb));
			for item_record in select * from jsonb_each_text(pocket)
			loop
				current_quantity := public.openworld_forest_inventory_quantity_v1(chest, item_record.key);
				chest := jsonb_set(chest, array[item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
			end loop;
			result := jsonb_set(result, '{pocket}', '{}'::jsonb, true);
			result := jsonb_set(result, '{chest}', chest, true);
			changed := true;
		elsif op_type = 'craft_recipe' then
			recipe_id := nullif(trim(coalesce(op_payload->>'recipe_id', '')), '');
			cost_payload := public.openworld_forest_recipe_cost_v1(recipe_id);
			if recipe_id is null or cost_payload is null then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;

			upgrades := public.openworld_forest_clean_upgrades_v1(coalesce(result->'upgrades', '{}'::jsonb));
			structures := public.openworld_forest_clean_structures_v1(coalesce(result->'structures', '{}'::jsonb));
			if not coalesce((upgrades->>recipe_id)::boolean, false)
				and not coalesce((structures->>recipe_id)::boolean, false) then
				chest := public.openworld_forest_clean_inventory_v1(coalesce(result->'chest', '{}'::jsonb));
				for item_record in select * from jsonb_each_text(cost_payload)
				loop
					needed_quantity := greatest(0, item_record.value::integer);
					current_quantity := public.openworld_forest_inventory_quantity_v1(chest, item_record.key);
					if current_quantity < needed_quantity then
						raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
					end if;
					if current_quantity = needed_quantity then
						chest := chest - item_record.key;
					else
						chest := jsonb_set(chest, array[item_record.key], to_jsonb(current_quantity - needed_quantity), true);
					end if;
				end loop;
				upgrades := jsonb_set(upgrades, array[recipe_id], to_jsonb(true), true);
				if recipe_id = 'fogueira_estavel_1' then
					structures := jsonb_set(structures, array[recipe_id], to_jsonb(true), true);
				end if;
				output_payload := coalesce(public.openworld_forest_recipe_output_v1(recipe_id), '{}'::jsonb);
				for item_record in select * from jsonb_each_text(output_payload)
				loop
					current_quantity := public.openworld_forest_inventory_quantity_v1(chest, item_record.key);
					chest := jsonb_set(chest, array[item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
				end loop;
				result := jsonb_set(result, '{chest}', chest, true);
				result := jsonb_set(result, '{upgrades}', upgrades, true);
				result := jsonb_set(result, '{structures}', structures, true);
			end if;
			changed := true;
		elsif op_type = 'guidance_update' then
			guidance_payload := case
				when jsonb_typeof(op_payload->'guidance') = 'object' then op_payload->'guidance'
				else '{}'::jsonb
			end;
			result := jsonb_set(result, '{guidance}', public.openworld_forest_normalize_guidance_v1(guidance_payload), true);
			changed := true;
		elsif op_type = 'position_update' then
			changed := true;
		else
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;

		applied_ops := jsonb_set(
			applied_ops,
			array[op_id],
			jsonb_build_object('type', op_type, 'accepted_at', p_now),
			true
		);
	end loop;

	if changed then
		next_revision := coalesce((result->>'progress_revision')::integer, 0) + 1;
		result := jsonb_set(result, '{applied_ops}', applied_ops, true);
		result := jsonb_set(result, '{last_checkpoint_session_id}', to_jsonb(p_session_id::text), true);
		result := jsonb_set(result, '{progress_revision}', to_jsonb(next_revision), true);
		result := jsonb_set(result, '{updated_at}', to_jsonb(p_now), true);
	end if;
	return public.openworld_forest_canonical_progress_v1(result);
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
	progress_row public.mode_progress%rowtype;
	session_row public.mode_sessions%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	next_snapshot jsonb;
	accepted_summary jsonb;
	durable_progress jsonb;
	base_progress jsonb;
	reward_ledger jsonb;
	reward_delta jsonb;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_ruleset_id text := nullif(trim(coalesce(p_request_payload->>'ruleset_id', '')), '');
	payload_ruleset_version integer := coalesce((p_request_payload->>'ruleset_version')::integer, 0);
	payload_checkpoint_id text := nullif(trim(coalesce(p_request_payload->>'checkpoint_id', '')), '');
	payload_base_revision integer := coalesce((p_request_payload->>'base_revision')::integer, -1);
	payload_client_sequence integer := coalesce((p_request_payload->>'client_sequence')::integer, -1);
	payload_snapshot jsonb := coalesce(p_request_payload->'snapshot_payload', '{}'::jsonb);
	payload_visit_snapshot jsonb := coalesce(p_request_payload->'visit_snapshot', '{}'::jsonb);
	payload_operations jsonb := coalesce(p_request_payload->'operations', '[]'::jsonb);
	payload_client_summary jsonb := coalesce(p_request_payload->'client_summary', '{}'::jsonb);
	current_client_sequence integer;
	revision_after integer;
	scope_id text;
	now_ts timestamptz := now();
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
	if jsonb_typeof(payload_operations) <> 'array' or jsonb_array_length(payload_operations) > 50 then
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
	if session_row.status <> 'started' or session_row.expires_at is null then
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.expires_at <= now_ts then
		update public.mode_sessions set status = 'expired', updated_at = now_ts where id = session_row.id;
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.ruleset_id <> 'openworld_forest_ruleset_v1' or session_row.ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;

	select *
	into progress_row
	from public.mode_progress
	where game_save_id = save_row.id
		and mode_id = payload_mode_id
	for update;
	durable_progress := public.openworld_forest_canonical_progress_v1(coalesce(progress_row.progress_payload, '{}'::jsonb));
	base_progress := case
		when jsonb_typeof(session_row.snapshot_payload->'durable_base') = 'object'
			then public.openworld_forest_canonical_progress_v1(session_row.snapshot_payload->'durable_base')
		else durable_progress
	end;

	current_client_sequence := greatest(0, coalesce(nullif(session_row.snapshot_payload#>>'{checkpoint,client_sequence}', '')::integer, 0));
	if payload_client_sequence < current_client_sequence then
		raise exception 'MODE_CHECKPOINT_STALE' using errcode = 'P0001';
	end if;

	if jsonb_array_length(payload_operations) > 0 then
		durable_progress := public.openworld_forest_apply_operations_v1(
			durable_progress,
			payload_operations,
			session_row.id,
			now_ts
		);
		next_snapshot := public.openworld_forest_recompute_snapshot_v1(session_row.snapshot_payload);
		if jsonb_typeof(payload_snapshot) = 'object' and jsonb_object_length(payload_snapshot) > 0 then
			next_snapshot := jsonb_set(next_snapshot, '{guidance}', coalesce(payload_snapshot->'guidance', coalesce(next_snapshot->'guidance', '{}'::jsonb)), true);
		end if;
		if jsonb_typeof(payload_visit_snapshot) = 'object' and jsonb_object_length(payload_visit_snapshot) > 0 then
			if jsonb_typeof(payload_visit_snapshot->'player_position') = 'object' then
				next_snapshot := jsonb_set(next_snapshot, '{player_position}', payload_visit_snapshot->'player_position', true);
			end if;
			if nullif(trim(coalesce(payload_visit_snapshot->>'session_seconds', '')), '') is not null then
				next_snapshot := jsonb_set(
					next_snapshot,
					'{session_seconds}',
					to_jsonb(greatest(0, least(7200, (payload_visit_snapshot->>'session_seconds')::integer))),
					true
				);
			end if;
		end if;
		next_snapshot := public.openworld_forest_snapshot_with_progress_v1(next_snapshot, durable_progress);
	else
		next_snapshot := public.openworld_forest_validate_checkpoint_v2(
			payload_snapshot,
			payload_checkpoint_id,
			payload_client_sequence,
			payload_base_revision,
			base_progress
		);
		durable_progress := public.openworld_forest_mark_checkpoint_progress_v1(durable_progress, next_snapshot, session_row.id);
	end if;

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
			'accepted_at', now_ts,
			'operations_count', jsonb_array_length(payload_operations)
		),
		true
	);
	next_snapshot := jsonb_set(next_snapshot, '{last_message}', to_jsonb('Bosque salvo no servidor.'::text), true);

	reward_ledger := coalesce(durable_progress->'reward_ledger', '{}'::jsonb);
	reward_delta := public.openworld_forest_inventory_delta_above_v1(
		coalesce(next_snapshot->'chest', '{}'::jsonb),
		coalesce(reward_ledger->'rewarded_chest', '{}'::jsonb)
	);
	next_snapshot := jsonb_set(
		next_snapshot,
		'{reward_payload}',
		jsonb_build_object(
			'deposited_items', reward_delta,
			'activity_score', coalesce((next_snapshot->>'activity_score')::integer, 0),
			'reward_basis', 'durable_chest_delta_v1'
		),
		true
	);

	update public.mode_progress as progress_update
	set
		local_schema_version = 'openworld_forest_progress_v2',
		progress_payload = durable_progress,
		updated_at = now_ts
	where progress_update.game_save_id = save_row.id
		and progress_update.mode_id = payload_mode_id;
	if not found then
		insert into public.mode_progress (
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
			'openworld_forest_progress_v2',
			durable_progress,
			'{"sessions_started":0,"sessions_completed":0,"activity_score":0}'::jsonb,
			now_ts
		);
	end if;

	update public.mode_sessions
	set
		snapshot_payload = next_snapshot,
		snapshot_revision = revision_after,
		last_event_at = now_ts,
		session_seconds = coalesce((next_snapshot->>'session_seconds')::integer, session_seconds),
		activity_score = coalesce((next_snapshot->>'activity_score')::integer, activity_score),
		deposited_items = reward_delta,
		updated_at = now_ts
	where id = session_row.id
	returning * into session_row;

	accepted_summary := jsonb_build_object(
		'checkpoint_id', payload_checkpoint_id,
		'client_sequence', payload_client_sequence,
		'base_revision', payload_base_revision,
		'snapshot_revision', revision_after,
		'operations_count', jsonb_array_length(payload_operations),
		'collected_count', jsonb_object_length(coalesce(next_snapshot->'collected_nodes', '{}'::jsonb)),
		'pocket', coalesce(next_snapshot->'pocket', '{}'::jsonb),
		'chest', coalesce(next_snapshot->'chest', '{}'::jsonb),
		'upgrades', coalesce(next_snapshot->'upgrades', '{}'::jsonb),
		'structures', coalesce(next_snapshot->'structures', '{}'::jsonb),
		'node_state', coalesce(next_snapshot->'node_state', '{}'::jsonb),
		'reward_delta', reward_delta,
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
			'client_summary', payload_client_summary,
			'operations', payload_operations,
			'durable_progress_revision', coalesce((durable_progress->>'progress_revision')::integer, 0)
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
		'operations_applied', coalesce(durable_progress->'applied_ops', '{}'::jsonb),
		'durable_progress', durable_progress,
		'complete_ready', true,
		'session', public.openworld_forest_session_payload_v1(session_row),
		'server_time', now_ts
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

create or replace function public.openworld_forest_progress_v2_guard_v1()
returns trigger
language plpgsql
as $$
begin
	if new.mode_id = 'openworld' then
		new.local_schema_version := 'openworld_forest_progress_v2';
		new.progress_payload := public.openworld_forest_canonical_progress_v1(new.progress_payload);
	end if;
	return new;
end;
$$;

drop trigger if exists openworld_forest_progress_v2_guard_v1 on public.mode_progress;
create trigger openworld_forest_progress_v2_guard_v1
before insert or update of local_schema_version, progress_payload on public.mode_progress
for each row
execute function public.openworld_forest_progress_v2_guard_v1();

update public.mode_progress as progress_update
set
	local_schema_version = 'openworld_forest_progress_v2',
	progress_payload = public.openworld_forest_canonical_progress_v1(progress_update.progress_payload),
	updated_at = now()
where progress_update.mode_id = 'openworld';

update public.mode_sessions as session_update
set
	snapshot_payload = public.openworld_forest_snapshot_with_progress_v1(
		public.openworld_forest_rewrite_legacy_snapshot_v1(session_update.snapshot_payload),
		coalesce(
			(
				select progress_update.progress_payload
				from public.mode_progress as progress_update
				where progress_update.game_save_id = session_update.game_save_id
					and progress_update.mode_id = session_update.mode_id
				limit 1
			),
			session_update.snapshot_payload->'durable_base',
			'{}'::jsonb
		)
	),
	updated_at = now()
where session_update.mode_id = 'openworld'
	and session_update.slice_id = 'forest'
	and session_update.status = 'started';

revoke all on function public.openworld_forest_item_respawn_seconds_v1(text) from public;
grant execute on function public.openworld_forest_item_respawn_seconds_v1(text) to service_role;

revoke all on function public.openworld_forest_clean_node_state_v1(jsonb) from public;
grant execute on function public.openworld_forest_clean_node_state_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_collected_nodes_from_node_state_v1(jsonb, timestamptz) from public;
grant execute on function public.openworld_forest_collected_nodes_from_node_state_v1(jsonb, timestamptz) to service_role;

revoke all on function public.openworld_forest_empty_progress_v1() from public;
grant execute on function public.openworld_forest_empty_progress_v1() to service_role;

revoke all on function public.openworld_forest_canonical_progress_v1(jsonb) from public;
grant execute on function public.openworld_forest_canonical_progress_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_apply_operations_v1(jsonb, jsonb, uuid, timestamptz) from public;
grant execute on function public.openworld_forest_apply_operations_v1(jsonb, jsonb, uuid, timestamptz) to service_role;

revoke all on function public.openworld_forest_progress_v2_guard_v1() from public;
grant execute on function public.openworld_forest_progress_v2_guard_v1() to service_role;

revoke all on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) to service_role;
