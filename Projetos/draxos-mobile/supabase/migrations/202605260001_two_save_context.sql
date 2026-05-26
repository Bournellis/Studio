-- DraxosMobile Track 03 P03B - Two-save server context.
-- Local-first foundation for account save_type: normal and progression_lab.

alter table public.players
	add column if not exists save_type text not null default 'normal'
	check (save_type in ('normal', 'progression_lab'));

do $$
begin
	alter table public.players drop constraint if exists players_auth_user_id_key;
exception
	when undefined_object then null;
end $$;

create unique index if not exists players_auth_user_save_type_uidx
	on public.players (auth_user_id, save_type);

create index if not exists players_auth_user_save_type_idx
	on public.players (auth_user_id, save_type);

drop function if exists public.create_guest_account(uuid, text, uuid, text);

create or replace function public.create_guest_account(
	p_auth_user_id uuid,
	p_invite_code text,
	p_request_id uuid,
	p_device_label text default null,
	p_save_type text default 'normal'
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_invite text := upper(trim(coalesce(p_invite_code, '')));
	normalized_save_type text := lower(trim(coalesce(p_save_type, 'normal')));
	existing_player public.players%rowtype;
	existing_payload jsonb;
	invite_row public.invite_codes%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	build_row public.builds%rowtype;
	auth_has_existing_player boolean := false;
	username_suffix text;
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
			and ik.endpoint = 'account/guest'
			and ik.request_id = p_request_id;

		if existing_payload is not null then
			return existing_payload;
		end if;

		raise exception 'ACCOUNT_ALREADY_CREATED' using errcode = 'P0001';
	end if;

	if auth_has_existing_player is not true then
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
	end if;

	username_suffix := case
		when normalized_save_type = 'progression_lab' then '_lab'
		else ''
	end;

	insert into public.players (auth_user_id, username, account_type, save_type, level, xp, power)
	values (
		p_auth_user_id,
		'guest_' || replace(left(p_auth_user_id::text, 8), '-', '') || username_suffix,
		'guest',
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
	values (player_row.id, 'account/guest', p_request_id, response_payload);

	return response_payload;
exception
	when unique_violation then
		raise exception 'ACCOUNT_CREATE_FAILED' using errcode = 'P0001';
end;
$$;

revoke all on function public.create_guest_account(uuid, text, uuid, text, text) from public;
grant execute on function public.create_guest_account(uuid, text, uuid, text, text) to service_role;

drop function if exists public.request_mvp_battle(uuid, uuid, text);

create or replace function public.request_mvp_battle(
	p_auth_user_id uuid,
	p_request_id uuid,
	p_mode text default 'MVP_ONLY',
	p_save_type text default 'normal'
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_mode text := upper(trim(coalesce(p_mode, '')));
	normalized_save_type text := lower(trim(coalesce(p_save_type, 'normal')));
	player_row public.players%rowtype;
	bot_row public.bot_builds%rowtype;
	existing_payload jsonb;
	battle_id uuid := gen_random_uuid();
	seed_text text;
	events_payload jsonb;
	result_payload jsonb;
	reward_payload jsonb;
	battle_log_payload jsonb;
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

	if normalized_mode <> 'MVP_ONLY' then
		raise exception 'UNSUPPORTED_MODE' using errcode = 'P0001';
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
		and ik.endpoint = 'battle/request'
		and ik.request_id = p_request_id;

	if existing_payload is not null then
		return existing_payload;
	end if;

	select *
	into bot_row
	from public.bot_builds
	where id = 'mvp_training_bot'
		and is_active = true;

	if bot_row.id is null then
		raise exception 'SIMULATION_FAILED' using errcode = 'P0001';
	end if;

	seed_text := 'mvp_training:' || player_row.id::text || ':' || p_request_id::text;
	events_payload := jsonb_build_array(
		jsonb_build_object('t', 0.0, 'seq', 1, 'type', 'battle_start', 'source', 'system', 'target', 'none'),
		jsonb_build_object('t', 0.5, 'seq', 2, 'type', 'weapon_attack', 'source', 'player', 'target', 'opponent', 'damage', 15, 'damage_type', 'arcano', 'weapon_id', 'varinha_cinzas', 'hp_after', 85),
		jsonb_build_object('t', 0.9, 'seq', 3, 'type', 'weapon_attack', 'source', 'opponent', 'target', 'player', 'damage', 8, 'damage_type', 'arcano', 'weapon_id', 'varinha_cinzas', 'hp_after', 92),
		jsonb_build_object('t', 1.2, 'seq', 4, 'type', 'spell_cast', 'source', 'player', 'target', 'opponent', 'spell_id', 'sussurro_medo', 'damage', 0, 'damage_type', 'none', 'hp_after', 60),
		jsonb_build_object('t', 2.1, 'seq', 5, 'type', 'weapon_attack', 'source', 'player', 'target', 'opponent', 'damage', 15, 'damage_type', 'arcano', 'weapon_id', 'varinha_cinzas', 'hp_after', 45),
		jsonb_build_object('t', 3.4, 'seq', 6, 'type', 'spell_cast', 'source', 'player', 'target', 'opponent', 'spell_id', 'sussurro_medo', 'damage', 0, 'damage_type', 'none', 'hp_after', 0),
		jsonb_build_object('t', 3.9, 'seq', 7, 'type', 'reward_preview', 'source', 'system', 'target', 'player', 'reward_type', 'MVP_ONLY'),
		jsonb_build_object('t', 4.0, 'seq', 8, 'type', 'battle_result', 'source', 'system', 'target', 'none', 'winner', 'player', 'reason', 'opponent_defeated')
	);
	result_payload := jsonb_build_object('winner', 'player', 'reason', 'opponent_defeated');
	reward_payload := jsonb_build_object(
		'type', 'MVP_ONLY',
		'reward_id', 'mvp_training_reward',
		'resources', jsonb_build_object('xp', 5, 'ossos', 1)
	);

	battle_log_payload := jsonb_build_object(
		'schema_version', 'battle_log_v1',
		'battle_id', battle_id,
		'seed', seed_text,
		'mode', 'MVP_ONLY',
		'duration', 4.2,
		'participants', jsonb_build_object(
			'player', jsonb_build_object('id', player_row.id, 'display_name', 'Draxos'),
			'opponent', jsonb_build_object('id', bot_row.id, 'display_name', 'Bot de Treino', 'is_bot', true)
		),
		'result', result_payload,
		'events', events_payload
	);

	response_payload := jsonb_build_object(
		'ok', true,
		'battle_log', battle_log_payload,
		'rewards', reward_payload
	);

	insert into public.battles (
		id, attacker_id, defender_id, defender_is_bot, schema_version, seed,
		result, event_log, reward_payload, reward_applied, request_id
	)
	values (
		battle_id, player_row.id, bot_row.id, true, 'battle_log_v1', seed_text,
		result_payload, events_payload, reward_payload, true, p_request_id
	);

	update public.players
	set xp = xp + 5,
		updated_at = now()
	where id = player_row.id;

	update public.resources
	set ossos = ossos + 1,
		updated_at = now()
	where player_id = player_row.id;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (player_row.id, 'battle/request', p_request_id, jsonb_build_object('xp', 5, 'ossos', 1));

	insert into public.idempotency_keys (player_id, endpoint, request_id, response_payload)
	values (player_row.id, 'battle/request', p_request_id, response_payload);

	return response_payload;
exception
	when unique_violation then
		select ik.response_payload
		into existing_payload
		from public.idempotency_keys as ik
		where ik.player_id = player_row.id
			and ik.endpoint = 'battle/request'
			and ik.request_id = p_request_id;

		if existing_payload is not null then
			return existing_payload;
		end if;

		raise exception 'SIMULATION_FAILED' using errcode = 'P0001';
end;
$$;

revoke all on function public.request_mvp_battle(uuid, uuid, text, text) from public;
grant execute on function public.request_mvp_battle(uuid, uuid, text, text) to service_role;
