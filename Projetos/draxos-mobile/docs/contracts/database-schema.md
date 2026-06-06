# Database Schema Contract

- Ultima atualizacao: `2026-06-05`
- Status: contrato logico com migrations MVP, battle, base, social, matchmaking, ranking, monetizacao, rewards, telemetria client, `save_type`, reset separado por save, Progression Lab, auth email/senha, manifest/update, Track 16 de comportamento/crafting/consumiveis e Foundation Expansion Readiness com `account_profiles`, `game_saves`, `ruleset_registry`, `admin_audit_log`, idempotencia v1, metadata de ruleset e dominios criticos promovidos para RPCs transacionais v1. Arena PVE v1 acrescenta schema implementado para tentativa, duelos, buffs, progresso, first clears e perfis DB-side de recompensa.

Este documento define o schema esperado. A fonte tecnica viva do runtime local e `../../supabase/migrations/`; `../../server/schema/migrations/` permanece como espelho backend durante o alpha local.

Migrations atuais:

- `202605190001_mvp_foundation.sql`: tabelas MVP, RLS base, policies de leitura e bot fixture.
- `202605190002_guest_account_mvp.sql`: convite alpha, RPC `create_guest_account` e estado inicial de conta guest.
- `202605200001_battle_request_mvp.sql`: RPC `request_mvp_battle`, log `battle_log_v1`, recompensa fixture e idempotencia server-side.
- `202605200003_base_manager_economy.sql`: estruturas permanentes, fila de construcao, RLS de leitura e bootstrap da Base v0.
- `202605200004_social_matchmaking_ranking.sql`: season ativa, amizades, guilda, estruturas de guilda, chat, ranking e telemetria minima.
- `202605200005_monetization_rewards_alpha.sql`: Battle Pass, progresso de passe, claims de reward, compras alpha, RLS de leitura e seed `bp_s1_01`.
- `202605260001_two_save_context.sql`: `players.save_type`, unicidade por `auth_user_id + save_type` e RPCs com contexto de save.
- `202605260002_reset_save_context.sql`: RPC `reset_player_save` para reconstruir apenas o save ativo sem tocar o outro.
- `202605260003_progression_lab_apply.sql`: RPC `apply_progression_lab_save` para aplicar um healthy save gerado no save `progression_lab`.
- `202605270001_alpha_email_account.sql`: RPC `create_alpha_account` para conta email/senha registrada, alpha gate por convite/username e criacao dos saves `normal`/`progression_lab`.
- `202605280001_behavior_crafting.sql`: `po_osso`, Ossos inteiros reescalados, inventario de consumiveis, slot de pocao, comportamentos de spells e ledger de itens.
- `202605300001_foundation_expansion_readiness.sql`: `account_profiles`, `game_saves`, `ruleset_registry`, `admin_audit_log`, idempotencia com `request_hash/scope_id/status`, metadata de ruleset em historicos e RPCs de bootstrap/idempotencia/reconciliacao.
- `202605300002_transactional_domain_enforcement.sql`: promove Base para efeitos reais em RPCs v1 (`complete_due_base_jobs_v1`, `collect_base_v1`, `start_base_upgrade_v1`), com lock do save, reserva idempotente, ledger/saldo/job na mesma transacao e grants somente para `service_role`.
- `202605300003_remaining_transactional_domain_enforcement.sql`: promove battle rewards, monetization rewards/alpha purchase, build equip, crafting craft/crush-bones e guild create/join para RPCs v1 com lock de `game_saves`, `request_hash`, idempotencia pending/completed, ledger e grants somente para `service_role`.
- `202605300004_foundation_closeout.sql`: corrige `ruleset_registry` para publicacao imutavel por `publication_id`, persiste hashes de ruleset em saves/historicos, cria admin interno auditavel e promove as mutacoes restantes de build behavior/potion e social friend/chat para RPCs v1 `service_role`-only.
- `202606020001_openworld_bosque_hardening_v1.sql`: promove `openworld/forest` para `active` no canal `internal_alpha`, adiciona snapshot/revision/event audit em Mode sessions, registra `openworld_forest_ruleset_v1`, aplica limites de sessao e torna o Reward Bridge do Bosque autoritativo pelo snapshot do servidor.
- `202606030001_progression_lab_apply_request_hash.sql`: adiciona assinatura `apply_progression_lab_save(..., p_request_hash, ...)`, exige hash obrigatorio, bloqueia mismatch de idempotencia e move reset/seed de consumables, potion slots, spell behaviors e item transactions do Progression Lab para dentro da RPC transacional.
- `202606050001_openworld_bosque_collect_batch_v1.sql`: adiciona `collect_batch` ao audit de `mode_session_events`, substitui `openworld_forest_apply_event_v1` com aplicacao atomica de varios nodes coletados em uma unica revisao e preserva compatibilidade de `collect_complete` para pacotes antigos.
- `202606050001_arena_reward_profiles_v1.sql`: cria `arena_reward_profiles`, habilita RLS read-only para perfis ativos, seeda todos os perfis de `data/definitions/arena_rewards.json` e mantem `ledger_source = arena_pve_v1`.
- `202606050002_account_reset_request_hash_v1.sql`: adiciona `reset_player_save_v1(game_save_id, request_id, request_hash, payload)`, exige hash obrigatorio, usa idempotencia v1 por `game_saves.id`, move limpeza de Arena/Modes/Track 16 para a transacao SQL e preserva social/guilda/chat account-wide.

## Regras De Escopo De Servico

Foundation Closeout altera o schema por migration corretiva/aditiva. A
classificacao de escopo usa o schema atual como limite operacional:

- `save-scoped`: endpoints legados resolvem `players.id` por `auth_user_id +
  players.save_type`; contratos novos devem resolver `game_saves.id` e manter
  `legacy_player_id` apenas como compatibilidade.
- `account-scoped`: endpoints sociais podem usar o save `normal` como
  identidade canonica da conta quando existir, validando o save ativo apenas
  para nao misturar `progression_lab` com ranking/social normal.
- `release`: endpoints operacionais como manifest/healthcheck nao leem nem
  escrevem tabelas de gameplay.
- `telemetry`: endpoints de diagnostico escrevem somente em `telemetry_events`
  e podem manter `player_id = null` antes da criacao de save.
- `admin-internal`: administracao interna auditavel, `service_role`-only, sem
  painel publico e sem segredo no cliente/export.

Mutacoes `save-scoped` e `account-scoped` atuais continuam usando
`idempotency_keys` com o `player_id` do save ativo ou da identidade social
canonica. Mutacoes novas devem usar `request_hash`, `scope_id` e status
`pending|completed|failed`; account-wide deve usar `account_profiles`.

Mutacoes v1 preservam compatibilidade de payload HTTP, mas o efeito autoritativo
usa `game_saves.id`, `request_hash`, `ruleset_registry`, `idempotency_keys.status`
e ledger/historicos dentro dos RPCs `service_role`-only.

## Account/Save Foundation

Contratos detalhados: `account-save.md`.

`account_profiles` e a identidade account-wide. `game_saves` e o progresso por
save. `players.save_type` permanece como compat layer alpha e alias historico,
nao como fonte primaria para novos contratos.

Campos novos minimos:

- `account_profiles.id`, `auth_user_id`, `canonical_player_id`, `username`, `account_type`, `status`, `metadata`.
- `game_saves.id`, `account_profile_id`, `legacy_player_id`, `save_type`,
  `slot_key`, `lifecycle_status`, `ruleset_id`, `ruleset_version`,
  `ruleset_publication_id`, `ruleset_content_hash`, `ruleset_simulator_hash`,
  `ruleset_schema_version`, `state_version`, `season_context`, `snapshot`.

## Ruleset Registry Foundation

Contrato detalhado: `ruleset-registry.md`.

`ruleset_registry` registra publicacoes imutaveis de ruleset. A identidade de
publicacao e `publication_id`; `ruleset_id` continua legivel e compoe a unicidade
`ruleset_id + ruleset_version + channel + cohort`. O registro inicial e
`foundation_ruleset_v0`, versao `1`, canal `internal_alpha`, cohort `all`, com
`content_hash` e `simulator_hash` gerados pelo repo.

Tabelas com metadata de ruleset nesta fundacao:

- `game_saves`
- `battles`
- `construction_jobs`
- `reward_claims`
- `alpha_purchases`

## Admin Audit Foundation

Contrato detalhado: `admin-ops.md`.

`admin_audit_log` e a base minima de auditoria interna. As RPCs
`admin_lookup_account_v1`, `admin_battle_diagnostics_v1`,
`resource_reconciliation_report_v1`, `admin_adjust_resource_balance_v1` e
`admin_flag_account_v1` sao internas, auditaveis e sem grant para
`anon`/`authenticated`.

## Arena PVE v1 Schema Contratado

Status: implementado parcialmente em migrations locais/remotas espelhadas. Tentativas,
duelos, progresso e first clears vivem nas migrations de Arena PVE; perfis de
recompensa calibraveis vivem em `arena_reward_profiles`.

Contrato de produto: `../pve-arena-v1.md`.

Novas tabelas futuras devem usar `game_saves.id` como autoridade primaria. `players.id` pode aparecer apenas como compatibilidade historica ou cache denormalizado.

### `pve_arena_progress`

Progresso agregado por save e arena.

Campos minimos:

- `id`
- `game_save_id`
- `arena_id`
- `highest_difficulty_cleared`
- `best_duel_index`
- `best_duel_count`
- `first_cleared_at`
- `last_played_at`
- `clear_count`
- `ruleset_publication_id`
- `created_at`
- `updated_at`

Regras:

- unico por `game_save_id + arena_id`;
- nao atualiza `ranking`;
- reset do save limpa ou reconstrui progresso deste save;
- `progression_lab` pode ter progresso proprio, sempre fora de ranking.

### `pve_arena_attempts`

Tentativa ativa ou historica de Arena PVE.

Campos minimos:

- `id`
- `game_save_id`
- `arena_id`
- `difficulty_tier`
- `state` (`active`, `completed`, `failed`, `abandoned`, `claimed`)
- `duel_count`
- `current_duel_index`
- `locked_loadout_snapshot`
- `locked_loadout_hash`
- `behavior_snapshot`
- `active_buff_payload`
- `reward_profile_id`
- `reward_payload`
- `request_id`
- `request_hash`
- `ruleset_publication_id`
- `ruleset_id`
- `ruleset_version`
- `ruleset_content_hash`
- `ruleset_simulator_hash`
- `ruleset_schema_version`
- `started_at`
- `completed_at`
- `claimed_at`
- `created_at`
- `updated_at`

Regras:

- no maximo uma tentativa `active` por `game_save_id`;
- loadout snapshot nao muda ate finalizar a tentativa;
- comportamento pode mudar entre duelos, mas deve ser registrado em snapshot/step;
- derrota encerra a tentativa v1;
- abandono nao concede recompensa de conclusao.

### `pve_arena_attempt_duels`

Registro de cada duelo dentro da tentativa.

Campos minimos:

- `id`
- `attempt_id`
- `game_save_id`
- `duel_index`
- `enemy_id`
- `battle_id`
- `state` (`pending`, `won`, `lost`, `error`)
- `buffs_before_duel`
- `behavior_before_duel`
- `hp_reset`
- `seed`
- `result_payload`
- `created_at`
- `resolved_at`

Regras:

- unico por `attempt_id + duel_index`;
- `hp_reset` deve ser `true` no v1;
- `battle_id` aponta para `battles.id` e o replay deve ler `battle_log_v1` salvo;
- erro de simulacao nao pode aplicar recompensa.

### `pve_arena_buff_offers`

Oferta de 3 buffs apos uma vitoria quando ainda ha proximo duelo.

Campos minimos:

- `id`
- `attempt_id`
- `game_save_id`
- `after_duel_index`
- `offered_buff_ids`
- `selected_buff_id`
- `selected_at`
- `request_id`
- `request_hash`
- `created_at`

Regras:

- `offered_buff_ids` deve ter exatamente 3 ids em v1;
- `selected_buff_id` deve pertencer a oferta;
- uma oferta so pode ser escolhida uma vez;
- repetir `request_id/request_hash` retorna a mesma escolha.

### `pve_arena_reward_claims`

Claim de recompensa de arena.

Campos minimos:

- `id`
- `attempt_id`
- `game_save_id`
- `arena_id`
- `reward_profile_id`
- `period_keys`
- `reward_payload`
- `repeat_multiplier`
- `source`
- `request_id`
- `request_hash`
- `ruleset_publication_id`
- `created_at`

Regras:

- unico por `attempt_id`;
- source de ledger: `arena_pve_v1`;
- grava deltas economicos em `resource_transactions`;
- primeira clear, recorde, repeticao e caps devem ser calculados no servidor;
- nao toca `ranking`.

### `arena_reward_profiles`

Status: **implementado em `202606050001_arena_reward_profiles_v1.sql`**.

Tabela read-only para perfis calibraveis de recompensa da Arena PVE.

Campos minimos:

- `id`
- `mode`
- `season_id`
- `version`
- `enabled`
- `display_name`
- `description`
- `tags`
- `resources`
- `first_clear_multiplier`
- `completion_multiplier`
- `repeat_multiplier`
- `record_bonus`
- `daily_bonus_key`
- `weekly_cap_key`
- `season_cap_key`
- `ledger_source`
- `payload`
- `source_collection`
- `source_schema_version`
- `updated_at`

Regras:

- seed idempotente a partir de `data/definitions/arena_rewards.json`;
- `ledger_source` fixo em `arena_pve_v1`;
- `mode` fixo em `PVE_ARENA_V1`;
- `resources`, `record_bonus` e `payload` devem ser objetos JSON;
- clientes autenticados podem ler apenas perfis `enabled`; escritas passam por
  migration/ops, nao por cliente;
- todo `reward_profile_id` de `pve_arena_difficulties.json` deve existir neste
  seed DB-side.

## Openworld Bosque v1 Schema Contratado

Status: migration local preparada em mirror `server/schema/migrations/` e
`supabase/migrations/`; nao aplicada remotamente nesta entrega.

Definition: `data/definitions/openworld/forest_ruleset_v1.json`.

### `mode_sessions`

Campos adicionais para modos retomaveis:

- `snapshot_payload`: snapshot server-authoritative do modo;
- `snapshot_revision`: revisao monotonicamente crescente;
- `last_event_at`: ultimo evento aceito pelo servidor.

Regras:

- `openworld/forest` usa `openworld_forest_snapshot_v1`;
- sessao ativa expira em 2 horas;
- no maximo uma sessao `started` por save/mode/slice;
- completion exige `expected_revision` igual a `snapshot_revision`;
- recompensa real deriva apenas de `snapshot_payload`.

### `mode_session_events`

Auditoria de eventos aceitos/rejeitados pelo Bosque.

Campos minimos:

- `id`
- `session_id`
- `game_save_id`
- `mode_id`
- `slice_id`
- `request_id`
- `request_hash`
- `event_type`
- `expected_revision`
- `revision_after`
- `event_payload`
- `snapshot_payload`
- `created_at`

Regras:

- unico por `session_id + request_id`;
- leitura/escrita direta do cliente proibida por RLS;
- acesso operacional via RPC `service_role`;
- stale write rejeita antes de mutar snapshot;
- no coletado nao pode ser consumido duas vezes;
- coleta em andamento nao e persistida.

### RPCs

- `mode_session_start_v1`: cria snapshot revision `0`, aplica
  `mode_limit_policies` com 1 sessao ativa, cooldown de 10s, limite diario de
  100 starts e expiracao de 2h.
- `mode_session_event_v1`: valida evento, `expected_revision`, ruleset e
  sessao ativa, aplica snapshot e avanca revisao.
- `mode_session_complete_v1`: usa somente snapshot do servidor para calcular
  `deposited_items`, `activity_score`, caps e reward ledger.
- `mode_session_abandon_v1`: idempotente, registra estado final e remove a
  sessao de retomada.

## MVP Tecnico

### `players`

Estado basico da conta de jogo.

Campos minimos:

- `id`
- `auth_user_id`
- `save_type`
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
- `po_osso`
- `diamante`
- `updated_at`

Regras Track 16:

- `ossos` e inteiro na escala atual (`1 Osso atual = 0.01 Osso antigo`).
- `po_osso` e inteiro, sempre nao negativo.
- A migracao Track 16 multiplica saldos/logs/rewards existentes de Ossos por `100` e impede novo saldo fracionario.

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

### `player_consumables`

Inventario save-scoped de consumiveis.

Campos minimos:

- `player_id`
- `item_id`
- `quantity`
- `updated_at`

Regras:

- chave unica por `player_id + item_id`;
- `quantity >= 0`;
- consumo em batalha e crafting sao server-authoritative.

### `player_potion_slots`

Slot save-scoped de pocao. Track 16 libera apenas o slot `1`, vazio por padrao.

Campos minimos:

- `player_id`
- `slot_index`
- `potion_id`
- `behavior`
- `updated_at`

### `player_spell_behaviors`

Comportamento salvo por spell equipada.

Campos minimos:

- `player_id`
- `spell_id`
- `behavior`
- `updated_at`

### `item_transactions`

Ledger de itens para crafting e consumo.

Campos minimos:

- `id`
- `player_id`
- `source`
- `request_id`
- `item_id`
- `delta`
- `metadata`
- `created_at`

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
- `request_hash`
- `scope_id`
- `status`
- `response_payload`
- `completed_at`
- `failed_at`
- `created_at`

Status v1: `pending`, `completed`, `failed`.

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

## Internal Alpha v0 - Extensao De Save

Track 03 precisa separar conta de teste e save de jogo sem quebrar o runtime atual. A direcao de longo prazo e:

- uma conta Supabase Auth pode ter metadados alpha;
- a conta possui dois saves logicos: `normal` e `progression_lab`;
- tabelas de gameplay devem conseguir apontar para o save correto;
- Progression Lab escreve somente no save `progression_lab`.

Implementacao inicial em `T03-P03B` usa uma evolucao compativel do schema atual:

- adicionar `save_type` a `players` com valores `normal` e `progression_lab`;
- garantir unicidade por `auth_user_id + save_type`;
- fazer tabelas existentes continuarem referenciando `players.id`;
- criar ou recuperar cada `player`/save conforme o header `x-draxos-save-type`;
- deixar `competition/ranking/current` fora do `progression_lab` com motivo explicito `PROGRESSION_LAB_DOES_NOT_RANK`.

Implementado em `T03-P03C`:

- `reset_player_save` reconstrui o save selecionado em torno do mesmo `player_id`;
- reset limpa estado de batalha, base, social, ranking, loja, recursos, build, jobs, idempotencia de acoes e progresso daquele save;
- reset nao toca outro `players.id` da mesma `auth_user_id`;
- reset usa `request_id`, grava ledger `account/saves/reset` e preserva idempotencia do proprio reset;
- `account/guest` do mesmo save passa a retornar o payload resetado se repetir o `request_id` original.

Atualizado no Track 22 pacote 4c:

- `reset_player_save_v1` recebe `game_save_id`, `request_id`, `request_hash` e payload canonico;
- `request_hash` e obrigatorio e mismatch de hash no mesmo `request_id` retorna `IDEMPOTENCY_HASH_MISMATCH` via `reserve_idempotency`;
- reset limpa runtime save-scoped de batalha/base/ranking/loja/jobs/Arena/Modes/Track 16 dentro da transacao SQL;
- reset preserva social/guilda/chat/amizades account-wide;
- a assinatura legada `reset_player_save(uuid, uuid, text)` tem acesso `service_role` revogado pela migration nova.

Implementado em `T03-P04`:

- `apply_progression_lab_save` seleciona somente o `players.id` com `save_type = progression_lab`;
- a Edge Function `progression-lab/apply` valida `profile_id`, `milestone_id` e `save_id` contra o catalogo versionado de healthy saves antes de chamar a RPC;
- aplicacao substitui level/xp/power, resources, build, base, job ativo e progresso do Battle Pass do Lab;
- aplicacao limpa batalha, ranking, social vinculado ao player do Lab quando existir, loja anterior, jobs, claims, compras alpha, ledger e idempotencias de acoes daquele save;
- a RPC nunca escreve no save `normal`, grava ledger `progression-lab/apply` e preserva idempotencia por `request_id`;
- `account/guest` do save Lab passa a retornar o payload aplicado se repetir o `request_id` original.

Implementado em `T03-P14`:

- `create_alpha_account` exige `auth.users.is_anonymous = false`;
- o primeiro save da conta exige convite alpha ativo e `username` valido;
- `players.account_type` fica como `registered` para contas email/senha;
- criar o segundo save da mesma conta nao consome novo convite;
- save `progression_lab` recebe username com sufixo `*_lab` para leitura social e permanece isolado do ranking;
- a Edge Function `account/bootstrap` chama a RPC com `request_id` idempotente;
- `account/guest` passa a rejeitar JWT registrado e fica restrito a fallback dev/local.

Estado apos Foundation Closeout:

- social foi promovido em `T03-P06` para identidade de conta no runtime: Edge Functions usam o save `normal` como `social_player` canonico quando ele existe e retornam marcador `lab` para o viewer em `progression_lab`;
- `account_profiles` + `game_saves` existem e nascem no bootstrap/guest/sync;
- tabelas de dominio ainda podem manter `player_id` como compatibilidade, mas novas mutations devem resolver e travar `game_saves.id`;
- o alpha gate ainda e simples: convite + username no primeiro save; admin minimo interno existe para lookup, diagnostico, reconciliacao, ajuste auditado e flag de conta, nao como painel publico.

Decisao Track 04 em `../../implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/account-save-gate-decision.md` foi superseded pela Foundation Expansion Readiness/Closeout. Ela permanece como historico, nao como direcao ativa.

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

- Base v0 usa 1 slot de construcao por padrao.
- `alpha_double_construction_queue`, registrado em `alpha_purchases`, libera 2 slots de construcao para aquele save.
- Nao ha dois jobs ativos da mesma estrutura.
- Jobs vencidos sao concluidos pelo servidor ao ler/coletar/evoluir base.
- Gastos e coletas usam `resource_transactions` e `idempotency_keys`.

### `seasons`

Status: **implementado em T00-P12**.

Seed atual: `season_001` / `Season 1 Alpha`, ativa.

### `friendships`

Status: **implementado em T00-P12** e refinado em `T03-P06`.

Guarda relacoes sociais entre jogadores. No alpha, `friends/add` cria arestas aceitas nos dois sentidos por username e o backend resolve usernames de save Lab para a identidade social normal da mesma conta quando possivel.

### `guilds`, `guild_members`, `guild_structures`

Status: **implementado em T00-P12** e refinado em `T03-P06`.

Guilda v0:

- level 1-10;
- jogador participa de 1 guilda por vez;
- criador entra como `owner`;
- `social/guild/join` permite entrar por nome de guilda;
- quatro estruturas iniciais: `oficina_ritual`, `condensador_astral`, `arquivo_de_dominio`, `cofre_abissal`.

### `chat_channels`, `chat_messages`

Status: **implementado em T00-P12** e refinado em `T03-P06`.

Chat v0 usa canal de guilda por polling. Mensagens tem limite de 280 caracteres, rate limit alpha por usuario/canal, soft delete futuro via `deleted_at` e leitura restrita a membros da guilda.

### `ranking`

Status: **implementado em T00-P12** e refinado em `T03-P07`.

Ranking da season ativa por jogador real. `competition/ranking/current` cria linha propria com 0 pontos quando necessario, retorna top 10 + posicao do jogador e mantem bots fora desta tabela. `battle/request` no modo `FIRST_SLICE_SIM` atualiza pontos do save `normal` com o modelo `alpha_v0_power_adjusted`; `progression_lab` nao insere nem pontua ranking.

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
- Redeems diarios usam `purchase_payload.redeem_period_key` com dia `America/Sao_Paulo` para impedir duplicacao por produto/save.
- Produtos unicos, como `alpha_battle_pass_premium` e `alpha_double_construction_queue`, retornam `already_owned=true` quando ja ativos e nao cobram de novo.
- Diamante, premium, fila dupla e pacotes continuam mutando estado apenas via Edge Function e ledger.

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

### `public.create_guest_account(p_auth_user_id, p_invite_code, p_request_id, p_device_label, p_save_type)`

Responsabilidade: criar de forma idempotente a conta guest inicial para um usuario Supabase Auth anonimo.

Implementado originalmente em: `202605190002_guest_account_mvp.sql`.
Atualizado em: `202605260001_two_save_context.sql`.

Regras:

- Exige usuario em `auth.users` com `is_anonymous = true`.
- `p_save_type` aceita apenas `normal` ou `progression_lab`.
- Valida convite ativo, nao expirado e com usos disponiveis.
- Cria ou recupera `players`, `resources` e `builds` com fixture `MVP_ONLY` para o save solicitado.
- Grava resposta em `idempotency_keys` para endpoint `account/guest`.
- `GRANT EXECUTE` fica restrito a `service_role`; cliente usa Edge Function, nao RPC direto.

### `public.request_mvp_battle(p_auth_user_id, p_request_id, p_mode, p_save_type)`

Responsabilidade: criar batalha fixture `MVP_ONLY` de forma idempotente para um jogador autenticado.

Implementado originalmente em: `202605200001_battle_request_mvp.sql`.
Atualizado em: `202605260001_two_save_context.sql`.

Regras:

- Exige player existente para o `auth_user_id` e `p_save_type`.
- `p_save_type` aceita apenas `normal` ou `progression_lab`.
- Aceita apenas `p_mode = 'MVP_ONLY'` no MVP tecnico.
- Usa bot ativo `mvp_training_bot`.
- Gera seed deterministica a partir de player e `request_id`.
- Grava `battles`, `resource_transactions` e `idempotency_keys`.
- Aplica uma unica vez a recompensa tecnica `mvp_training_reward`: `xp +5`, `ossos +1`.
- `GRANT EXECUTE` fica restrito a `service_role`; cliente usa Edge Function, nao RPC direto.

### `public.reset_player_save_v1(p_game_save_id, p_request_id, p_request_hash, p_request_payload)`

Responsabilidade: resetar de forma server-authoritative apenas o save selecionado de uma conta.

Implementado em: `202606050002_account_reset_request_hash_v1.sql`.

Regras:

- Exige `game_saves.id` ativo, `request_id` UUID e `request_hash` nao vazio.
- Usa `public.reserve_idempotency(..., endpoint = 'account/saves/reset', scope_id = game_save_id)`.
- Repetir `request_id/request_hash` retorna o payload gravado; repetir `request_id` com hash divergente retorna `IDEMPOTENCY_HASH_MISMATCH`.
- Mantem o mesmo `players.id`, `auth_user_id`, `username`, `account_type` e `save_type`.
- Reseta `level`, `xp`, `power`, `resources`, `builds`, `base_structures`, `construction_jobs`, `battles`, `ranking`, `battle_pass_progress`, `reward_claims`, `alpha_purchases`, Arena PVE, Mode sessions/progress/reward claims, Track 16 consumables/potion slots/spell behaviors/item ledger e idempotencias de acoes daquele save.
- Nao altera linhas de outro save da mesma conta.
- Preserva guildas, memberships, amizades, chat, guild contributions e construction helps account-wide.
- Desassocia telemetria client antiga do `player_id` resetado.
- Grava `resource_transactions` com source `account/saves/reset`.
- Atualiza o payload idempotente de `account/guest` do mesmo save para refletir o estado resetado.
- `GRANT EXECUTE` fica restrito a `service_role`; cliente usa Edge Function, nao RPC direto.

## Regras De Temporada

- `players.level`, Instrumento Ritual, spells, Familiar, Doutrina, construcoes, qualidade do instrumento inicial e maestrias permanecem entre seasons.
- O cap de todos os sistemas sobe por season conforme configuracao autoritativa de economia.
- Catch-up aplica multiplicadores suaves de XP/recursos para jogadores abaixo do cap anterior, sem mutar levels diretamente.
- Battle Pass, ranking/eventos de arena, missoes sazonais e ofertas temporarias resetam por season.
- Snapshot de ranking deve preservar season encerrada.
