-- DraxosMobile Track 16 - Behavior, bone dust and potion crafting.
-- Keeps crafting, build behavior and battle consumable state save-scoped by player.

alter table public.resources
	add column if not exists po_osso integer not null default 0 check (po_osso >= 0);

update public.resources
set ossos = round(ossos * 100);

alter table public.resources
	alter column ossos type numeric(12, 0) using round(ossos);

do $$
begin
	if not exists (
		select 1 from pg_constraint where conname = 'resources_ossos_whole'
	) then
		alter table public.resources
			add constraint resources_ossos_whole check (ossos = trunc(ossos));
	end if;
end $$;

create table if not exists public.player_consumables (
	player_id uuid not null references public.players(id) on delete cascade,
	item_id text not null,
	quantity integer not null default 0 check (quantity >= 0),
	updated_at timestamptz not null default now(),
	primary key (player_id, item_id)
);

create table if not exists public.player_potion_slots (
	player_id uuid not null references public.players(id) on delete cascade,
	slot_index integer not null check (slot_index = 1),
	potion_id text,
	behavior jsonb not null default '{"enabled": true, "hp": {"mode": "below", "percent": 40}, "mana": {"mode": "ignore", "percent": 0}}'::jsonb,
	updated_at timestamptz not null default now(),
	primary key (player_id, slot_index)
);

create table if not exists public.player_spell_behaviors (
	player_id uuid not null references public.players(id) on delete cascade,
	spell_id text not null,
	behavior jsonb not null,
	updated_at timestamptz not null default now(),
	primary key (player_id, spell_id)
);

create table if not exists public.item_transactions (
	id uuid primary key default gen_random_uuid(),
	player_id uuid not null references public.players(id) on delete cascade,
	source text not null,
	request_id uuid,
	item_id text not null,
	delta integer not null,
	payload jsonb not null default '{}'::jsonb,
	created_at timestamptz not null default now()
);

insert into public.player_potion_slots (player_id, slot_index)
select id, 1
from public.players
on conflict (player_id, slot_index) do nothing;

create or replace function public.create_default_potion_slot_for_player()
returns trigger
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
	insert into public.player_potion_slots (player_id, slot_index)
	values (new.id, 1)
	on conflict (player_id, slot_index) do nothing;

	return new;
end;
$$;

drop trigger if exists players_default_potion_slot on public.players;

create trigger players_default_potion_slot
after insert on public.players
for each row
execute function public.create_default_potion_slot_for_player();

update public.resource_transactions
set delta = jsonb_set(
	delta,
	'{ossos}',
	to_jsonb(round((delta->>'ossos')::numeric * 100)::integer),
	false
)
where delta ? 'ossos';

update public.battles
set reward_payload = jsonb_set(
	reward_payload,
	'{resources,ossos}',
	to_jsonb(round((reward_payload #>> '{resources,ossos}')::numeric * 100)::integer),
	false
)
where reward_payload #>> '{resources,ossos}' is not null;

update public.battles as battle
set event_log = scaled_events.event_log
from (
	select
		b.id,
		jsonb_agg(
			case
				when event.value #>> '{resources,ossos}' is not null then jsonb_set(
					event.value,
					'{resources,ossos}',
					to_jsonb(round((event.value #>> '{resources,ossos}')::numeric * 100)::integer),
					false
				)
				else event.value
			end
			order by event.ordinality
		) as event_log
	from public.battles as b,
		jsonb_array_elements(b.event_log) with ordinality as event(value, ordinality)
	group by b.id
) as scaled_events
where battle.id = scaled_events.id
	and battle.event_log::text like '%"ossos"%';

update public.reward_claims
set reward_payload = jsonb_set(
	reward_payload,
	'{resources,ossos}',
	to_jsonb(round((reward_payload #>> '{resources,ossos}')::numeric * 100)::integer),
	false
)
where reward_payload #>> '{resources,ossos}' is not null;

update public.alpha_purchases
set purchase_payload = jsonb_set(
	purchase_payload,
	'{resources,ossos}',
	to_jsonb(round((purchase_payload #>> '{resources,ossos}')::numeric * 100)::integer),
	false
)
where purchase_payload #>> '{resources,ossos}' is not null;

update public.alpha_purchases
set purchase_payload = jsonb_set(
	purchase_payload,
	'{delta,ossos}',
	to_jsonb(round((purchase_payload #>> '{delta,ossos}')::numeric * 100)::integer),
	false
)
where purchase_payload #>> '{delta,ossos}' is not null;

update public.battle_passes
set free_rewards = jsonb_set(
	jsonb_set(
		free_rewards,
		'{totals,ossos}',
		to_jsonb(round((free_rewards #>> '{totals,ossos}')::numeric * 100)::integer),
		false
	),
	'{sample_rewards,0,resources,ossos}',
	to_jsonb(round((free_rewards #>> '{sample_rewards,0,resources,ossos}')::numeric * 100)::integer),
	false
)
where free_rewards #>> '{totals,ossos}' is not null
	and free_rewards #>> '{sample_rewards,0,resources,ossos}' is not null;

update public.battle_passes
set premium_rewards = jsonb_set(
	jsonb_set(
		premium_rewards,
		'{totals,ossos}',
		to_jsonb(round((premium_rewards #>> '{totals,ossos}')::numeric * 100)::integer),
		false
	),
	'{sample_rewards,0,resources,ossos}',
	to_jsonb(round((premium_rewards #>> '{sample_rewards,0,resources,ossos}')::numeric * 100)::integer),
	false
)
where premium_rewards #>> '{totals,ossos}' is not null
	and premium_rewards #>> '{sample_rewards,0,resources,ossos}' is not null;

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
		'resources', jsonb_build_object('xp', 5, 'ossos', 100)
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
	set ossos = ossos + 100,
		updated_at = now()
	where player_id = player_row.id;

	insert into public.resource_transactions (player_id, source, request_id, delta)
	values (player_row.id, 'battle/request', p_request_id, jsonb_build_object('xp', 5, 'ossos', 100));

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

alter table public.player_consumables enable row level security;
alter table public.player_potion_slots enable row level security;
alter table public.player_spell_behaviors enable row level security;
alter table public.item_transactions enable row level security;

create policy "player_consumables_select_own"
	on public.player_consumables for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "player_potion_slots_select_own"
	on public.player_potion_slots for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "player_spell_behaviors_select_own"
	on public.player_spell_behaviors for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "item_transactions_select_own"
	on public.item_transactions for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);
