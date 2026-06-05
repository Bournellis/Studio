# server/tests/

Testes Deno/TypeScript das Edge Functions e do simulador server-authoritative.

No MVP atual, o alvo inicial e validar:

- `healthcheck` responde `ok: true`.
- migrations aplicam em banco limpo.
- `battle/request` exige auth, retorna `battle_log_v1` e respeita idempotencia
  por `request_id`.
- `telemetry/client-event` exige auth, grava eventos client nao autoritativos e
  continua protegido por RLS contra insert direto.

## Smokes

Sem Supabase local:

```powershell
npx -y deno test --allow-read server/tests/foundation_contracts_test.ts
npx -y deno test --allow-read server/tests/lab_heuristics_contract_test.ts
npx -y deno test --allow-read server/tests/foundation_expansion_schema_test.ts
npx -y deno test --allow-read server/tests/foundation_closeout_schema_test.ts
npx -y deno test --allow-read server/tests/api_version_contract_test.ts
npx -y deno test --allow-read server/tests/progression_lab_apply_contract_test.ts
npx -y deno test --allow-read server/tests/transactional_domain_enforcement_schema_test.ts
npx -y deno test --allow-read server/tests/remaining_transactional_domain_enforcement_schema_test.ts
npx -y deno test --allow-read server/tests/battle_combatants_test.ts
npx -y deno test --allow-read server/tests/base_domain_test.ts
npx -y deno test --allow-read server/tests/battle_log_projection_test.ts
npx -y deno test --allow-read server/tests/progression_domain_test.ts
npx -y deno test --allow-read server/tests/economy_domain_test.ts
npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts
npx -y deno test --allow-read server/tests/integer_bones_contract_test.ts
npx -y deno test --allow-read server/tests/mode_definitions_schema_test.ts
npx -y deno test --allow-read server/tests/release_auth_contract_test.ts
```

O teste `foundation_contracts_test.ts` le `docs/contracts/api-endpoints.md` e o
feature registry para garantir que a matriz atual declare escopo por endpoint e
que os cards mantenham campos obrigatorios completos antes de novas
features/servicos.

O teste `lab_heuristics_contract_test.ts` valida que
`docs/contracts/lab-heuristics.md` registra os modelos atuais de Battle
Lab/Progression Lab, que o Battle Lab Godot exibe os mesmos pesos de poder do
runner TypeScript e que os seletores de perfil/milestone do Progression Lab
seguem o modelo versionado. Ele tambem bloqueia regressao de autoridade:
geradores dos Labs precisam continuar offline/adapter-free, o seeder do
Progression Lab precisa continuar local-only e o runtime server nao pode
importar geradores ou telas dev.

O teste `foundation_expansion_schema_test.ts` valida a migration espelhada de
Foundation Expansion Readiness: account/save, ruleset registry, admin audit,
idempotencia v1, metadata de ruleset e RPCs scaffold.

O teste `foundation_closeout_schema_test.ts` valida a migration corretiva de
Foundation Closeout: `publication_id` imutavel no registry, hashes persistidos
em saves/historicos, admin interno `service_role`-only e as mutacoes restantes
de build behavior/potion e social friend/chat promovidas para RPCs v1.

O teste `api_version_contract_test.ts` valida o header oficial
`x-draxos-api-version: 1`, CORS e rejeicao de valor explicito diferente de `1`
nos endpoints versionados.

O teste `transactional_domain_enforcement_schema_test.ts` valida a promotion de
Base para RPCs transacionais v1: migration espelhada, `collect_base_v1`,
`start_base_upgrade_v1`, grants service-role e adapter HTTP sem writes REST
multi-step para coleta/upgrade.

O teste `remaining_transactional_domain_enforcement_schema_test.ts` valida a
promotion dos dominios restantes para RPCs transacionais v1: battle rewards,
monetization rewards/alpha purchase, build equip, crafting e guild create/join.

O teste `battle_combatants_test.ts` valida que o mapeamento de
player/build/inventario/potion slot/behavior e bot `build_data` para
`CombatantBuild` vive no modulo portavel `_shared/battle_combatants.ts`,
espelhado entre server/supabase e sem HTTP/Supabase REST.

O teste `base_domain_test.ts` valida que regras puras de Base vivem no modulo
portavel `_shared/base_domain.ts`: estruturas, producao, coleta pendente,
custos/duracoes, bloqueios de upgrade, payload de estado e mirror
server/supabase sem HTTP/Supabase REST.

O teste `battle_log_projection_test.ts` valida que a projecao de
`battle_log_v1`, historico e metadata de ruleset vive no modulo portavel
`_shared/battle_log_projection.ts`, sem depender de simulacao atual nem do
adapter HTTP.

O teste `progression_domain_test.ts` valida que payload de build, unlocks,
validacao de equipamento, power runtime e helpers usados pelo Battle vivem no
modulo portavel `_shared/progression_domain.ts`, espelhado entre server/supabase
e sem HTTP/Supabase REST.

O teste `economy_domain_test.ts` valida que rewards, produtos alpha, deltas de
source/sink, payloads de monetization/crafting e projecoes de craft/conversao
vivem no modulo portavel `_shared/economy_domain.ts`, espelhado entre
server/supabase e sem HTTP/Supabase REST.

O teste `foundation_ruleset_test.ts` valida que `foundation_ruleset_v0` tem
hashes deterministicos e mirrors server/supabase alinhados.

O teste `integer_bones_contract_test.ts` valida que o catalogo Grimoire
server/site publica Ossos em escala inteira e que a coleta da base preserva
acumulo parcial ate existir pelo menos 1 Osso visivel para coletar.

O teste `mode_definitions_schema_test.ts` valida o schema estrito de
`data/definitions/modes/*`, bloqueia campos extras, pastas de modo sem decisao,
placeholders jogaveis/reward-enabled e decision packs sem freeze operacional.

Com Supabase local rodando:

```powershell
npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/battle_history_replay_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/client_telemetry_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/two_save_context_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/reset_save_context_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/progression_lab_apply_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/email_auth_alpha_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/release_download_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/grimoire_catalog_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/build_equip_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/runtime_config_smoke.ts
deno run --allow-net --allow-env server/tests/transactional_rpc_live_test.ts
deno run --allow-net --allow-env server/tests/transactional_edge_rpc_smoke.ts
deno run --allow-net --allow-env server/tests/modes_platform_live_test.ts
deno run --allow-net --allow-env server/tests/foundation_admin_rls_live_smoke.ts
```

Ops read-only CLI:

```powershell
npx -y deno check tools/ops_readonly.ts server/tests/ops_readonly_cli_test.ts
npx -y deno test --allow-read server/tests/ops_readonly_cli_test.ts
```

O smoke cria uma sessao anonima, cria conta guest, solicita batalha `MVP_ONLY`,
repete o mesmo `request_id`, consulta `battle/latest` e confirma que XP/Ossos
nao duplicam.

O smoke `first_slice_battle_smoke.ts` cria sessao anonima, cria conta guest,
solicita `FIRST_SLICE_SIM` contra bots de efeito/invocacao, repete o mesmo
`request_id`, consulta `battle/latest`/`competition/ranking/current` e confirma
eventos ricos, idempotencia, aplicacao de XP/Almas/Energia/Sangue/Ossos e
pontuacao de arena sem duplicar o mesmo `request_id`.

O smoke `battle_history_replay_smoke.ts` valida `GET /battle/history` e
`GET /battle/replay?battle_id=...`: auth obrigatoria, lista recente sem
`event_log` completo, replay salvo com `battle_log_v1`, leitura sem alterar
XP/recursos e isolamento entre saves `normal` e `progression_lab`. Use
`BATTLE_FUNCTION_URL=http://127.0.0.1:8000` quando a funcao `battle` for servida
diretamente por Deno para validar um worktree sem reiniciar o Edge Runtime
compartilhado.

O smoke `base_manager_smoke.ts` valida auth obrigatoria, inicializacao dos seis
predios, payload de UI com custo/tempo/status, coleta idempotente, compra alpha
de Energia, upgrade server-authoritative por predio e bloqueio de segunda
construcao quando a fila esta cheia.

O smoke `social_competition_smoke.ts` valida social basico com dois testadores:
auth obrigatoria, identidade social de conta, amizade por username, guilda
create/join, membros enriquecidos, chat de guilda idempotente, rate limit,
polling com usernames, matchmaking com bot fora do ranking, ranking top 10 com
posicao do jogador e RLS contra insert direto em guilda.

O smoke `client_telemetry_smoke.ts` valida auth obrigatoria, evento pre-conta
com `player_id = null`, evento pos-conta, rejeicao de schema desconhecido e
bloqueio de insert direto em `telemetry_events` com JWT anonimo.

O smoke `two_save_context_smoke.ts` valida o contexto `normal` e
`progression_lab` usando o header `x-draxos-save-type`: dois players isolados na
mesma sessao auth, batalha/base/loja no save Lab e ranking bloqueado para
`progression_lab`.

O smoke `reset_save_context_smoke.ts` valida `POST /account/saves/reset`: reset
do Lab preserva Normal, reset do Normal preserva Lab, `request_hash`
obrigatorio, idempotencia por `request_id` + hash, rejeicao de hash divergente
e `save_type` divergente entre body/header e rejeitado.

O teste `account_reset_request_hash_contract_test.ts` valida que a nova RPC
`reset_player_save_v1` exige `p_request_hash`, usa `game_saves.id` como escopo,
move limpeza de Arena/Modes/Track 16 para dentro da transacao SQL, preserva
social/guilda/chat account-wide, revoga o acesso da assinatura legada sem hash
e impede o adapter Edge de fazer cleanup REST pos-RPC.

O smoke `progression_lab_apply_smoke.ts` valida `POST /progression-lab/apply`:
perfil/milestone versionado aplicado no save `progression_lab`, save normal
preservado, `request_hash` obrigatorio, idempotencia por `request_id` + hash,
rejeicao de mesmo `request_id` com hash divergente, ranking do Lab bloqueado e
batalha do Lab ainda jogavel apos a aplicacao.

O teste `progression_lab_apply_contract_test.ts` valida que a nova assinatura da
RPC exige `p_request_hash`, grava/verifica `idempotency_keys.request_hash`,
move reset/seed de consumables, potion slots, spell behaviors e item
transactions para dentro da transacao SQL e impede o adapter Edge de fazer
cleanup REST pos-RPC.

O smoke `email_auth_alpha_smoke.ts` valida signup/login por email/senha,
`POST /account/bootstrap`, criacao do save `normal`, criacao do save
`progression_lab` com sufixo `*_lab`, recuperacao por `account/state` e login
posterior na mesma conta.

O smoke `release_manifest_smoke.ts` valida `GET /release/manifest`: schema do
manifest de update, canal `internal_alpha`, versao/code atuais e metadados de
artefatos Android/PC/Web. Defina `DRAXOS_EXPECTED_RELEASE_ROOT` com o release
root versionado esperado para impedir que smokes passem contra manifest/fallback
antigo.

O smoke `release_download_smoke.ts` valida `GET /release/download` com conta
email/senha alpha: cria URLs assinadas temporarias de Android/PC e confirma que
elas usam rota valida de Supabase Storage. Ele tambem forja o `sub` de um JWT
valido e confirma que o backend rejeita o token antes de criar URL assinada.

O teste `release_auth_contract_test.ts` bloqueia regressao estatica no
`/release/download`: o bearer token precisa ser validado em `/auth/v1/user`
com publishable/anon key, o `sub` decodificado precisa bater com o usuario
autenticado, contas anonimas/sem email sao rejeitadas e o fallback de manifest
nao pode apontar para roots antigos de Openworld.

O smoke `grimoire_catalog_smoke.ts` valida `GET /content/grimoire`: auth
obrigatoria, bloqueio de JWT anonimo, bloqueio de conta email sem save alpha e
catalogo `grimoire_catalog_v1` completo apos `/account/bootstrap`.

O smoke `build_equip_smoke.ts` valida `GET /build/state` e `POST /build/equip`
no save `progression_lab`: opcoes de equipamento com nomes publicos,
equipar/remover instrumento, spell, doutrina e familiar, bloqueio de posicao por
nivel, item inexistente, spell duplicada, idempotencia por `request_id` e
`players.power` recalculado pelo servidor.

O smoke `runtime_config_smoke.ts` valida `GET /release/config`: schema
`runtime_config_v1`, flags booleanas da Track 06, fallback offline permitido e
guardrails contra service role, secrets, estado de jogador e tuning de gameplay.

O smoke `transactional_rpc_live_test.ts` valida as RPCs transacionais v1
diretamente no Postgres local apos `supabase db reset`: rollback de falha
parcial, retry apos precondicao corrigida, resposta idempotente por `request_id`
e rejeicao de `request_hash` divergente para battle rewards, build equip,
crafting, reward claim, alpha purchase e guild create/join. Ele usa
`DRAXOS_LOCAL_DB_URL` quando definido, ou o banco local padrao da Supabase CLI
`postgres://postgres:postgres@127.0.0.1:54322/postgres`.

O smoke `transactional_edge_rpc_smoke.ts` valida o caminho HTTP local das Edge
Functions sobre os adapters RPC v1. Ele exige `supabase functions serve` ativo,
chama `base`, `battle`, `build`, `crafting`, `monetization` e `social` via
`/functions/v1`, cobre `build/spell-behavior`, `build/potion/equip`,
`build/potion-behavior`, `social/friends/add`, `social/chat/send`, verifica
`UNSUPPORTED_API_VERSION` e confirma no Postgres local que cada mutation criou
`idempotency_keys` `completed` com `request_hash` calculado pelo adapter.

O smoke `modes_platform_live_test.ts` valida o caminho HTTP local da Edge
Function `modes` e o Reward Bridge v0: registry/state com JWT e
`x-draxos-save-type`, session start idempotente, complete idempotente,
ledger/reward claim uma unica vez, rejeicao de `request_hash` divergente,
rejeicao de resultado adulterado e bloqueio de recompensa real no save
`progression_lab`.

O smoke `foundation_admin_rls_live_smoke.ts` valida o hardening final de
Foundation em stack local real: RLS de `account_profiles`, `game_saves`,
`ruleset_registry` e `admin_audit_log`; matriz de grants provando bloqueio das
RPCs admin para `anon/authenticated`; execucao via `service_role` de lookup,
reconciliacao, diagnostico, ajuste auditavel/idempotente e flag de conta. Ele
recusa URLs remotas e exige Supabase local + Edge Runtime ativos.

O smoke `release_artifacts_remote_smoke.ts` valida somente leitura contra o
remoto publicado: manifest, hashes Android/PC no payload, alcance do APK/ZIP via
`HEAD` ou `GET` parcial, Portal com `DraxosMobile` e Web HTML com
`GODOT_CONFIG`. Ele exige URL remota e publishable key, recusa URL local/service
role e nao publica nada.

Validacao standalone de Edge Functions pode usar `npx deno`. Validacao de
runtime Supabase depende de Docker e Supabase CLI no ambiente local.

## Remote Internal Alpha

Depois de criar um projeto Supabase remoto e publicar o healthcheck:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
```

O smoke remoto rejeita URLs locais e service role no lugar da publishable key.
Use `DRAXOS_REMOTE_ANON_AUTH_SMOKE=1` para incluir Auth anonimo,
`DRAXOS_REMOTE_ACCOUNT_SMOKE=1` para validar account guest dev e
`DRAXOS_REMOTE_EMAIL_AUTH_SMOKE=1` para validar email/senha, `account/bootstrap`
e os dois saves da conta alpha. Use `DRAXOS_REMOTE_RELEASE_SMOKE=1` para validar
tambem o manifest remoto de updates.

Para validar links ja publicados sem redeploy:

```powershell
$env:SUPABASE_URL='https://<project-ref>.supabase.co'
$env:SUPABASE_PUBLISHABLE_KEY='sb_publishable_<public-key>'
npx -y deno run --allow-net --allow-env server/tests/release_artifacts_remote_smoke.ts
```
