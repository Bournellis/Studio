# Database Schema Contract

- Ultima atualizacao: `2026-05-19`
- Status: contrato logico com migrations MVP e conta guest criadas

Este documento define o schema esperado. A fonte tecnica viva do runtime local e `../../supabase/migrations/`; `../../server/schema/migrations/` permanece como espelho backend durante o bootstrap.

Migrations atuais:

- `202605190001_mvp_foundation.sql`: tabelas MVP, RLS base, policies de leitura e bot fixture.
- `202605190002_guest_account_mvp.sql`: convite alpha, RPC `create_guest_account` e estado inicial de conta guest.

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

Seed MVP atual:

- `ALPHA-TEST`: convite local de teste para `POST /account/guest`.

### `idempotency_keys`

Registro de respostas ja processadas por player, endpoint e `request_id`.

Campos minimos:

- `player_id`
- `endpoint`
- `request_id`
- `response_payload`
- `created_at`

### `resource_transactions`

Ledger de mutacoes economicas.

Campos minimos:

- `id`
- `player_id`
- `source`
- `request_id`
- `delta`
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
- `telemetry_events`

## Regras De Seguranca

- RLS: jogador acessa apenas seus dados.
- Edge Functions com service role fazem mutacoes autoritativas.
- Cliente nunca envia delta de recurso final; envia intencao.
- Toda mutacao economica deve gravar ledger em `resource_transactions`.
- Toda mutacao com efeito deve usar idempotencia por `request_id`.
- `DMOB-D043` resolvido: no MVP, cliente nao recebe insert/update/delete policies para estado autoritativo.
- Escritas em `players`, `resources`, `builds`, `battles`, `idempotency_keys` e `resource_transactions` sao feitas por Edge Functions com service role.
- Policies client-side atuais sao de leitura propria, mais leitura de bots ativos.

## RPCs MVP

### `public.create_guest_account(p_auth_user_id, p_invite_code, p_request_id, p_device_label)`

Responsabilidade: criar de forma idempotente a conta guest inicial para um usuario Supabase Auth anonimo.

Implementado em: `202605190002_guest_account_mvp.sql`.

Regras:

- Exige usuario em `auth.users` com `is_anonymous = true`.
- Valida convite ativo, nao expirado e com usos disponiveis.
- Cria `players`, `resources` e `builds` com fixture `MVP_ONLY`.
- Grava resposta em `idempotency_keys` para endpoint `account/guest`.
- `GRANT EXECUTE` fica restrito a `service_role`; cliente usa Edge Function, nao RPC direto.

## Regras De Temporada

- `players.level`, maestrias, passivas e base permanecem entre seasons.
- Levels sazonais de arma, spells e pet resetam conforme design autoritativo.
- Snapshot de ranking deve preservar season encerrada.
