-- Bosque Fogueira Potion Crafting v1.
-- Station craft is server-authoritative for global consumables, while
-- Bosque runtime play and durable inventory remain checkpoint/offline-first.

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
			'station_craft',
			'complete_requested',
			'abandon_requested'
		)
	);

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

create or replace function public.openworld_forest_clean_structures_v1(p_structures jsonb)
returns jsonb
language plpgsql
immutable
as $$
declare
	source jsonb := coalesce(p_structures, '{}'::jsonb);
	result jsonb := '{}'::jsonb;
begin
	if jsonb_typeof(source) <> 'object' then
		return '{}'::jsonb;
	end if;
	if coalesce((source->>'fogueira_estavel_1')::boolean, false) then
		result := jsonb_set(result, '{fogueira_estavel_1}', to_jsonb(true), true);
	end if;
	return result;
end;
$$;

create or replace function public.openworld_forest_empty_progress_v1()
returns jsonb
language sql
immutable
as $$
	select '{
		"schema_version":"openworld_forest_progress_v1",
		"pocket":{},
		"chest":{},
		"upgrades":{},
		"structures":{},
		"reward_ledger":{"rewarded_chest":{}},
		"progress_revision":0
	}'::jsonb
$$;

create or replace function public.openworld_forest_canonical_progress_v1(p_progress jsonb)
returns jsonb
language plpgsql
as $$
declare
	source jsonb := coalesce(p_progress, '{}'::jsonb);
	reward_ledger jsonb := case when jsonb_typeof(source->'reward_ledger') = 'object' then source->'reward_ledger' else '{}'::jsonb end;
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
	result := jsonb_set(result, '{structures}', coalesce(progress->'structures', '{}'::jsonb), true);
	result := jsonb_set(result, '{durable_base}', progress, true);
	result := jsonb_set(result, '{collected_nodes}', '{}'::jsonb, true);
	result := jsonb_set(result, '{last_message}', to_jsonb('Bosque pronto.'::text), true);
	return public.openworld_forest_recompute_snapshot_v1(result);
end;
$$;

create or replace function public.craft_station_item_v1(
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
	resource_row public.resources%rowtype;
	consumable_row public.player_consumables%rowtype;
	progress_row public.mode_progress%rowtype;
	session_row public.mode_sessions%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	station_context jsonb := coalesce(p_request_payload->'station_context', '{}'::jsonb);
	payload_recipe_id text := nullif(trim(coalesce(p_request_payload->>'recipe_id', '')), '');
	payload_quantity integer := coalesce((p_request_payload->>'quantity')::integer, 1);
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(station_context->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(station_context->>'slice_id', '')), '');
	payload_station_id text := nullif(trim(coalesce(station_context->>'station_id', '')), '');
	expected_progress_revision integer := coalesce((station_context->>'expected_progress_revision')::integer, -1);
	output_item_id text;
	output_quantity integer;
	required_po_osso numeric := 0;
	chest_cost jsonb := '{}'::jsonb;
	resource_delta jsonb := '{}'::jsonb;
	durable_progress jsonb;
	next_progress jsonb;
	next_chest jsonb;
	next_snapshot jsonb;
	item_record record;
	current_quantity integer;
	needed_quantity integer;
	previous_snapshot_revision integer;
	revision_after integer;
	now_ts timestamptz := now();
	scope_id text;
begin
	if p_game_save_id is null or p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if payload_recipe_id is null or payload_quantity <= 0 or payload_quantity > 20 then
		raise exception 'INVALID_RECIPE' using errcode = 'P0001';
	end if;
	if payload_mode_id <> 'openworld' or payload_slice_id <> 'forest' or payload_station_id <> 'fogueira_estavel_1' then
		raise exception 'INVALID_STATION_CONTEXT' using errcode = 'P0001';
	end if;
	if expected_progress_revision < 0 then
		raise exception 'INVALID_PROGRESS_REVISION' using errcode = 'P0001';
	end if;
	begin
		payload_session_id := (station_context->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_SESSION_ID' using errcode = 'P0001';
	end;

	if payload_recipe_id = 'craft_pocao_vida' then
		output_item_id := 'pocao_vida';
		chest_cost := jsonb_build_object('folha', 2 * payload_quantity, 'cogumelo', 1 * payload_quantity);
		required_po_osso := 25 * payload_quantity;
	elsif payload_recipe_id = 'craft_pocao_foco' then
		output_item_id := 'pocao_foco';
		chest_cost := jsonb_build_object('fungo', 1 * payload_quantity, 'inseto', 1 * payload_quantity);
		required_po_osso := 15 * payload_quantity;
	elsif payload_recipe_id = 'craft_pocao_resguardo' then
		output_item_id := 'pocao_resguardo';
		chest_cost := jsonb_build_object('resina', 1 * payload_quantity, 'pedra_pequena', 1 * payload_quantity);
		required_po_osso := 20 * payload_quantity;
	else
		raise exception 'INVALID_RECIPE' using errcode = 'P0001';
	end if;
	output_quantity := payload_quantity;
	resource_delta := jsonb_build_object('po_osso', -required_po_osso);

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

	scope_id := 'crafting:station:' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'crafting/station-craft',
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
		and mode_id = 'openworld'
		and slice_id = 'forest'
	for update;
	if session_row.id is null then
		raise exception 'MODE_SESSION_NOT_FOUND' using errcode = 'P0001';
	end if;
	if session_row.status <> 'started' then
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.expires_at <= now_ts then
		update public.mode_sessions set status = 'expired', updated_at = now_ts where id = session_row.id;
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if nullif(session_row.snapshot_payload#>>'{checkpoint,accepted_checkpoint_id}', '') is null then
		raise exception 'MODE_CHECKPOINT_REQUIRED' using errcode = 'P0001';
	end if;

	select *
	into progress_row
	from public.mode_progress
	where game_save_id = save_row.id
		and mode_id = 'openworld'
	for update;
	durable_progress := public.openworld_forest_canonical_progress_v1(coalesce(progress_row.progress_payload, '{}'::jsonb));
	if coalesce((durable_progress->>'progress_revision')::integer, 0) <> expected_progress_revision then
		raise exception 'PROGRESS_REVISION_MISMATCH' using errcode = 'P0001';
	end if;
	if not (
		coalesce((durable_progress#>>'{structures,fogueira_estavel_1}')::boolean, false)
		or coalesce((durable_progress#>>'{upgrades,fogueira_estavel_1}')::boolean, false)
	) then
		raise exception 'STATION_NOT_BUILT' using errcode = 'P0001';
	end if;

	select *
	into resource_row
	from public.resources
	where player_id = save_row.legacy_player_id
	for update;
	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;
	if resource_row.po_osso < required_po_osso then
		raise exception 'INSUFFICIENT_RESOURCES' using errcode = 'P0001';
	end if;

	next_chest := coalesce(durable_progress->'chest', '{}'::jsonb);
	for item_record in select * from jsonb_each_text(chest_cost)
	loop
		needed_quantity := greatest(0, item_record.value::integer);
		current_quantity := public.openworld_forest_inventory_quantity_v1(next_chest, item_record.key);
		if current_quantity < needed_quantity then
			raise exception 'INSUFFICIENT_OPENWORLD_MATERIALS' using errcode = 'P0001';
		end if;
		if current_quantity = needed_quantity then
			next_chest := next_chest - item_record.key;
		else
			next_chest := jsonb_set(next_chest, array[item_record.key], to_jsonb(current_quantity - needed_quantity), true);
		end if;
	end loop;

	next_progress := jsonb_set(durable_progress, '{chest}', next_chest, true);
	next_progress := jsonb_set(next_progress, '{progress_revision}', to_jsonb(expected_progress_revision + 1), true);
	next_progress := jsonb_set(next_progress, '{updated_at}', to_jsonb(now_ts), true);
	next_progress := public.openworld_forest_canonical_progress_v1(next_progress);

	update public.resources
	set
		po_osso = po_osso - required_po_osso,
		updated_at = now_ts
	where player_id = save_row.legacy_player_id
	returning * into resource_row;

	insert into public.player_consumables as consumable (player_id, item_id, quantity, updated_at)
	values (save_row.legacy_player_id, output_item_id, output_quantity, now_ts)
	on conflict (player_id, item_id) do update
	set
		quantity = consumable.quantity + excluded.quantity,
		updated_at = excluded.updated_at
	returning * into consumable_row;

	update public.mode_progress as progress_update
	set
		local_schema_version = 'openworld_forest_progress_v1',
		progress_payload = next_progress,
		updated_at = now_ts
	where progress_update.game_save_id = save_row.id
		and progress_update.mode_id = 'openworld';
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
			'openworld',
			'openworld_forest_progress_v1',
			next_progress,
			'{"sessions_started":0,"sessions_completed":0,"activity_score":0}'::jsonb,
			now_ts
		);
	end if;

	previous_snapshot_revision := session_row.snapshot_revision;
	revision_after := previous_snapshot_revision + 1;
	next_snapshot := public.openworld_forest_recompute_snapshot_v1(session_row.snapshot_payload);
	next_snapshot := jsonb_set(next_snapshot, '{chest}', next_chest, true);
	next_snapshot := jsonb_set(next_snapshot, '{upgrades}', coalesce(next_progress->'upgrades', '{}'::jsonb), true);
	next_snapshot := jsonb_set(next_snapshot, '{structures}', coalesce(next_progress->'structures', '{}'::jsonb), true);
	next_snapshot := jsonb_set(next_snapshot, '{durable_base}', next_progress, true);
	next_snapshot := jsonb_set(next_snapshot, '{revision}', to_jsonb(revision_after), true);
	next_snapshot := jsonb_set(next_snapshot, '{last_message}', to_jsonb('Pocao preparada na Fogueira.'::text), true);
	next_snapshot := public.openworld_forest_recompute_snapshot_v1(next_snapshot);

	update public.mode_sessions
	set
		snapshot_payload = next_snapshot,
		snapshot_revision = revision_after,
		last_event_at = now_ts,
		activity_score = coalesce((next_snapshot->>'activity_score')::integer, activity_score),
		updated_at = now_ts
	where id = session_row.id
	returning * into session_row;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (save_row.legacy_player_id, 'crafting/station-craft', p_request_id, resource_delta);

	insert into public.item_transactions (player_id, source, request_id, item_id, delta, payload)
	values (
		save_row.legacy_player_id,
		'crafting/station-craft',
		p_request_id,
		output_item_id,
		output_quantity,
		jsonb_build_object(
			'recipe_id', payload_recipe_id,
			'station_id', payload_station_id,
			'session_id', session_row.id,
			'openworld_chest_delta', chest_cost,
			'resource_delta', resource_delta
		)
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
		'openworld',
		'forest',
		p_request_id,
		p_request_hash,
		'station_craft',
		previous_snapshot_revision,
		revision_after,
		jsonb_build_object(
			'recipe_id', payload_recipe_id,
			'quantity', payload_quantity,
			'station_id', payload_station_id,
			'output', jsonb_build_object('item_id', output_item_id, 'quantity', output_quantity),
			'resource_delta', resource_delta,
			'openworld_chest_delta', chest_cost,
			'expected_progress_revision', expected_progress_revision,
			'progress_revision_after', coalesce((next_progress->>'progress_revision')::integer, 0)
		),
		next_snapshot
	);

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'foundation_station_craft_response_v1',
		'endpoint', 'crafting/station-craft',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'crafted', jsonb_build_object(
			'recipe_id', payload_recipe_id,
			'output', jsonb_build_object('item_id', output_item_id, 'quantity', output_quantity),
			'cost', resource_delta,
			'openworld_cost', chest_cost
		),
		'station_craft', jsonb_build_object(
			'recipe_id', payload_recipe_id,
			'quantity', payload_quantity,
			'station_context', station_context,
			'output', jsonb_build_object('item_id', output_item_id, 'quantity', output_quantity),
			'progress_revision_after', coalesce((next_progress->>'progress_revision')::integer, 0)
		),
		'resources', to_jsonb(resource_row),
		'item', to_jsonb(consumable_row),
		'durable_progress', next_progress,
		'session', public.openworld_forest_session_payload_v1(session_row)
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'crafting/station-craft',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

create or replace function public.build_potion_equip_v1(
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
	consumable_row public.player_consumables%rowtype;
	slot_row public.player_potion_slots%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	payload_slot_index integer := coalesce((p_request_payload->>'slot_index')::integer, 1);
	payload_item_id text := nullif(trim(coalesce(p_request_payload->>'item_id', '')), '');
	payload_behavior jsonb := coalesce(p_request_payload->'behavior', '{"enabled": true, "hp": {"mode": "below", "percent": 40}, "mana": {"mode": "ignore", "percent": 0}}'::jsonb);
begin
	if p_game_save_id is null or p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if payload_slot_index <> 1 then
		raise exception 'INVALID_SLOT' using errcode = 'P0001';
	end if;
	if jsonb_typeof(payload_behavior) <> 'object' then
		raise exception 'INVALID_PAYLOAD' using errcode = 'P0001';
	end if;
	if payload_item_id is not null and payload_item_id not in ('pocao_vida', 'pocao_foco', 'pocao_resguardo') then
		raise exception 'INVALID_POTION' using errcode = 'P0001';
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
		'build/potion/equip',
		p_request_id,
		p_request_hash,
		'build:' || save_row.save_type
	);
	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	if payload_item_id is not null then
		select *
		into consumable_row
		from public.player_consumables
		where player_id = save_row.legacy_player_id
			and item_id = payload_item_id
		for update;
		if consumable_row.player_id is null or consumable_row.quantity <= 0 then
			raise exception 'POTION_NOT_OWNED' using errcode = 'P0001';
		end if;
	end if;

	insert into public.player_potion_slots as potion_slot (
		player_id,
		slot_index,
		potion_id,
		behavior,
		updated_at
	)
	values (
		save_row.legacy_player_id,
		payload_slot_index,
		payload_item_id,
		payload_behavior,
		now()
	)
	on conflict (player_id, slot_index) do update
	set
		potion_id = excluded.potion_id,
		behavior = excluded.behavior,
		updated_at = excluded.updated_at
	returning * into slot_row;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'foundation_build_potion_equip_response_v1',
		'endpoint', 'build/potion/equip',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'equipped_potion', jsonb_build_object('slot_index', payload_slot_index, 'potion_id', payload_item_id),
		'potion_slot', to_jsonb(slot_row)
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'build/potion/equip',
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

revoke all on function public.openworld_forest_clean_structures_v1(jsonb) from public;
grant execute on function public.openworld_forest_clean_structures_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_empty_progress_v1() from public;
grant execute on function public.openworld_forest_empty_progress_v1() to service_role;

revoke all on function public.openworld_forest_canonical_progress_v1(jsonb) from public;
grant execute on function public.openworld_forest_canonical_progress_v1(jsonb) to service_role;

revoke all on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) to service_role;

revoke all on function public.craft_station_item_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.craft_station_item_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.build_potion_equip_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.build_potion_equip_v1(uuid, uuid, text, jsonb) to service_role;
