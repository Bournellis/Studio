-- Bosque World Hub Domain Separation v1
-- Keeps Bosque-local materials separate from global account resources and
-- makes durable structures explicit in accepted checkpoints.

create or replace function public.openworld_forest_canonical_item_id_v1(p_item_id text)
returns text
language sql
immutable
as $$
	select case p_item_id
		when 'ossos_preview' then 'resto_ritual'
		when 'po_osso_preview' then 'po_cinzento'
		else p_item_id
	end
$$;

create or replace function public.openworld_forest_item_weight_v1(p_item_id text)
returns numeric
language sql
immutable
as $$
	select case public.openworld_forest_canonical_item_id_v1(p_item_id)
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
		when 'resto_ritual' then 1.2
		when 'po_cinzento' then 0.5
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
		when 'node_galho_02' then 'galho'
		when 'node_galho_03' then 'galho'
		when 'node_galho_04' then 'galho'
		when 'node_galho_05' then 'galho'
		when 'node_galho_06' then 'galho'
		when 'node_galho_07' then 'galho'
		when 'node_folha_01' then 'folha'
		when 'node_folha_02' then 'folha'
		when 'node_folha_03' then 'folha'
		when 'node_folha_04' then 'folha'
		when 'node_madeira_01' then 'madeira'
		when 'node_pedra_pequena_01' then 'pedra_pequena'
		when 'node_pedra_pequena_02' then 'pedra_pequena'
		when 'node_pedra_01' then 'pedra'
		when 'node_cogumelo_01' then 'cogumelo'
		when 'node_cogumelo_02' then 'cogumelo'
		when 'node_fungo_01' then 'fungo'
		when 'node_inseto_01' then 'inseto'
		when 'node_resina_01' then 'resina'
		when 'node_resina_02' then 'resina'
		when 'node_folha_seca_01' then 'folha_seca'
		when 'node_folha_seca_02' then 'folha_seca'
		when 'node_folha_seca_03' then 'folha_seca'
		when 'node_cinzas_preview_01' then 'cinzas_preview'
		when 'node_ossos_preview_01' then 'resto_ritual'
		when 'node_po_osso_preview_01' then 'po_cinzento'
		else null
	end
$$;

create or replace function public.openworld_forest_clean_inventory_v1(p_inventory jsonb)
returns jsonb
language plpgsql
immutable
as $$
declare
	source jsonb := coalesce(p_inventory, '{}'::jsonb);
	result jsonb := '{}'::jsonb;
	item_record record;
	clean_item_id text;
	item_weight numeric;
	current_quantity integer;
	next_quantity integer;
begin
	if jsonb_typeof(source) <> 'object' then
		return '{}'::jsonb;
	end if;

	for item_record in select * from jsonb_each_text(source)
	loop
		clean_item_id := public.openworld_forest_canonical_item_id_v1(item_record.key);
		item_weight := public.openworld_forest_item_weight_v1(clean_item_id);
		if item_weight is null then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		next_quantity := greatest(0, item_record.value::integer);
		if next_quantity > 0 then
			current_quantity := greatest(0, coalesce(nullif(result->>clean_item_id, '')::integer, 0));
			result := jsonb_set(result, array[clean_item_id], to_jsonb(current_quantity + next_quantity), true);
		end if;
	end loop;

	return result;
end;
$$;

create or replace function public.openworld_forest_rewrite_legacy_snapshot_v1(p_snapshot jsonb)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := coalesce(p_snapshot, '{}'::jsonb);
	result jsonb := coalesce(p_snapshot, '{}'::jsonb);
	clean_upgrades jsonb;
	clean_structures jsonb;
	clean_durable jsonb;
begin
	if jsonb_typeof(source) <> 'object' then
		return public.openworld_forest_initial_snapshot_v1();
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
	if jsonb_typeof(source->'reward_payload') = 'object' then
		result := jsonb_set(
			result,
			'{reward_payload,deposited_items}',
			public.openworld_forest_clean_inventory_v1(coalesce(source#>'{reward_payload,deposited_items}', '{}'::jsonb)),
			true
		);
	end if;
	if jsonb_typeof(source->'durable_base') = 'object' then
		clean_durable := public.openworld_forest_canonical_progress_v1(source->'durable_base');
		result := jsonb_set(result, '{durable_base}', clean_durable, true);
	end if;
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
	base_structures jsonb := public.openworld_forest_clean_structures_v1(base_progress->'structures');
	clean_snapshot jsonb := '{}'::jsonb;
	clean_pocket jsonb;
	clean_chest jsonb;
	clean_upgrades jsonb := '{}'::jsonb;
	clean_structures jsonb := '{}'::jsonb;
	clean_nodes jsonb := '{}'::jsonb;
	collected_counts jsonb := '{}'::jsonb;
	recipe_costs jsonb := '{}'::jsonb;
	recipe_outputs jsonb := '{}'::jsonb;
	charged_upgrades jsonb := '{}'::jsonb;
	all_item_keys jsonb := '{}'::jsonb;
	node_record record;
	upgrade_record record;
	structure_record record;
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

	if coalesce((base_upgrades->>'fogueira_estavel_1')::boolean, false)
		or coalesce((base_structures->>'fogueira_estavel_1')::boolean, false) then
		base_upgrades := jsonb_set(base_upgrades, '{fogueira_estavel_1}', to_jsonb(true), true);
		base_structures := jsonb_set(base_structures, '{fogueira_estavel_1}', to_jsonb(true), true);
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
	for structure_record in select * from jsonb_each(base_structures)
	loop
		if structure_record.value::text = 'true' then
			clean_structures := jsonb_set(clean_structures, array[structure_record.key], to_jsonb(true), true);
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
				charged_upgrades := jsonb_set(charged_upgrades, array[upgrade_record.key], to_jsonb(true), true);
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

	if jsonb_typeof(coalesce(source->'structures', '{}'::jsonb)) <> 'object' then
		raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
	end if;
	for structure_record in select * from jsonb_each(coalesce(source->'structures', '{}'::jsonb))
	loop
		if jsonb_typeof(structure_record.value) <> 'boolean' then
			raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
		end if;
		if structure_record.value::text = 'true' then
			if structure_record.key <> 'fogueira_estavel_1' then
				raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
			end if;
			clean_structures := jsonb_set(clean_structures, array[structure_record.key], to_jsonb(true), true);
			clean_upgrades := jsonb_set(clean_upgrades, array[structure_record.key], to_jsonb(true), true);
			if not coalesce((base_structures#>>array[structure_record.key])::boolean, false)
				and not coalesce((base_upgrades#>>array[structure_record.key])::boolean, false)
				and not coalesce((charged_upgrades#>>array[structure_record.key])::boolean, false) then
				cost_payload := public.openworld_forest_recipe_cost_v1(structure_record.key);
				if cost_payload is null then
					raise exception 'MODE_CHECKPOINT_REJECTED' using errcode = 'P0001';
				end if;
				charged_upgrades := jsonb_set(charged_upgrades, array[structure_record.key], to_jsonb(true), true);
				for item_record in select * from jsonb_each_text(cost_payload)
				loop
					current_quantity := public.openworld_forest_inventory_quantity_v1(recipe_costs, item_record.key);
					recipe_costs := jsonb_set(recipe_costs, array[item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
					all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
				end loop;
				output_payload := coalesce(public.openworld_forest_recipe_output_v1(structure_record.key), '{}'::jsonb);
				for item_record in select * from jsonb_each_text(output_payload)
				loop
					current_quantity := public.openworld_forest_inventory_quantity_v1(recipe_outputs, item_record.key);
					recipe_outputs := jsonb_set(recipe_outputs, array[item_record.key], to_jsonb(current_quantity + item_record.value::integer), true);
					all_item_keys := jsonb_set(all_item_keys, array[item_record.key], to_jsonb(true), true);
				end loop;
			end if;
		end if;
	end loop;

	if coalesce((clean_upgrades->>'fogueira_estavel_1')::boolean, false)
		or coalesce((clean_structures->>'fogueira_estavel_1')::boolean, false) then
		clean_upgrades := jsonb_set(clean_upgrades, '{fogueira_estavel_1}', to_jsonb(true), true);
		clean_structures := jsonb_set(clean_structures, '{fogueira_estavel_1}', to_jsonb(true), true);
	end if;
	base_progress := jsonb_set(base_progress, '{upgrades}', base_upgrades, true);
	base_progress := jsonb_set(base_progress, '{structures}', base_structures, true);

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
		'structures', clean_structures,
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
		'structures', coalesce(next_snapshot->'structures', '{}'::jsonb),
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

update public.mode_progress as progress_update
set
	progress_payload = public.openworld_forest_canonical_progress_v1(progress_update.progress_payload),
	updated_at = now()
where progress_update.mode_id = 'openworld';

update public.mode_sessions as session_update
set
	snapshot_payload = public.openworld_forest_rewrite_legacy_snapshot_v1(session_update.snapshot_payload),
	updated_at = now()
where session_update.mode_id = 'openworld'
	and session_update.slice_id = 'forest';

revoke all on function public.openworld_forest_canonical_item_id_v1(text) from public;
grant execute on function public.openworld_forest_canonical_item_id_v1(text) to service_role;

revoke all on function public.openworld_forest_item_weight_v1(text) from public;
grant execute on function public.openworld_forest_item_weight_v1(text) to service_role;

revoke all on function public.openworld_forest_node_item_v1(text) from public;
grant execute on function public.openworld_forest_node_item_v1(text) to service_role;

revoke all on function public.openworld_forest_clean_inventory_v1(jsonb) from public;
grant execute on function public.openworld_forest_clean_inventory_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_rewrite_legacy_snapshot_v1(jsonb) from public;
grant execute on function public.openworld_forest_rewrite_legacy_snapshot_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_validate_checkpoint_v2(jsonb, text, integer, integer, jsonb) from public;
grant execute on function public.openworld_forest_validate_checkpoint_v2(jsonb, text, integer, integer, jsonb) to service_role;

revoke all on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_checkpoint_v1(uuid, uuid, text, jsonb) to service_role;
