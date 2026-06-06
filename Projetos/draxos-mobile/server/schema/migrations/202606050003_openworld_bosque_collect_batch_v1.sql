-- Openworld Bosque collect batch v1.
-- Reduces server round-trips during resource gathering while preserving
-- snapshot revision authority for deposit, craft and completion.

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
			'complete_requested',
			'abandon_requested'
		)
	);

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
	nodes_payload jsonb;
	node_payload jsonb;
	batch_node_id text;
	batch_item_id text;
	batch_seen_nodes jsonb := '{}'::jsonb;
	batch_count integer := 0;
begin
	session_seconds := greatest(0, least(7200, coalesce((p_event_payload->>'session_seconds')::integer, coalesce((result->>'session_seconds')::integer, 0))));
	result := jsonb_set(result, '{session_seconds}', to_jsonb(session_seconds), true);

	if p_event_type = 'move_heartbeat' then
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
	elsif p_event_type = 'collect_batch' then
		nodes_payload := coalesce(p_event_payload->'nodes', '[]'::jsonb);
		if jsonb_typeof(nodes_payload) <> 'array' then
			raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
		end if;

		for node_payload in select value from jsonb_array_elements(nodes_payload)
		loop
			if jsonb_typeof(node_payload) <> 'object' then
				raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
			end if;

			batch_node_id := nullif(trim(coalesce(node_payload->>'node_id', '')), '');
			batch_item_id := nullif(trim(coalesce(node_payload->>'item_id', '')), '');
			expected_item_id := public.openworld_forest_node_item_v1(batch_node_id);
			if expected_item_id is null or expected_item_id <> batch_item_id then
				raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
			end if;
			if batch_seen_nodes ? batch_node_id then
				raise exception 'OPENWORLD_NODE_ALREADY_COLLECTED' using errcode = 'P0001';
			end if;
			if coalesce((result#>>array['collected_nodes', batch_node_id])::boolean, false) then
				raise exception 'OPENWORLD_NODE_ALREADY_COLLECTED' using errcode = 'P0001';
			end if;

			item_weight := public.openworld_forest_item_weight_v1(batch_item_id);
			if item_weight is null then
				raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
			end if;
			capacity := coalesce((result->>'capacity')::numeric, 20);
			pocket_weight := public.openworld_forest_inventory_weight_v1(result->'pocket');
			if pocket_weight + item_weight > capacity + 0.001 then
				raise exception 'MODE_RESULT_REJECTED' using errcode = 'P0001';
			end if;

			current_quantity := public.openworld_forest_inventory_quantity_v1(result->'pocket', batch_item_id);
			result := jsonb_set(result, array['pocket', batch_item_id], to_jsonb(current_quantity + 1), true);
			result := jsonb_set(result, array['collected_nodes', batch_node_id], to_jsonb(true), true);
			batch_seen_nodes := jsonb_set(batch_seen_nodes, array[batch_node_id], to_jsonb(true), true);
			batch_count := batch_count + 1;
		end loop;

		if batch_count < 1 then
			raise exception 'INVALID_MODE_EVENT' using errcode = 'P0001';
		end if;

		result := jsonb_set(result, '{last_message}', to_jsonb(('Coletas registradas: ' || batch_count || '.')::text), true);
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
