-- DraxosMobile Foundation Closeout.
-- Corrects ruleset publication identity, persists historical ruleset hashes and
-- adds internal auditable admin/reconciliation RPCs.

create extension if not exists "pgcrypto";

alter table public.ruleset_registry
	add column if not exists publication_id uuid default gen_random_uuid();

update public.ruleset_registry
set publication_id = gen_random_uuid()
where publication_id is null;

alter table public.ruleset_registry
	alter column publication_id set not null;

update public.ruleset_registry
set
	content_hash = 'bad44d18be6ee170e698fc933929ed58bf4fb6932261e1b19bd9f8156e11638e',
	simulator_hash = 'e835cadde3c937cba45c46785da3761139373ab23ac9dfaaed814d79f933bbe9',
	schema_version = 'foundation_ruleset_manifest_v1',
	status = 'active',
	channel = 'internal_alpha',
	cohort = 'all',
	updated_at = now()
where ruleset_id = 'foundation_ruleset_v0'
	and ruleset_version = 1;

do $$
begin
	alter table public.game_saves drop constraint if exists game_saves_ruleset_id_fkey;
	alter table public.battles drop constraint if exists battles_ruleset_id_fkey;
	alter table public.construction_jobs drop constraint if exists construction_jobs_ruleset_id_fkey;
	alter table public.reward_claims drop constraint if exists reward_claims_ruleset_id_fkey;
	alter table public.alpha_purchases drop constraint if exists alpha_purchases_ruleset_id_fkey;
end $$;

do $$
begin
	if exists (
		select 1 from pg_constraint
		where conrelid = 'public.ruleset_registry'::regclass
			and conname = 'ruleset_registry_pkey'
	) and not exists (
		select 1 from pg_constraint
		where conrelid = 'public.ruleset_registry'::regclass
			and conname = 'ruleset_registry_publication_pkey'
	) then
		alter table public.ruleset_registry drop constraint ruleset_registry_pkey;
	end if;
end $$;

do $$
begin
	if not exists (
		select 1 from pg_constraint
		where conrelid = 'public.ruleset_registry'::regclass
			and conname = 'ruleset_registry_publication_pkey'
	) then
		alter table public.ruleset_registry
			add constraint ruleset_registry_publication_pkey primary key (publication_id);
	end if;
end $$;

create unique index if not exists ruleset_registry_publication_identity_idx
	on public.ruleset_registry (ruleset_id, ruleset_version, channel, cohort);

create unique index if not exists ruleset_registry_active_publication_idx
	on public.ruleset_registry (ruleset_id, channel, cohort)
	where status = 'active';

create index if not exists ruleset_registry_ruleset_lookup_idx
	on public.ruleset_registry (ruleset_id, ruleset_version, status, active_from desc);

alter table public.game_saves
	add column if not exists ruleset_publication_id uuid references public.ruleset_registry(publication_id),
	add column if not exists ruleset_content_hash text,
	add column if not exists ruleset_simulator_hash text,
	add column if not exists ruleset_schema_version text,
	add column if not exists state_version integer not null default 1,
	add column if not exists season_context jsonb not null default '{"season_id":"alpha_0","channel":"internal_alpha"}'::jsonb;

alter table public.battles
	add column if not exists ruleset_publication_id uuid references public.ruleset_registry(publication_id),
	add column if not exists ruleset_content_hash text,
	add column if not exists ruleset_simulator_hash text,
	add column if not exists ruleset_schema_version text;

alter table public.construction_jobs
	add column if not exists ruleset_publication_id uuid references public.ruleset_registry(publication_id),
	add column if not exists ruleset_content_hash text,
	add column if not exists ruleset_simulator_hash text,
	add column if not exists ruleset_schema_version text;

alter table public.reward_claims
	add column if not exists ruleset_publication_id uuid references public.ruleset_registry(publication_id),
	add column if not exists ruleset_content_hash text,
	add column if not exists ruleset_simulator_hash text,
	add column if not exists ruleset_schema_version text;

alter table public.alpha_purchases
	add column if not exists ruleset_publication_id uuid references public.ruleset_registry(publication_id),
	add column if not exists ruleset_content_hash text,
	add column if not exists ruleset_simulator_hash text,
	add column if not exists ruleset_schema_version text;

create index if not exists game_saves_ruleset_publication_idx
	on public.game_saves (ruleset_publication_id, lifecycle_status);

create index if not exists battles_ruleset_publication_idx
	on public.battles (ruleset_publication_id, created_at desc);

create index if not exists construction_jobs_ruleset_publication_idx
	on public.construction_jobs (ruleset_publication_id, created_at desc);

create index if not exists reward_claims_ruleset_publication_idx
	on public.reward_claims (ruleset_publication_id, created_at desc);

create index if not exists alpha_purchases_ruleset_publication_idx
	on public.alpha_purchases (ruleset_publication_id, created_at desc);

create unique index if not exists admin_audit_log_action_request_idx
	on public.admin_audit_log (action, request_id)
	where request_id is not null;

create or replace function public.active_ruleset_publication_v1(
	p_ruleset_id text default 'foundation_ruleset_v0',
	p_channel text default 'internal_alpha',
	p_cohort text default 'all'
)
returns public.ruleset_registry
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	ruleset_row public.ruleset_registry%rowtype;
begin
	select *
	into ruleset_row
	from public.ruleset_registry
	where ruleset_id = coalesce(nullif(trim(p_ruleset_id), ''), 'foundation_ruleset_v0')
		and channel = coalesce(nullif(trim(p_channel), ''), 'internal_alpha')
		and cohort = coalesce(nullif(trim(p_cohort), ''), 'all')
		and status = 'active'
	order by active_from desc, ruleset_version desc
	limit 1;

	if ruleset_row.publication_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	return ruleset_row;
end;
$$;

create or replace function public.resolve_ruleset_publication_v1(
	p_ruleset_id text default 'foundation_ruleset_v0',
	p_ruleset_version integer default 1,
	p_channel text default 'internal_alpha',
	p_cohort text default 'all'
)
returns public.ruleset_registry
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	ruleset_row public.ruleset_registry%rowtype;
begin
	select *
	into ruleset_row
	from public.ruleset_registry
	where ruleset_id = coalesce(nullif(trim(p_ruleset_id), ''), 'foundation_ruleset_v0')
		and ruleset_version = coalesce(p_ruleset_version, 1)
		and channel = coalesce(nullif(trim(p_channel), ''), 'internal_alpha')
		and cohort = coalesce(nullif(trim(p_cohort), ''), 'all')
		and status in ('active', 'deprecated', 'draft')
	order by case status when 'active' then 0 when 'deprecated' then 1 else 2 end,
		active_from desc
	limit 1;

	if ruleset_row.publication_id is null then
		return public.active_ruleset_publication_v1(
			coalesce(nullif(trim(p_ruleset_id), ''), 'foundation_ruleset_v0'),
			coalesce(nullif(trim(p_channel), ''), 'internal_alpha'),
			coalesce(nullif(trim(p_cohort), ''), 'all')
		);
	end if;

	return ruleset_row;
end;
$$;

create or replace function public.foundation_ruleset_json_v1(
	p_ruleset public.ruleset_registry
)
returns jsonb
language sql
stable
as $$
	select jsonb_build_object(
		'publication_id', p_ruleset.publication_id,
		'ruleset_id', p_ruleset.ruleset_id,
		'ruleset_version', p_ruleset.ruleset_version,
		'content_hash', p_ruleset.content_hash,
		'simulator_hash', p_ruleset.simulator_hash,
		'schema_version', p_ruleset.schema_version,
		'channel', p_ruleset.channel,
		'cohort', p_ruleset.cohort,
		'status', p_ruleset.status
	);
$$;

create or replace function public.set_game_save_ruleset_context_v1()
returns trigger
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	ruleset_row public.ruleset_registry%rowtype;
begin
	if new.ruleset_publication_id is not null then
		select *
		into ruleset_row
		from public.ruleset_registry
		where publication_id = new.ruleset_publication_id;
	else
		ruleset_row := public.resolve_ruleset_publication_v1(
			coalesce(nullif(new.ruleset_id, ''), 'foundation_ruleset_v0'),
			coalesce(new.ruleset_version, 1),
			coalesce(new.season_context->>'channel', 'internal_alpha'),
			coalesce(new.season_context->>'cohort', 'all')
		);
	end if;

	if ruleset_row.publication_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	new.ruleset_publication_id := ruleset_row.publication_id;
	new.ruleset_id := ruleset_row.ruleset_id;
	new.ruleset_version := ruleset_row.ruleset_version;
	new.ruleset_content_hash := ruleset_row.content_hash;
	new.ruleset_simulator_hash := ruleset_row.simulator_hash;
	new.ruleset_schema_version := ruleset_row.schema_version;
	new.state_version := coalesce(new.state_version, 1);
	if new.season_context is null or jsonb_typeof(new.season_context) <> 'object' then
		new.season_context := '{"season_id":"alpha_0","channel":"internal_alpha"}'::jsonb;
	end if;
	if new.season_context ? 'channel' is not true then
		new.season_context := new.season_context || '{"channel":"internal_alpha"}'::jsonb;
	end if;

	return new;
end;
$$;

drop trigger if exists game_saves_ruleset_context_v1 on public.game_saves;
create trigger game_saves_ruleset_context_v1
before insert or update of ruleset_publication_id, ruleset_id, ruleset_version, season_context, state_version
on public.game_saves
for each row
execute function public.set_game_save_ruleset_context_v1();

create or replace function public.set_history_ruleset_context_v1()
returns trigger
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	ruleset_row public.ruleset_registry%rowtype;
begin
	if new.ruleset_publication_id is not null then
		select *
		into ruleset_row
		from public.ruleset_registry
		where publication_id = new.ruleset_publication_id;
	else
		ruleset_row := public.resolve_ruleset_publication_v1(
			coalesce(nullif(new.ruleset_id, ''), 'foundation_ruleset_v0'),
			coalesce(new.ruleset_version, 1),
			'internal_alpha',
			'all'
		);
	end if;

	if ruleset_row.publication_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	new.ruleset_publication_id := ruleset_row.publication_id;
	new.ruleset_id := ruleset_row.ruleset_id;
	new.ruleset_version := ruleset_row.ruleset_version;
	new.ruleset_content_hash := ruleset_row.content_hash;
	new.ruleset_simulator_hash := ruleset_row.simulator_hash;
	new.ruleset_schema_version := ruleset_row.schema_version;

	return new;
end;
$$;

drop trigger if exists battles_ruleset_context_v1 on public.battles;
create trigger battles_ruleset_context_v1
before insert or update of ruleset_publication_id, ruleset_id, ruleset_version
on public.battles
for each row
execute function public.set_history_ruleset_context_v1();

drop trigger if exists construction_jobs_ruleset_context_v1 on public.construction_jobs;
create trigger construction_jobs_ruleset_context_v1
before insert or update of ruleset_publication_id, ruleset_id, ruleset_version
on public.construction_jobs
for each row
execute function public.set_history_ruleset_context_v1();

drop trigger if exists reward_claims_ruleset_context_v1 on public.reward_claims;
create trigger reward_claims_ruleset_context_v1
before insert or update of ruleset_publication_id, ruleset_id, ruleset_version
on public.reward_claims
for each row
execute function public.set_history_ruleset_context_v1();

drop trigger if exists alpha_purchases_ruleset_context_v1 on public.alpha_purchases;
create trigger alpha_purchases_ruleset_context_v1
before insert or update of ruleset_publication_id, ruleset_id, ruleset_version
on public.alpha_purchases
for each row
execute function public.set_history_ruleset_context_v1();

update public.game_saves
set ruleset_id = coalesce(nullif(ruleset_id, ''), 'foundation_ruleset_v0');

update public.battles
set ruleset_id = coalesce(nullif(ruleset_id, ''), 'foundation_ruleset_v0');

update public.construction_jobs
set ruleset_id = coalesce(nullif(ruleset_id, ''), 'foundation_ruleset_v0');

update public.reward_claims
set ruleset_id = coalesce(nullif(ruleset_id, ''), 'foundation_ruleset_v0');

update public.alpha_purchases
set ruleset_id = coalesce(nullif(ruleset_id, ''), 'foundation_ruleset_v0');

alter table public.game_saves
	alter column ruleset_publication_id set not null,
	alter column ruleset_content_hash set not null,
	alter column ruleset_simulator_hash set not null,
	alter column ruleset_schema_version set not null;

create or replace function public.foundation_account_context_v1(
	p_player_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	save_row public.game_saves%rowtype;
	profile_row public.account_profiles%rowtype;
begin
	if p_player_id is null then
		raise exception 'INVALID_PLAYER_ID' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where legacy_player_id = p_player_id
		and lifecycle_status = 'active'
	limit 1;

	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into profile_row
	from public.account_profiles
	where id = save_row.account_profile_id;

	if profile_row.id is null then
		raise exception 'ACCOUNT_PROFILE_NOT_FOUND' using errcode = 'P0001';
	end if;

	return jsonb_build_object(
		'schema_version', 'foundation_account_context_v1',
		'api_version', 1,
		'account', jsonb_build_object(
			'account_profile_id', profile_row.id,
			'auth_user_id', profile_row.auth_user_id,
			'canonical_player_id', profile_row.canonical_player_id,
			'username', profile_row.username,
			'account_type', profile_row.account_type,
			'status', profile_row.status
		),
		'save', jsonb_build_object(
			'game_save_id', save_row.id,
			'save_type', save_row.save_type,
			'slot_key', save_row.slot_key,
			'display_name', save_row.display_name,
			'legacy_player_id', save_row.legacy_player_id,
			'state_version', save_row.state_version,
			'season_context', save_row.season_context,
			'lifecycle_status', save_row.lifecycle_status
		),
		'ruleset', jsonb_build_object(
			'publication_id', save_row.ruleset_publication_id,
			'ruleset_id', save_row.ruleset_id,
			'ruleset_version', save_row.ruleset_version,
			'content_hash', save_row.ruleset_content_hash,
			'simulator_hash', save_row.ruleset_simulator_hash,
			'schema_version', save_row.ruleset_schema_version
		)
	);
end;
$$;

create or replace function public.ensure_foundation_profile_and_saves(
	p_auth_user_id uuid,
	p_ruleset_id text default 'foundation_ruleset_v0'
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	profile_row public.account_profiles%rowtype;
	ruleset_row public.ruleset_registry%rowtype;
	save_count integer := 0;
begin
	if p_auth_user_id is null then
		raise exception 'UNAUTHENTICATED' using errcode = 'P0001';
	end if;

	if not exists (select 1 from auth.users where id = p_auth_user_id) then
		raise exception 'AUTH_USER_NOT_FOUND' using errcode = 'P0001';
	end if;

	ruleset_row := public.active_ruleset_publication_v1(p_ruleset_id, 'internal_alpha', 'all');

	insert into public.account_profiles (
		auth_user_id,
		canonical_player_id,
		username,
		account_type,
		created_at,
		updated_at
	)
	select
		p_auth_user_id,
		(array_agg(p.id order by case when p.save_type = 'normal' then 0 else 1 end, p.created_at))[1],
		(array_agg(p.username order by case when p.save_type = 'normal' then 0 else 1 end, p.created_at))[1],
		coalesce((array_agg(p.account_type order by case when p.save_type = 'normal' then 0 else 1 end, p.created_at))[1], 'registered'),
		coalesce(min(p.created_at), now()),
		now()
	from public.players as p
	where p.auth_user_id = p_auth_user_id
	group by p.auth_user_id
	on conflict (auth_user_id) do update set
		canonical_player_id = coalesce(public.account_profiles.canonical_player_id, excluded.canonical_player_id),
		username = coalesce(nullif(public.account_profiles.username, ''), excluded.username),
		account_type = excluded.account_type,
		updated_at = now()
	returning * into profile_row;

	if profile_row.id is null then
		insert into public.account_profiles (auth_user_id, account_type)
		values (p_auth_user_id, 'registered')
		on conflict (auth_user_id) do update set updated_at = now()
		returning * into profile_row;
	end if;

	insert into public.game_saves (
		account_profile_id,
		legacy_player_id,
		save_type,
		slot_key,
		display_name,
		ruleset_publication_id,
		ruleset_id,
		ruleset_version,
		state_version,
		season_context,
		snapshot,
		created_at,
		updated_at
	)
	select
		profile_row.id,
		p.id,
		p.save_type,
		p.save_type,
		case
			when p.save_type = 'progression_lab' then 'Progression Lab'
			else 'Normal'
		end,
		ruleset_row.publication_id,
		ruleset_row.ruleset_id,
		ruleset_row.ruleset_version,
		1,
		jsonb_build_object('season_id', 'alpha_0', 'channel', ruleset_row.channel, 'cohort', ruleset_row.cohort),
		jsonb_build_object(
			'legacy_player_id', p.id,
			'player_level', p.level,
			'player_xp', p.xp,
			'player_power', p.power
		),
		p.created_at,
		now()
	from public.players as p
	where p.auth_user_id = p_auth_user_id
	on conflict (account_profile_id, save_type) do update set
		legacy_player_id = coalesce(public.game_saves.legacy_player_id, excluded.legacy_player_id),
		slot_key = excluded.slot_key,
		display_name = excluded.display_name,
		ruleset_publication_id = excluded.ruleset_publication_id,
		ruleset_id = excluded.ruleset_id,
		ruleset_version = excluded.ruleset_version,
		season_context = excluded.season_context,
		snapshot = excluded.snapshot,
		updated_at = now();

	select count(*)
	into save_count
	from public.game_saves
	where account_profile_id = profile_row.id
		and lifecycle_status = 'active';

	return jsonb_build_object(
		'ok', true,
		'schema_version', 'ensure_foundation_profile_and_saves_v2',
		'api_version', 1,
		'account_profile_id', profile_row.id,
		'auth_user_id', profile_row.auth_user_id,
		'canonical_player_id', profile_row.canonical_player_id,
		'save_count', save_count,
		'ruleset', public.foundation_ruleset_json_v1(ruleset_row)
	);
end;
$$;

create or replace function public.ensure_foundation_save_after_player_insert_v1()
returns trigger
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
	perform public.ensure_foundation_profile_and_saves(new.auth_user_id, 'foundation_ruleset_v0');
	return new;
end;
$$;

drop trigger if exists players_foundation_save_after_insert_v1 on public.players;
create trigger players_foundation_save_after_insert_v1
after insert on public.players
for each row
execute function public.ensure_foundation_save_after_player_insert_v1();

create or replace function public.resource_reconciliation_report_v1(
	p_game_save_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	save_row public.game_saves%rowtype;
	resource_row public.resources%rowtype;
	ledger jsonb;
	current_payload jsonb;
	difference jsonb;
	balanced boolean := true;
	resource_key text;
	diff_value numeric;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where id = p_game_save_id
		and lifecycle_status = 'active';

	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into resource_row
	from public.resources
	where player_id = save_row.legacy_player_id;

	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	select jsonb_build_object(
		'almas', coalesce(sum(coalesce(nullif(delta->>'almas', '')::numeric, 0)), 0),
		'energia', coalesce(sum(coalesce(nullif(delta->>'energia', '')::numeric, 0)), 0),
		'sangue', coalesce(sum(coalesce(nullif(delta->>'sangue', '')::numeric, 0)), 0),
		'cristais', coalesce(sum(coalesce(nullif(delta->>'cristais', '')::numeric, 0)), 0),
		'ossos', coalesce(sum(coalesce(nullif(delta->>'ossos', '')::numeric, 0)), 0),
		'po_osso', coalesce(sum(coalesce(nullif(delta->>'po_osso', '')::numeric, 0)), 0),
		'diamante', coalesce(sum(coalesce(nullif(delta->>'diamante', '')::numeric, 0)), 0)
	)
	into ledger
	from public.resource_transactions
	where player_id = save_row.legacy_player_id;

	current_payload := jsonb_build_object(
		'almas', resource_row.almas,
		'energia', resource_row.energia,
		'sangue', resource_row.sangue,
		'cristais', resource_row.cristais,
		'ossos', resource_row.ossos,
		'po_osso', resource_row.po_osso,
		'diamante', resource_row.diamante
	);

	difference := '{}'::jsonb;
	foreach resource_key in array array['almas', 'energia', 'sangue', 'cristais', 'ossos', 'po_osso', 'diamante']
	loop
		diff_value := coalesce(nullif(current_payload->>resource_key, '')::numeric, 0)
			- coalesce(nullif(ledger->>resource_key, '')::numeric, 0);
		if diff_value <> 0 then
			balanced := false;
		end if;
		difference := difference || jsonb_build_object(resource_key, diff_value);
	end loop;

	return jsonb_build_object(
		'ok', true,
		'schema_version', 'resource_reconciliation_report_v1',
		'game_save_id', save_row.id,
		'account_profile_id', save_row.account_profile_id,
		'legacy_player_id', save_row.legacy_player_id,
		'current_balance', current_payload,
		'ledger_balance', ledger,
		'difference', difference,
		'balanced', balanced
	);
end;
$$;

create or replace function public.admin_adjust_resource_balance_v1(
	p_game_save_id uuid,
	p_delta jsonb,
	p_reason text,
	p_request_id uuid,
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
		jsonb_build_object('delta', delta_payload, 'response_payload', response_payload)
	);

	return response_payload;
end;
$$;

create or replace function public.admin_lookup_account_v1(
	p_auth_user_id uuid default null,
	p_username text default null,
	p_player_id uuid default null,
	p_game_save_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	profile_row public.account_profiles%rowtype;
begin
	select ap.*
	into profile_row
	from public.account_profiles as ap
	left join public.game_saves as gs on gs.account_profile_id = ap.id
	left join public.players as p on p.id = gs.legacy_player_id
	where (p_auth_user_id is not null and ap.auth_user_id = p_auth_user_id)
		or (nullif(trim(coalesce(p_username, '')), '') is not null and ap.username = lower(trim(p_username)))
		or (p_player_id is not null and gs.legacy_player_id = p_player_id)
		or (p_game_save_id is not null and gs.id = p_game_save_id)
	order by ap.created_at
	limit 1;

	if profile_row.id is null then
		raise exception 'ACCOUNT_PROFILE_NOT_FOUND' using errcode = 'P0001';
	end if;

	return jsonb_build_object(
		'ok', true,
		'schema_version', 'admin_lookup_account_v1',
		'account', jsonb_build_object(
			'account_profile_id', profile_row.id,
			'auth_user_id', profile_row.auth_user_id,
			'canonical_player_id', profile_row.canonical_player_id,
			'username', profile_row.username,
			'account_type', profile_row.account_type,
			'status', profile_row.status
		),
		'saves', coalesce((
			select jsonb_agg(jsonb_build_object(
				'game_save_id', gs.id,
				'save_type', gs.save_type,
				'legacy_player_id', gs.legacy_player_id,
				'state_version', gs.state_version,
				'season_context', gs.season_context,
				'ruleset', jsonb_build_object(
					'publication_id', gs.ruleset_publication_id,
					'ruleset_id', gs.ruleset_id,
					'ruleset_version', gs.ruleset_version,
					'content_hash', gs.ruleset_content_hash,
					'simulator_hash', gs.ruleset_simulator_hash,
					'schema_version', gs.ruleset_schema_version
				)
			) order by gs.save_type)
			from public.game_saves as gs
			where gs.account_profile_id = profile_row.id
		), '[]'::jsonb)
	);
end;
$$;

create or replace function public.admin_battle_diagnostics_v1(
	p_battle_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	battle_row public.battles%rowtype;
	save_row public.game_saves%rowtype;
begin
	if p_battle_id is null then
		raise exception 'INVALID_BATTLE_ID' using errcode = 'P0001';
	end if;

	select *
	into battle_row
	from public.battles
	where id = p_battle_id;

	if battle_row.id is null then
		raise exception 'BATTLE_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where legacy_player_id = battle_row.attacker_id
		and lifecycle_status = 'active'
	limit 1;

	return jsonb_build_object(
		'ok', true,
		'schema_version', 'admin_battle_diagnostics_v1',
		'battle_id', battle_row.id,
		'game_save_id', save_row.id,
		'account_profile_id', save_row.account_profile_id,
		'attacker_id', battle_row.attacker_id,
		'defender_id', battle_row.defender_id,
		'defender_is_bot', battle_row.defender_is_bot,
		'battle_schema_version', battle_row.schema_version,
		'ruleset', jsonb_build_object(
			'publication_id', battle_row.ruleset_publication_id,
			'ruleset_id', battle_row.ruleset_id,
			'ruleset_version', battle_row.ruleset_version,
			'content_hash', battle_row.ruleset_content_hash,
			'simulator_hash', battle_row.ruleset_simulator_hash,
			'schema_version', battle_row.ruleset_schema_version
		),
		'result', battle_row.result,
		'reward_payload', battle_row.reward_payload,
		'event_count', coalesce(jsonb_array_length(battle_row.event_log), 0),
		'ledger', coalesce((
			select jsonb_agg(to_jsonb(rt) order by rt.created_at)
			from public.resource_transactions as rt
			where rt.player_id = battle_row.attacker_id
				and rt.request_id is not distinct from (
					select request_id
					from public.idempotency_keys as ik
					where ik.player_id = battle_row.attacker_id
						and ik.endpoint = 'battle/request'
						and ik.response_payload->>'battle_id' = battle_row.id::text
					limit 1
				)
		), '[]'::jsonb)
	);
end;
$$;

create or replace function public.admin_flag_account_v1(
	p_account_profile_id uuid,
	p_status text,
	p_reason text,
	p_request_id uuid,
	p_actor_auth_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_status text := lower(trim(coalesce(p_status, '')));
	profile_before public.account_profiles%rowtype;
	profile_after public.account_profiles%rowtype;
	existing_audit public.admin_audit_log%rowtype;
	response_payload jsonb;
begin
	if p_account_profile_id is null then
		raise exception 'INVALID_ACCOUNT_PROFILE_ID' using errcode = 'P0001';
	end if;
	if normalized_status not in ('active', 'suspended', 'deleted') then
		raise exception 'INVALID_ACCOUNT_STATUS' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if nullif(trim(coalesce(p_reason, '')), '') is null then
		raise exception 'INVALID_REASON' using errcode = 'P0001';
	end if;

	select *
	into existing_audit
	from public.admin_audit_log
	where action = 'admin_flag_account_v1'
		and request_id = p_request_id;

	if existing_audit.id is not null then
		return coalesce(existing_audit.metadata->'response_payload', existing_audit.after_state);
	end if;

	select *
	into profile_before
	from public.account_profiles
	where id = p_account_profile_id
	for update;

	if profile_before.id is null then
		raise exception 'ACCOUNT_PROFILE_NOT_FOUND' using errcode = 'P0001';
	end if;

	update public.account_profiles
	set status = normalized_status,
		updated_at = now()
	where id = p_account_profile_id
	returning * into profile_after;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'admin_flag_account_v1',
		'request_id', p_request_id,
		'account_profile_id', profile_after.id,
		'previous_status', profile_before.status,
		'status', profile_after.status
	);

	insert into public.admin_audit_log (
		actor_auth_user_id,
		account_profile_id,
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
		profile_after.id,
		profile_after.canonical_player_id,
		'admin_flag_account_v1',
		p_reason,
		p_request_id,
		to_jsonb(profile_before),
		to_jsonb(profile_after),
		jsonb_build_object('response_payload', response_payload)
	);

	return response_payload;
end;
$$;

create or replace function public.apply_build_preparation_mutation_v1(
	p_game_save_id uuid,
	p_endpoint text,
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
	build_row public.builds%rowtype;
	slot_row public.player_potion_slots%rowtype;
	consumable_row public.player_consumables%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	normalized_endpoint text := trim(coalesce(p_endpoint, ''));
	payload_spell_id text;
	payload_item_id text;
	payload_behavior jsonb;
	payload_slot_index integer := 1;
	default_potion_behavior jsonb := '{"enabled": true, "hp": {"mode": "below", "percent": 40}, "mana": {"mode": "ignore", "percent": 0}}'::jsonb;
begin
	if normalized_endpoint not in ('build/spell-behavior', 'build/potion/equip', 'build/potion-behavior') then
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
	end if;

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

	if save_row.ruleset_publication_id is not null then
		select *
		into ruleset_row
		from public.ruleset_registry
		where publication_id = save_row.ruleset_publication_id;
	else
		ruleset_row := public.resolve_ruleset_publication_v1(
			coalesce(nullif(save_row.ruleset_id, ''), 'foundation_ruleset_v0'),
			coalesce(save_row.ruleset_version, 1),
			coalesce(save_row.season_context->>'channel', 'internal_alpha'),
			coalesce(save_row.season_context->>'cohort', 'all')
		);
	end if;

	if ruleset_row.publication_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		normalized_endpoint,
		p_request_id,
		p_request_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into player_row
	from public.players
	where id = save_row.legacy_player_id
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into build_row
	from public.builds
	where player_id = save_row.legacy_player_id
	for update;

	if build_row.player_id is null then
		raise exception 'BUILD_NOT_FOUND' using errcode = 'P0001';
	end if;

	if normalized_endpoint = 'build/spell-behavior' then
		payload_spell_id := nullif(trim(coalesce(p_request_payload->>'spell_id', '')), '');
		payload_behavior := coalesce(p_request_payload->'behavior', '{}'::jsonb);

		if payload_spell_id is null then
			raise exception 'INVALID_SPELL' using errcode = 'P0001';
		end if;

		if jsonb_typeof(payload_behavior) <> 'object' then
			raise exception 'INVALID_PAYLOAD' using errcode = 'P0001';
		end if;

		if not exists (
			select 1
			from jsonb_array_elements_text(coalesce(build_row.spell_slots, '[]'::jsonb)) as equipped(value)
			where equipped.value = payload_spell_id
		) then
			raise exception 'SPELL_NOT_EQUIPPED' using errcode = 'P0001';
		end if;

		insert into public.player_spell_behaviors as behavior_row (
			player_id,
			spell_id,
			behavior,
			updated_at
		)
		values (
			save_row.legacy_player_id,
			payload_spell_id,
			payload_behavior,
			now()
		)
		on conflict (player_id, spell_id) do update
		set
			behavior = excluded.behavior,
			updated_at = excluded.updated_at;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_build_spell_behavior_response_v1',
			'endpoint', normalized_endpoint,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'account_profile_id', save_row.account_profile_id,
			'game_save_id', save_row.id,
			'legacy_player_id', save_row.legacy_player_id,
			'ruleset', public.foundation_ruleset_json_v1(ruleset_row),
			'updated_behavior', jsonb_build_object('spell_id', payload_spell_id, 'behavior', payload_behavior)
		);
	elsif normalized_endpoint = 'build/potion/equip' then
		payload_slot_index := coalesce((p_request_payload->>'slot_index')::integer, 1);
		payload_item_id := nullif(trim(coalesce(p_request_payload->>'item_id', '')), '');

		if payload_slot_index <> 1 then
			raise exception 'INVALID_SLOT' using errcode = 'P0001';
		end if;

		if payload_item_id is not null then
			select *
			into consumable_row
			from public.player_consumables
			where player_id = save_row.legacy_player_id
				and item_id = payload_item_id
			for update;

			if consumable_row.player_id is null or consumable_row.quantity <= 0 then
				raise exception 'POTION_NOT_OWNED' using errcode = 'P0001';
			end if;
		end if;

		select *
		into slot_row
		from public.player_potion_slots
		where player_id = save_row.legacy_player_id
			and slot_index = payload_slot_index
		for update;

		insert into public.player_potion_slots as potion_slot (
			player_id,
			slot_index,
			potion_id,
			behavior,
			updated_at
		)
		values (
			save_row.legacy_player_id,
			payload_slot_index,
			payload_item_id,
			coalesce(slot_row.behavior, default_potion_behavior),
			now()
		)
		on conflict (player_id, slot_index) do update
		set
			potion_id = excluded.potion_id,
			behavior = coalesce(potion_slot.behavior, excluded.behavior),
			updated_at = excluded.updated_at
		returning * into slot_row;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_build_potion_equip_response_v1',
			'endpoint', normalized_endpoint,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'account_profile_id', save_row.account_profile_id,
			'game_save_id', save_row.id,
			'legacy_player_id', save_row.legacy_player_id,
			'ruleset', public.foundation_ruleset_json_v1(ruleset_row),
			'equipped_potion', jsonb_build_object('slot_index', payload_slot_index, 'potion_id', payload_item_id),
			'potion_slot', to_jsonb(slot_row)
		);
	else
		payload_slot_index := coalesce((p_request_payload->>'slot_index')::integer, 1);
		payload_behavior := coalesce(p_request_payload->'behavior', '{}'::jsonb);

		if payload_slot_index <> 1 then
			raise exception 'INVALID_SLOT' using errcode = 'P0001';
		end if;

		if jsonb_typeof(payload_behavior) <> 'object' then
			raise exception 'INVALID_PAYLOAD' using errcode = 'P0001';
		end if;

		select *
		into slot_row
		from public.player_potion_slots
		where player_id = save_row.legacy_player_id
			and slot_index = payload_slot_index
		for update;

		insert into public.player_potion_slots as potion_slot (
			player_id,
			slot_index,
			potion_id,
			behavior,
			updated_at
		)
		values (
			save_row.legacy_player_id,
			payload_slot_index,
			slot_row.potion_id,
			payload_behavior,
			now()
		)
		on conflict (player_id, slot_index) do update
		set
			potion_id = potion_slot.potion_id,
			behavior = excluded.behavior,
			updated_at = excluded.updated_at
		returning * into slot_row;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_build_potion_behavior_response_v1',
			'endpoint', normalized_endpoint,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'account_profile_id', save_row.account_profile_id,
			'game_save_id', save_row.id,
			'legacy_player_id', save_row.legacy_player_id,
			'ruleset', public.foundation_ruleset_json_v1(ruleset_row),
			'updated_behavior', jsonb_build_object('slot_index', payload_slot_index, 'behavior', payload_behavior),
			'potion_slot', to_jsonb(slot_row)
		);
	end if;

	return public.complete_idempotency(
		save_row.legacy_player_id,
		normalized_endpoint,
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

create or replace function public.build_spell_behavior_v1(
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
begin
	return public.apply_build_preparation_mutation_v1(p_game_save_id, 'build/spell-behavior', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.build_potion_equip_v1(
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
begin
	return public.apply_build_preparation_mutation_v1(p_game_save_id, 'build/potion/equip', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.build_potion_behavior_v1(
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
begin
	return public.apply_build_preparation_mutation_v1(p_game_save_id, 'build/potion-behavior', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.apply_social_mutation_v1(
	p_game_save_id uuid,
	p_endpoint text,
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
	target_row public.players%rowtype;
	target_social_row public.players%rowtype;
	membership_row public.guild_members%rowtype;
	channel_row public.chat_channels%rowtype;
	message_row public.chat_messages%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	normalized_endpoint text := trim(coalesce(p_endpoint, ''));
	payload_username text;
	payload_content text;
begin
	if normalized_endpoint not in ('social/friends/add', 'social/chat/send') then
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
	end if;

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

	if save_row.ruleset_publication_id is not null then
		select *
		into ruleset_row
		from public.ruleset_registry
		where publication_id = save_row.ruleset_publication_id;
	else
		ruleset_row := public.resolve_ruleset_publication_v1(
			coalesce(nullif(save_row.ruleset_id, ''), 'foundation_ruleset_v0'),
			coalesce(save_row.ruleset_version, 1),
			coalesce(save_row.season_context->>'channel', 'internal_alpha'),
			coalesce(save_row.season_context->>'cohort', 'all')
		);
	end if;

	if ruleset_row.publication_id is null then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		normalized_endpoint,
		p_request_id,
		p_request_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into player_row
	from public.players
	where id = save_row.legacy_player_id
	for update;

	if player_row.id is null then
		raise exception 'PLAYER_NOT_FOUND' using errcode = 'P0001';
	end if;

	if normalized_endpoint = 'social/friends/add' then
		payload_username := nullif(trim(coalesce(p_request_payload->>'username', '')), '');
		if payload_username is null then
			raise exception 'INVALID_USERNAME' using errcode = 'P0001';
		end if;

		select *
		into target_row
		from public.players
		where username = payload_username
		order by case when save_type = 'normal' then 0 else 1 end
		limit 1;

		if target_row.id is null then
			raise exception 'USER_NOT_FOUND' using errcode = 'P0001';
		end if;

		if target_row.save_type = 'normal' then
			target_social_row := target_row;
		else
			select *
			into target_social_row
			from public.players
			where auth_user_id = target_row.auth_user_id
				and save_type = 'normal'
			limit 1;

			if target_social_row.id is null then
				target_social_row := target_row;
			end if;
		end if;

		if target_social_row.auth_user_id = player_row.auth_user_id then
			raise exception 'INVALID_FRIEND' using errcode = 'P0001';
		end if;

		insert into public.friendships as friendship (
			player_id,
			friend_id,
			status,
			updated_at
		)
		values
			(player_row.id, target_social_row.id, 'accepted', now()),
			(target_social_row.id, player_row.id, 'accepted', now())
		on conflict (player_id, friend_id) do update
		set
			status = 'accepted',
			updated_at = excluded.updated_at;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_social_friend_add_response_v1',
			'endpoint', normalized_endpoint,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'account_profile_id', save_row.account_profile_id,
			'game_save_id', save_row.id,
			'legacy_player_id', save_row.legacy_player_id,
			'ruleset', public.foundation_ruleset_json_v1(ruleset_row),
			'friend', jsonb_build_object(
				'id', target_social_row.id,
				'username', target_social_row.username,
				'save_type', target_social_row.save_type
			)
		);
	else
		payload_content := substring(nullif(trim(coalesce(p_request_payload->>'content', '')), '') from 1 for 280);
		if payload_content is null then
			raise exception 'EMPTY_MESSAGE' using errcode = 'P0001';
		end if;

		select *
		into membership_row
		from public.guild_members
		where player_id = player_row.id
		for update;

		if membership_row.guild_id is null then
			raise exception 'GUILD_REQUIRED' using errcode = 'P0001';
		end if;

		select *
		into channel_row
		from public.chat_channels
		where channel_type = 'guild'
			and guild_id = membership_row.guild_id
		limit 1;

		if channel_row.id is null then
			raise exception 'CHAT_SEND_FAILED' using errcode = 'P0001';
		end if;

		if exists (
			select 1
			from public.chat_messages
			where channel_id = channel_row.id
				and sender_id = player_row.id
				and deleted_at is null
				and created_at >= now() - interval '2 seconds'
			limit 1
		) then
			raise exception 'CHAT_RATE_LIMITED' using errcode = 'P0001';
		end if;

		insert into public.chat_messages (
			channel_id,
			sender_id,
			content
		)
		values (
			channel_row.id,
			player_row.id,
			payload_content
		)
		returning * into message_row;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_social_chat_send_response_v1',
			'endpoint', normalized_endpoint,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'account_profile_id', save_row.account_profile_id,
			'game_save_id', save_row.id,
			'legacy_player_id', save_row.legacy_player_id,
			'ruleset', public.foundation_ruleset_json_v1(ruleset_row),
			'message', to_jsonb(message_row)
		);
	end if;

	return public.complete_idempotency(
		save_row.legacy_player_id,
		normalized_endpoint,
		p_request_id,
		response_payload,
		p_request_hash
	);
end;
$$;

create or replace function public.social_friend_add_v1(
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
begin
	return public.apply_social_mutation_v1(p_game_save_id, 'social/friends/add', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.social_chat_send_v1(
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
begin
	return public.apply_social_mutation_v1(p_game_save_id, 'social/chat/send', p_request_id, p_request_hash, p_request_payload);
end;
$$;

revoke all on function public.ensure_foundation_profile_and_saves(uuid, text) from public, anon, authenticated;
grant execute on function public.ensure_foundation_profile_and_saves(uuid, text) to service_role;

revoke all on function public.reserve_idempotency(uuid, text, uuid, text, text) from public, anon, authenticated;
grant execute on function public.reserve_idempotency(uuid, text, uuid, text, text) to service_role;

revoke all on function public.complete_idempotency(uuid, text, uuid, jsonb, text) from public, anon, authenticated;
grant execute on function public.complete_idempotency(uuid, text, uuid, jsonb, text) to service_role;

revoke all on function public.fail_idempotency(uuid, text, uuid, jsonb) from public, anon, authenticated;
grant execute on function public.fail_idempotency(uuid, text, uuid, jsonb) to service_role;

revoke all on function public.reconcile_resource_balance(uuid, jsonb, text, uuid, uuid) from public, anon, authenticated;
grant execute on function public.reconcile_resource_balance(uuid, jsonb, text, uuid, uuid) to service_role;

revoke all on function public.foundation_command_v1(uuid, text, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.foundation_command_v1(uuid, text, uuid, text, jsonb) to service_role;

revoke all on function public.complete_due_base_jobs_v1(uuid, timestamptz) from public, anon, authenticated;
grant execute on function public.complete_due_base_jobs_v1(uuid, timestamptz) to service_role;

revoke all on function public.collect_base_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.collect_base_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.start_base_upgrade_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.start_base_upgrade_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.foundation_jsonb_numeric_v1(jsonb, text) from public, anon, authenticated;
grant execute on function public.foundation_jsonb_numeric_v1(jsonb, text) to service_role;

revoke all on function public.foundation_jsonb_integer_v1(jsonb, text) from public, anon, authenticated;
grant execute on function public.foundation_jsonb_integer_v1(jsonb, text) to service_role;

revoke all on function public.apply_foundation_mutation_v1(uuid, text, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.apply_foundation_mutation_v1(uuid, text, uuid, text, jsonb) to service_role;

revoke all on function public.request_battle_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.request_battle_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.equip_build_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.equip_build_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.crush_bones_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.crush_bones_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.craft_item_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.craft_item_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.claim_reward_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.claim_reward_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.alpha_purchase_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.alpha_purchase_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.guild_create_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.guild_create_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.guild_join_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.guild_join_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.active_ruleset_publication_v1(text, text, text) from public, anon, authenticated;
grant execute on function public.active_ruleset_publication_v1(text, text, text) to service_role;

revoke all on function public.resolve_ruleset_publication_v1(text, integer, text, text) from public, anon, authenticated;
grant execute on function public.resolve_ruleset_publication_v1(text, integer, text, text) to service_role;

revoke all on function public.foundation_account_context_v1(uuid) from public, anon, authenticated;
grant execute on function public.foundation_account_context_v1(uuid) to service_role;

revoke all on function public.resource_reconciliation_report_v1(uuid) from public, anon, authenticated;
grant execute on function public.resource_reconciliation_report_v1(uuid) to service_role;

revoke all on function public.admin_adjust_resource_balance_v1(uuid, jsonb, text, uuid, uuid) from public, anon, authenticated;
grant execute on function public.admin_adjust_resource_balance_v1(uuid, jsonb, text, uuid, uuid) to service_role;

revoke all on function public.admin_lookup_account_v1(uuid, text, uuid, uuid) from public, anon, authenticated;
grant execute on function public.admin_lookup_account_v1(uuid, text, uuid, uuid) to service_role;

revoke all on function public.admin_battle_diagnostics_v1(uuid) from public, anon, authenticated;
grant execute on function public.admin_battle_diagnostics_v1(uuid) to service_role;

revoke all on function public.admin_flag_account_v1(uuid, text, text, uuid, uuid) from public, anon, authenticated;
grant execute on function public.admin_flag_account_v1(uuid, text, text, uuid, uuid) to service_role;

revoke all on function public.apply_build_preparation_mutation_v1(uuid, text, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.apply_build_preparation_mutation_v1(uuid, text, uuid, text, jsonb) to service_role;

revoke all on function public.build_spell_behavior_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.build_spell_behavior_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.build_potion_equip_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.build_potion_equip_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.build_potion_behavior_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.build_potion_behavior_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.apply_social_mutation_v1(uuid, text, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.apply_social_mutation_v1(uuid, text, uuid, text, jsonb) to service_role;

revoke all on function public.social_friend_add_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.social_friend_add_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.social_chat_send_v1(uuid, uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.social_chat_send_v1(uuid, uuid, text, jsonb) to service_role;
