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
		"weapon_id": "varinha_magica",
		"weapon_level": 1,
		"weapon_quality": "inicial",
		"spell_ids": ["raio_cosmico"],
		"spell_levels": {"raio_cosmico": 1},
		"passive_id": "foco_astral",
		"passive_level": 1,
		"pet_id": "familiar_cinzento",
		"pet_level": 1
	}'::jsonb,
	true
),
(
	'bot_starter_wand_01',
	85,
	'band_001',
	'{
		"display_name": "Aprendiz de Cinzas",
		"level": 2,
		"weapon_id": "varinha_magica",
		"weapon_level": 2,
		"weapon_quality": "inicial",
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
	'bot_cosmic_apprentice_01',
	260,
	'band_002',
	'{
		"display_name": "Aprendiz Cosmico",
		"level": 5,
		"weapon_id": "varinha_magica",
		"weapon_level": 5,
		"weapon_quality": "reforcada",
		"spell_ids": ["raio_cosmico"],
		"spell_levels": {"raio_cosmico": 5},
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
		"weapon_id": "varinha_magica",
		"weapon_level": 12,
		"weapon_quality": "ritual",
		"spell_ids": ["raio_cosmico", "acender"],
		"spell_levels": {"raio_cosmico": 12, "acender": 10},
		"passive_id": "forca",
		"passive_level": 8,
		"pet_id": "",
		"pet_level": 0
	}'::jsonb,
	true
),
(
	'bot_pet_handler_01',
	1320,
	'band_004',
	'{
		"display_name": "Condutor de Familiar",
		"level": 22,
		"weapon_id": "varinha_magica",
		"weapon_level": 20,
		"weapon_quality": "abissal",
		"spell_ids": ["raio_cosmico", "congelar"],
		"spell_levels": {"raio_cosmico": 18, "congelar": 16},
		"passive_id": "resistencia",
		"passive_level": 15,
		"pet_id": "familiar_cinzento",
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
		"weapon_id": "varinha_magica",
		"weapon_level": 1,
		"weapon_quality": "inicial",
		"spell_ids": ["acender", "congelar"],
		"spell_levels": {"acender": 1, "congelar": 1},
		"passive_id": "escudo",
		"passive_level": 1,
		"pet_id": "familiar_cinzento",
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
		"weapon_id": "varinha_magica",
		"weapon_level": 1,
		"weapon_quality": "inicial",
		"spell_ids": ["animar_morto", "congelar"],
		"spell_levels": {"animar_morto": 1, "congelar": 1},
		"passive_id": "",
		"passive_level": 0,
		"pet_id": "familiar_cinzento",
		"pet_level": 1
	}'::jsonb,
	true
),
(
	'bot_summoner_01',
	2450,
	'band_005',
	'{
		"display_name": "Invocador Abissal",
		"level": 35,
		"weapon_id": "varinha_magica",
		"weapon_level": 32,
		"weapon_quality": "cosmica",
		"spell_ids": ["raio_cosmico", "invocar_demonio", "animar_morto"],
		"spell_levels": {"raio_cosmico": 30, "invocar_demonio": 28, "animar_morto": 28},
		"passive_id": "foco_astral",
		"passive_level": 25,
		"pet_id": "brasido",
		"pet_level": 24
	}'::jsonb,
	true
)
on conflict (id) do update set
	power = excluded.power,
	power_band = excluded.power_band,
	build_data = excluded.build_data,
	is_active = excluded.is_active;
