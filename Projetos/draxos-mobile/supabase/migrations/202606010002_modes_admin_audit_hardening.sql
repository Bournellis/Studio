-- Modes admin audit hardening.
-- Keeps /modes/admin mutations behind service-role RPCs with admin_audit_log.

create or replace function public.admin_set_mode_status_v1(
	p_mode_id text,
	p_status text,
	p_reason text,
	p_request_id uuid,
	p_request_hash text,
	p_actor_auth_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_mode_id text := lower(trim(coalesce(p_mode_id, '')));
	normalized_status text := lower(trim(coalesce(p_status, '')));
	mode_before public.mode_registry%rowtype;
	mode_after public.mode_registry%rowtype;
	existing_audit public.admin_audit_log%rowtype;
	response_payload jsonb;
begin
	if normalized_mode_id = '' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;
	if normalized_status not in ('active', 'dev_only', 'internal_alpha', 'planned_disabled', 'paused', 'retired') then
		raise exception 'INVALID_MODE_STATUS' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_reason, '')), '') is null then
		raise exception 'INVALID_REASON' using errcode = 'P0001';
	end if;

	select *
	into existing_audit
	from public.admin_audit_log
	where action = 'admin_set_mode_status_v1'
		and request_id = p_request_id;

	if existing_audit.id is not null then
		if coalesce(existing_audit.metadata->>'request_hash', '') <> p_request_hash then
			raise exception 'IDEMPOTENCY_HASH_MISMATCH' using errcode = 'P0001';
		end if;
		return coalesce(existing_audit.metadata->'response_payload', existing_audit.after_state);
	end if;

	select *
	into mode_before
	from public.mode_registry
	where mode_id = normalized_mode_id
	for update;

	if mode_before.mode_id is null then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;

	update public.mode_registry
	set
		status = normalized_status,
		updated_at = now()
	where mode_id = normalized_mode_id
	returning * into mode_after;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'admin_set_mode_status_v1',
		'request_id', p_request_id,
		'mode', jsonb_build_object(
			'mode_id', mode_after.mode_id,
			'display_name', mode_after.display_name,
			'status', mode_after.status,
			'release_channel', mode_after.release_channel,
			'default_slice_id', mode_after.default_slice_id,
			'active_ruleset_id', mode_after.active_ruleset_id,
			'active_ruleset_version', mode_after.active_ruleset_version,
			'metadata', mode_after.metadata,
			'updated_at', mode_after.updated_at
		),
		'server_time', now()
	);

	insert into public.admin_audit_log (
		actor_auth_user_id,
		action,
		reason,
		request_id,
		before_state,
		after_state,
		metadata
	)
	values (
		p_actor_auth_user_id,
		'admin_set_mode_status_v1',
		p_reason,
		p_request_id,
		to_jsonb(mode_before),
		to_jsonb(mode_after),
		jsonb_build_object(
			'request_hash', p_request_hash,
			'mode_id', normalized_mode_id,
			'target_status', normalized_status,
			'response_payload', response_payload
		)
	);

	return response_payload;
end;
$$;

create or replace function public.admin_expire_mode_session_v1(
	p_session_id uuid,
	p_reason text,
	p_request_id uuid,
	p_request_hash text,
	p_actor_auth_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	session_before public.mode_sessions%rowtype;
	session_after public.mode_sessions%rowtype;
	save_row public.game_saves%rowtype;
	existing_audit public.admin_audit_log%rowtype;
	response_payload jsonb;
begin
	if p_session_id is null then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_reason, '')), '') is null then
		raise exception 'INVALID_REASON' using errcode = 'P0001';
	end if;

	select *
	into existing_audit
	from public.admin_audit_log
	where action = 'admin_expire_mode_session_v1'
		and request_id = p_request_id;

	if existing_audit.id is not null then
		if coalesce(existing_audit.metadata->>'request_hash', '') <> p_request_hash then
			raise exception 'IDEMPOTENCY_HASH_MISMATCH' using errcode = 'P0001';
		end if;
		return coalesce(existing_audit.metadata->'response_payload', existing_audit.after_state);
	end if;

	select *
	into session_before
	from public.mode_sessions
	where id = p_session_id
	for update;

	if session_before.id is null then
		raise exception 'MODE_SESSION_NOT_FOUND' using errcode = 'P0001';
	end if;
	if session_before.status <> 'started' then
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where id = session_before.game_save_id;

	update public.mode_sessions
	set
		status = 'expired',
		expires_at = now()
	where id = p_session_id
	returning * into session_after;

	response_payload := public.mode_admin_session_response_v1(
		'admin_expire_mode_session_v1',
		p_request_id,
		session_after
	);

	insert into public.admin_audit_log (
		actor_auth_user_id,
		account_profile_id,
		game_save_id,
		player_id,
		action,
		reason,
		request_id,
		before_state,
		after_state,
		metadata
	)
	values (
		p_actor_auth_user_id,
		save_row.account_profile_id,
		session_after.game_save_id,
		save_row.legacy_player_id,
		'admin_expire_mode_session_v1',
		p_reason,
		p_request_id,
		to_jsonb(session_before),
		to_jsonb(session_after),
		jsonb_build_object(
			'request_hash', p_request_hash,
			'session_id', p_session_id,
			'response_payload', response_payload
		)
	);

	return response_payload;
end;
$$;

create or replace function public.admin_invalidate_mode_session_v1(
	p_session_id uuid,
	p_reason text,
	p_request_id uuid,
	p_request_hash text,
	p_actor_auth_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	session_before public.mode_sessions%rowtype;
	session_after public.mode_sessions%rowtype;
	save_row public.game_saves%rowtype;
	existing_audit public.admin_audit_log%rowtype;
	response_payload jsonb;
begin
	if p_session_id is null then
		raise exception 'INVALID_SESSION' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_reason, '')), '') is null then
		raise exception 'INVALID_REASON' using errcode = 'P0001';
	end if;

	select *
	into existing_audit
	from public.admin_audit_log
	where action = 'admin_invalidate_mode_session_v1'
		and request_id = p_request_id;

	if existing_audit.id is not null then
		if coalesce(existing_audit.metadata->>'request_hash', '') <> p_request_hash then
			raise exception 'IDEMPOTENCY_HASH_MISMATCH' using errcode = 'P0001';
		end if;
		return coalesce(existing_audit.metadata->'response_payload', existing_audit.after_state);
	end if;

	select *
	into session_before
	from public.mode_sessions
	where id = p_session_id
	for update;

	if session_before.id is null then
		raise exception 'MODE_SESSION_NOT_FOUND' using errcode = 'P0001';
	end if;
	if session_before.status = 'completed' then
		raise exception 'MODE_SESSION_ALREADY_COMPLETED' using errcode = 'P0001';
	end if;
	if session_before.status = 'invalidated' then
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where id = session_before.game_save_id;

	update public.mode_sessions
	set
		status = 'invalidated',
		invalidated_at = now(),
		invalidated_reason = p_reason
	where id = p_session_id
	returning * into session_after;

	response_payload := public.mode_admin_session_response_v1(
		'admin_invalidate_mode_session_v1',
		p_request_id,
		session_after
	);

	insert into public.admin_audit_log (
		actor_auth_user_id,
		account_profile_id,
		game_save_id,
		player_id,
		action,
		reason,
		request_id,
		before_state,
		after_state,
		metadata
	)
	values (
		p_actor_auth_user_id,
		save_row.account_profile_id,
		session_after.game_save_id,
		save_row.legacy_player_id,
		'admin_invalidate_mode_session_v1',
		p_reason,
		p_request_id,
		to_jsonb(session_before),
		to_jsonb(session_after),
		jsonb_build_object(
			'request_hash', p_request_hash,
			'session_id', p_session_id,
			'response_payload', response_payload
		)
	);

	return response_payload;
end;
$$;

create or replace function public.mode_admin_session_response_v1(
	p_schema_version text,
	p_request_id uuid,
	p_session public.mode_sessions
)
returns jsonb
language sql
stable
set search_path = public, extensions
as $$
	select jsonb_build_object(
		'ok', true,
		'schema_version', p_schema_version,
		'request_id', p_request_id,
		'session', jsonb_build_object(
			'id', (p_session).id,
			'game_save_id', (p_session).game_save_id,
			'mode_id', (p_session).mode_id,
			'slice_id', (p_session).slice_id,
			'ruleset_id', (p_session).ruleset_id,
			'ruleset_version', (p_session).ruleset_version,
			'status', (p_session).status,
			'session_seconds', (p_session).session_seconds,
			'activity_score', (p_session).activity_score,
			'deposited_items', (p_session).deposited_items,
			'result_payload', (p_session).result_payload,
			'reward_payload', (p_session).reward_payload,
			'started_at', (p_session).started_at,
			'completed_at', (p_session).completed_at,
			'expires_at', (p_session).expires_at,
			'abandoned_at', (p_session).abandoned_at,
			'invalidated_at', (p_session).invalidated_at,
			'invalidated_reason', (p_session).invalidated_reason
		),
		'server_time', now()
	);
$$;

revoke all on function public.admin_set_mode_status_v1(text, text, text, uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.admin_set_mode_status_v1(text, text, text, uuid, text, uuid) to service_role;

revoke all on function public.admin_expire_mode_session_v1(uuid, text, uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.admin_expire_mode_session_v1(uuid, text, uuid, text, uuid) to service_role;

revoke all on function public.admin_invalidate_mode_session_v1(uuid, text, uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.admin_invalidate_mode_session_v1(uuid, text, uuid, text, uuid) to service_role;

revoke all on function public.mode_admin_session_response_v1(text, uuid, public.mode_sessions) from public, anon, authenticated;
grant execute on function public.mode_admin_session_response_v1(text, uuid, public.mode_sessions) to service_role;
