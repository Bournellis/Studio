# Database Schema Contract

- Ultima atualizacao: `2026-05-26`
- Status: contrato logico com migrations MVP, battle, base, social, matchmaking, ranking, monetizacao, rewards e telemetria client implementadas; Track 03 planeja suporte a email/senha e dois saves por conta

Este documento define o schema esperado. A fonte tecnica viva do runtime local e `../../supabase/migrations/`; `../../server/schema/migrations/` permanece como espelho backend durante o alpha local.

Migrations atuais:

- `202605190001_mvp_foundation.sql`: tabelas MVP, RLS base, policies de leitura e bot fixture.
- `202605190002_guest_account_mvp.sql`: convite alpha, RPC `create_guest_account` e estado inicial de conta guest.
- `202605200001_battle_request_mvp.sql`: RPC `request_mvp_battle`, log `battle_log_v1`, recompensa fixture e idempotencia server-side.
- `202605200003_base_manager_economy.sql`: estruturas permanentes, fila de construcao, RLS de leitura e bootstrap da Base v0.
- `202605200004_social_matchmaking_ranking.sql`: season ativa, amizades, guilda, estruturas de guilda, chat, ranking e telemetria minima.
- `202605200005_monetization_rewards_alpha.sql`: Battle Pass, progresso de passe, claims de reward, compras alpha, RLS de leitura e seed `bp_s1_01`.

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

- `builds` permanece como resumo de equipamento atual para leitura rapida: instrumento ritual, qualidade, level do instrumento, doutrina/passiva equipada, familiar/pet equipado, poder calculado, versao da formula de poder e `updated_at`.
- `player_spell_state` guarda spells desbloqueadas e progresso: `player_id`, `spell_id`, `spell_level`, `is_unlocked`, `unlocked_at_level`, `updated_at`.
- `player_spell_slots` guarda equipamento por slot: `player_id`, `slot_index` (`1..3`), `unlocked_at_level` (`3`, `7`, `25`), `equipped_spell_id`, `updated_at`.
- `player_passive_state` guarda Doutrinas desbloqueadas e levels. O slot de doutrina abre no level 10.
- `player_pet_state` guarda Familiares desbloqueados e levels. O slot de familiar abre no level 15.

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
- `reward_claims`
- `alpha_purchases`
- `telemetry_events`

## Internal Alpha v0 - Extensao Planejada

Track 03 precisa separar conta de teste e save de jogo sem quebrar o runtime atual. A direcao de longo prazo e:

- uma conta Supabase Auth pode ter metadados alpha;
- a conta possui dois saves logicos: `normal` e `progression_lab`;
- tabelas de gameplay devem conseguir apontar para o save correto;
- Progression Lab escreve somente no save `progression_lab`.

Implementacao inicial pode usar uma evolucao compativel do schema atual:

- adicionar `save_type` a `players` com valores `normal` e `progression_lab`;
- garantir unicidade por `auth_user_id + save_type`;
- fazer tabelas existentes continuarem referenciando `players.id`;
- criar os dois `players`/saves no bootstrap da conta alpha;
- marcar metadados do save lab em payload ou coluna propria.

Refatoracao futura, se o projeto crescer:

- criar `account_profiles` para dados da conta;
- criar `game_saves` para saves por modo/tipo;
- migrar tabelas de gameplay de `player_id` para `save_id` ou manter `player_id` como alias de save.

Regras de seguranca:

- RLS precisa isolar saves do mesmo `auth_user_id` de outros usuarios.
- Edge Functions decidem o save ativo.
- Reset de um save nao toca linhas do outro.
- Ranking/social normal nao recebe efeitos de `progression_lab`, salvo decisao explicita futura.

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
- Eventos client Track 01 usam `schema_version = telemetry_client_v1`, `source = client` e `session_id` local persistido pelo Godot.
- Telemetria client pode usar `player_id = null` antes da criacao da conta guest, mas continua exigindo JWT valido.

### `base_structures`

Status: **implementado em T00-P11**.

Estado permanente das seis estruturas pessoais da Base v0.

Campos:

- `player_id`
- `structure_id`
- `level`
- `last_collected_at`
- `updated_at`

IDs validos:

- `altar_das_almas`
- `nucleo_energia`
- `pocos_sangue`
- `minas_cristal`
- `estrutura_stats`
- `ossario`

Regras:

- `level` vai de 0 a 40.
- Estruturas level 0 produzem 0.
- Producao offline e calculada por Edge Function a partir de `last_collected_at`.
- Cliente possui apenas leitura propria via RLS.

### `construction_jobs`

Status: **implementado em T00-P11**.

Fila de upgrades permanentes da base.

Campos:

- `id`
- `player_id`
- `structure_id`
- `target_level`
- `status`
- `cost_payload`
- `started_at`
- `completes_at`
- `completed_at`
- `request_id`
- `created_at`
- `updated_at`

Regras:

- Base v0 usa 1 slot de construcao.
- Segundo slot existe como contrato de design, mas compra/liberacao fica para monetizacao/alpha posterior.
- Nao ha dois jobs ativos da mesma estrutura.
- Jobs vencidos sao concluidos pelo servidor ao ler/coletar/evoluir base.
- Gastos e coletas usam `resource_transactions` e `idempotency_keys`.

### `seasons`

Status: **implementado em T00-P12**.

Seed atual: `season_001` / `Season 1 Alpha`, ativa.

### `friendships`

Status: **implementado em T00-P12**.

Guarda relacoes sociais entre jogadores. No alpha, `friends/add` cria arestas aceitas nos dois sentidos por username.

### `guilds`, `guild_members`, `guild_structures`

Status: **implementado em T00-P12**.

Guilda v0:

- level 1-10;
- jogador participa de 1 guilda por vez;
- criador entra como `owner`;
- quatro estruturas iniciais: `oficina_ritual`, `condensador_astral`, `arquivo_de_dominio`, `cofre_abissal`.

### `chat_channels`, `chat_messages`

Status: **implementado em T00-P12**.

Chat v0 usa canal de guilda por polling. Mensagens tem limite de 280 caracteres, soft delete futuro via `deleted_at` e leitura restrita a membros da guilda.

### `ranking`

Status: **implementado em T00-P12**.

Ranking da season ativa por jogador real. `competition/ranking/current` cria linha propria com 0 pontos quando necessario. Bots ficam fora desta tabela.

### `guild_contributions`, `construction_helps`

Status: **schema preparado em T00-P12**.

Tabelas preparadas para contribuicoes e ajudas sociais. Endpoints completos de contribuicao/ajuda ficam para refinamento posterior se necessario durante alpha.

### `battle_passes`

Status: **implementado em T00-P13**.

Seed atual: `bp_s1_01` / `Battle Pass Alpha 01`, vinculado a `season_001`, ativo de `2026-05-20` a `2026-07-19`.

Campos:

- `id`
- `season_id`
- `pass_index`
- `display_name`
- `starts_at`
- `ends_at`
- `free_rewards`
- `premium_rewards`
- `is_active`
- `created_at`

Regras:

- Cliente possui leitura somente de passes ativos.
- Rewards detalhadas ficam em JSON de contrato e no Edge Function `monetization`.
- T00-P13 materializa tier 1 free/premium e os totais do baseline de economia.

### `battle_pass_progress`

Status: **implementado em T00-P13**.

Progresso do jogador no Battle Pass ativo.

Campos:

- `player_id`
- `pass_id`
- `pass_xp`
- `premium_unlocked`
- `updated_at`

Regras:

- Row criada sob demanda por `GET /monetization/state`.
- `pass_xp` aumenta com rewards diarias/semanais.
- `premium_unlocked` muda apenas por `POST /monetization/alpha-purchase`.

### `reward_claims`

Status: **implementado em T00-P13**.

Registro idempotente de claims diarios, semanais e de Battle Pass.

Campos:

- `id`
- `player_id`
- `source` (`daily`, `weekly`, `battle_pass`)
- `reward_id`
- `period_key`
- `request_id`
- `reward_payload`
- `created_at`

Regras:

- Unico por `player_id + source + reward_id + period_key`.
- Novo `request_id` para claim ja feita no mesmo periodo retorna `already_claimed=true`.
- Cliente possui apenas leitura propria via RLS.

### `alpha_purchases`

Status: **implementado em T00-P13**.

Registro de compras alpha simuladas.

Campos:

- `id`
- `player_id`
- `product_id`
- `request_id`
- `purchase_payload`
- `created_at`

Regras:

- Unico por `player_id + request_id`.
- Compras alpha nao integram gateway real de pagamento.
- Diamante, premium e pacotes continuam mutando estado apenas via Edge Function e ledger.

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

- `players.level`, Instrumento Ritual, spells, Familiar, Doutrina, construcoes, qualidade do instrumento inicial e maestrias permanecem entre seasons.
- O cap de todos os sistemas sobe por season conforme configuracao autoritativa de economia.
- Catch-up aplica multiplicadores suaves de XP/recursos para jogadores abaixo do cap anterior, sem mutar levels diretamente.
- Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias resetam por season.
- Snapshot de ranking deve preservar season encerrada.
