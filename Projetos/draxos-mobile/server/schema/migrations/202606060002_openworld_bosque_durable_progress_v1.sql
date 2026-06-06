-- Openworld Bosque durable progress v1.
-- Baú, Mochila/Bolso, upgrades and crafted structures persist per save.
-- Active session nodes still reset per visit; rewards use high-water ledger deltas.

create or replace function public.openworld_forest_clean_upgrades_v1(p_upgrades jsonb)
returns jsonb
language plpgsql
immutable
as $$
declare
	upgrade_record record;
	result jsonb := '{}'::jsonb;
begin
	if jsonb_typeof(coalesce(p_upgrades, '{}'::jsonb)) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;

	for upgrade_record in select * from jsonb_each(coalesce(p_upgrades, '{}'::jsonb))
	loop
		if jsonb_typeof(upgrade_record.value) <> 'boolean' then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		if upgrade_record.value::text = 'true' then
			if public.openworld_forest_recipe_cost_v1(upgrade_record.key) is null then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;
			result := jsonb_set(result, array[upgrade_record.key], to_jsonb(true), true);
		end if;
	end loop;

	return result;
end;
$$;

create or replace function public.openworld_forest_inventory_highwater_v1(
	p_current jsonb,
	p_next jsonb
)
returns jsonb
language plpgsql
immutable
as $$
declare
	current_inventory jsonb := public.openworld_forest_clean_inventory_v1(coalesce(p_current, '{}'::jsonb));
	next_inventory jsonb := public.openworld_forest_clean_inventory_v1(coalesce(p_next, '{}'::jsonb));
	all_item_keys jsonb := '{}'::jsonb;
	item_record record;
	current_quantity integer;
	next_quantity integer;
	result jsonb := '{}'::jsonb;
begin
	for item_record in select * from jsonb_each_text(current_inventory)
	loop
		all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
	end loop;
	for item_record in select * from jsonb_each_text(next_inventory)
	loop
		all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
	end loop;
	for item_record in select * from jsonb_each_text(all_item_keys)
	loop
		current_quantity := public.openworld_forest_inventory_quantity_v1(current_inventory, item_record.key);
		next_quantity := public.openworld_forest_inventory_quantity_v1(next_inventory, item_record.key);
		if greatest(current_quantity, next_quantity) > 0 then
			result := jsonb_set(result, array[item_record.key], to_jsonb(greatest(current_quantity, next_quantity)), true);
		end if;
	end loop;
	return result;
end;
$$;

create or replace function public.openworld_forest_inventory_delta_above_v1(
	p_inventory jsonb,
	p_highwater jsonb
)
returns jsonb
language plpgsql
immutable
as $$
declare
	inventory jsonb := public.openworld_forest_clean_inventory_v1(coalesce(p_inventory, '{}'::jsonb));
	highwater jsonb := public.openworld_forest_clean_inventory_v1(coalesce(p_highwater, '{}'::jsonb));
	item_record record;
	current_quantity integer;
	highwater_quantity integer;
	result jsonb := '{}'::jsonb;
begin
	for item_record in select * from jsonb_each_text(inventory)
	loop
		current_quantity := greatest(0, item_record.value::integer);
		highwater_quantity := public.openworld_forest_inventory_quantity_v1(highwater, item_record.key);
		if current_quantity > highwater_quantity then
			result := jsonb_set(result, array[item_record.key], to_jsonb(current_quantity - highwater_quantity), true);
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
		'schema_version', 'openworld_forest_progress_v1',
		'pocket', '{}'::jsonb,
		'chest', '{}'::jsonb,
		'upgrades', '{}'::jsonb,
		'reward_ledger', jsonb_build_object('rewarded_chest', '{}'::jsonb),
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
	result jsonb := public.openworld_forest_empty_progress_v1();
	progress_revision integer := greatest(0, coalesce(nullif(source->>'progress_revision', '')::integer, 0));
	last_checkpoint text := nullif(trim(coalesce(source->>'last_checkpoint_session_id', '')), '');
	last_completed text := nullif(trim(coalesce(source->>'last_completed_session_id', '')), '');
begin
	result := jsonb_set(result, '{pocket}', public.openworld_forest_clean_inventory_v1(coalesce(source->'pocket', '{}'::jsonb)), true);
	result := jsonb_set(result, '{chest}', public.openworld_forest_clean_inventory_v1(coalesce(source->'chest', '{}'::jsonb)), true);
	result := jsonb_set(result, '{upgrades}', public.openworld_forest_clean_upgrades_v1(coalesce(source->'upgrades', '{}'::jsonb)), true);
	result := jsonb_set(
		result,
		'{reward_ledger}',
		jsonb_build_object(
			'rewarded_chest',
			public.openworld_forest_clean_inventory_v1(coalesce(reward_ledger->'rewarded_chest', '{}'::jsonb))
		),
		true
	);
	result := jsonb_set(result, '{progress_revision}', to_jsonb(progress_revision), true);
	if last_checkpoint is not null then
		result := jsonb_set(result, '{last_checkpoint_session_id}', to_jsonb(last_checkpoint), true);
	end if;
	if last_completed is not null then
		result := jsonb_set(result, '{last_completed_session_id}', to_jsonb(last_completed), true);
	elsif nullif(trim(coalesce(source->>'last_completed_session_id', '')), '') is not null then
		result := jsonb_set(result, '{last_completed_session_id}', to_jsonb(source->>'last_completed_session_id'), true);
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
begin
	if jsonb_typeof(source) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	result := jsonb_set(result, '{pocket}', public.openworld_forest_clean_inventory_v1(coalesce(source->'pocket', '{}'::jsonb)), true);
	result := jsonb_set(result, '{chest}', public.openworld_forest_clean_inventory_v1(coalesce(source->'chest', '{}'::jsonb)), true);
	result := jsonb_set(result, '{upgrades}', public.openworld_forest_clean_upgrades_v1(coalesce(source->'upgrades', '{}'::jsonb)), true);
	return result;
end;
$$;

create or replace function public.openworld_forest_mark_checkpoint_progress_v1(
	p_progress jsonb,
	p_snapshot jsonb,
	p_session_id uuid
)
returns jsonb
language plpgsql
as $$
declare
	result jsonb := public.openworld_forest_progress_from_snapshot_v1(p_progress, p_snapshot);
	next_revision integer := coalesce((result->>'progress_revision')::integer, 0) + 1;
begin
	result := jsonb_set(result, '{last_checkpoint_session_id}', to_jsonb(p_session_id::text), true);
	result := jsonb_set(result, '{progress_revision}', to_jsonb(next_revision), true);
	result := jsonb_set(result, '{updated_at}', to_jsonb(now()), true);
	return result;
end;
$$;

create or replace function public.openworld_forest_mark_completed_progress_v1(
	p_progress jsonb,
	p_snapshot jsonb,
	p_session_id uuid
)
returns jsonb
language plpgsql
as $$
declare
	result jsonb := public.openworld_forest_progress_from_snapshot_v1(p_progress, p_snapshot);
	reward_ledger jsonb := coalesce(result->'reward_ledger', '{}'::jsonb);
	next_rewarded_chest jsonb;
	next_revision integer := coalesce((result->>'progress_revision')::integer, 0) + 1;
begin
	next_rewarded_chest := public.openworld_forest_inventory_highwater_v1(
		coalesce(reward_ledger->'rewarded_chest', '{}'::jsonb),
		coalesce(result->'chest', '{}'::jsonb)
	);
	result := jsonb_set(result, '{reward_ledger}', jsonb_build_object('rewarded_chest', next_rewarded_chest), true);
	result := jsonb_set(result, '{last_completed_session_id}', to_jsonb(p_session_id::text), true);
	result := jsonb_set(result, '{progress_revision}', to_jsonb(next_revision), true);
	result := jsonb_set(result, '{updated_at}', to_jsonb(now()), true);
	return result;
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
	result := jsonb_set(result, '{durable_base}', progress, true);
	result := jsonb_set(result, '{collected_nodes}', '{}'::jsonb, true);
	result := jsonb_set(result, '{last_message}', to_jsonb('Bosque pronto.'::text), true);
	return public.openworld_forest_recompute_snapshot_v1(result);
end;
$$;

create or replace function public.openworld_forest_validate_checkpoint_v2(
	p_snapshot jsonb,
	p_checkpoint_id text,
	p_client_sequence integer,
	p_base_revision integer,
	p_base_progress jsonb
)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := coalesce(p_snapshot, '{}'::jsonb);
	base_progress jsonb := public.openworld_forest_canonical_progress_v1(p_base_progress);
	base_pocket jsonb := public.openworld_forest_clean_inventory_v1(base_progress->'pocket');
	base_chest jsonb := public.openworld_forest_clean_inventory_v1(base_progress->'chest');
	base_upgrades jsonb := public.openworld_forest_clean_upgrades_v1(base_progress->'upgrades');
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

	for upgrade_record in select * from jsonb_each(base_upgrades)
	loop
		if upgrade_record.value::text = 'true' then
			clean_upgrades := jsonb_set(clean_upgrades, array[upgrade_record.key], to_jsonb(true), true);
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
			if not coalesce((base_upgrades#>>array[upgrade_record.key])::boolean, false) then
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
		end if;
	end loop;

	for item_record in select * from jsonb_each_text(base_pocket)
	loop
		all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
	end loop;
	for item_record in select * from jsonb_each_text(base_chest)
	loop
		all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
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
		available_quantity := public.openworld_forest_inventory_quantity_v1(base_pocket, item_record.key)
			+ public.openworld_forest_inventory_quantity_v1(base_chest, item_record.key)
			+ public.openworld_forest_inventory_quantity_v1(collected_counts, item_record.key)
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
		'durable_base', base_progress,
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
	progress_row public.mode_progress%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	session_row public.mode_sessions%rowtype;
	initial_snapshot jsonb;
	saved_guidance jsonb;
	durable_progress jsonb;
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

	select *
	into progress_row
	from public.mode_progress
	where game_save_id = save_row.id
		and mode_id = payload_mode_id
	for update;
	durable_progress := public.openworld_forest_canonical_progress_v1(coalesce(progress_row.progress_payload, '{}'::jsonb));

	initial_snapshot := public.openworld_forest_initial_snapshot_v1();
	initial_snapshot := public.openworld_forest_snapshot_with_progress_v1(initial_snapshot, durable_progress);
	saved_guidance := coalesce(save_row.snapshot#>'{openworld,forest,guidance}', '{}'::jsonb);
	initial_snapshot := jsonb_set(
		initial_snapshot,
		'{guidance}',
		public.openworld_forest_normalize_guidance_v1(saved_guidance),
		true
	);
	initial_snapshot := public.openworld_forest_recompute_snapshot_v1(initial_snapshot);

	insert into public.mode_progress as progress_insert (
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
		'openworld_forest_progress_v1',
		durable_progress,
		'{"sessions_started":1,"sessions_completed":0,"activity_score":0}'::jsonb,
		now()
	)
	on conflict (game_save_id, mode_id) do update
	set
		local_schema_version = 'openworld_forest_progress_v1',
		progress_payload = durable_progress,
		totals_payload = jsonb_set(
			progress_insert.totals_payload,
			'{sessions_started}',
			to_jsonb(coalesce(nullif(progress_insert.totals_payload->>'sessions_started', '')::integer, 0) + 1),
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
			'release_channel', 'internal_alpha'
		),
		'session', public.openworld_forest_session_payload_v1(session_row),
		'durable_progress', durable_progress,
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

	next_snapshot := public.openworld_forest_validate_checkpoint_v2(
		payload_snapshot,
		payload_checkpoint_id,
		payload_client_sequence,
		payload_base_revision,
		base_progress
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

	durable_progress := public.openworld_forest_mark_checkpoint_progress_v1(durable_progress, next_snapshot, session_row.id);
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
		local_schema_version = 'openworld_forest_progress_v1',
		progress_payload = durable_progress,
		updated_at = now()
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
			'openworld_forest_progress_v1',
			durable_progress,
			'{"sessions_started":0,"sessions_completed":0,"activity_score":0}'::jsonb,
			now()
		);
	end if;

	update public.mode_sessions
	set
		snapshot_payload = next_snapshot,
		snapshot_revision = revision_after,
		last_event_at = now(),
		session_seconds = coalesce((next_snapshot->>'session_seconds')::integer, session_seconds),
		activity_score = coalesce((next_snapshot->>'activity_score')::integer, activity_score),
		deposited_items = reward_delta,
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
		'durable_progress', durable_progress,
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
	progress_row public.mode_progress%rowtype;
	durable_progress_before jsonb;
	durable_progress_after jsonb;
	legacy_response jsonb;
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

	select *
	into progress_row
	from public.mode_progress
	where game_save_id = save_row.id
		and mode_id = payload_mode_id
	for update;
	durable_progress_before := public.openworld_forest_canonical_progress_v1(coalesce(progress_row.progress_payload, '{}'::jsonb));

	legacy_response := public.mode_session_complete_legacy_v1(
		p_game_save_id,
		p_request_id,
		p_request_hash,
		p_request_payload
	);

	select *
	into session_row
	from public.mode_sessions
	where id = payload_session_id
		and game_save_id = save_row.id
		and mode_id = payload_mode_id
		and slice_id = payload_slice_id
	for update;

	durable_progress_after := public.openworld_forest_mark_completed_progress_v1(
		durable_progress_before,
		session_row.snapshot_payload,
		session_row.id
	);

	update public.mode_progress as progress_update
	set
		local_schema_version = 'openworld_forest_progress_v1',
		progress_payload = durable_progress_after,
		totals_payload = coalesce(progress_update.totals_payload, '{}'::jsonb),
		last_session_id = session_row.id,
		updated_at = now()
	where progress_update.game_save_id = save_row.id
		and progress_update.mode_id = payload_mode_id;
	if not found then
		insert into public.mode_progress (
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
			'openworld_forest_progress_v1',
			durable_progress_after,
			'{"sessions_started":0,"sessions_completed":1,"activity_score":0}'::jsonb,
			session_row.id,
			now()
		);
	end if;

	legacy_response := jsonb_set(coalesce(legacy_response, '{}'::jsonb), '{durable_progress}', durable_progress_after, true);
	update public.mode_sessions
	set reward_payload = jsonb_set(coalesce(reward_payload, '{}'::jsonb), '{durable_progress}', durable_progress_after, true)
	where id = session_row.id;

	return legacy_response;
end;
$$;

with latest_sessions as (
	select distinct on (progress_source.game_save_id, progress_source.mode_id)
		progress_source.game_save_id,
		progress_source.mode_id,
		session_row.snapshot_payload
	from public.mode_progress progress_source
	join public.mode_sessions session_row
		on session_row.game_save_id = progress_source.game_save_id
		and session_row.mode_id = progress_source.mode_id
		and session_row.slice_id = 'forest'
		and session_row.snapshot_payload ? 'schema_version'
	where progress_source.mode_id = 'openworld'
	order by
		progress_source.game_save_id,
		progress_source.mode_id,
		session_row.updated_at desc nulls last,
		session_row.started_at desc nulls last
)
update public.mode_progress as progress_update
set
	local_schema_version = 'openworld_forest_progress_v1',
	progress_payload = public.openworld_forest_progress_from_snapshot_v1(
		progress_update.progress_payload,
		coalesce(latest_sessions.snapshot_payload, '{}'::jsonb)
	),
	updated_at = now()
from latest_sessions
where progress_update.game_save_id = latest_sessions.game_save_id
	and progress_update.mode_id = latest_sessions.mode_id
	and progress_update.mode_id = 'openworld'
	and coalesce(progress_update.progress_payload->>'schema_version', '') <> 'openworld_forest_progress_v1';

revoke all on function public.openworld_forest_clean_upgrades_v1(jsonb) from public;
grant execute on function public.openworld_forest_clean_upgrades_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_inventory_highwater_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_inventory_highwater_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_inventory_delta_above_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_inventory_delta_above_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_empty_progress_v1() from public;
grant execute on function public.openworld_forest_empty_progress_v1() to service_role;

revoke all on function public.openworld_forest_canonical_progress_v1(jsonb) from public;
grant execute on function public.openworld_forest_canonical_progress_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_mark_checkpoint_progress_v1(jsonb, jsonb, uuid) from public;
grant execute on function public.openworld_forest_mark_checkpoint_progress_v1(jsonb, jsonb, uuid) to service_role;

revoke all on function public.openworld_forest_mark_completed_progress_v1(jsonb, jsonb, uuid) from public;
grant execute on function public.openworld_forest_mark_completed_progress_v1(jsonb, jsonb, uuid) to service_role;

revoke all on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_validate_checkpoint_v2(jsonb, text, integer, integer, jsonb) from public;
grant execute on function public.openworld_forest_validate_checkpoint_v2(jsonb, text, integer, integer, jsonb) to service_role;

revoke all on function public.mode_session_start_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.mode_session_start_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) to service_role;
