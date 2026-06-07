-- Bosque Session Lifecycle & Durable Structures Hotfix v1
-- Keeps durable structures in progress snapshots and new-session bootstrap.

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
	result := jsonb_set(result, '{durable_base}', progress, true);
	result := jsonb_set(result, '{collected_nodes}', '{}'::jsonb, true);
	result := jsonb_set(result, '{last_message}', to_jsonb('Bosque pronto.'::text), true);
	return public.openworld_forest_recompute_snapshot_v1(result);
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
	and session_update.slice_id = 'forest'
	and session_update.status = 'started';

revoke all on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_progress_from_snapshot_v1(jsonb, jsonb) to service_role;

revoke all on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) from public;
grant execute on function public.openworld_forest_snapshot_with_progress_v1(jsonb, jsonb) to service_role;
