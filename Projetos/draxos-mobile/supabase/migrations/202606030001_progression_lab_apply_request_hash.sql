-- Foundation Solidification Follow-up - Progression Lab apply request hash.
-- The public Edge adapter must call this signature and pass a non-empty
-- request_hash. Track 16 consumable/behavior reset now happens in the RPC
-- transaction instead of post-RPC REST cleanup.

create or replace function public.apply_progression_lab_save(
	p_auth_user_id uuid,
	p_request_id uuid,
	p_request_hash text,
	p_profile_id text,
	p_milestone_id text,
	p_save_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_request_hash text := trim(coalesce(p_request_hash, ''));
	player_row public.players%rowtype;
	existing_row public.idempotency_keys%rowtype;
	apply_response_payload jsonb;
	consumables_payload jsonb := coalesce(p_save_payload->'consumables', '{}'::jsonb);
	inventory_payload jsonb := '[]'::jsonb;
	potion_slots_payload jsonb := '[]'::jsonb;
	spell_behaviors_payload jsonb := '{}'::jsonb;
	default_potion_behavior jsonb := '{"enabled": true, "hp": {"mode": "below", "percent": 40}, "mana": {"mode": "ignore", "percent": 0}}'::jsonb;
begin
	if normalized_request_hash = '' then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	select *
	into player_row
	from public.players
	where auth_user_id = p_auth_user_id
		and save_type = 'progression_lab'
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into existing_row
	from public.idempotency_keys as ik
	where ik.player_id = player_row.id
		and ik.endpoint = 'progression-lab/apply'
		and ik.request_id = p_request_id;

	if existing_row.player_id is not null then
		if coalesce(existing_row.request_hash, '') <> normalized_request_hash then
			raise exception 'IDEMPOTENCY_HASH_MISMATCH' using errcode = 'P0001';
		end if;
		if existing_row.response_payload is not null then
			return existing_row.response_payload;
		end if;
	end if;

	apply_response_payload := public.apply_progression_lab_save(
		p_auth_user_id,
		p_request_id,
		p_profile_id,
		p_milestone_id,
		p_save_payload
	);

	if jsonb_typeof(consumables_payload->'inventory') = 'array' then
		inventory_payload := consumables_payload->'inventory';
	end if;
	if jsonb_typeof(consumables_payload->'potion_slots') = 'array' then
		potion_slots_payload := consumables_payload->'potion_slots';
	end if;
	if jsonb_typeof(consumables_payload->'spell_behaviors') = 'object' then
		spell_behaviors_payload := consumables_payload->'spell_behaviors';
	end if;

	delete from public.player_consumables
	where player_id = player_row.id;

	delete from public.player_spell_behaviors
	where player_id = player_row.id;

	delete from public.player_potion_slots
	where player_id = player_row.id;

	delete from public.item_transactions
	where player_id = player_row.id;

	insert into public.player_consumables (player_id, item_id, quantity, updated_at)
	select
		player_row.id,
		item_payload->>'item_id',
		greatest(0, coalesce(nullif(item_payload->>'quantity', '')::integer, 0)),
		now()
	from jsonb_array_elements(inventory_payload) as item(item_payload)
	where coalesce(item_payload->>'item_id', '') <> ''
		and greatest(0, coalesce(nullif(item_payload->>'quantity', '')::integer, 0)) > 0
	on conflict (player_id, item_id) do update
	set quantity = excluded.quantity,
		updated_at = excluded.updated_at;

	insert into public.item_transactions (
		player_id,
		source,
		request_id,
		item_id,
		delta,
		payload,
		created_at
	)
	select
		player_row.id,
		'progression-lab/apply',
		p_request_id,
		item_payload->>'item_id',
		greatest(0, coalesce(nullif(item_payload->>'quantity', '')::integer, 0)),
		jsonb_build_object(
			'progression_lab', true,
			'request_hash', normalized_request_hash,
			'source_save_id', p_save_payload->>'id',
			'profile_id', p_profile_id,
			'milestone_id', p_milestone_id
		),
		now()
	from jsonb_array_elements(inventory_payload) as item(item_payload)
	where coalesce(item_payload->>'item_id', '') <> ''
		and greatest(0, coalesce(nullif(item_payload->>'quantity', '')::integer, 0)) > 0;

	insert into public.player_potion_slots (
		player_id,
		slot_index,
		potion_id,
		behavior,
		updated_at
	)
	select
		player_row.id,
		1,
		nullif(slot_payload->>'potion_id', ''),
		coalesce(slot_payload->'behavior', default_potion_behavior),
		now()
	from jsonb_array_elements(potion_slots_payload) as slot(slot_payload)
	where coalesce(nullif(slot_payload->>'slot_index', '')::integer, 1) = 1
	limit 1
	on conflict (player_id, slot_index) do update
	set potion_id = excluded.potion_id,
		behavior = excluded.behavior,
		updated_at = excluded.updated_at;

	insert into public.player_potion_slots (
		player_id,
		slot_index,
		potion_id,
		behavior,
		updated_at
	)
	select player_row.id, 1, null, default_potion_behavior, now()
	where not exists (
		select 1
		from public.player_potion_slots
		where player_id = player_row.id
			and slot_index = 1
	);

	insert into public.player_spell_behaviors (
		player_id,
		spell_id,
		behavior,
		updated_at
	)
	select
		player_row.id,
		spell_entry.key,
		spell_entry.value,
		now()
	from jsonb_each(spell_behaviors_payload) as spell_entry(key, value)
	where spell_entry.key <> ''
	on conflict (player_id, spell_id) do update
	set behavior = excluded.behavior,
		updated_at = excluded.updated_at;

	update public.idempotency_keys
	set request_hash = normalized_request_hash,
		status = 'completed',
		response_payload = apply_response_payload,
		completed_at = coalesce(completed_at, now())
	where player_id = player_row.id
		and endpoint = 'progression-lab/apply'
		and request_id = p_request_id;

	return apply_response_payload;
end;
$$;

revoke all on function public.apply_progression_lab_save(uuid, uuid, text, text, jsonb) from public;
revoke all on function public.apply_progression_lab_save(uuid, uuid, text, text, jsonb) from service_role;
revoke all on function public.apply_progression_lab_save(uuid, uuid, text, text, text, jsonb) from public;
grant execute on function public.apply_progression_lab_save(uuid, uuid, text, text, text, jsonb) to service_role;
