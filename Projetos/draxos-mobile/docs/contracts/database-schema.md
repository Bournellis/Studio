# Database Schema Contract

- Ultima atualizacao: `2026-05-20`
- Status: contrato logico com migrations MVP, conta guest e battle request criadas

Este documento define o schema esperado. A fonte tecnica viva do runtime local e `../../supabase/migrations/`; `../../server/schema/migrations/` permanece como espelho backend durante o bootstrap.

Migrations atuais:

- `202605190001_mvp_foundation.sql`: tabelas MVP, RLS base, policies de leitura e bot fixture.
- `202605190002_guest_account_mvp.sql`: convite alpha, RPC `create_guest_account` e estado inicial de conta guest.
- `202605200001_battle_request_mvp.sql`: RPC `request_mvp_battle`, log `battle_log_v1`, recompensa fixture e idempotencia server-side.

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

Schema do primeiro slice:

- `builds` permanece como resumo de equipamento atual para leitura rapida: arma, qualidade, level da arma, passiva equipada, pet equipado, poder calculado, versao da formula de poder e `updated_at`.
- `player_spell_state` guarda spells desbloqueadas e progresso: `player_id`, `spell_id`, `spell_level`, `is_unlocked`, `unlocked_at_level`, `updated_at`.
- `player_spell_slots` guarda equipamento por slot: `player_id`, `slot_index` (`1..3`), `unlocked_at_level` (`3`, `7`, `25`), `equipped_spell_id`, `updated_at`.
- `player_passive_state` guarda passivas desbloqueadas e levels. O slot de passiva abre no level 10.
- `player_pet_state` guarda pets desbloqueados e levels. O slot de pet abre no level 15.

Regras:

- O personagem comeca com 0 slots de spell equipaveis.
- `build/equip` deve rejeitar equipamento em slot bloqueado pelo level.
- Spells desbloqueadas podem ser equipadas em qualquer slot desbloqueado.
- O servidor recalcula `players.power` sempre que build, level ou upgrade mudar.

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

### `telemetry_events`

Eventos de telemetria para balanceamento, UX e matchmaking.

Campos minimos:

- `id`
- `player_id` nullable para simulacoes bot-vs-bot
- `battle_id` nullable
- `session_id` nullable
- `event_type`
- `schema_version`
- `source` (`client`, `server`, `simulation_job`)
- `payload`
- `created_at`

Eventos minimos do primeiro slice:

- `battle_requested`
- `match_selected`
- `battle_simulated`
- `reward_applied`
- `build_snapshot`
- `bot_balance_simulated`

Regras:

- Telemetria nao concede recompensa, ranking ou progresso.
- Payloads carregam snapshots compactos, nao dados secretos completos de outro jogador para o cliente.
- Batalhas bot-vs-bot usam `player_id = null`, `source = simulation_job` e ficam fora do ranking.

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

### `public.request_mvp_battle(p_auth_user_id, p_request_id, p_mode)`

Responsabilidade: criar batalha fixture `MVP_ONLY` de forma idempotente para um jogador autenticado.

Implementado em: `202605200001_battle_request_mvp.sql`.

Regras:

- Exige player existente para o `auth_user_id`.
- Aceita apenas `p_mode = 'MVP_ONLY'` no MVP tecnico.
- Usa bot ativo `mvp_training_bot`.
- Gera seed deterministica a partir de player e `request_id`.
- Grava `battles`, `resource_transactions` e `idempotency_keys`.
- Aplica uma unica vez a recompensa tecnica `mvp_training_reward`: `xp +5`, `ossos +1`.
- `GRANT EXECUTE` fica restrito a `service_role`; cliente usa Edge Function, nao RPC direto.

## Regras De Temporada

- `players.level`, arma, spells, pet, passivas, construcoes, qualidade da varinha e maestrias permanecem entre seasons.
- O cap de todos os sistemas sobe por season conforme configuracao autoritativa de economia.
- Catch-up aplica multiplicadores suaves de XP/recursos para jogadores abaixo do cap anterior, sem mutar levels diretamente.
- Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias resetam por season.
- Snapshot de ranking deve preservar season encerrada.
