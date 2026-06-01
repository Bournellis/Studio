-- Foundation Hardening V2: make player-driven mode abandon transactional and idempotent.

create or replace function public.mode_session_abandon_v1(
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
	session_row public.mode_sessions%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := coalesce(nullif(trim(coalesce(p_request_payload->>'slice_id', '')), ''), 'forest');
	payload_reason text := nullif(trim(coalesce(p_request_payload->>'reason', '')), '');
	scope_id text;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	if coalesce(payload_mode_id, '') <> 'openworld' or payload_slice_id <> 'forest' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;

	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
	end;

	if payload_session_id is null then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
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

	scope_id := 'mode:openworld:' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'modes/session/abandon',
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

	update public.mode_sessions
	set
		status = 'abandoned',
		abandoned_at = now(),
		result_payload = jsonb_build_object(
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'mode_id', 'openworld',
			'slice_id', 'forest',
			'session_id', payload_session_id,
			'abandon_reason', coalesce(payload_reason, '')
		),
		updated_at = now()
	where id = session_row.id
	returning * into session_row;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode', jsonb_build_object(
			'mode_id', session_row.mode_id,
			'slice_id', session_row.slice_id,
			'ruleset_id', session_row.ruleset_id,
			'ruleset_version', session_row.ruleset_version,
			'release_channel', 'internal_alpha'
		),
		'session', jsonb_build_object(
			'id', session_row.id,
			'mode_id', session_row.mode_id,
			'slice_id', session_row.slice_id,
			'ruleset_id', session_row.ruleset_id,
			'ruleset_version', session_row.ruleset_version,
			'status', session_row.status,
			'session_seconds', session_row.session_seconds,
			'activity_score', session_row.activity_score,
			'deposited_items', coalesce(session_row.deposited_items, '{}'::jsonb),
			'result_payload', coalesce(session_row.result_payload, '{}'::jsonb),
			'reward_payload', coalesce(session_row.reward_payload, '{}'::jsonb),
			'started_at', session_row.started_at,
			'completed_at', session_row.completed_at,
			'expires_at', session_row.expires_at,
			'abandoned_at', session_row.abandoned_at,
			'invalidated_at', session_row.invalidated_at,
			'invalidated_reason', coalesce(session_row.invalidated_reason, '')
		),
		'server_time', now()
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/abandon',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

revoke all on function public.mode_session_abandon_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_abandon_v1(uuid, uuid, text, jsonb) to service_role;
