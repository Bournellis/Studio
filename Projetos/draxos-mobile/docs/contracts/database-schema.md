# Database Schema Contract

- Ultima atualizacao: `2026-05-19`
- Status: contrato logico antes das migrations reais

Este documento define o schema esperado. Quando `server/schema/` existir, migrations passam a ser a fonte tecnica viva, mas este contrato deve continuar explicando a intencao das tabelas.

## MVP Tecnico

### `players`

Estado basico da conta de jogo.

Campos minimos:

- `id`
- `auth_user_id`
- `username`
- `account_type`
- `level`
- `xp`
- `power`
- `created_at`
- `updated_at`

### `resources`

Recursos do jogador.

Campos minimos:

- `player_id`
- `almas`
- `energia`
- `sangue`
- `cristais`
- `ossos`
- `diamante`
- `updated_at`

### `builds`

Build atual do jogador.

Campos MVP:

- `player_id`
- `weapon_type`
- `weapon_quality`
- `weapon_level`
- `spell_slots`
- `spells_unlocked`
- `pet_id`
- `pet_level`
- `passive_id`
- `passive_level`
- `updated_at`

Nota: a representacao final de spells desbloqueadas vs equipadas ainda e pendencia `DMOB-D026`.

### `battles`

Historico de batalhas server-authoritative.

Campos minimos:

- `id`
- `attacker_id`
- `defender_id`
- `defender_is_bot`
- `schema_version`
- `seed`
- `result`
- `event_log`
- `reward_payload`
- `reward_applied`
- `request_id`
- `created_at`

### `bot_builds`

Builds simuladas.

Campos minimos:

- `id`
- `power`
- `power_band`
- `build_data`
- `is_active`
- `created_at`

### `invite_codes`

Convites de alpha.

Campos minimos:

- `code`
- `max_uses`
- `used_count`
- `expires_at`
- `is_active`
- `created_at`

## Primeiro Slice Completo

Adicionar ou detalhar:

- `base_structures`
- `construction_jobs`
- `resource_transactions`
- `seasons`
- `ranking`
- `friends`
- `guilds`
- `guild_members`
- `guild_structures`
- `guild_contributions`
- `help_requests`
- `chat_channels`
- `chat_messages`
- `battle_passes`
- `battle_pass_progress`
- `daily_rewards`
- `reward_claims`
- `idempotency_keys`
- `telemetry_events`

## Regras De Seguranca

- RLS: jogador acessa apenas seus dados.
- Edge Functions com service role fazem mutacoes autoritativas.
- Cliente nunca envia delta de recurso final; envia intencao.
- Toda mutacao economica deve gravar ledger em `resource_transactions`.
- Toda mutacao com efeito deve usar idempotencia por `request_id`.

## Regras De Temporada

- `players.level`, maestrias, passivas e base permanecem entre seasons.
- Levels sazonais de arma, spells e pet resetam conforme design autoritativo.
- Snapshot de ranking deve preservar season encerrada.
