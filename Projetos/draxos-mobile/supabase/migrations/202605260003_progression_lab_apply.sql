-- DraxosMobile Track 03 P04 - Apply a generated Progression Lab save.
-- The RPC only targets the progression_lab save for the authenticated account.

create or replace function public.apply_progression_lab_save(
	p_auth_user_id uuid,
	p_request_id uuid,
	p_profile_id text,
	p_milestone_id text,
	p_save_payload jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_profile_id text := lower(trim(coalesce(p_profile_id, '')));
	normalized_milestone_id text := lower(trim(coalesce(p_milestone_id, '')));
	save_id text := trim(coalesce(p_save_payload->>'id', ''));
	save_profile_id text := lower(trim(coalesce(p_save_payload->>'profile_id', '')));
	save_milestone_id text := lower(trim(coalesce(p_save_payload->>'milestone_id', '')));
	player_payload jsonb := coalesce(p_save_payload->'player', '{}'::jsonb);
	resources_payload jsonb := coalesce(p_save_payload->'resources', '{}'::jsonb);
	build_payload jsonb := coalesce(p_save_payload->'build', '{}'::jsonb);
	base_payload jsonb := coalesce(p_save_payload->'base', '{}'::jsonb);
	monetization_payload jsonb := coalesce(p_save_payload->'monetization', '{}'::jsonb);
	active_job_payload jsonb := coalesce(base_payload->'active_job', 'null'::jsonb);
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	build_row public.builds%rowtype;
	existing_payload jsonb;
	progression_payload jsonb;
	apply_response_payload jsonb;
	applied_at timestamptz := now();
begin
	if p_auth_user_id is null then
		raise exception 'UNAUTHENTICATED' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if jsonb_typeof(p_save_payload) is distinct from 'object' then
		raise exception 'INVALID_PROGRESSION_LAB_SAVE' using errcode = 'P0001';
	end if;

	if normalized_profile_id = ''
		or normalized_milestone_id = ''
		or save_id = ''
		or save_profile_id <> normalized_profile_id
		or save_milestone_id <> normalized_milestone_id then
		raise exception 'INVALID_PROGRESSION_LAB_SAVE' using errcode = 'P0001';
	end if;

	select *
	into player_row
	from public.players
	where auth_user_id = p_auth_user_id
		and save_type = 'progression_lab'
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	select ik.response_payload
	into existing_payload
	from public.idempotency_keys as ik
	where ik.player_id = player_row.id
		and ik.endpoint = 'progression-lab/apply'
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
		updated_at = applied_at
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
	set level = greatest(1, coalesce(nullif(player_payload->>'level', '')::integer, 1)),
		xp = greatest(0, coalesce(nullif(player_payload->>'xp', '')::integer, 0)),
		power = greatest(0, coalesce(nullif(player_payload->>'power', '')::integer, 0)),
		updated_at = applied_at
	where id = player_row.id
	returning * into player_row;

	insert into public.resources (
		player_id,
		almas,
		energia,
		sangue,
		cristais,
		ossos,
		diamante,
		updated_at
	)
	values (
		player_row.id,
		greatest(0, coalesce(nullif(resources_payload->>'almas', '')::numeric, 0)),
		greatest(0, coalesce(nullif(resources_payload->>'energia', '')::numeric, 0)),
		greatest(0, coalesce(nullif(resources_payload->>'sangue', '')::numeric, 0)),
		greatest(0, coalesce(nullif(resources_payload->>'cristais', '')::numeric, 0)),
		greatest(0, coalesce(nullif(resources_payload->>'ossos', '')::numeric, 0)),
		greatest(0, round(coalesce(nullif(resources_payload->>'diamante', '')::numeric, 0))::integer),
		applied_at
	)
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
		passive_level,
		updated_at
	)
	values (
		player_row.id,
		coalesce(nullif(build_payload->>'weapon_type', ''), 'varinha_cinzas'),
		coalesce(nullif(build_payload->>'weapon_quality', ''), 'starter'),
		greatest(1, coalesce(nullif(build_payload->>'weapon_level', '')::integer, 1)),
		coalesce(build_payload->'spell_slots', '[]'::jsonb),
		coalesce(build_payload->'spells_unlocked', '[]'::jsonb),
		nullif(build_payload->>'pet_id', ''),
		greatest(0, coalesce(nullif(build_payload->>'pet_level', '')::integer, 0)),
		nullif(build_payload->>'passive_id', ''),
		greatest(0, coalesce(nullif(build_payload->>'passive_level', '')::integer, 0)),
		applied_at
	)
	returning * into build_row;

	insert into public.base_structures (player_id, structure_id, level, last_collected_at, updated_at)
	select player_row.id, structure_ids.structure_id, 0, applied_at, applied_at
	from (
		values
			('altar_das_almas'),
			('nucleo_energia'),
			('pocos_sangue'),
			('minas_cristal'),
			('estrutura_stats'),
			('ossario')
	) as structure_ids(structure_id);

	insert into public.base_structures (player_id, structure_id, level, last_collected_at, updated_at)
	select
		player_row.id,
		structure_entry.structure_payload->>'structure_id',
		least(40, greatest(0, coalesce(nullif(structure_entry.structure_payload->>'level', '')::integer, 0))),
		applied_at,
		applied_at
	from jsonb_array_elements(coalesce(base_payload->'structures', '[]'::jsonb)) as structure_entry(structure_payload)
	where structure_entry.structure_payload->>'structure_id' in (
		'altar_das_almas',
		'nucleo_energia',
		'pocos_sangue',
		'minas_cristal',
		'estrutura_stats',
		'ossario'
	)
	on conflict (player_id, structure_id) do update
	set level = excluded.level,
		last_collected_at = excluded.last_collected_at,
		updated_at = excluded.updated_at;

	if jsonb_typeof(active_job_payload) = 'object'
		and coalesce(active_job_payload->>'structure_id', '') in (
			'altar_das_almas',
			'nucleo_energia',
			'pocos_sangue',
			'minas_cristal',
			'estrutura_stats',
			'ossario'
		) then
		insert into public.construction_jobs (
			player_id,
			structure_id,
			target_level,
			status,
			cost_payload,
			started_at,
			completes_at,
			request_id,
			updated_at
		)
		values (
			player_row.id,
			active_job_payload->>'structure_id',
			least(40, greatest(1, coalesce(nullif(active_job_payload->>'target_level', '')::integer, 1))),
			'active',
			jsonb_build_object(
				'progression_lab', true,
				'source_save_id', save_id,
				'profile_id', normalized_profile_id,
				'milestone_id', normalized_milestone_id
			),
			applied_at,
			applied_at + (greatest(0, coalesce(nullif(active_job_payload->>'remaining_minutes', '')::integer, 0)) || ' minutes')::interval,
			gen_random_uuid(),
			applied_at
		);
	end if;

	insert into public.battle_pass_progress (
		player_id,
		pass_id,
		pass_xp,
		premium_unlocked,
		updated_at
	)
	values (
		player_row.id,
		'bp_s1_01',
		greatest(0, coalesce(nullif(monetization_payload->>'battle_pass_xp', '')::integer, 0)),
		coalesce(nullif(monetization_payload->>'premium_unlocked', '')::boolean, false),
		applied_at
	);

	insert into public.reward_claims (
		player_id,
		source,
		reward_id,
		period_key,
		request_id,
		reward_payload,
		created_at
	)
	values (
		player_row.id,
		'daily',
		'progression_lab_checkpoint',
		save_id,
		gen_random_uuid(),
		jsonb_build_object(
			'progression_lab', true,
			'profile_id', normalized_profile_id,
			'milestone_id', normalized_milestone_id,
			'resources', resources_payload
		),
		applied_at
	);

	progression_payload := jsonb_build_object(
		'save_id', save_id,
		'profile_id', normalized_profile_id,
		'milestone_id', normalized_milestone_id,
		'local_only', false,
		'hours', coalesce(nullif(p_save_payload->>'hours', '')::numeric, 0),
		'status', coalesce(nullif(p_save_payload->>'status', ''), 'UNKNOWN'),
		'notes', coalesce(p_save_payload->'notes', '[]'::jsonb),
		'manual_checklist', coalesce(p_save_payload->'manual_checklist', '[]'::jsonb),
		'applied_at', applied_at
	);

	apply_response_payload := jsonb_build_object(
		'ok', true,
		'applied', jsonb_build_object(
			'save_type', player_row.save_type,
			'player_id', player_row.id,
			'request_id', p_request_id,
			'save_id', save_id,
			'profile_id', normalized_profile_id,
			'milestone_id', normalized_milestone_id
		),
		'progression_lab', progression_payload,
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
	set response_payload = apply_response_payload
	where player_id = player_row.id
		and endpoint = 'account/guest';

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (
		player_row.id,
		'progression-lab/apply',
		p_request_id,
		jsonb_build_object(
			'progression_lab', true,
			'save_id', save_id,
			'profile_id', normalized_profile_id,
			'milestone_id', normalized_milestone_id
		)
	);

	insert into public.idempotency_keys (player_id, endpoint, request_id, response_payload)
	values (player_row.id, 'progression-lab/apply', p_request_id, apply_response_payload)
	on conflict (player_id, endpoint, request_id) do update
	set response_payload = excluded.response_payload;

	return apply_response_payload;
end;
$$;

revoke all on function public.apply_progression_lab_save(uuid, uuid, text, text, jsonb) from public;
grant execute on function public.apply_progression_lab_save(uuid, uuid, text, text, jsonb) to service_role;
