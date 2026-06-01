-- Track 19 - Arena Consistency Pass
-- Keeps Arena PVE rewards on final duel clear, makes claim a read/ack endpoint,
-- and consumes live potion stock for each arena duel idempotently.

create or replace function public.arena_record_duel_v1(
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
	attempt_row public.arena_attempts%rowtype;
	step_row public.arena_attempt_steps%rowtype;
	progress_row public.arena_progress%rowtype;
	player_row public.players%rowtype;
	resource_row public.resources%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	reward_delta jsonb := '{}'::jsonb;
	consumables_used jsonb := '[]'::jsonb;
	consumable_entry jsonb;
	consumable_owner text;
	consumable_item_id text;
	consumable_quantity integer;
	consumable_slot integer;
	current_quantity integer;
	payload_attempt_id uuid;
	next_step_index integer;
	winner text;
	next_status text := 'active';
	next_action text := 'choose_buff';
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	now_ts timestamptz := now();
	xp_delta integer := 0;
	delta_almas numeric := 0;
	delta_energia numeric := 0;
	delta_sangue numeric := 0;
	delta_cristais numeric := 0;
	delta_ossos numeric := 0;
	delta_po_osso numeric := 0;
	delta_diamante integer := 0;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	payload_attempt_id := (p_request_payload->>'attempt_id')::uuid;
	if payload_attempt_id is null then
		raise exception 'INVALID_ARENA_ATTEMPT' using errcode = 'P0001';
	end if;

	consumables_used := coalesce(p_request_payload->'consumables_used', '[]'::jsonb);
	if jsonb_typeof(consumables_used) <> 'array' then
		raise exception 'INVALID_ARENA_CONSUMABLES' using errcode = 'P0001';
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

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'arena/duel/request',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into attempt_row
	from public.arena_attempts
	where id = payload_attempt_id
		and game_save_id = save_row.id
		and status = 'active'
	for update;

	if attempt_row.id is null then
		raise exception 'ARENA_ATTEMPT_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	next_step_index := attempt_row.current_step_index + 1;
	if next_step_index > attempt_row.max_steps then
		raise exception 'ARENA_ATTEMPT_COMPLETE' using errcode = 'P0001';
	end if;
	if jsonb_typeof(coalesce(p_request_payload->'battle_log', '{}'::jsonb)) <> 'object' then
		raise exception 'INVALID_ARENA_PAYLOAD' using errcode = 'P0001';
	end if;

	winner := coalesce(p_request_payload#>>'{result,winner}', p_request_payload#>>'{battle_log,result,winner}', 'opponent');
	if winner <> 'player' then
		next_status := 'failed';
		next_action := 'failed';
	elsif next_step_index >= attempt_row.max_steps then
		next_status := 'completed';
		next_action := 'completed';
	else
		next_status := 'active';
		next_action := 'choose_buff';
	end if;

	insert into public.arena_attempt_steps (
		attempt_id,
		game_save_id,
		player_id,
		step_index,
		step_type,
		status,
		opponent_bot_id,
		seed,
		battle_log,
		result,
		reward_payload,
		buff_options,
		request_id,
		request_hash,
		completed_at,
		updated_at
	)
	values (
		attempt_row.id,
		save_row.id,
		save_row.legacy_player_id,
		next_step_index,
		'duel',
		'completed',
		nullif(trim(coalesce(p_request_payload->>'opponent_bot_id', '')), ''),
		coalesce(p_request_payload->>'seed', ''),
		coalesce(p_request_payload->'battle_log', '{}'::jsonb),
		coalesce(p_request_payload->'result', coalesce(p_request_payload#>'{battle_log,result}', '{}'::jsonb)),
		coalesce(p_request_payload->'reward_payload', '{}'::jsonb),
		coalesce(p_request_payload->'buff_options', '[]'::jsonb),
		p_request_id,
		normalized_hash,
		now_ts,
		now_ts
	)
	returning * into step_row;

	update public.arena_attempts
	set
		current_step_index = next_step_index,
		status = next_status,
		reward_payload = case when next_status = 'completed' then coalesce(p_request_payload->'reward_payload', '{}'::jsonb) else reward_payload end,
		completed_at = case when next_status in ('completed', 'failed') then now_ts else completed_at end,
		updated_at = now_ts
	where id = attempt_row.id
	returning * into attempt_row;

	for consumable_entry in
		select value from jsonb_array_elements(consumables_used) as consumable_values(value)
	loop
		consumable_owner := coalesce(consumable_entry->>'owner', '');
		if consumable_owner <> 'player' then
			continue;
		end if;

		consumable_item_id := nullif(trim(coalesce(consumable_entry->>'item_id', '')), '');
		consumable_quantity := greatest(0, coalesce(nullif(consumable_entry->>'quantity', '')::integer, 0));
		consumable_slot := coalesce(nullif(consumable_entry->>'slot_index', '')::integer, 0);

		if consumable_item_id is null or consumable_quantity <= 0 then
			raise exception 'INVALID_ARENA_CONSUMABLES' using errcode = 'P0001';
		end if;

		current_quantity := null;
		select quantity
		into current_quantity
		from public.player_consumables
		where player_id = save_row.legacy_player_id
			and item_id = consumable_item_id
		for update;

		if current_quantity is null or current_quantity < consumable_quantity then
			raise exception 'ARENA_CONSUMABLE_STOCK_CHANGED' using errcode = 'P0001';
		end if;

		update public.player_consumables
		set
			quantity = current_quantity - consumable_quantity,
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
			and item_id = consumable_item_id;

		insert into public.item_transactions (
			player_id,
			source,
			request_id,
			item_id,
			delta,
			payload
		)
		values (
			save_row.legacy_player_id,
			'arena_pve_v1',
			p_request_id,
			consumable_item_id,
			-consumable_quantity,
			jsonb_build_object(
				'attempt_id', attempt_row.id,
				'step_index', next_step_index,
				'slot_index', consumable_slot
			)
		);
	end loop;

	progress_row := public.ensure_arena_progress_v1(save_row.id);

	if next_status = 'completed' then
		reward_delta := coalesce(
			p_request_payload->'reward_delta',
			p_request_payload#>'{reward_payload,economy_delta}',
			'{}'::jsonb
		);
		if jsonb_typeof(reward_delta) <> 'object' then
			raise exception 'INVALID_ARENA_REWARD' using errcode = 'P0001';
		end if;

		xp_delta := public.foundation_jsonb_integer_v1(reward_delta, 'xp');
		delta_almas := public.foundation_jsonb_numeric_v1(reward_delta, 'almas');
		delta_energia := public.foundation_jsonb_numeric_v1(reward_delta, 'energia');
		delta_sangue := public.foundation_jsonb_numeric_v1(reward_delta, 'sangue');
		delta_cristais := public.foundation_jsonb_numeric_v1(reward_delta, 'cristais');
		delta_ossos := public.foundation_jsonb_numeric_v1(reward_delta, 'ossos');
		delta_po_osso := public.foundation_jsonb_numeric_v1(reward_delta, 'po_osso');
		delta_diamante := public.foundation_jsonb_integer_v1(reward_delta, 'diamante');

		update public.players
		set
			xp = xp + greatest(0, xp_delta),
			updated_at = now_ts
		where id = save_row.legacy_player_id
		returning * into player_row;

		update public.resources
		set
			almas = almas + greatest(0, delta_almas),
			energia = energia + greatest(0, delta_energia),
			sangue = sangue + greatest(0, delta_sangue),
			cristais = cristais + greatest(0, delta_cristais),
			ossos = ossos + greatest(0, delta_ossos),
			po_osso = po_osso + greatest(0, delta_po_osso),
			diamante = diamante + greatest(0, delta_diamante),
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into resource_row;

		insert into public.resource_transactions (player_id, source, request_id, delta)
		values (save_row.legacy_player_id, 'arena_pve_v1', p_request_id, reward_delta);
	end if;

	update public.arena_progress
	set
		best_attempt_step = greatest(best_attempt_step, next_step_index),
		best_completed_difficulty = case
			when next_status = 'completed' then greatest(best_completed_difficulty, attempt_row.difficulty_rank)
			else best_completed_difficulty
		end,
		best_completed_length = case
			when next_status = 'completed' then greatest(best_completed_length, attempt_row.max_steps)
			else best_completed_length
		end,
		tutorial_completed = tutorial_completed or (next_status = 'completed' and attempt_row.arena_id = 'arena_tutorial_cinzas'),
		total_clears = total_clears + case when next_status = 'completed' then 1 else 0 end,
		last_attempt_id = attempt_row.id,
		updated_at = now_ts
	where game_save_id = save_row.id
	returning * into progress_row;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'arena_duel_response_v1',
		'endpoint', 'arena/duel/request',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'attempt', to_jsonb(attempt_row),
		'step', to_jsonb(step_row),
		'progress', to_jsonb(progress_row),
		'player', to_jsonb(player_row),
		'resources', to_jsonb(resource_row),
		'reward_delta', reward_delta,
		'consumables_used', consumables_used,
		'next_action', next_action,
		'ranking', jsonb_build_object('mutated', false, 'reason', 'ARENA_PVE_DOES_NOT_RANK')
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'arena/duel/request',
		p_request_id,
		response_payload,
		normalized_hash
	);
end;
$$;

create or replace function public.arena_choose_buff_v1(
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
	attempt_row public.arena_attempts%rowtype;
	step_row public.arena_attempt_steps%rowtype;
	reservation_payload jsonb;
	response_payload jsonb;
	selected_option jsonb;
	payload_attempt_id uuid;
	payload_step_index integer := coalesce((p_request_payload->>'step_index')::integer, 0);
	payload_buff_id text := nullif(trim(coalesce(p_request_payload->>'buff_id', '')), '');
	normalized_hash text := nullif(trim(coalesce(p_request_hash, '')), '');
	now_ts timestamptz := now();
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;
	if p_request_id is null then
		raise exception 'INVALID_REQUEST_ID' using errcode = 'P0001';
	end if;
	if normalized_hash is null then
		raise exception 'INVALID_REQUEST_HASH' using errcode = 'P0001';
	end if;

	payload_attempt_id := (p_request_payload->>'attempt_id')::uuid;
	if payload_attempt_id is null or payload_step_index <= 0 or payload_buff_id is null then
		raise exception 'INVALID_ARENA_PAYLOAD' using errcode = 'P0001';
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

	reservation_payload := public.reserve_idempotency(
		save_row.legacy_player_id,
		'arena/pve/buff/select',
		p_request_id,
		normalized_hash,
		save_row.id::text
	);

	if coalesce((reservation_payload->>'pending_created')::boolean, false) = false then
		return coalesce(reservation_payload->'response_payload', '{}'::jsonb);
	end if;

	select *
	into attempt_row
	from public.arena_attempts
	where id = payload_attempt_id
		and game_save_id = save_row.id
		and status = 'active'
	for update;

	if attempt_row.id is null then
		raise exception 'ARENA_ATTEMPT_NOT_ACTIVE' using errcode = 'P0001';
	end if;

	select *
	into step_row
	from public.arena_attempt_steps
	where attempt_id = attempt_row.id
		and step_index = payload_step_index
		and step_type = 'duel'
	for update;

	if step_row.id is null then
		raise exception 'ARENA_STEP_NOT_FOUND' using errcode = 'P0001';
	end if;

	if step_row.selected_buff is not null then
		if coalesce(step_row.selected_buff->>'id', '') = payload_buff_id then
			selected_option := step_row.selected_buff;
		else
			raise exception 'ARENA_BUFF_ALREADY_CHOSEN' using errcode = 'P0001';
		end if;
	else
		select option_value
		into selected_option
		from jsonb_array_elements(coalesce(step_row.buff_options, '[]'::jsonb)) as option_value
		where option_value->>'id' = payload_buff_id
		limit 1;

		if selected_option is null then
			raise exception 'ARENA_BUFF_NOT_AVAILABLE' using errcode = 'P0001';
		end if;

		update public.arena_attempt_steps
		set
			selected_buff = selected_option,
			updated_at = now_ts
		where id = step_row.id
		returning * into step_row;

		update public.arena_attempts
		set
			active_buffs = active_buffs || jsonb_build_array(selected_option),
			updated_at = now_ts
		where id = attempt_row.id
		returning * into attempt_row;
	end if;

	response_payload := jsonb_build_object(
		'ok', true,
		'schema_version', 'arena_buff_select_response_v1',
		'endpoint', 'arena/pve/buff/select',
		'request_id', p_request_id,
		'request_hash', normalized_hash,
		'account_profile_id', save_row.account_profile_id,
		'game_save_id', save_row.id,
		'legacy_player_id', save_row.legacy_player_id,
		'attempt', to_jsonb(attempt_row),
		'step', to_jsonb(step_row),
		'selected_buff', selected_option
	);

	return public.complete_idempotency(
		save_row.legacy_player_id,
		'arena/pve/buff/select',
		p_request_id,
		response_payload,
		normalized_hash
	);
end;
$$;

revoke all on function public.arena_record_duel_v1(uuid, uuid, text, jsonb) from public;
revoke all on function public.arena_choose_buff_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.arena_record_duel_v1(uuid, uuid, text, jsonb) to service_role;
grant execute on function public.arena_choose_buff_v1(uuid, uuid, text, jsonb) to service_role;
