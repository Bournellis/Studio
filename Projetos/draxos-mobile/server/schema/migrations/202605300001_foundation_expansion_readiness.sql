-- DraxosMobile Foundation Expansion Readiness.
-- Additive account/save, ruleset, admin audit and idempotency scaffolds.

create extension if not exists "pgcrypto";

create table if not exists public.ruleset_registry (
	ruleset_id text primary key,
	ruleset_version integer not null,
	content_hash text not null,
	simulator_hash text not null,
	schema_version text not null,
	active_from timestamptz not null default now(),
	channel text not null default 'internal_alpha',
	cohort text not null default 'all',
	status text not null default 'active' check (status in ('draft', 'active', 'deprecated', 'retired')),
	publication_payload jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

insert into public.ruleset_registry (
	ruleset_id,
	ruleset_version,
	content_hash,
	simulator_hash,
	schema_version,
	active_from,
	channel,
	cohort,
	status,
	publication_payload
)
values (
	'foundation_ruleset_v0',
	1,
	'5b7121a37a78e966c06098cc70283dabc5dbbcc1d3f9a21d279b855d09aee1e7',
	'6387afc69b1862c2c63b1fe04a85da42574eb0a6ab5ca46e8ae8950ed5b11536',
	'foundation_ruleset_manifest_v1',
	now(),
	'internal_alpha',
	'all',
	'active',
	'{"purpose": "Foundation Expansion Readiness default ruleset.", "authoring_source": "data/rulesets/foundation_ruleset_v0.json", "registry_role": "publication registry"}'::jsonb
)
on conflict (ruleset_id) do update set
	ruleset_version = excluded.ruleset_version,
	content_hash = excluded.content_hash,
	simulator_hash = excluded.simulator_hash,
	schema_version = excluded.schema_version,
	active_from = least(public.ruleset_registry.active_from, excluded.active_from),
	channel = excluded.channel,
	cohort = excluded.cohort,
	status = excluded.status,
	publication_payload = excluded.publication_payload,
	updated_at = now();

create table if not exists public.account_profiles (
	id uuid primary key default gen_random_uuid(),
	auth_user_id uuid not null unique references auth.users(id) on delete cascade,
	canonical_player_id uuid references public.players(id) on delete set null,
	username text,
	account_type text not null default 'registered' check (account_type in ('guest', 'registered', 'google')),
	status text not null default 'active' check (status in ('active', 'suspended', 'deleted')),
	metadata jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now()
);

create index if not exists account_profiles_auth_user_id_idx
	on public.account_profiles (auth_user_id);

create index if not exists account_profiles_canonical_player_idx
	on public.account_profiles (canonical_player_id);

create table if not exists public.game_saves (
	id uuid primary key default gen_random_uuid(),
	account_profile_id uuid not null references public.account_profiles(id) on delete cascade,
	legacy_player_id uuid unique references public.players(id) on delete set null,
	save_type text not null check (save_type in ('normal', 'progression_lab')),
	slot_key text not null,
	display_name text not null,
	lifecycle_status text not null default 'active' check (lifecycle_status in ('active', 'archived', 'resetting', 'deleted')),
	ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id),
	ruleset_version integer not null default 1,
	snapshot jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	unique (account_profile_id, save_type),
	unique (account_profile_id, slot_key)
);

create index if not exists game_saves_account_profile_idx
	on public.game_saves (account_profile_id, lifecycle_status);

create index if not exists game_saves_ruleset_idx
	on public.game_saves (ruleset_id, ruleset_version);

create table if not exists public.admin_audit_log (
	id uuid primary key default gen_random_uuid(),
	actor_auth_user_id uuid references auth.users(id) on delete set null,
	account_profile_id uuid references public.account_profiles(id) on delete set null,
	game_save_id uuid references public.game_saves(id) on delete set null,
	player_id uuid references public.players(id) on delete set null,
	action text not null,
	reason text,
	request_id uuid,
	before_state jsonb not null default '{}'::jsonb,
	after_state jsonb not null default '{}'::jsonb,
	metadata jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now()
);

create index if not exists admin_audit_log_account_profile_idx
	on public.admin_audit_log (account_profile_id, created_at desc);

create index if not exists admin_audit_log_game_save_idx
	on public.admin_audit_log (game_save_id, created_at desc);

create index if not exists admin_audit_log_player_idx
	on public.admin_audit_log (player_id, created_at desc);

alter table public.account_profiles enable row level security;
alter table public.game_saves enable row level security;
alter table public.ruleset_registry enable row level security;
alter table public.admin_audit_log enable row level security;

drop policy if exists "account_profiles_select_own" on public.account_profiles;
create policy "account_profiles_select_own"
	on public.account_profiles for select
	using (auth.uid() = auth_user_id);

drop policy if exists "game_saves_select_own" on public.game_saves;
create policy "game_saves_select_own"
	on public.game_saves for select
	using (
		account_profile_id in (
			select id from public.account_profiles where auth_user_id = auth.uid()
		)
	);

drop policy if exists "ruleset_registry_select_active" on public.ruleset_registry;
create policy "ruleset_registry_select_active"
	on public.ruleset_registry for select
	using (status in ('active', 'deprecated'));

alter table public.idempotency_keys
	add column if not exists request_hash text,
	add column if not exists scope_id text,
	add column if not exists status text not null default 'completed',
	add column if not exists completed_at timestamptz,
	add column if not exists failed_at timestamptz;

update public.idempotency_keys
set scope_id = player_id::text
where scope_id is null;

update public.idempotency_keys
set status = 'completed'
where status is null;

update public.idempotency_keys
set completed_at = created_at
where status = 'completed'
	and completed_at is null;

do $$
begin
	if not exists (
		select 1 from pg_constraint where conname = 'idempotency_keys_status_check'
	) then
		alter table public.idempotency_keys
			add constraint idempotency_keys_status_check
			check (status in ('pending', 'completed', 'failed'));
	end if;
end $$;

create index if not exists idempotency_keys_scope_status_idx
	on public.idempotency_keys (scope_id, endpoint, status, created_at desc);

create index if not exists idempotency_keys_request_hash_idx
	on public.idempotency_keys (request_hash)
	where request_hash is not null;

create or replace function public.set_idempotency_scope_defaults()
returns trigger
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
	new.scope_id := coalesce(nullif(new.scope_id, ''), new.player_id::text);
	new.status := coalesce(nullif(new.status, ''), 'completed');

	if new.status = 'completed' and new.completed_at is null then
		new.completed_at := now();
	end if;

	if new.status = 'failed' and new.failed_at is null then
		new.failed_at := now();
	end if;

	return new;
end;
$$;

drop trigger if exists idempotency_keys_scope_defaults on public.idempotency_keys;

create trigger idempotency_keys_scope_defaults
before insert or update on public.idempotency_keys
for each row
execute function public.set_idempotency_scope_defaults();

alter table public.battles
	add column if not exists ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id),
	add column if not exists ruleset_version integer not null default 1;

alter table public.construction_jobs
	add column if not exists ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id),
	add column if not exists ruleset_version integer not null default 1;

alter table public.reward_claims
	add column if not exists ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id),
	add column if not exists ruleset_version integer not null default 1;

alter table public.alpha_purchases
	add column if not exists ruleset_id text not null default 'foundation_ruleset_v0' references public.ruleset_registry(ruleset_id),
	add column if not exists ruleset_version integer not null default 1;

create index if not exists battles_ruleset_idx
	on public.battles (ruleset_id, ruleset_version, created_at desc);

create index if not exists construction_jobs_ruleset_idx
	on public.construction_jobs (ruleset_id, ruleset_version, created_at desc);

create index if not exists reward_claims_ruleset_idx
	on public.reward_claims (ruleset_id, ruleset_version, created_at desc);

create index if not exists alpha_purchases_ruleset_idx
	on public.alpha_purchases (ruleset_id, ruleset_version, created_at desc);

insert into public.account_profiles (
	auth_user_id,
	canonical_player_id,
	username,
	account_type,
	created_at,
	updated_at
)
select
	grouped.auth_user_id,
	grouped.canonical_player_id,
	grouped.username,
	grouped.account_type,
	grouped.created_at,
	now()
from (
	select
		p.auth_user_id,
		(array_agg(p.id order by case when p.save_type = 'normal' then 0 else 1 end, p.created_at))[1] as canonical_player_id,
		(array_agg(p.username order by case when p.save_type = 'normal' then 0 else 1 end, p.created_at))[1] as username,
		(array_agg(p.account_type order by case when p.save_type = 'normal' then 0 else 1 end, p.created_at))[1] as account_type,
		min(p.created_at) as created_at
	from public.players as p
	group by p.auth_user_id
) as grouped
on conflict (auth_user_id) do update set
	canonical_player_id = coalesce(public.account_profiles.canonical_player_id, excluded.canonical_player_id),
	username = coalesce(nullif(public.account_profiles.username, ''), excluded.username),
	account_type = excluded.account_type,
	updated_at = now();

insert into public.game_saves (
	account_profile_id,
	legacy_player_id,
	save_type,
	slot_key,
	display_name,
	ruleset_id,
	ruleset_version,
	snapshot,
	created_at,
	updated_at
)
select
	ap.id,
	p.id,
	p.save_type,
	p.save_type,
	case
		when p.save_type = 'progression_lab' then 'Progression Lab'
		else 'Normal'
	end,
	'foundation_ruleset_v0',
	1,
	jsonb_build_object(
		'legacy_player_id', p.id,
		'player_level', p.level,
		'player_xp', p.xp,
		'player_power', p.power
	),
	p.created_at,
	now()
from public.players as p
join public.account_profiles as ap on ap.auth_user_id = p.auth_user_id
on conflict (account_profile_id, save_type) do update set
	legacy_player_id = coalesce(public.game_saves.legacy_player_id, excluded.legacy_player_id),
	slot_key = excluded.slot_key,
	display_name = excluded.display_name,
	ruleset_id = excluded.ruleset_id,
	ruleset_version = excluded.ruleset_version,
	snapshot = excluded.snapshot,
	updated_at = now();

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
	save_count integer := 0;
begin
	if p_auth_user_id is null then
		raise exception 'UNAUTHENTICATED' using errcode = 'P0001';
	end if;

	if not exists (select 1 from auth.users where id = p_auth_user_id) then
		raise exception 'AUTH_USER_NOT_FOUND' using errcode = 'P0001';
	end if;

	if not exists (
		select 1 from public.ruleset_registry where ruleset_id = p_ruleset_id
	) then
		raise exception 'RULESET_NOT_FOUND' using errcode = 'P0001';
	end if;

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
		ruleset_id,
		ruleset_version,
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
		p_ruleset_id,
		(select ruleset_version from public.ruleset_registry where ruleset_id = p_ruleset_id),
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
		ruleset_id = excluded.ruleset_id,
		ruleset_version = excluded.ruleset_version,
		snapshot = excluded.snapshot,
		updated_at = now();

	select count(*)
	into save_count
	from public.game_saves
	where account_profile_id = profile_row.id
		and lifecycle_status = 'active';

	return jsonb_build_object(
		'ok', true,
		'account_profile_id', profile_row.id,
		'auth_user_id', profile_row.auth_user_id,
		'canonical_player_id', profile_row.canonical_player_id,
		'save_count', save_count
	);
end;
$$;

create or replace function public.reserve_idempotency(
	p_player_id uuid,
	p_endpoint text,
	p_request_id uuid,
	p_request_hash text,
	p_scope_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_endpoint text := trim(coalesce(p_endpoint, ''));
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	normalized_scope text := nullif(trim(coalesce(p_scope_id, '')), '');
	existing_row public.idempotency_keys%rowtype;
begin
	if p_player_id is null then
		raise exception 'INVALID_PLAYER_ID' using errcode = 'P0001';
	end if;

	if normalized_endpoint = '' then
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	select *
	into existing_row
	from public.idempotency_keys
	where player_id = p_player_id
		and endpoint = normalized_endpoint
		and request_id = p_request_id
	for update;

	if existing_row.player_id is not null then
		if existing_row.request_hash is not null and existing_row.request_hash <> normalized_hash then
			raise exception 'IDEMPOTENCY_HASH_MISMATCH' using errcode = 'P0001';
		end if;

		return jsonb_build_object(
			'ok', true,
			'pending_created', false,
			'status', existing_row.status,
			'response_payload', existing_row.response_payload
		);
	end if;

	insert into public.idempotency_keys (
		player_id,
		endpoint,
		request_id,
		request_hash,
		scope_id,
		status,
		response_payload
	)
	values (
		p_player_id,
		normalized_endpoint,
		p_request_id,
		normalized_hash,
		coalesce(normalized_scope, p_player_id::text),
		'pending',
		'{}'::jsonb
	);

	return jsonb_build_object(
		'ok', true,
		'pending_created', true,
		'status', 'pending',
		'response_payload', '{}'::jsonb
	);
end;
$$;

create or replace function public.complete_idempotency(
	p_player_id uuid,
	p_endpoint text,
	p_request_id uuid,
	p_response_payload jsonb,
	p_request_hash text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_endpoint text := trim(coalesce(p_endpoint, ''));
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	updated_payload jsonb;
begin
	if p_player_id is null then
		raise exception 'INVALID_PLAYER_ID' using errcode = 'P0001';
	end if;

	if normalized_endpoint = '' then
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	update public.idempotency_keys
	set
		response_payload = coalesce(p_response_payload, '{}'::jsonb),
		request_hash = coalesce(request_hash, normalized_hash),
		status = 'completed',
		completed_at = now(),
		failed_at = null
	where player_id = p_player_id
		and endpoint = normalized_endpoint
		and request_id = p_request_id
	returning response_payload into updated_payload;

	if updated_payload is null then
		raise exception 'IDEMPOTENCY_PENDING_NOT_FOUND' using errcode = 'P0001';
	end if;

	return updated_payload;
end;
$$;

create or replace function public.fail_idempotency(
	p_player_id uuid,
	p_endpoint text,
	p_request_id uuid,
	p_error_payload jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	normalized_endpoint text := trim(coalesce(p_endpoint, ''));
	updated_payload jsonb;
begin
	if p_player_id is null then
		raise exception 'INVALID_PLAYER_ID' using errcode = 'P0001';
	end if;

	if normalized_endpoint = '' then
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
	end if;

	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;

	update public.idempotency_keys
	set
		response_payload = coalesce(p_error_payload, '{}'::jsonb),
		status = 'failed',
		failed_at = now()
	where player_id = p_player_id
		and endpoint = normalized_endpoint
		and request_id = p_request_id
	returning response_payload into updated_payload;

	if updated_payload is null then
		raise exception 'IDEMPOTENCY_PENDING_NOT_FOUND' using errcode = 'P0001';
	end if;

	return updated_payload;
end;
$$;

create or replace function public.reconcile_resource_balance(
	p_player_id uuid,
	p_expected_resources jsonb,
	p_reason text default null,
	p_request_id uuid default null,
	p_actor_auth_user_id uuid default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
declare
	resource_before public.resources%rowtype;
	resource_after public.resources%rowtype;
	profile_id uuid;
	save_id uuid;
	request_id uuid := coalesce(p_request_id, gen_random_uuid());
	before_payload jsonb;
	after_payload jsonb;
	delta_payload jsonb;
begin
	if p_player_id is null then
		raise exception 'INVALID_PLAYER_ID' using errcode = 'P0001';
	end if;

	if p_expected_resources is null or jsonb_typeof(p_expected_resources) <> 'object' then
		raise exception 'INVALID_RESOURCE_PAYLOAD' using errcode = 'P0001';
	end if;

	select *
	into resource_before
	from public.resources
	where player_id = p_player_id
	for update;

	if resource_before.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	before_payload := jsonb_build_object(
		'almas', resource_before.almas,
		'energia', resource_before.energia,
		'sangue', resource_before.sangue,
		'cristais', resource_before.cristais,
		'ossos', resource_before.ossos,
		'po_osso', resource_before.po_osso,
		'diamante', resource_before.diamante
	);

	update public.resources
	set
		almas = greatest(0, coalesce((p_expected_resources->>'almas')::numeric, almas)),
		energia = greatest(0, coalesce((p_expected_resources->>'energia')::numeric, energia)),
		sangue = greatest(0, coalesce((p_expected_resources->>'sangue')::numeric, sangue)),
		cristais = greatest(0, coalesce((p_expected_resources->>'cristais')::numeric, cristais)),
		ossos = greatest(0, round(coalesce((p_expected_resources->>'ossos')::numeric, ossos))),
		po_osso = greatest(0, coalesce((p_expected_resources->>'po_osso')::integer, po_osso)),
		diamante = greatest(0, coalesce((p_expected_resources->>'diamante')::integer, diamante)),
		updated_at = now()
	where player_id = p_player_id
	returning * into resource_after;

	after_payload := jsonb_build_object(
		'almas', resource_after.almas,
		'energia', resource_after.energia,
		'sangue', resource_after.sangue,
		'cristais', resource_after.cristais,
		'ossos', resource_after.ossos,
		'po_osso', resource_after.po_osso,
		'diamante', resource_after.diamante
	);

	delta_payload := jsonb_build_object(
		'almas', resource_after.almas - resource_before.almas,
		'energia', resource_after.energia - resource_before.energia,
		'sangue', resource_after.sangue - resource_before.sangue,
		'cristais', resource_after.cristais - resource_before.cristais,
		'ossos', resource_after.ossos - resource_before.ossos,
		'po_osso', resource_after.po_osso - resource_before.po_osso,
		'diamante', resource_after.diamante - resource_before.diamante
	);

	select gs.account_profile_id, gs.id
	into profile_id, save_id
	from public.game_saves as gs
	where gs.legacy_player_id = p_player_id
	limit 1;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (p_player_id, 'admin/reconcile_resource_balance', request_id, delta_payload);

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
		profile_id,
		save_id,
		p_player_id,
		'reconcile_resource_balance',
		p_reason,
		request_id,
		before_payload,
		after_payload,
		jsonb_build_object('delta', delta_payload)
	);

	return jsonb_build_object(
		'ok', true,
		'player_id', p_player_id,
		'request_id', request_id,
		'before', before_payload,
		'after', after_payload,
		'delta', delta_payload
	);
end;
$$;

revoke all on function public.ensure_foundation_profile_and_saves(uuid, text) from public;
grant execute on function public.ensure_foundation_profile_and_saves(uuid, text) to service_role;

revoke all on function public.reserve_idempotency(uuid, text, uuid, text, text) from public;
grant execute on function public.reserve_idempotency(uuid, text, uuid, text, text) to service_role;

revoke all on function public.complete_idempotency(uuid, text, uuid, jsonb, text) from public;
grant execute on function public.complete_idempotency(uuid, text, uuid, jsonb, text) to service_role;

revoke all on function public.fail_idempotency(uuid, text, uuid, jsonb) from public;
grant execute on function public.fail_idempotency(uuid, text, uuid, jsonb) to service_role;

revoke all on function public.reconcile_resource_balance(uuid, jsonb, text, uuid, uuid) from public;
grant execute on function public.reconcile_resource_balance(uuid, jsonb, text, uuid, uuid) to service_role;
