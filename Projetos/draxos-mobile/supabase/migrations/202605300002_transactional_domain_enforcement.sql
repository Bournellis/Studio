-- DraxosMobile Foundation Expansion Readiness - transactional domain enforcement.
-- Moves the first real Base mutations from reserved v1 slots to atomic RPC effects.

create or replace function public.complete_due_base_jobs_v1(
	p_player_id uuid,
	p_now timestamptz default now()
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	completed_payload jsonb;
begin
	if p_player_id is null then
		raise exception 'INVALID_PLAYER_ID' using errcode = 'P0001';
	end if;

	with due_jobs as (
		update public.construction_jobs
		set
			status = 'completed',
			completed_at = p_now,
			updated_at = p_now
		where player_id = p_player_id
			and status = 'active'
			and completes_at <= p_now
		returning id, structure_id, target_level, ruleset_id, ruleset_version
	),
	applied_structures as (
		update public.base_structures as structure
		set
			level = due_jobs.target_level,
			updated_at = p_now
		from due_jobs
		where structure.player_id = p_player_id
			and structure.structure_id = due_jobs.structure_id
		returning
			due_jobs.id,
			due_jobs.structure_id,
			due_jobs.target_level,
			due_jobs.ruleset_id,
			due_jobs.ruleset_version
	)
	select coalesce(
		jsonb_agg(
			jsonb_build_object(
				'job_id', id,
				'structure_id', structure_id,
				'target_level', target_level,
				'ruleset_id', ruleset_id,
				'ruleset_version', ruleset_version
			)
			order by structure_id
		),
		'[]'::jsonb
	)
	into completed_payload
	from applied_structures;

	return completed_payload;
end;
$$;

create or replace function public.collect_base_v1(
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
	ruleset_row public.ruleset_registry%rowtype;
	resource_before public.resources%rowtype;
	resource_after public.resources%rowtype;
	reservation_payload jsonb;
	completed_jobs_payload jsonb;
	response_payload jsonb;
	collected_payload jsonb;
	now_ts timestamptz := now();
	delta_almas numeric := 0;
	delta_energia numeric := 0;
	delta_sangue numeric := 0;
	delta_cristais numeric := 0;
	delta_ossos numeric := 0;
	has_delta boolean := false;
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
	into ruleset_row
	from public.ruleset_registry
	where ruleset_id = save_row.ruleset_id
		and ruleset_version = save_row.ruleset_version;

	if ruleset_row.ruleset_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'base/collect',
		p_request_id,
		p_request_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	completed_jobs_payload := public.complete_due_base_jobs_v1(save_row.legacy_player_id, now_ts);

	select *
	into resource_before
	from public.resources
	where player_id = save_row.legacy_player_id
	for update;

	if resource_before.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	with producers(structure_id, resource_key, daily_at_level_40) as (
		values
			('altar_das_almas', 'almas', 10.0),
			('nucleo_energia', 'energia', 80.0),
			('pocos_sangue', 'sangue', 8.0),
			('minas_cristal', 'cristais', 5.0),
			('ossario', 'ossos', 200.0)
	),
	collectable as (
		select
			producers.resource_key,
			case
				when producers.resource_key = 'ossos' then floor(
					least(
						greatest(8.0, ceil(greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) * 2.0)),
						greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) *
							(greatest(0.0, extract(epoch from (now_ts - structure.last_collected_at))) / 86400.0)
					)
				)
				else round(
					least(
						greatest(8.0, ceil(greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) * 2.0)),
						greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) *
							(greatest(0.0, extract(epoch from (now_ts - structure.last_collected_at))) / 86400.0)
					)::numeric,
					2
				)
			end as amount
		from public.base_structures as structure
		join producers on producers.structure_id = structure.structure_id
		where structure.player_id = save_row.legacy_player_id
			and structure.level > 0
	),
	totals as (
		select
			coalesce(sum(amount) filter (where resource_key = 'almas'), 0) as almas,
			coalesce(sum(amount) filter (where resource_key = 'energia'), 0) as energia,
			coalesce(sum(amount) filter (where resource_key = 'sangue'), 0) as sangue,
			coalesce(sum(amount) filter (where resource_key = 'cristais'), 0) as cristais,
			coalesce(sum(amount) filter (where resource_key = 'ossos'), 0) as ossos
		from collectable
	)
	select almas, energia, sangue, cristais, ossos
	into delta_almas, delta_energia, delta_sangue, delta_cristais, delta_ossos
	from totals;

	has_delta := delta_almas > 0
		or delta_energia > 0
		or delta_sangue > 0
		or delta_cristais > 0
		or delta_ossos > 0;

	if has_delta then
		update public.resources
		set
			almas = almas + delta_almas,
			energia = energia + delta_energia,
			sangue = sangue + delta_sangue,
			cristais = cristais + delta_cristais,
			ossos = ossos + delta_ossos,
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into resource_after;

		insert into public.resource_transactions (player_id, source, request_id, delta)
		values (
			save_row.legacy_player_id,
			'base/collect',
			p_request_id,
			jsonb_build_object(
				'almas', delta_almas,
				'energia', delta_energia,
				'sangue', delta_sangue,
				'cristais', delta_cristais,
				'ossos', delta_ossos
			)
		);

		with producers(structure_id, resource_key, daily_at_level_40) as (
			values
				('altar_das_almas', 'almas', 10.0),
				('nucleo_energia', 'energia', 80.0),
				('pocos_sangue', 'sangue', 8.0),
				('minas_cristal', 'cristais', 5.0),
				('ossario', 'ossos', 200.0)
		),
		collectable as (
			select
				structure.structure_id,
				case
					when producers.resource_key = 'ossos' then floor(
						least(
							greatest(8.0, ceil(greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) * 2.0)),
							greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) *
								(greatest(0.0, extract(epoch from (now_ts - structure.last_collected_at))) / 86400.0)
						)
					)
					else round(
						least(
							greatest(8.0, ceil(greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) * 2.0)),
							greatest(1.0, round(producers.daily_at_level_40 * structure.level / 40.0)) *
								(greatest(0.0, extract(epoch from (now_ts - structure.last_collected_at))) / 86400.0)
						)::numeric,
						2
					)
				end as amount
			from public.base_structures as structure
			join producers on producers.structure_id = structure.structure_id
			where structure.player_id = save_row.legacy_player_id
				and structure.level > 0
		)
		update public.base_structures as structure
		set
			last_collected_at = now_ts,
			updated_at = now_ts
		from collectable
		where structure.player_id = save_row.legacy_player_id
			and structure.structure_id = collectable.structure_id
			and collectable.amount > 0;
	else
		resource_after := resource_before;
	end if;

	collected_payload := jsonb_build_object(
		'almas', delta_almas,
		'energia', delta_energia,
		'sangue', delta_sangue,
		'cristais', delta_cristais,
		'ossos', delta_ossos
	);

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'foundation_base_collect_response_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'ruleset', jsonb_build_object(
			'ruleset_id', ruleset_row.ruleset_id,
			'ruleset_version', ruleset_row.ruleset_version,
			'content_hash', ruleset_row.content_hash,
			'simulator_hash', ruleset_row.simulator_hash,
			'schema_version', ruleset_row.schema_version
		),
		'completed_jobs', completed_jobs_payload,
		'collected', collected_payload,
		'resources', jsonb_build_object(
			'almas', resource_after.almas,
			'energia', resource_after.energia,
			'sangue', resource_after.sangue,
			'cristais', resource_after.cristais,
			'ossos', resource_after.ossos,
			'po_osso', resource_after.po_osso,
			'diamante', resource_after.diamante,
			'updated_at', resource_after.updated_at
		)
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'base/collect',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

create or replace function public.start_base_upgrade_v1(
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
	ruleset_row public.ruleset_registry%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	structure_row public.base_structures%rowtype;
	job_row public.construction_jobs%rowtype;
	reservation_payload jsonb;
	completed_jobs_payload jsonb;
	response_payload jsonb;
	requested_structure_id text := nullif(trim(coalesce(p_request_payload->>'structure_id', '')), '');
	now_ts timestamptz := now();
	active_jobs integer := 0;
	construction_slots integer := 1;
	target_level integer := 0;
	level_cap integer := 0;
	cost_energia integer := 0;
	duration_seconds integer := 0;
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

	if requested_structure_id is null then
		raise exception 'INVALID_STRUCTURE' using errcode = 'P0001';
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
	into ruleset_row
	from public.ruleset_registry
	where ruleset_id = save_row.ruleset_id
		and ruleset_version = save_row.ruleset_version;

	if ruleset_row.ruleset_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'base/upgrade',
		p_request_id,
		p_request_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	completed_jobs_payload := public.complete_due_base_jobs_v1(save_row.legacy_player_id, now_ts);

	select *
	into player_row
	from public.players
	where id = save_row.legacy_player_id
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into resource_row
	from public.resources
	where player_id = save_row.legacy_player_id
	for update;

	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	if requested_structure_id not in (
		'altar_das_almas',
		'nucleo_energia',
		'pocos_sangue',
		'minas_cristal',
		'estrutura_stats',
		'ossario'
	) then
		raise exception 'INVALID_STRUCTURE' using errcode = 'P0001';
	end if;

	select *
	into structure_row
	from public.base_structures
	where player_id = save_row.legacy_player_id
		and structure_id = requested_structure_id
	for update;

	if structure_row.player_id is null then
		raise exception 'BASE_STATE_INCOMPLETE' using errcode = 'P0001';
	end if;

	perform 1
	from public.construction_jobs
	where player_id = save_row.legacy_player_id
		and status = 'active'
	for update;

	select count(*)
	into active_jobs
	from public.construction_jobs
	where player_id = save_row.legacy_player_id
		and status = 'active';

	if exists (
		select 1
		from public.construction_jobs
		where player_id = save_row.legacy_player_id
			and structure_id = requested_structure_id
			and status = 'active'
	) then
		raise exception 'STRUCTURE_ALREADY_UPGRADING' using errcode = 'P0001';
	end if;

	if exists (
		select 1
		from public.alpha_purchases
		where player_id = save_row.legacy_player_id
			and product_id = 'alpha_double_construction_queue'
	) then
		construction_slots := 2;
	end if;

	if active_jobs >= construction_slots then
		raise exception 'CONSTRUCTION_QUEUE_FULL' using errcode = 'P0001';
	end if;

	target_level := structure_row.level + 1;
	level_cap := least(40, greatest(1, player_row.level));

	if target_level > 40 then
		raise exception 'MAX_LEVEL_REACHED' using errcode = 'P0001';
	end if;

	if target_level > level_cap then
		raise exception 'LEVEL_CAP_REACHED' using errcode = 'P0001';
	end if;

	cost_energia := greatest(20, round(0.5 * target_level * target_level)::integer);

	if resource_row.energia < cost_energia then
		raise exception 'INSUFFICIENT_RESOURCES' using errcode = 'P0001';
	end if;

	duration_seconds := greatest(120, round(0.1 * target_level * target_level * 3600)::integer);

	update public.resources
	set
		energia = energia - cost_energia,
		updated_at = now_ts
	where player_id = save_row.legacy_player_id
	returning * into resource_row;

	insert into public.construction_jobs (
		player_id,
		structure_id,
		target_level,
		cost_payload,
		started_at,
		completes_at,
		request_id,
		ruleset_id,
		ruleset_version
	)
	values (
		save_row.legacy_player_id,
		requested_structure_id,
		target_level,
		jsonb_build_object('energia', -cost_energia),
		now_ts,
		now_ts + make_interval(secs => duration_seconds),
		p_request_id,
		ruleset_row.ruleset_id,
		ruleset_row.ruleset_version
	)
	returning * into job_row;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (
		save_row.legacy_player_id,
		'base/upgrade',
		p_request_id,
		jsonb_build_object('energia', -cost_energia)
	);

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'foundation_base_upgrade_response_v1',
		'request_id', p_request_id,
		'request_hash', p_request_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'ruleset', jsonb_build_object(
			'ruleset_id', ruleset_row.ruleset_id,
			'ruleset_version', ruleset_row.ruleset_version,
			'content_hash', ruleset_row.content_hash,
			'simulator_hash', ruleset_row.simulator_hash,
			'schema_version', ruleset_row.schema_version
		),
		'completed_jobs', completed_jobs_payload,
		'resources', jsonb_build_object(
			'almas', resource_row.almas,
			'energia', resource_row.energia,
			'sangue', resource_row.sangue,
			'cristais', resource_row.cristais,
			'ossos', resource_row.ossos,
			'po_osso', resource_row.po_osso,
			'diamante', resource_row.diamante,
			'updated_at', resource_row.updated_at
		),
		'job', jsonb_build_object(
			'id', job_row.id,
			'structure_id', job_row.structure_id,
			'target_level', job_row.target_level,
			'status', job_row.status,
			'cost_payload', job_row.cost_payload,
			'started_at', job_row.started_at,
			'completes_at', job_row.completes_at,
			'request_id', job_row.request_id,
			'ruleset_id', job_row.ruleset_id,
			'ruleset_version', job_row.ruleset_version
		)
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'base/upgrade',
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

revoke all on function public.complete_due_base_jobs_v1(uuid, timestamptz) from public;
grant execute on function public.complete_due_base_jobs_v1(uuid, timestamptz) to service_role;

revoke all on function public.collect_base_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.collect_base_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.start_base_upgrade_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.start_base_upgrade_v1(uuid, uuid, text, jsonb) to service_role;
