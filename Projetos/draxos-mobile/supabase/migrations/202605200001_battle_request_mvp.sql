-- DraxosMobile Track 00 P07 - Battle request MVP.
-- Battle outcome and MVP reward are server-authoritative and idempotent.

create or replace function public.request_mvp_battle(
	p_auth_user_id uuid,
	p_request_id uuid,
	p_mode text default 'MVP_ONLY'
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_mode text := upper(trim(coalesce(p_mode, '')));
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

	if normalized_mode <> 'MVP_ONLY' then
		raise exception 'UNSUPPORTED_MODE' using errcode = 'P0001';
	end if;

	select *
	into player_row
	from public.players
	where auth_user_id = p_auth_user_id
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
	result_payload := jsonb_build_object(
		'winner', 'player',
		'reason', 'opponent_defeated'
	);
	reward_payload := jsonb_build_object(
		'type', 'MVP_ONLY',
		'reward_id', 'mvp_training_reward',
		'resources', jsonb_build_object(
			'xp', 5,
			'ossos', 1
		)
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
		id,
		attacker_id,
		defender_id,
		defender_is_bot,
		schema_version,
		seed,
		result,
		event_log,
		reward_payload,
		reward_applied,
		request_id
	)
	values (
		battle_id,
		player_row.id,
		bot_row.id,
		true,
		'battle_log_v1',
		seed_text,
		result_payload,
		events_payload,
		reward_payload,
		true,
		p_request_id
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
	values (
		player_row.id,
		'battle/request',
		p_request_id,
		jsonb_build_object('xp', 5, 'ossos', 1)
	);

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

revoke all on function public.request_mvp_battle(uuid, uuid, text) from public;
grant execute on function public.request_mvp_battle(uuid, uuid, text) to service_role;
