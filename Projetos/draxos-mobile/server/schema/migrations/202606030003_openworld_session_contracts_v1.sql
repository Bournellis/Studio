-- Openworld Foundation Pass - session completion contract hardening.
-- Keeps Bosque reward values unchanged while making cap-zero/idempotent
-- completion and global XP -> level consistency explicit.

create or replace function public.mode_session_complete_v1(
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
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	session_row public.mode_sessions%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	reward_payload_value jsonb;
	resource_delta_value jsonb;
	deposited_items_payload jsonb;
	item_record record;
	item_quantity numeric;
	total_deposited numeric := 0;
	preview_ossos numeric := 0;
	preview_po_osso numeric := 0;
	payload_session_id uuid;
	payload_mode_id text := nullif(trim(coalesce(p_request_payload->>'mode_id', '')), '');
	payload_slice_id text := nullif(trim(coalesce(p_request_payload->>'slice_id', '')), '');
	payload_ruleset_id text := nullif(trim(coalesce(p_request_payload->>'ruleset_id', '')), '');
	payload_ruleset_version integer := coalesce((p_request_payload->>'ruleset_version')::integer, 0);
	payload_expected_revision integer := coalesce((p_request_payload->>'expected_revision')::integer, -1);
	payload_session_seconds integer;
	payload_activity_score integer;
	plausible_score integer;
	base_energia integer;
	base_ossos integer;
	base_xp integer;
	daily_energia numeric := 0;
	daily_ossos numeric := 0;
	daily_xp numeric := 0;
	reward_energia integer := 0;
	reward_ossos integer := 0;
	reward_xp integer := 0;
	reward_period_key text := to_char(now() at time zone 'UTC', 'YYYY-MM-DD');
	reward_status text := 'applied';
	cap_zero boolean := false;
	reward_message text := 'Recompensa do Bosque aplicada.';
	reward_limits_value jsonb;
	scope_id text;
begin
	if p_game_save_id is null or p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_request_hash, '')), '') is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;
	if payload_mode_id <> 'openworld' or payload_slice_id <> 'forest' then
		raise exception 'INVALID_MODE' using errcode = 'P0001';
	end if;
	if payload_ruleset_id <> 'openworld_forest_ruleset_v1' or payload_ruleset_version <> 1 then
		raise exception 'INVALID_RULESET' using errcode = 'P0001';
	end if;
	begin
		payload_session_id := (p_request_payload->>'session_id')::uuid;
	exception when others then
		raise exception 'INVALID_RESULT' using errcode = 'P0001';
	end;

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
	if save_row.save_type = 'progression_lab' then
		raise exception 'MODE_REWARD_BLOCKED_FOR_LAB' using errcode = 'P0001';
	end if;

	scope_id := 'mode:' || payload_mode_id || ':' || save_row.save_type;
	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'modes/session/complete',
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
		and mode_id = payload_mode_id
		and slice_id = payload_slice_id
	for update;
	if session_row.id is null then
		raise exception 'MODE_SESSION_NOT_FOUND' using errcode = 'P0001';
	end if;
	if session_row.status = 'completed' then
		return public.complete_idempotency(
			save_row.legacy_player_id,
			'modes/session/complete',
			p_request_id,
			coalesce(session_row.reward_payload, '{}'::jsonb),
			p_request_hash
		);
	end if;
	if session_row.status <> 'started' then
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if session_row.expires_at <= now() then
		update public.mode_sessions set status = 'expired', updated_at = now() where id = session_row.id;
		raise exception 'MODE_SESSION_NOT_ACTIVE' using errcode = 'P0001';
	end if;
	if payload_expected_revision <> session_row.snapshot_revision then
		raise exception 'MODE_SESSION_REVISION_STALE' using errcode = 'P0001';
	end if;

	deposited_items_payload := coalesce(session_row.snapshot_payload#>'{reward_payload,deposited_items}', session_row.snapshot_payload->'chest', '{}'::jsonb);
	payload_session_seconds := greatest(5, least(1800, coalesce((session_row.snapshot_payload->>'session_seconds')::integer, 5)));
	payload_activity_score := greatest(0, least(500, coalesce((session_row.snapshot_payload->>'activity_score')::integer, 0)));

	for item_record in select * from jsonb_each_text(coalesce(deposited_items_payload, '{}'::jsonb))
	loop
		item_quantity := greatest(0, item_record.value::numeric);
		total_deposited := total_deposited + item_quantity;
		if item_record.key = 'ossos_preview' then
			preview_ossos := preview_ossos + item_quantity;
		elsif item_record.key = 'po_osso_preview' then
			preview_po_osso := preview_po_osso + item_quantity;
		end if;
	end loop;

	select * into player_row from public.players where id = save_row.legacy_player_id for update;
	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;
	select * into resource_row from public.resources where player_id = save_row.legacy_player_id for update;
	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	plausible_score := floor(least(payload_activity_score, total_deposited * 12 + payload_session_seconds / 3.0, 240))::integer;
	base_energia := least(12, floor(plausible_score / 8.0)::integer);
	base_ossos := least(2, floor((preview_ossos + preview_po_osso) / 3.0)::integer);
	base_xp := least(8, floor(plausible_score / 20.0)::integer);

	select
		coalesce(sum(coalesce(nullif(mode_reward_claims.resource_delta->>'energia', '')::numeric, 0)), 0),
		coalesce(sum(coalesce(nullif(mode_reward_claims.resource_delta->>'ossos', '')::numeric, 0)), 0),
		coalesce(sum(mode_reward_claims.xp_delta), 0)
	into daily_energia, daily_ossos, daily_xp
	from public.mode_reward_claims
	where player_id = save_row.legacy_player_id
		and mode_id = payload_mode_id
		and period_key = reward_period_key;

	reward_energia := greatest(0, least(base_energia::numeric, 30 - daily_energia))::integer;
	reward_ossos := greatest(0, least(base_ossos::numeric, 6 - daily_ossos))::integer;
	reward_xp := greatest(0, least(base_xp::numeric, 24 - daily_xp))::integer;
	resource_delta_value := jsonb_build_object('energia', reward_energia, 'ossos', reward_ossos, 'xp', reward_xp);

	if reward_energia = 0 and reward_ossos = 0 and reward_xp = 0 then
		if base_energia > 0 or base_ossos > 0 or base_xp > 0 then
			reward_status := 'cap_zero';
			cap_zero := true;
			reward_message := 'Limite diario UTC do Bosque ja foi usado; sessao concluida sem recompensa.';
		else
			reward_status := 'no_reward';
			reward_message := 'Sessao do Bosque concluida sem itens suficientes para recompensa.';
		end if;
	end if;

	reward_limits_value := jsonb_build_object(
		'daily', jsonb_build_object('energia', 30, 'ossos', 6, 'xp', 24),
		'per_session', jsonb_build_object('energia', 12, 'ossos', 2, 'xp', 8),
		'used_today_before', jsonb_build_object('energia', daily_energia, 'ossos', daily_ossos, 'xp', daily_xp),
		'remaining_before', jsonb_build_object(
			'energia', greatest(0, 30 - daily_energia)::integer,
			'ossos', greatest(0, 6 - daily_ossos)::integer,
			'xp', greatest(0, 24 - daily_xp)::integer
		),
		'applied', resource_delta_value,
		'period_key', reward_period_key,
		'reward_status', reward_status,
		'cap_zero', cap_zero
	);

	update public.resources
	set energia = energia + reward_energia, ossos = ossos + reward_ossos, updated_at = now()
	where player_id = save_row.legacy_player_id
	returning * into resource_row;

	update public.players
	set
		xp = coalesce(xp, 0) + greatest(0, reward_xp),
		level = greatest(
			coalesce(level, 1),
			public.foundation_level_for_xp_v1(coalesce(xp, 0) + greatest(0, reward_xp), 40)
		),
		updated_at = now()
	where id = save_row.legacy_player_id
	returning * into player_row;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (save_row.legacy_player_id, 'mode:openworld:forest', p_request_id, resource_delta_value);

	reward_payload_value := jsonb_build_object(
		'schema_version', 'openworld_reward_bridge_v1',
		'mode_id', payload_mode_id,
		'slice_id', payload_slice_id,
		'ruleset_id', payload_ruleset_id,
		'ruleset_version', payload_ruleset_version,
		'session_id', session_row.id,
		'period_key', reward_period_key,
		'reward_status', reward_status,
		'cap_zero', cap_zero,
		'message', reward_message,
		'activity_score', payload_activity_score,
		'validated_score', plausible_score,
		'resource_delta', resource_delta_value,
		'local_items_accepted', deposited_items_payload,
		'limits', reward_limits_value,
		'source', 'mode:openworld:forest',
		'authority', 'server_snapshot'
	);

	insert into public.mode_reward_claims (
		game_save_id,
		player_id,
		mode_id,
		session_id,
		request_id,
		request_hash,
		period_key,
		reward_payload,
		resource_delta,
		xp_delta
	)
	values (
		save_row.id,
		save_row.legacy_player_id,
		payload_mode_id,
		session_row.id,
		p_request_id,
		p_request_hash,
		reward_period_key,
		reward_payload_value,
		resource_delta_value,
		reward_xp
	);

	update public.mode_sessions
	set
		status = 'completed',
		complete_request_id = p_request_id,
		session_seconds = payload_session_seconds,
		activity_score = payload_activity_score,
		deposited_items = deposited_items_payload,
		result_payload = p_request_payload,
		completed_at = now(),
		updated_at = now()
	where id = session_row.id
	returning * into session_row;

	insert into public.mode_progress as progress_row (
		game_save_id,
		mode_id,
		local_schema_version,
		progress_payload,
		totals_payload,
		last_session_id,
		updated_at
	)
	values (
		save_row.id,
		payload_mode_id,
		'openworld_forest_snapshot_v1',
		jsonb_build_object('last_completed_session_id', session_row.id),
		jsonb_build_object('sessions_started', 1, 'sessions_completed', 1, 'activity_score', payload_activity_score, 'validated_score', plausible_score),
		session_row.id,
		now()
	)
	on conflict (game_save_id, mode_id) do update
	set
		local_schema_version = 'openworld_forest_snapshot_v1',
		progress_payload = jsonb_build_object('last_completed_session_id', session_row.id),
		totals_payload = jsonb_build_object(
			'sessions_started', coalesce(nullif(progress_row.totals_payload->>'sessions_started', '')::integer, 0),
			'sessions_completed', coalesce(nullif(progress_row.totals_payload->>'sessions_completed', '')::integer, 0) + 1,
			'activity_score', coalesce(nullif(progress_row.totals_payload->>'activity_score', '')::integer, 0) + payload_activity_score,
			'validated_score', coalesce(nullif(progress_row.totals_payload->>'validated_score', '')::integer, 0) + plausible_score
		),
		last_session_id = session_row.id,
		updated_at = now();

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'mode_platform_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'mode', jsonb_build_object('mode_id', payload_mode_id, 'slice_id', payload_slice_id, 'ruleset_id', payload_ruleset_id, 'ruleset_version', payload_ruleset_version, 'release_channel', 'internal_alpha'),
		'session', public.openworld_forest_session_payload_v1(session_row),
		'reward', reward_payload_value,
		'reward_status', reward_status,
		'cap_zero', cap_zero,
		'period_key', reward_period_key,
		'message', reward_message,
		'resources', jsonb_build_object('energia', resource_row.energia, 'ossos', resource_row.ossos, 'xp', player_row.xp, 'level', player_row.level),
		'limits', reward_limits_value,
		'server_time', now()
	);

	update public.mode_sessions
	set reward_payload = response_payload
	where id = session_row.id;

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'modes/session/complete',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

revoke all on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.mode_session_complete_v1(uuid, uuid, text, jsonb) to service_role;
