-- DraxosMobile Track 03 P14 - Email/password alpha accounts.
-- Keeps guest/dev account creation intact while adding the real Internal Alpha path.

create or replace function public.create_alpha_account(
	p_auth_user_id uuid,
	p_invite_code text,
	p_request_id uuid,
	p_device_label text default null,
	p_save_type text default 'normal',
	p_username text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_invite text := upper(trim(coalesce(p_invite_code, '')));
	normalized_save_type text := lower(trim(coalesce(p_save_type, 'normal')));
	requested_username text := lower(trim(coalesce(p_username, '')));
	existing_player public.players%rowtype;
	existing_payload jsonb;
	invite_row public.invite_codes%rowtype;
	normal_player public.players%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	build_row public.builds%rowtype;
	auth_has_existing_player boolean := false;
	base_username text;
	final_username text;
	response_payload jsonb;
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

	if requested_username <> '' and requested_username !~ '^[a-z0-9_]{3,24}$' then
		raise exception 'INVALID_USERNAME' using errcode = 'P0001';
	end if;

	if not exists (
		select 1
		from auth.users
		where id = p_auth_user_id
			and coalesce(is_anonymous, false) is not true
	) then
		raise exception 'AUTH_REQUIRES_EMAIL' using errcode = 'P0001';
	end if;

	select *
	into existing_player
	from public.players
	where auth_user_id = p_auth_user_id
		and save_type = normalized_save_type;

	select exists (
		select 1
		from public.players
		where auth_user_id = p_auth_user_id
	)
	into auth_has_existing_player;

	if existing_player.id is not null then
		select ik.response_payload
		into existing_payload
		from public.idempotency_keys as ik
		where ik.player_id = existing_player.id
			and ik.endpoint = 'account/bootstrap'
			and ik.request_id = p_request_id;

		if existing_payload is not null then
			return existing_payload;
		end if;

		raise exception 'ACCOUNT_ALREADY_CREATED' using errcode = 'P0001';
	end if;

	if auth_has_existing_player is not true then
		if normalized_invite = '' then
			raise exception 'INVALID_INVITE' using errcode = 'P0001';
		end if;

		if requested_username = '' then
			raise exception 'INVALID_USERNAME' using errcode = 'P0001';
		end if;

		if exists (
			select 1
			from public.players
			where username = requested_username
		) then
			raise exception 'USERNAME_TAKEN' using errcode = 'P0001';
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

		base_username := requested_username;
	else
		select *
		into normal_player
		from public.players
		where auth_user_id = p_auth_user_id
			and save_type = 'normal';

		base_username := coalesce(
			nullif(requested_username, ''),
			nullif(normal_player.username, ''),
			'player_' || replace(left(p_auth_user_id::text, 8), '-', '')
		);
	end if;

	final_username := case
		when normalized_save_type = 'progression_lab' and base_username not like '%\_lab' escape '\' then base_username || '_lab'
		else base_username
	end;

	if exists (
		select 1
		from public.players
		where username = final_username
	) then
		raise exception 'USERNAME_TAKEN' using errcode = 'P0001';
	end if;

	insert into public.players (auth_user_id, username, account_type, save_type, level, xp, power)
	values (
		p_auth_user_id,
		final_username,
		'registered',
		normalized_save_type,
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

	if auth_has_existing_player is not true then
		update public.invite_codes
		set used_count = used_count + 1
		where code = invite_row.code;
	end if;

	response_payload := jsonb_build_object(
		'ok', true,
		'player', jsonb_build_object(
			'id', player_row.id,
			'username', player_row.username,
			'account_type', player_row.account_type,
			'save_type', player_row.save_type,
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
	values (player_row.id, 'account/bootstrap', p_request_id, response_payload);

	return response_payload;
exception
	when unique_violation then
		raise exception 'USERNAME_TAKEN' using errcode = 'P0001';
end;
$$;

revoke all on function public.create_alpha_account(uuid, text, uuid, text, text, text) from public;
grant execute on function public.create_alpha_account(uuid, text, uuid, text, text, text) to service_role;
