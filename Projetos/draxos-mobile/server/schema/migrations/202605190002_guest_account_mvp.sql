-- DraxosMobile Track 00 P05 - Guest account MVP.
-- Account creation remains server-authoritative through Edge Functions.

insert into public.invite_codes (code, max_uses, used_count, expires_at, is_active)
values ('ALPHA-TEST', 500, 0, null, true)
on conflict (code) do update set
	max_uses = excluded.max_uses,
	expires_at = excluded.expires_at,
	is_active = excluded.is_active;

create or replace function public.create_guest_account(
	p_auth_user_id uuid,
	p_invite_code text,
	p_request_id uuid,
	p_device_label text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_invite text := upper(trim(coalesce(p_invite_code, '')));
	existing_player public.players%rowtype;
	existing_payload jsonb;
	invite_row public.invite_codes%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	build_row public.builds%rowtype;
	response_payload jsonb;
begin
	if p_auth_user_id is null then
		raise exception 'UNAUTHENTICATED' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if not exists (
		select 1
		from auth.users
		where id = p_auth_user_id
			and is_anonymous = true
	) then
		raise exception 'UNAUTHENTICATED' using errcode = 'P0001';
	end if;

	select *
	into existing_player
	from public.players
	where auth_user_id = p_auth_user_id;

	if existing_player.id is not null then
		select ik.response_payload
		into existing_payload
		from public.idempotency_keys as ik
		where ik.player_id = existing_player.id
			and ik.endpoint = 'account/guest'
			and ik.request_id = p_request_id;

		if existing_payload is not null then
			return existing_payload;
		end if;

		raise exception 'ACCOUNT_ALREADY_CREATED' using errcode = 'P0001';
	end if;

	select *
	into invite_row
	from public.invite_codes
	where code = normalized_invite
	for update;

	if invite_row.code is null
		or invite_row.is_active is not true
		or (invite_row.expires_at is not null and invite_row.expires_at <= now()) then
		raise exception 'INVALID_INVITE' using errcode = 'P0001';
	end if;

	if invite_row.used_count >= invite_row.max_uses then
		raise exception 'INVITE_EXHAUSTED' using errcode = 'P0001';
	end if;

	insert into public.players (auth_user_id, username, account_type, level, xp, power)
	values (
		p_auth_user_id,
		'guest_' || replace(left(p_auth_user_id::text, 8), '-', ''),
		'guest',
		1,
		0,
		0
	)
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

	update public.invite_codes
	set used_count = used_count + 1
	where code = invite_row.code;

	response_payload := jsonb_build_object(
		'ok', true,
		'player', jsonb_build_object(
			'id', player_row.id,
			'username', player_row.username,
			'account_type', player_row.account_type,
			'level', player_row.level,
			'xp', player_row.xp,
			'power', player_row.power
		),
		'resources', jsonb_build_object(
			'almas', resource_row.almas,
			'energia', resource_row.energia,
			'sangue', resource_row.sangue,
			'cristais', resource_row.cristais,
			'ossos', resource_row.ossos,
			'diamante', resource_row.diamante
		),
		'build', jsonb_build_object(
			'weapon_type', build_row.weapon_type,
			'weapon_quality', build_row.weapon_quality,
			'weapon_level', build_row.weapon_level,
			'spell_slots', build_row.spell_slots,
			'spells_unlocked', build_row.spells_unlocked,
			'pet_id', build_row.pet_id,
			'pet_level', build_row.pet_level,
			'passive_id', build_row.passive_id,
			'passive_level', build_row.passive_level
		)
	);

	insert into public.idempotency_keys (player_id, endpoint, request_id, response_payload)
	values (player_row.id, 'account/guest', p_request_id, response_payload);

	return response_payload;
exception
	when unique_violation then
		raise exception 'ACCOUNT_CREATE_FAILED' using errcode = 'P0001';
end;
$$;

revoke all on function public.create_guest_account(uuid, text, uuid, text) from public;
grant execute on function public.create_guest_account(uuid, text, uuid, text) to service_role;
