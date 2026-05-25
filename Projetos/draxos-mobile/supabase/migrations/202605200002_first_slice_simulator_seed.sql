-- DraxosMobile Track 00 P10 - First-slice simulator bot seeds.
-- Mirrors data/definitions/bot_builds.json for server-authoritative battle requests.

insert into public.bot_builds (id, power, power_band, build_data, is_active)
values
(
	'mvp_training_bot',
	50,
	'MVP_ONLY',
	'{
		"display_name": "Bot de Treino MVP",
		"level": 1,
		"weapon_id": "varinha_cinzas",
		"weapon_level": 1,
		"weapon_quality": "starter",
		"spell_ids": ["sussurro_medo"],
		"spell_levels": {"sussurro_medo": 1},
		"passive_id": "doutrina_pavor",
		"passive_level": 1,
		"pet_id": "corvo_pressagio",
		"pet_level": 1
	}'::jsonb,
	true
),
(
	'bot_starter_instrument_01',
	85,
	'band_001',
	'{
		"display_name": "Aprendiz de Cinzas",
		"level": 2,
		"weapon_id": "varinha_cinzas",
		"weapon_level": 2,
		"weapon_quality": "starter",
		"spell_ids": [],
		"spell_levels": {},
		"passive_id": "",
		"passive_level": 0,
		"pet_id": "",
		"pet_level": 0
	}'::jsonb,
	true
),
(
	'bot_mental_controller_01',
	260,
	'band_002',
	'{
		"display_name": "Sussurrador do Veu",
		"level": 5,
		"weapon_id": "grimorio_veu",
		"weapon_level": 5,
		"weapon_quality": "reforcada",
		"spell_ids": ["sussurro_medo"],
		"spell_levels": {"sussurro_medo": 5},
		"passive_id": "",
		"passive_level": 0,
		"pet_id": "",
		"pet_level": 0
	}'::jsonb,
	true
),
(
	'bot_elemental_mixer_01',
	720,
	'band_003',
	'{
		"display_name": "Misturador Elemental",
		"level": 14,
		"weapon_id": "orbe_tempestade",
		"weapon_level": 12,
		"weapon_quality": "ritual",
		"spell_ids": ["descarga_nervosa", "marca_brasa"],
		"spell_levels": {"descarga_nervosa": 12, "marca_brasa": 10},
		"passive_id": "pulso_tempestade",
		"passive_level": 8,
		"pet_id": "",
		"pet_level": 0
	}'::jsonb,
	true
),
(
	'bot_familiar_handler_01',
	1320,
	'band_004',
	'{
		"display_name": "Condutor de Familiar",
		"level": 22,
		"weapon_id": "varinha_cinzas",
		"weapon_level": 20,
		"weapon_quality": "abissal",
		"spell_ids": ["sussurro_medo", "geada_ossos"],
		"spell_levels": {"sussurro_medo": 18, "geada_ossos": 16},
		"passive_id": "pacto_familiar",
		"passive_level": 15,
		"pet_id": "corvo_pressagio",
		"pet_level": 16
	}'::jsonb,
	true
),
(
	'bot_effect_trainer_01',
	180,
	'band_002',
	'{
		"display_name": "Treinador de Efeitos",
		"level": 6,
		"weapon_id": "varinha_cinzas",
		"weapon_level": 1,
		"weapon_quality": "starter",
		"spell_ids": ["marca_brasa", "geada_ossos"],
		"spell_levels": {"marca_brasa": 1, "geada_ossos": 1},
		"passive_id": "pedra_interna",
		"passive_level": 1,
		"pet_id": "corvo_pressagio",
		"pet_level": 1
	}'::jsonb,
	true
),
(
	'bot_summon_trainer_01',
	210,
	'band_002',
	'{
		"display_name": "Treinador de Invocacao",
		"level": 6,
		"weapon_id": "cajado_ossario",
		"weapon_level": 1,
		"weapon_quality": "starter",
		"spell_ids": ["erguer_ossos", "geada_ossos"],
		"spell_levels": {"erguer_ossos": 1, "geada_ossos": 1},
		"passive_id": "",
		"passive_level": 0,
		"pet_id": "corvo_pressagio",
		"pet_level": 1
	}'::jsonb,
	true
),
(
	'bot_summoner_01',
	2450,
	'band_005',
	'{
		"display_name": "Invocador Ossario",
		"level": 35,
		"weapon_id": "cajado_ossario",
		"weapon_level": 32,
		"weapon_quality": "cosmica",
		"spell_ids": ["sussurro_medo", "erguer_ossos", "invocar_brasa_faminta"],
		"spell_levels": {"sussurro_medo": 30, "erguer_ossos": 28, "invocar_brasa_faminta": 28},
		"passive_id": "ossuario_interior",
		"passive_level": 25,
		"pet_id": "cranio_errante",
		"pet_level": 24
	}'::jsonb,
	true
)
on conflict (id) do update set
	power = excluded.power,
	power_band = excluded.power_band,
	build_data = excluded.build_data,
	is_active = excluded.is_active;
