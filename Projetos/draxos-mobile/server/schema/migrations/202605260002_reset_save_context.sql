-- DraxosMobile Track 03 P03C - Reset one save without touching the other.
-- The active save is resolved by auth_user_id + save_type and rebuilt in place.

create or replace function public.reset_player_save(
	p_auth_user_id uuid,
	p_request_id uuid,
	p_save_type text default 'normal'
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_save_type text := lower(trim(coalesce(p_save_type, 'normal')));
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	build_row public.builds%rowtype;
	existing_payload jsonb;
	reset_payload jsonb;
begin
	if p_auth_user_id is null then
		raise exception 'UNAUTHENTICATED' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if normalized_save_type not in ('normal', 'progression_lab') then
		raise exception 'INVALID_SAVE_TYPE' using errcode = 'P0001';
	end if;

	select *
	into player_row
	from public.players
	where auth_user_id = p_auth_user_id
		and save_type = normalized_save_type
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	select ik.response_payload
	into existing_payload
	from public.idempotency_keys as ik
	where ik.player_id = player_row.id
		and ik.endpoint = 'account/saves/reset'
		and ik.request_id = p_request_id;

	if existing_payload is not null then
		return existing_payload;
	end if;

	delete from public.guilds
	where owner_id = player_row.id;

	with removed_memberships as (
		delete from public.guild_members
		where player_id = player_row.id
		returning guild_id
	)
	update public.guilds as guild
	set member_count = greatest(guild.member_count - 1, 0),
		updated_at = now()
	where guild.id in (select guild_id from removed_memberships);

	delete from public.friendships
	where player_id = player_row.id
		or friend_id = player_row.id;

	delete from public.chat_messages
	where sender_id = player_row.id;

	delete from public.guild_contributions
	where player_id = player_row.id;

	delete from public.construction_helps
	where helper_id = player_row.id
		or receiver_id = player_row.id;

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

	delete from public.resource_transactions
	where player_id = player_row.id;

	delete from public.idempotency_keys
	where player_id = player_row.id
		and endpoint <> 'account/guest';

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

	reset_payload := jsonb_build_object(
		'ok', true,
		'reset', jsonb_build_object(
			'save_type', player_row.save_type,
			'player_id', player_row.id,
			'request_id', p_request_id
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
		jsonb_build_object('reset', true, 'save_type', player_row.save_type)
	);

	insert into public.idempotency_keys (player_id, endpoint, request_id, response_payload)
	values (player_row.id, 'account/saves/reset', p_request_id, reset_payload)
	on conflict (player_id, endpoint, request_id) do update
	set response_payload = excluded.response_payload;

	return reset_payload;
end;
$$;

revoke all on function public.reset_player_save(uuid, uuid, text) from public;
grant execute on function public.reset_player_save(uuid, uuid, text) to service_role;
