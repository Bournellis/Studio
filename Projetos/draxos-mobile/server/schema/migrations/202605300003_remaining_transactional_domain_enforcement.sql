-- DraxosMobile Foundation Expansion Readiness - remaining transactional domain enforcement.
-- Promotes battle rewards, monetization, build equip, crafting and guild mutations to atomic RPC effects.

create or replace function public.foundation_jsonb_numeric_v1(
	p_payload jsonb,
	p_key text
)
returns numeric
language sql
immutable
as $$
	select coalesce(nullif(trim(coalesce(p_payload->>p_key, '')), '')::numeric, 0);
$$;

create or replace function public.foundation_jsonb_integer_v1(
	p_payload jsonb,
	p_key text
)
returns integer
language sql
immutable
as $$
	select coalesce(nullif(trim(coalesce(p_payload->>p_key, '')), '')::integer, 0);
$$;

create or replace function public.apply_foundation_mutation_v1(
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
	resource_row public.resources%rowtype;
	resource_delta jsonb := '{}'::jsonb;
	delta_almas numeric := 0;
	delta_energia numeric := 0;
	delta_sangue numeric := 0;
	delta_cristais numeric := 0;
	delta_ossos numeric := 0;
	delta_po_osso numeric := 0;
	delta_diamante integer := 0;
	reservation_payload jsonb;
	response_payload jsonb;
	build_payload jsonb;
	build_row public.builds%rowtype;
	progress_row public.battle_pass_progress%rowtype;
	reward_claim_row public.reward_claims%rowtype;
	alpha_purchase_row public.alpha_purchases%rowtype;
	guild_row public.guilds%rowtype;
	membership_row public.guild_members%rowtype;
	ranking_row public.ranking%rowtype;
	used_item jsonb;
	consumable_row public.player_consumables%rowtype;
	now_ts timestamptz := now();
	normalized_endpoint text := trim(coalesce(p_endpoint, ''));
	payload_pass_id text;
	payload_reward_source text;
	payload_reward_id text;
	payload_period_key text;
	payload_product_id text;
	payload_recipe_id text;
	payload_item_id text;
	payload_guild_name text;
	payload_battle_id uuid;
	battle_log jsonb;
	competition_input jsonb;
	competition_payload jsonb;
	payload_season_id text;
	payload_outcome text;
	raw_arena_delta integer := 0;
	next_arena_points integer := 0;
	applied_arena_delta integer := 0;
	xp_delta integer := 0;
	item_delta integer := 0;
	player_power integer := 0;
	already_redeemed boolean := false;
	already_owned boolean := false;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	if normalized_endpoint = '' then
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
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

	if normalized_endpoint in (
		'battle/request',
		'crafting/craft',
		'crafting/crush-bones',
		'monetization/rewards/claim',
		'monetization/alpha-purchase'
	) then
		select *
		into resource_row
		from public.resources
		where player_id = save_row.legacy_player_id
		for update;

		if resource_row.player_id is null then
			raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
		end if;
	end if;

	if normalized_endpoint = 'build/equip' then
		build_payload := coalesce(p_request_payload->'build', '{}'::jsonb);
		if jsonb_typeof(build_payload) <> 'object' then
			raise exception 'INVALID_PAYLOAD' using errcode = 'P0001';
		end if;

		player_power := greatest(0, coalesce((p_request_payload->>'player_power')::integer, player_row.power));

		update public.builds
		set
			weapon_type = coalesce(nullif(build_payload->>'weapon_type', ''), weapon_type),
			weapon_quality = coalesce(nullif(build_payload->>'weapon_quality', ''), weapon_quality),
			spell_slots = coalesce(build_payload->'spell_slots', spell_slots),
			passive_id = case when build_payload ? 'passive_id' then nullif(build_payload->>'passive_id', '') else passive_id end,
			pet_id = case when build_payload ? 'pet_id' then nullif(build_payload->>'pet_id', '') else pet_id end,
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into build_row;

		if build_row.player_id is null then
			raise exception 'BUILD_NOT_FOUND' using errcode = 'P0001';
		end if;

		update public.players
		set
			power = player_power,
			updated_at = now_ts
		where id = save_row.legacy_player_id
		returning * into player_row;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_build_equip_response_v1',
			'endpoint', normalized_endpoint,
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
			'equipped_build', coalesce(p_request_payload->'equipped_build', '{}'::jsonb),
			'build', to_jsonb(build_row),
			'player', to_jsonb(player_row)
		);
	elsif normalized_endpoint = 'crafting/crush-bones' then
		item_delta := greatest(0, coalesce((p_request_payload->>'amount')::integer, 0));
		if item_delta <= 0 then
			raise exception 'INVALID_PAYLOAD' using errcode = 'P0001';
		end if;

		resource_delta := jsonb_build_object('ossos', -item_delta, 'po_osso', item_delta);
		delta_ossos := -item_delta;
		delta_po_osso := item_delta;

		if resource_row.ossos + delta_ossos < 0 then
			raise exception 'INSUFFICIENT_RESOURCES' using errcode = 'P0001';
		end if;

		update public.resources
		set
			ossos = ossos + delta_ossos,
			po_osso = po_osso + delta_po_osso,
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into resource_row;

		insert into public.resource_transactions (player_id, source, request_id, delta)
		values (save_row.legacy_player_id, normalized_endpoint, p_request_id, resource_delta);

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_crafting_crush_bones_response_v1',
			'endpoint', normalized_endpoint,
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
			'conversion', jsonb_build_object(
				'input', jsonb_build_object('ossos', item_delta),
				'output', jsonb_build_object('po_osso', item_delta)
			),
			'resources', to_jsonb(resource_row)
		);
	elsif normalized_endpoint = 'crafting/craft' then
		payload_recipe_id := nullif(trim(coalesce(p_request_payload->>'recipe_id', '')), '');
		payload_item_id := nullif(trim(coalesce(p_request_payload#>>'{output,item_id}', '')), '');
		item_delta := coalesce((p_request_payload#>>'{output,quantity}')::integer, 0);
		resource_delta := coalesce(p_request_payload->'resource_delta', '{}'::jsonb);

		if payload_recipe_id is null or payload_item_id is null or item_delta <= 0 then
			raise exception 'INVALID_RECIPE' using errcode = 'P0001';
		end if;

		delta_almas := public.foundation_jsonb_numeric_v1(resource_delta, 'almas');
		delta_energia := public.foundation_jsonb_numeric_v1(resource_delta, 'energia');
		delta_sangue := public.foundation_jsonb_numeric_v1(resource_delta, 'sangue');
		delta_cristais := public.foundation_jsonb_numeric_v1(resource_delta, 'cristais');
		delta_ossos := public.foundation_jsonb_numeric_v1(resource_delta, 'ossos');
		delta_po_osso := public.foundation_jsonb_numeric_v1(resource_delta, 'po_osso');
		delta_diamante := public.foundation_jsonb_integer_v1(resource_delta, 'diamante');

		if resource_row.almas + delta_almas < 0
			or resource_row.energia + delta_energia < 0
			or resource_row.sangue + delta_sangue < 0
			or resource_row.cristais + delta_cristais < 0
			or resource_row.ossos + delta_ossos < 0
			or resource_row.po_osso + delta_po_osso < 0
			or resource_row.diamante + delta_diamante < 0 then
			raise exception 'INSUFFICIENT_RESOURCES' using errcode = 'P0001';
		end if;

		update public.resources
		set
			almas = almas + delta_almas,
			energia = energia + delta_energia,
			sangue = sangue + delta_sangue,
			cristais = cristais + delta_cristais,
			ossos = ossos + delta_ossos,
			po_osso = po_osso + delta_po_osso,
			diamante = diamante + delta_diamante,
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into resource_row;

		insert into public.player_consumables as consumable (player_id, item_id, quantity, updated_at)
		values (save_row.legacy_player_id, payload_item_id, item_delta, now_ts)
		on conflict (player_id, item_id) do update
		set
			quantity = consumable.quantity + excluded.quantity,
			updated_at = excluded.updated_at
		returning * into consumable_row;

		insert into public.resource_transactions (player_id, source, request_id, delta)
		values (save_row.legacy_player_id, normalized_endpoint, p_request_id, resource_delta);

		insert into public.item_transactions (player_id, source, request_id, item_id, delta, payload)
		values (
			save_row.legacy_player_id,
			normalized_endpoint,
			p_request_id,
			payload_item_id,
			item_delta,
			jsonb_build_object('recipe_id', payload_recipe_id)
		);

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_crafting_craft_response_v1',
			'endpoint', normalized_endpoint,
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
			'crafted', jsonb_build_object(
				'recipe_id', payload_recipe_id,
				'output', jsonb_build_object('item_id', payload_item_id, 'quantity', item_delta),
				'cost', resource_delta
			),
			'resources', to_jsonb(resource_row),
			'item', to_jsonb(consumable_row)
		);
	elsif normalized_endpoint = 'monetization/rewards/claim' then
		payload_reward_id := nullif(trim(coalesce(p_request_payload->>'reward_id', '')), '');
		payload_reward_source := nullif(trim(coalesce(p_request_payload->>'source', '')), '');
		payload_period_key := nullif(trim(coalesce(p_request_payload->>'period_key', '')), '');
		payload_pass_id := nullif(trim(coalesce(p_request_payload->>'pass_id', '')), '');
		resource_delta := coalesce(p_request_payload->'resources', '{}'::jsonb);
		xp_delta := coalesce((p_request_payload->>'xp')::integer, 0);

		if payload_reward_id is null or payload_reward_source is null or payload_period_key is null or payload_pass_id is null then
			raise exception 'INVALID_REWARD' using errcode = 'P0001';
		end if;

		insert into public.battle_pass_progress (player_id, pass_id)
		values (save_row.legacy_player_id, payload_pass_id)
		on conflict (player_id, pass_id) do nothing;

		select *
		into progress_row
		from public.battle_pass_progress
		where player_id = save_row.legacy_player_id
			and battle_pass_progress.pass_id = payload_pass_id
		for update;

		if coalesce((p_request_payload->>'premium_required')::boolean, false)
			and coalesce(progress_row.premium_unlocked, false) = false then
			raise exception 'PREMIUM_REQUIRED' using errcode = 'P0001';
		end if;

		select *
		into reward_claim_row
		from public.reward_claims
		where player_id = save_row.legacy_player_id
			and reward_claims.source = payload_reward_source
			and reward_claims.reward_id = payload_reward_id
			and reward_claims.period_key = payload_period_key
		for update;

		if reward_claim_row.id is not null then
			response_payload := jsonb_build_object(
				'ok', true,
				'schema_version', 'foundation_reward_claim_response_v1',
				'endpoint', normalized_endpoint,
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
				'already_claimed', true,
				'reward', jsonb_build_object(
					'id', reward_claim_row.reward_id,
					'source', reward_claim_row.source,
					'period_key', reward_claim_row.period_key,
					'payload', reward_claim_row.reward_payload
				)
			);
		else
			delta_almas := public.foundation_jsonb_numeric_v1(resource_delta, 'almas');
			delta_energia := public.foundation_jsonb_numeric_v1(resource_delta, 'energia');
			delta_sangue := public.foundation_jsonb_numeric_v1(resource_delta, 'sangue');
			delta_cristais := public.foundation_jsonb_numeric_v1(resource_delta, 'cristais');
			delta_ossos := public.foundation_jsonb_numeric_v1(resource_delta, 'ossos');
			delta_po_osso := public.foundation_jsonb_numeric_v1(resource_delta, 'po_osso');
			delta_diamante := public.foundation_jsonb_integer_v1(resource_delta, 'diamante');

			update public.players
			set
				xp = xp + greatest(0, xp_delta),
				updated_at = now_ts
			where id = save_row.legacy_player_id
			returning * into player_row;

			update public.resources
			set
				almas = almas + delta_almas,
				energia = energia + delta_energia,
				sangue = sangue + delta_sangue,
				cristais = cristais + delta_cristais,
				ossos = ossos + delta_ossos,
				po_osso = po_osso + delta_po_osso,
				diamante = diamante + delta_diamante,
				updated_at = now_ts
			where player_id = save_row.legacy_player_id
			returning * into resource_row;

			update public.battle_pass_progress
			set
				pass_xp = pass_xp + greatest(0, coalesce((p_request_payload->>'pass_xp_delta')::integer, 0)),
				updated_at = now_ts
			where player_id = save_row.legacy_player_id
				and battle_pass_progress.pass_id = payload_pass_id
			returning * into progress_row;

			insert into public.reward_claims (
				player_id,
				source,
				reward_id,
				period_key,
				request_id,
				reward_payload,
				ruleset_id,
				ruleset_version
			)
			values (
				save_row.legacy_player_id,
				payload_reward_source,
				payload_reward_id,
				payload_period_key,
				p_request_id,
				coalesce(p_request_payload->'reward_payload', '{}'::jsonb),
				ruleset_row.ruleset_id,
				ruleset_row.ruleset_version
			)
			returning * into reward_claim_row;

			insert into public.resource_transactions (player_id, source, request_id, delta)
			values (
				save_row.legacy_player_id,
				'monetization/reward',
				p_request_id,
				jsonb_build_object('xp', xp_delta) || resource_delta
			);

			response_payload := jsonb_build_object(
				'ok', true,
				'schema_version', 'foundation_reward_claim_response_v1',
				'endpoint', normalized_endpoint,
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
				'already_claimed', false,
				'reward', jsonb_build_object(
					'id', payload_reward_id,
					'source', payload_reward_source,
					'period_key', payload_period_key,
					'payload', coalesce(p_request_payload->'reward_payload', '{}'::jsonb)
				),
				'resources', to_jsonb(resource_row),
				'progress', to_jsonb(progress_row),
				'claim', to_jsonb(reward_claim_row)
			);
		end if;
	elsif normalized_endpoint = 'monetization/alpha-purchase' then
		payload_product_id := nullif(trim(coalesce(p_request_payload->>'product_id', '')), '');
		payload_pass_id := nullif(trim(coalesce(p_request_payload->>'pass_id', '')), '');
		payload_period_key := nullif(trim(coalesce(p_request_payload->>'daily_redeem_period_key', '')), '');
		resource_delta := coalesce(p_request_payload->'resource_delta', '{}'::jsonb);

		if payload_product_id is null or payload_pass_id is null then
			raise exception 'INVALID_PRODUCT' using errcode = 'P0001';
		end if;

		insert into public.battle_pass_progress (player_id, pass_id)
		values (save_row.legacy_player_id, payload_pass_id)
		on conflict (player_id, pass_id) do nothing;

		select *
		into progress_row
		from public.battle_pass_progress
		where player_id = save_row.legacy_player_id
			and battle_pass_progress.pass_id = payload_pass_id
		for update;

		if coalesce((p_request_payload->>'daily_redeem')::boolean, false) and payload_period_key is not null then
			select exists (
				select 1
				from public.alpha_purchases
				where player_id = save_row.legacy_player_id
					and alpha_purchases.product_id = payload_product_id
					and (
						purchase_payload->>'redeem_period_key' = payload_period_key
						or (
							not (purchase_payload ? 'redeem_period_key')
							and to_char(created_at at time zone 'America/Sao_Paulo', 'YYYY-MM-DD') = payload_period_key
						)
					)
			) into already_redeemed;
		end if;

		if coalesce((p_request_payload->>'unlock_premium')::boolean, false)
			and progress_row.premium_unlocked then
			already_owned := true;
		end if;

		if coalesce((p_request_payload->>'owned_once')::boolean, false) then
			select exists (
				select 1
				from public.alpha_purchases
				where player_id = save_row.legacy_player_id
					and alpha_purchases.product_id = payload_product_id
			) into already_owned;
		end if;

		if already_redeemed or already_owned then
			response_payload := jsonb_build_object(
				'ok', true,
				'schema_version', 'foundation_alpha_purchase_response_v1',
				'endpoint', normalized_endpoint,
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
				'already_redeemed', already_redeemed,
				'already_owned', already_owned,
				'purchase', coalesce(p_request_payload->'product_payload', '{}'::jsonb)
			);
		else
			delta_almas := public.foundation_jsonb_numeric_v1(resource_delta, 'almas');
			delta_energia := public.foundation_jsonb_numeric_v1(resource_delta, 'energia');
			delta_sangue := public.foundation_jsonb_numeric_v1(resource_delta, 'sangue');
			delta_cristais := public.foundation_jsonb_numeric_v1(resource_delta, 'cristais');
			delta_ossos := public.foundation_jsonb_numeric_v1(resource_delta, 'ossos');
			delta_po_osso := public.foundation_jsonb_numeric_v1(resource_delta, 'po_osso');
			delta_diamante := public.foundation_jsonb_integer_v1(resource_delta, 'diamante');

			if resource_row.almas + delta_almas < 0
				or resource_row.energia + delta_energia < 0
				or resource_row.sangue + delta_sangue < 0
				or resource_row.cristais + delta_cristais < 0
				or resource_row.ossos + delta_ossos < 0
				or resource_row.po_osso + delta_po_osso < 0
				or resource_row.diamante + delta_diamante < 0 then
				raise exception 'INSUFFICIENT_RESOURCES' using errcode = 'P0001';
			end if;

			update public.resources
			set
				almas = almas + delta_almas,
				energia = energia + delta_energia,
				sangue = sangue + delta_sangue,
				cristais = cristais + delta_cristais,
				ossos = ossos + delta_ossos,
				po_osso = po_osso + delta_po_osso,
				diamante = diamante + delta_diamante,
				updated_at = now_ts
			where player_id = save_row.legacy_player_id
			returning * into resource_row;

			update public.battle_pass_progress
			set
				premium_unlocked = premium_unlocked or coalesce((p_request_payload->>'unlock_premium')::boolean, false),
				updated_at = now_ts
			where player_id = save_row.legacy_player_id
				and battle_pass_progress.pass_id = payload_pass_id
			returning * into progress_row;

			insert into public.alpha_purchases (
				player_id,
				product_id,
				request_id,
				purchase_payload,
				ruleset_id,
				ruleset_version
			)
			values (
				save_row.legacy_player_id,
				payload_product_id,
				p_request_id,
				coalesce(p_request_payload->'purchase_payload', '{}'::jsonb),
				ruleset_row.ruleset_id,
				ruleset_row.ruleset_version
			)
			returning * into alpha_purchase_row;

			insert into public.resource_transactions (player_id, source, request_id, delta)
			values (save_row.legacy_player_id, normalized_endpoint, p_request_id, resource_delta);

			response_payload := jsonb_build_object(
				'ok', true,
				'schema_version', 'foundation_alpha_purchase_response_v1',
				'endpoint', normalized_endpoint,
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
				'already_redeemed', false,
				'already_owned', false,
				'purchase', coalesce(p_request_payload->'purchase_payload', '{}'::jsonb),
				'resources', to_jsonb(resource_row),
				'progress', to_jsonb(progress_row),
				'purchase_row', to_jsonb(alpha_purchase_row)
			);
		end if;
	elsif normalized_endpoint = 'guild/create' then
		payload_guild_name := nullif(trim(coalesce(p_request_payload->>'name', '')), '');
		if payload_guild_name is null or char_length(payload_guild_name) < 3 or char_length(payload_guild_name) > 32 then
			raise exception 'INVALID_GUILD_NAME' using errcode = 'P0001';
		end if;

		select *
		into membership_row
		from public.guild_members
		where player_id = save_row.legacy_player_id
		for update;

		if membership_row.player_id is not null then
			raise exception 'GUILD_ALREADY_JOINED' using errcode = 'P0001';
		end if;

		insert into public.guilds (name, owner_id)
		values (payload_guild_name, save_row.legacy_player_id)
		returning * into guild_row;

		insert into public.guild_members (guild_id, player_id, role)
		values (guild_row.id, save_row.legacy_player_id, 'owner')
		returning * into membership_row;

		insert into public.guild_structures (guild_id, structure_id, level)
		select guild_row.id, structure_id, 1
		from jsonb_array_elements_text(coalesce(
			p_request_payload->'structures',
			'["oficina_ritual","condensador_astral","arquivo_de_dominio","cofre_abissal"]'::jsonb
		)) as structure_ids(structure_id)
		on conflict (guild_id, structure_id) do nothing;

		insert into public.chat_channels (channel_type, guild_id)
		values ('guild', guild_row.id)
		on conflict (channel_type, guild_id) do nothing;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_guild_create_response_v1',
			'endpoint', normalized_endpoint,
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
			'guild', to_jsonb(guild_row),
			'membership', to_jsonb(membership_row)
		);
	elsif normalized_endpoint = 'guild/join' then
		payload_guild_name := nullif(trim(coalesce(p_request_payload->>'name', '')), '');
		if payload_guild_name is null or char_length(payload_guild_name) < 3 or char_length(payload_guild_name) > 32 then
			raise exception 'INVALID_GUILD_NAME' using errcode = 'P0001';
		end if;

		select *
		into guild_row
		from public.guilds
		where lower(name) = lower(payload_guild_name)
		limit 1
		for update;

		if guild_row.id is null then
			raise exception 'GUILD_NOT_FOUND' using errcode = 'P0001';
		end if;

		select *
		into membership_row
		from public.guild_members
		where player_id = save_row.legacy_player_id
		for update;

		if membership_row.player_id is not null and membership_row.guild_id <> guild_row.id then
			raise exception 'GUILD_ALREADY_JOINED' using errcode = 'P0001';
		end if;

		if membership_row.player_id is null then
			if guild_row.member_count >= 50 then
				raise exception 'GUILD_FULL' using errcode = 'P0001';
			end if;

			insert into public.guild_members (guild_id, player_id, role)
			values (guild_row.id, save_row.legacy_player_id, 'member')
			returning * into membership_row;

			update public.guilds
			set
				member_count = member_count + 1,
				updated_at = now_ts
			where id = guild_row.id
			returning * into guild_row;
		end if;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_guild_join_response_v1',
			'endpoint', normalized_endpoint,
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
			'guild', to_jsonb(guild_row),
			'membership', to_jsonb(membership_row),
			'already_joined', membership_row.player_id is not null
		);
	elsif normalized_endpoint = 'battle/request' then
		payload_battle_id := (p_request_payload->>'battle_id')::uuid;
		battle_log := coalesce(p_request_payload->'battle_log', '{}'::jsonb);
		resource_delta := coalesce(p_request_payload->'reward_delta', '{}'::jsonb);
		competition_input := coalesce(p_request_payload->'competition', '{}'::jsonb);
		xp_delta := public.foundation_jsonb_integer_v1(resource_delta, 'xp');

		if payload_battle_id is null or jsonb_typeof(battle_log) <> 'object' then
			raise exception 'INVALID_PAYLOAD' using errcode = 'P0001';
		end if;

		insert into public.battles (
			id,
			attacker_id,
			defender_id,
			defender_is_bot,
			schema_version,
			seed,
			result,
			event_log,
			reward_payload,
			reward_applied,
			request_id,
			ruleset_id,
			ruleset_version
		)
		values (
			payload_battle_id,
			save_row.legacy_player_id,
			nullif(trim(coalesce(p_request_payload->>'defender_id', '')), ''),
			coalesce((p_request_payload->>'defender_is_bot')::boolean, true),
			coalesce(battle_log->>'schema_version', 'battle_log_v1'),
			coalesce(p_request_payload->>'seed', ''),
			coalesce(battle_log->'result', '{}'::jsonb),
			coalesce(battle_log->'events', '[]'::jsonb),
			coalesce(p_request_payload->'reward_payload', '{}'::jsonb),
			true,
			p_request_id,
			ruleset_row.ruleset_id,
			ruleset_row.ruleset_version
		);

		delta_almas := public.foundation_jsonb_numeric_v1(resource_delta, 'almas');
		delta_energia := public.foundation_jsonb_numeric_v1(resource_delta, 'energia');
		delta_sangue := public.foundation_jsonb_numeric_v1(resource_delta, 'sangue');
		delta_cristais := public.foundation_jsonb_numeric_v1(resource_delta, 'cristais');
		delta_ossos := public.foundation_jsonb_numeric_v1(resource_delta, 'ossos');
		delta_po_osso := public.foundation_jsonb_numeric_v1(resource_delta, 'po_osso');
		delta_diamante := public.foundation_jsonb_integer_v1(resource_delta, 'diamante');

		update public.players
		set
			xp = xp + greatest(0, xp_delta),
			updated_at = now_ts
		where id = save_row.legacy_player_id
		returning * into player_row;

		update public.resources
		set
			almas = almas + delta_almas,
			energia = energia + delta_energia,
			sangue = sangue + delta_sangue,
			cristais = cristais + delta_cristais,
			ossos = ossos + delta_ossos,
			po_osso = po_osso + delta_po_osso,
			diamante = diamante + delta_diamante,
			updated_at = now_ts
		where player_id = save_row.legacy_player_id
		returning * into resource_row;

		insert into public.resource_transactions (player_id, source, request_id, delta)
		values (save_row.legacy_player_id, normalized_endpoint, p_request_id, resource_delta);

		for used_item in
			select value
			from jsonb_array_elements(coalesce(p_request_payload#>'{consumables,used}', '[]'::jsonb))
		loop
			if coalesce(used_item->>'owner', '') = 'player' then
				payload_item_id := nullif(trim(coalesce(used_item->>'item_id', '')), '');
				item_delta := greatest(0, coalesce((used_item->>'quantity')::integer, 0));
				if payload_item_id is null or item_delta <= 0 then
					raise exception 'CONSUMABLE_APPLY_FAILED' using errcode = 'P0001';
				end if;

				select *
				into consumable_row
				from public.player_consumables
				where player_id = save_row.legacy_player_id
					and player_consumables.item_id = payload_item_id
				for update;

				if consumable_row.player_id is null or consumable_row.quantity < item_delta then
					raise exception 'CONSUMABLE_APPLY_FAILED' using errcode = 'P0001';
				end if;

				update public.player_consumables
				set
					quantity = quantity - item_delta,
					updated_at = now_ts
				where player_id = save_row.legacy_player_id
					and player_consumables.item_id = payload_item_id;

				insert into public.item_transactions (player_id, source, request_id, item_id, delta, payload)
				values (
					save_row.legacy_player_id,
					normalized_endpoint,
					p_request_id,
					payload_item_id,
					-item_delta,
					jsonb_build_object('slot_index', used_item->'slot_index')
				);
			end if;
		end loop;

		if coalesce((competition_input->>'ranked')::boolean, false) then
			payload_season_id := nullif(trim(coalesce(competition_input#>>'{season,id}', competition_input->>'season_id', '')), '');
			payload_outcome := coalesce(competition_input->>'result', 'draw');
			raw_arena_delta := coalesce((competition_input->>'arena_delta_raw')::integer, 0);

			if payload_season_id is null then
				raise exception 'RANKING_APPLY_FAILED' using errcode = 'P0001';
			end if;

			insert into public.ranking (season_id, player_id)
			values (payload_season_id, save_row.legacy_player_id)
			on conflict (season_id, player_id) do nothing;

			select *
			into ranking_row
			from public.ranking
			where ranking.season_id = payload_season_id
				and player_id = save_row.legacy_player_id
			for update;

			next_arena_points := greatest(0, ranking_row.arena_points + raw_arena_delta);
			applied_arena_delta := next_arena_points - ranking_row.arena_points;

			update public.ranking
			set
				arena_points = next_arena_points,
				wins = wins + case when payload_outcome = 'win' then 1 else 0 end,
				losses = losses + case when payload_outcome = 'loss' then 1 else 0 end,
				updated_at = now_ts
			where ranking.season_id = payload_season_id
				and player_id = save_row.legacy_player_id
			returning * into ranking_row;

			competition_payload := jsonb_build_object(
				'ranked', true,
				'season', competition_input->'season',
				'result', payload_outcome,
				'scoring_model', coalesce(competition_input->>'scoring_model', 'alpha_v0_power_adjusted'),
				'arena_delta', applied_arena_delta,
				'arena_delta_raw', raw_arena_delta,
				'player_power', coalesce((competition_input->>'player_power')::integer, 0),
				'opponent_power', coalesce((competition_input->>'opponent_power')::integer, 0),
				'opponent', coalesce(competition_input->'opponent', '{}'::jsonb),
				'ranking', to_jsonb(ranking_row)
			);
		else
			competition_payload := competition_input || jsonb_build_object('ranked', false);
		end if;

		response_payload := jsonb_build_object(
			'ok', true,
			'schema_version', 'foundation_battle_request_response_v1',
			'endpoint', normalized_endpoint,
			'request_id', p_request_id,
			'request_hash', p_request_hash,
			'account_profile_id', save_row.account_profile_id,
			'game_save_id', save_row.id,
			'legacy_player_id', save_row.legacy_player_id,
			'battle_log', battle_log,
			'ruleset', jsonb_build_object(
				'ruleset_id', ruleset_row.ruleset_id,
				'ruleset_version', ruleset_row.ruleset_version,
				'content_hash', ruleset_row.content_hash,
				'simulator_hash', ruleset_row.simulator_hash,
				'schema_version', ruleset_row.schema_version
			),
			'rewards', coalesce(p_request_payload->'reward_payload', '{}'::jsonb),
			'consumables', coalesce(p_request_payload->'consumables', '{}'::jsonb),
			'competition', competition_payload
		);
	else
		raise exception 'INVALID_ENDPOINT' using errcode = 'P0001';
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

create or replace function public.request_battle_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'battle/request', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.equip_build_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'build/equip', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.crush_bones_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'crafting/crush-bones', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.craft_item_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'crafting/craft', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.claim_reward_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'monetization/rewards/claim', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.alpha_purchase_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'monetization/alpha-purchase', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.guild_create_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'guild/create', p_request_id, p_request_hash, p_request_payload);
end;
$$;

create or replace function public.guild_join_v1(
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
	return public.apply_foundation_mutation_v1(p_game_save_id, 'guild/join', p_request_id, p_request_hash, p_request_payload);
end;
$$;

revoke all on function public.foundation_jsonb_numeric_v1(jsonb, text) from public;
grant execute on function public.foundation_jsonb_numeric_v1(jsonb, text) to service_role;

revoke all on function public.foundation_jsonb_integer_v1(jsonb, text) from public;
grant execute on function public.foundation_jsonb_integer_v1(jsonb, text) to service_role;

revoke all on function public.apply_foundation_mutation_v1(uuid, text, uuid, text, jsonb) from public;
grant execute on function public.apply_foundation_mutation_v1(uuid, text, uuid, text, jsonb) to service_role;

revoke all on function public.request_battle_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.request_battle_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.equip_build_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.equip_build_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.crush_bones_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.crush_bones_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.craft_item_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.craft_item_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.claim_reward_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.claim_reward_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.alpha_purchase_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.alpha_purchase_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.guild_create_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.guild_create_v1(uuid, uuid, text, jsonb) to service_role;

revoke all on function public.guild_join_v1(uuid, uuid, text, jsonb) from public;
grant execute on function public.guild_join_v1(uuid, uuid, text, jsonb) to service_role;
