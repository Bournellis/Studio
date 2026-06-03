-- Admin compensation request-hash hardening.
-- Keeps support compensation idempotent across payload retries.

create or replace function public.admin_adjust_resource_balance_v1(
	p_game_save_id uuid,
	p_delta jsonb,
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
	save_row public.game_saves%rowtype;
	before_report jsonb;
	after_report jsonb;
	before_resource jsonb;
	after_resource jsonb;
	existing_audit public.admin_audit_log%rowtype;
	response_payload jsonb;
	delta_payload jsonb := coalesce(p_delta, '{}'::jsonb);
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
	if nullif(trim(coalesce(p_reason, '')), '') is null then
		raise exception 'INVALID_REASON' using errcode = 'P0001';
	end if;
	if jsonb_typeof(delta_payload) <> 'object' then
		raise exception 'INVALID_DELTA' using errcode = 'P0001';
	end if;

	select *
	into existing_audit
	from public.admin_audit_log
	where action = 'admin_adjust_resource_balance_v1'
		and request_id = p_request_id;

	if existing_audit.id is not null then
		if coalesce(existing_audit.metadata->>'request_hash', '') <> p_request_hash then
			raise exception 'IDEMPOTENCY_HASH_MISMATCH' using errcode = 'P0001';
		end if;
		return coalesce(existing_audit.metadata->'response_payload', existing_audit.after_state);
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

	before_report := public.resource_reconciliation_report_v1(p_game_save_id);
	before_resource := coalesce(before_report->'current_balance', '{}'::jsonb);

	update public.resources
	set
		almas = greatest(0, almas + coalesce(nullif(delta_payload->>'almas', '')::numeric, 0)),
		energia = greatest(0, energia + coalesce(nullif(delta_payload->>'energia', '')::numeric, 0)),
		sangue = greatest(0, sangue + coalesce(nullif(delta_payload->>'sangue', '')::numeric, 0)),
		cristais = greatest(0, cristais + coalesce(nullif(delta_payload->>'cristais', '')::numeric, 0)),
		ossos = greatest(0, ossos + coalesce(nullif(delta_payload->>'ossos', '')::numeric, 0)),
		po_osso = greatest(0, po_osso + coalesce(nullif(delta_payload->>'po_osso', '')::numeric, 0)),
		diamante = greatest(0, diamante + coalesce(nullif(delta_payload->>'diamante', '')::integer, 0)),
		updated_at = now()
	where player_id = save_row.legacy_player_id;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (
		save_row.legacy_player_id,
		'admin/adjust_resource_balance_v1',
		p_request_id,
		delta_payload
	);

	after_report := public.resource_reconciliation_report_v1(p_game_save_id);
	after_resource := coalesce(after_report->'current_balance', '{}'::jsonb);

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'admin_adjust_resource_balance_v1',
		'request_id', p_request_id,
		'game_save_id', save_row.id,
		'account_profile_id', save_row.account_profile_id,
		'legacy_player_id', save_row.legacy_player_id,
		'delta', delta_payload,
		'before_report', before_report,
		'after_report', after_report
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
		save_row.id,
		save_row.legacy_player_id,
		'admin_adjust_resource_balance_v1',
		p_reason,
		p_request_id,
		before_resource,
		after_resource,
		jsonb_build_object(
			'request_hash', p_request_hash,
			'delta', delta_payload,
			'response_payload', response_payload
		)
	);

	return response_payload;
end;
$$;

revoke all on function public.admin_adjust_resource_balance_v1(uuid, jsonb, text, uuid, uuid) from public, anon, authenticated, service_role;
revoke all on function public.admin_adjust_resource_balance_v1(uuid, jsonb, text, uuid, text, uuid) from public, anon, authenticated;
grant execute on function public.admin_adjust_resource_balance_v1(uuid, jsonb, text, uuid, text, uuid) to service_role;
