-- Account reset request hash v1.
-- Adds a save-scoped transactional reset RPC that requires request_hash,
-- preserves account-social state, and moves Track 16/Arena/Modes cleanup
-- inside the same database transaction.

create or replace function public.reset_player_save_v1(
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
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	save_row public.game_saves%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	build_row public.builds%rowtype;
	reservation_payload jsonb;
	reset_payload jsonb;
	default_potion_behavior jsonb := '{"enabled": true, "hp": {"mode": "below", "percent": 40}, "mana": {"mode": "ignore", "percent": 0}}'::jsonb;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	if p_request_payload is null or jsonb_typeof(p_request_payload) <> 'object' then
		raise exception 'INVALID_REQUEST_PAYLOAD' using errcode = 'P0001';
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

	select *
	into player_row
	from public.players
	where id = save_row.legacy_player_id
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	reservation_payload := public.reserve_idempotency(
		player_row.id,
		'account/saves/reset',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	delete from public.arena_attempt_steps
	where attempt_id in (
		select id
		from public.arena_attempts
		where game_save_id = save_row.id
	);

	delete from public.arena_attempts
	where game_save_id = save_row.id;

	delete from public.arena_first_clears
	where game_save_id = save_row.id;

	delete from public.arena_progress
	where game_save_id = save_row.id;

	delete from public.mode_reward_claims
	where game_save_id = save_row.id;

	delete from public.mode_sessions
	where game_save_id = save_row.id;

	delete from public.mode_progress
	where game_save_id = save_row.id;

	delete from public.ranking
	where player_id = player_row.id;

	update public.telemetry_events
	set player_id = null
	where player_id = player_row.id;

	delete from public.battles
	where attacker_id = player_row.id;

	delete from public.construction_jobs
	where player_id = player_row.id;

	delete from public.base_structures
	where player_id = player_row.id;

	delete from public.battle_pass_progress
	where player_id = player_row.id;

	delete from public.reward_claims
	where player_id = player_row.id;

	delete from public.alpha_purchases
	where player_id = player_row.id;

	delete from public.player_consumables
	where player_id = player_row.id;

	delete from public.player_spell_behaviors
	where player_id = player_row.id;

	delete from public.player_potion_slots
	where player_id = player_row.id;

	delete from public.item_transactions
	where player_id = player_row.id;

	delete from public.resource_transactions
	where player_id = player_row.id;

	delete from public.idempotency_keys
	where player_id = player_row.id
		and endpoint <> 'account/guest'
		and not (
			endpoint = 'account/saves/reset'
			and request_id = p_request_id
		);

	delete from public.resources
	where player_id = player_row.id;

	delete from public.builds
	where player_id = player_row.id;

	update public.players
	set level = 1,
		xp = 0,
		power = 0,
		updated_at = now()
	where id = player_row.id
	returning * into player_row;

	insert into public.resources (player_id)
	values (player_row.id)
	returning * into resource_row;

	insert into public.builds (
		player_id,
		weapon_type,
		weapon_quality,
		weapon_level,
		spell_slots,
		spells_unlocked,
		pet_id,
		pet_level,
		passive_id,
		passive_level
	)
	values (
		player_row.id,
		'varinha_cinzas',
		'starter',
		1,
		'["sussurro_medo"]'::jsonb,
		'["sussurro_medo"]'::jsonb,
		'corvo_pressagio',
		1,
		'doutrina_pavor',
		1
	)
	returning * into build_row;

	insert into public.base_structures (player_id, structure_id)
	select player_row.id, structure_ids.structure_id
	from (
		values
			('altar_das_almas'),
			('nucleo_energia'),
			('pocos_sangue'),
			('minas_cristal'),
			('estrutura_stats'),
			('ossario')
	) as structure_ids(structure_id);

	insert into public.player_potion_slots (
		player_id,
		slot_index,
		potion_id,
		behavior,
		updated_at
	)
	values (
		player_row.id,
		1,
		null,
		default_potion_behavior,
		now()
	);

	update public.game_saves
	set snapshot = jsonb_build_object(
			'legacy_player_id', player_row.id,
			'player_level', player_row.level,
			'player_xp', player_row.xp,
			'player_power', player_row.power,
			'reset_request_id', p_request_id,
			'reset_request_hash', normalized_hash,
			'reset_at', now()
		),
		updated_at = now()
	where id = save_row.id
	returning * into save_row;

	reset_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'account_save_reset_response_v1',
		'endpoint', 'account/saves/reset',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'reset', jsonb_build_object(
			'save_type', player_row.save_type,
			'player_id', player_row.id,
			'game_save_id', save_row.id,
			'request_id', p_request_id,
			'request_hash', normalized_hash,
			'preserved_account_social', true
		),
		'player', jsonb_build_object(
			'id', player_row.id,
			'username', player_row.username,
			'account_type', player_row.account_type,
			'save_type', player_row.save_type,
			'level', player_row.level,
			'xp', player_row.xp,
			'power', player_row.power,
			'created_at', player_row.created_at,
			'updated_at', player_row.updated_at
		),
		'resources', jsonb_build_object(
			'player_id', resource_row.player_id,
			'almas', resource_row.almas,
			'energia', resource_row.energia,
			'sangue', resource_row.sangue,
			'cristais', resource_row.cristais,
			'ossos', resource_row.ossos,
			'po_osso', resource_row.po_osso,
			'diamante', resource_row.diamante,
			'updated_at', resource_row.updated_at
		),
		'build', jsonb_build_object(
			'player_id', build_row.player_id,
			'weapon_type', build_row.weapon_type,
			'weapon_quality', build_row.weapon_quality,
			'weapon_level', build_row.weapon_level,
			'spell_slots', build_row.spell_slots,
			'spells_unlocked', build_row.spells_unlocked,
			'pet_id', build_row.pet_id,
			'pet_level', build_row.pet_level,
			'passive_id', build_row.passive_id,
			'passive_level', build_row.passive_level,
			'updated_at', build_row.updated_at
		),
		'last_battle_id', null
	);

	update public.idempotency_keys
	set response_payload = reset_payload
	where player_id = player_row.id
		and endpoint = 'account/guest';

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (
		player_row.id,
		'account/saves/reset',
		p_request_id,
		jsonb_build_object(
			'reset', true,
			'save_type', player_row.save_type,
			'game_save_id', save_row.id,
			'request_hash', normalized_hash
		)
	);

	perform public.complete_idempotency(
		player_row.id,
		'account/saves/reset',
		p_request_id,
		reset_payload,
		normalized_hash
	);

	return reset_payload;
end;
$$;

revoke all on function public.reset_player_save_v1(uuid, uuid, text, jsonb) from public;
revoke all on function public.reset_player_save(uuid, uuid, text) from service_role;
grant execute on function public.reset_player_save_v1(uuid, uuid, text, jsonb) to service_role;
