# Current Status

- Last Updated: `2026-05-26`
- Active Project Name: `draxos-mobile`
- Active Surface: `Track 03 - Internal Alpha v0`
- Active Track: `Track 03 - Internal Alpha v0`
- Active Track Status: `READY_FOR_IMPLEMENTATION - DOCUMENTATION AND WORKSPACE PREP`
- Current Operational Baseline: Track 00 completa com primeiro slice server-authoritative, Track 01 completa para hardening do alpha PC local e Track 02 com Progression Lab/Battle Lab v1 implementados. Godot 4.6.2 possui hub alpha, Base/Social/Competicao/Monetizacao v0, batalha `battle_log_v1` server-authoritative, mockup visual 2D procedural compartilhado por Batalha/Battle Lab, exports Android/PC/Web, validate/GUT/smokes verdes no ultimo baseline e Supabase local em layout oficial. Track 03 prepara Internal Alpha v0: email/senha, dois saves por conta (`normal` e `progression_lab`), Supabase remoto Free, Progression Lab isolado, loja com redeems alpha, leaderboards basicas, social/base jogaveis e manifest de updates para Android/PC/Web.

---

## Estado Atual

| Area | Estado | Observacao |
|---|---|---|
| MVP tecnico minimo | Completo | Loop guest -> battle/request -> replay placeholder -> latest/state validado; cliente nao calcula resultado, recompensa ou progressao |
| Primeiro slice completo | Completo para alpha | T00-P13 completo; Track 01 hardening aplicado para PC local |
| Design pendente | T00-P09 completo | DMOB-D047 resolvido pelo Character Systems Rework 2026-05-25; D030 recebeu Source Identity Balance v2 com Battle Lab `PASS`; D006-D007 e D029-D032 seguem calibraveis via simulador/playtest |
| Economia e seasons | Baseline calibravel | `../docs/economy/README.md`, JSON versionado e gerador Deno/TypeScript criados; outputs em `../docs/economy/generated/` |
| Progression Lab | Ferramenta v1 atualizada para Source Identity Balance v2 | Gera `25` saves, `75` bots, relatorios HTML/CSV/JSON, seeder Supabase local, cache `.progression_lab_scratch/`, fallback local-only sem Supabase e sem token valido, tela dev-only no Refugio e matriz Progression Lab no Battle Lab; cache local-only abre base como snapshot somente leitura e bloqueia acoes online com mensagem objetiva; status atual `REVIEW` por premium gap e janelas 15h/20h calibraveis, falta rodada manual real no editor com Supabase local |
| Internal Alpha v0 | Preparada para implementacao | Track 03 documentada com escopo, plano, runbook, checklist, pendencias de design `DMOB-D048`-`DMOB-D055`, contratos planejados de email/senha/dois saves e regra de updates via manifest remoto |
| Reuso entre projetos | Documentado | Fonte viva: `../docs/reuse-map.md`; estrategia conservadora |
| Contratos tecnicos | Definidos | Fonte inicial: `../docs/contracts/` |
| Godot project | Alpha PC local pronto + Battle Lab/Progression Lab dev + battle stage 2D continuous cooldowns | Hub alpha hardenizado, autoloads, `.gutconfig.json`, content generator, catalogo gerado, `SessionStore` com `session_id`, `apply_snapshot_cache` e metadados `progression_lab`, `SupabaseClient` com telemetria, `BattleLogPresenter`, `BattleVisualMockup`, `BattleStage2D` responsivo com tooltips imediatos, nos estaveis durante efeitos, cooldown restante por relogio continuo de replay e feedback textual com nomes completos, telas dev-only do Battle Lab e Progression Lab, cache local-only read-only sem token valido, runner Deno sanitizado/Windows-safe, smoke real de labs, smoke visual/comportamental e GUT |
| Supabase project | Conta guest + battle MVP + first-slice sim + base/social/competicao/monetizacao/telemetria v0 prontos | Layout `supabase/`, migrations MVP/base/social/ranking/monetizacao, Auth anonimo, healthcheck, `account/*`, `battle/*`, `base/*`, `social/*`, `competition/*`, `monetization/*`, `telemetry/*`, seeds `FIRST_SLICE`, JWT config de funcoes e simulador compartilhado configurados |
| Validacao | Verde tecnico; tuning manual pendente | Godot validate + GUT `41/41`, `253` asserts passam; smoke session shell passa; smoke de labs executa Battle Lab/Progression Lab via `OS.execute`; smoke visual/comportamental passa e valida cache local-only sem token online; smoke de exports passa; Deno tests passam; dry-run do seeder seleciona `25/25` saves; Battle Lab Source Identity Balance v2 gera `PASS`; Progression Lab gera `REVIEW`; Supabase runtime real ainda precisa rodada manual com `SUPABASE_SERVICE_ROLE_KEY` |

---

## Character Systems Rework - 2026-05-25

- Nova fonte autoritativa: `../docs/character-systems-rework.md`.
- Catalogo vivo atualizado em `data/definitions/`: Instrumentos Rituais, Spells, Doutrinas, Familiares, bots e fixtures.
- `FIRST_SLICE_SIM` atualizado para `weaponId`, fontes Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte, status mental/corporal/elemental/Morte e familiares com dano, DoT e status.
- Edge Function `battle/request`, migrations e seeds agora usam `varinha_cinzas`, `sussurro_medo`, `doutrina_pavor` e `corvo_pressagio` como baseline de conta/fixture.
- Battle Lab, Progression Lab, tela dev-only do Battle Lab, testes Godot e testes Deno foram atualizados para validar `weapon_id`, os novos ids, invocacao Deno Windows-safe no Godot e amostras de replay com spells visiveis.
- Follow-up de 2026-05-26: Battle Lab custom replay agora entra em Replay/History como resultado de sessao, a velocidade do replay mostra a porcentagem do tempo normal e o autoplay usa o `t` do `battle_log_v1` para manter cooldowns continuos; Progression Lab cria cache local-only a partir de healthy saves quando nao ha Supabase service key, sem token valido e com bloqueio de acoes online na shell; telas dev-only corrigem quebra vertical de texto em `ScrollContainer`; conhecimento operacional registrado em `../docs/dev-lab-workflow.md`.
- Baseline de tuning 2026-05-21 permanece arquivado como historico pre-rework; comparacoes numericas contra ele servem apenas como alerta de compatibilidade.
- Source Identity Balance v2: Battle Lab run `2026-05-25_source_identity_balance_v02` gerou `3132` batalhas e `212` builds com status `PASS`, duracao media `24.08s`, anti-stall `4.95%`, dominancia em poder proximo maxima `63.46%` e checks de identidade de fonte em `PASS`; Progression Lab gerou `25` saves e `75` bots com status `REVIEW`.
- Proxima calibracao deve mirar premium gap 10h, janelas 15h/20h, sensacao manual de Familiar/Funeral, Defesa/Mental em near-power e pesos de poder apos playtest no Godot.

---

## Fontes Vivas

- Escopo Track 00: `tracks/track-00-first-slice-foundation/scope.md`
- Escopo Track 01: `tracks/track-01-alpha-playtest-hardening/scope.md`
- Status Track 01: `tracks/track-01-alpha-playtest-hardening/current-status.md`
- Escopo Track 02: `tracks/track-02-progression-lab/scope.md`
- Status Track 02: `tracks/track-02-progression-lab/current-status.md`
- Escopo Track 03: `tracks/track-03-internal-alpha-v0/scope.md`
- Plano Track 03: `tracks/track-03-internal-alpha-v0/implementation-plan.md`
- Status Track 03: `tracks/track-03-internal-alpha-v0/current-status.md`
- Internal Alpha v0: `../docs/internal-alpha-v0.md`
- Checklist Internal Alpha v0: `../docs/playtest-internal-alpha-v0.md`
- Progression Lab: `../docs/progression-lab/README.md`
- Dev Lab Workflow Notes: `../docs/dev-lab-workflow.md`
- MVP tecnico: `tracks/track-00-first-slice-foundation/mvp-technical-definition.md`
- Plano sequencial: `tracks/track-00-first-slice-foundation/implementation-plan.md`
- Prompts atomicos: `tracks/track-00-first-slice-foundation/implementation-prompts.md`
- Mapa de reuso: `../docs/reuse-map.md`
- Pendencias de design: `../docs/design-pending.md`
- Contratos: `../docs/contracts/`
- Design autoritativo: `../docs/game-design-document.md`
- Checklist de playtest alpha: `../docs/playtest-alpha.md`
- Decision log historico: `../docs/pre-implementation-decisions.md`

---

## Decisoes De Escopo

- Track 00 monta o primeiro slice completo.
- Track 01 hardeniza o primeiro slice para playtest alpha PC local.
- Track 02 calibra o loop inicial com saves saudaveis, perfis 2h-20h, bots, poder, moeda premium e teste manual no Godot.
- Track 03 transforma o alpha local em build fechada realista com email/senha, dois saves, Supabase remoto, base/social/competicao/loja funcionais e updates internos.
- MVP tecnico minimo e a primeira etapa da Track 00.
- MVP tecnico usa fixtures `MVP_ONLY` e nao depende de balanceamento final.
- Economia de Season 1 usa cap 40 por padrao, todos os levels sao permanentes e caps futuros ficam editaveis no simulador.
- Reuso de outros projetos e conservador: padroes e infraestrutura, nao gameplay.
- Tudo que exigir design ou tuning entra em `../docs/design-pending.md` antes de implementar.
- iOS e mobile browser ficam fora da Track 00.
- Qualquer `POS_SLICE` ou mecanica nova exige sessao de design antes de implementacao.

---

## Baseline De Conceito Preservada

- Personagem: Draxos, sem classes, 1 Instrumento Ritual, 0-3 spells por unlock de level, 1 Doutrina, 1 Familiar, summons.
- Combate: fontes Arcano/Fisico/Fogo/Agua/Gelo/Terra/Vento/Raio/Veneno/Sangue/Morte, familias de status mentais/corporais/elementais/Morte, DoTs, resistencias, barreiras, anti-stall.
- Base Manager: 6 estruturas permanentes e Energia como gargalo.
- Social: amigos, guilda, ajudas, chat de guilda e direct.
- Infraestrutura: Godot 4.6.2, Supabase, batalha 100% servidor, Android + PC + PC browser.
- Season: 4 meses, 2 Battle Passes, cap Season 1 = 40, progressao permanente e catch-up suave futuro.

---

## Implementacao Atual

- `project.godot` registra `UiTokens`, `AssetIds`, `ContentLibrary`, `SessionStore` e `SupabaseClient`.
- `data/definitions/` contem os 9 arquivos esperados pelo contrato com conteudo inicial de primeiro slice.
- `tools/content_generator.gd` gera `data/generated/draxos_mobile_catalog.tres`.
- `tools/validate.gd` gera conteudo, valida contrato client, valida recursos/autoloads, smoke de exports e roda GUT.
- `tools/smoke_dev_labs.gd` valida o spawn real de Battle Lab e Progression Lab pelo Godot, incluindo replay custom com spells/effects e geracao dos outputs do Progression Lab.
- `tools/smoke_dev_lab_ui.gd` valida comportamento visual das telas dev-only e captura screenshots quando rodado sem `--headless`.
- `tools/smoke_exports.gd` valida presets Android Alpha, PC Windows Alpha e PC Browser Alpha sem exigir templates instalados.
- `docs/battle-visual-mockup.md` documenta o mockup visual de batalha, palco 2D procedural, slots front/middle/back, asset hooks futuros e o processo de evolucao de eventos visuais.
- `online/session_store.gd` guarda token/cache local nao autoritativo, valida expiracao, preserva snapshots de estado recebido do servidor, registra metadados `progression_lab`, identifica cache local-only e persiste `session_id` local para telemetria.
- `online/supabase_client.gd` implementa HTTPRequest para Auth anonimo, `account/*`, `battle/*`, `base/*`, `social/*`, `competition/*`, `monetization/*` e `telemetry/*` no Supabase local.
- `ui/battle_log_presenter.gd` ordena e formata eventos `battle_log_v1`, tolerando tipos desconhecidos sem quebrar replay.
- `ui/battle_visual_mockup.gd` apresenta `battle_log_v1` como HUD visual reutilizavel com palco 2D procedural, personagens placeholder, HP/Mana/Barreira, simbolos de evento, status/buffs, spells/cooldowns com tempo restante por relogio continuo de replay, slots front/middle/back, summons, Familiar, resultado e timeline sem calcular combate.
- `ui/battle_stage_2d.gd`, `ui/battle_actor_marker.gd` e `ui/battle_symbol_icon.gd` desenham personagens parados frente a frente, cooldowns com timer restante atualizado entre eventos, status, pets/summons, numeros flutuantes com nomes completos de efeito/dano, projeteis simples, flashes e tooltips imediatos usando apenas recursos nativos do Godot.
- `modes/boot/boot.gd` apresenta um hub alpha com abas para Batalha, Base, Social, Competicao e Loja, areas rolaveis, Voltar/Esc, confirmacoes simples para mutacoes, feedback visivel para sucesso/erro/pre-condicao, busy states, refresh, reset seguro de cache local, bloqueio de acoes online quando o Progression Lab esta em cache local-only, mockup visual compartilhado na aba Batalha e telemetria de telas/acoes/replay/offline.
- `tests/client/` cobre `ProjectInfo`, autoloads, tokens, asset ids, catalogo gerado, fixture `mvp_training_battle`, session shell, snapshots Base/Social/Competicao/Monetizacao, presenter de replay, mockup visual de batalha, palco 2D procedural, cooldown restante continuo e nomes completos nos textos de feedback.
- `supabase/migrations/202605190001_mvp_foundation.sql` e `supabase/functions/healthcheck/` sao a fonte de execucao local da Supabase CLI.
- `supabase/migrations/202605190002_guest_account_mvp.sql` cria convite `ALPHA-TEST`, RPC `create_guest_account` e fixture inicial de `players/resources/builds`.
- `supabase/migrations/202605200001_battle_request_mvp.sql` cria RPC `request_mvp_battle`, aplica recompensa `MVP_ONLY` e grava `battle_log_v1`.
- `supabase/migrations/202605200002_first_slice_simulator_seed.sql` cria seeds de bots `FIRST_SLICE` para matchmaking/simulacao.
- `supabase/migrations/202605200003_base_manager_economy.sql` cria `base_structures`, `construction_jobs`, RLS de leitura e bootstrap das seis estruturas da Base v0.
- `supabase/migrations/202605200004_social_matchmaking_ranking.sql` cria season ativa, amizades, guilda, estruturas de guilda, chat, ranking, telemetria minima e RLS de leitura.
- `supabase/migrations/202605200005_monetization_rewards_alpha.sql` cria Battle Pass, progresso de passe, reward claims, compras alpha, RLS de leitura e seed `bp_s1_01`.
- `supabase/functions/account/` implementa `POST /account/guest` e `GET /account/state` com JWT anonimo, service role interno e idempotencia por `request_id`.
- `supabase/functions/battle/` implementa `POST /battle/request` e `GET /battle/latest` com JWT anonimo, service role interno, idempotencia por `request_id`, modo `MVP_ONLY` via RPC e modo `FIRST_SLICE_SIM` via simulador TypeScript.
- `supabase/functions/base/` implementa `GET /base/state`, `POST /base/collect` e `POST /base/upgrade` com estruturas permanentes, fila de construcao, conclusao de jobs vencidos, coleta offline, ledger e idempotencia por `request_id`.
- `supabase/functions/social/` implementa `GET /social/state`, `POST /social/friends/add`, `POST /social/guild/create` e `POST /social/chat/send` com guilda/chat por polling e idempotencia.
- `supabase/functions/competition/` implementa `GET /competition/matchmaking/preview` e `GET /competition/ranking/current` com fallback de bot e ranking de season sem bots.
- `supabase/functions/monetization/` implementa `GET /monetization/state`, `POST /monetization/rewards/claim` e `POST /monetization/alpha-purchase` com Battle Pass, Diamante, recompensas diarias/semanais, premium alpha, ledger e idempotencia.
- `supabase/functions/telemetry/` implementa `POST /telemetry/client-event` com JWT, schema `telemetry_client_v1`, `source = client`, `player_id` opcional antes da conta guest e escrita exclusiva em `telemetry_events`.
- `supabase/functions/_shared/battle_simulator.ts` e `server/functions/_shared/battle_simulator.ts` simulam batalha com Instrumento Ritual, Vida/regen de Vida, mana, spells diretas e nao-dano, DoTs, status mentais/corporais/elementais/Morte, resistencias, Doutrinas, barreira, Familiares, summons, cooldowns, anti-stall e recompensa server-authoritative. Em 2026-05-25 receberam o rework de personagem e continuam usando pacing alpha de Vida como baseline calibravel.
- `tools/battle_lab/` gera simulacoes offline bot-vs-bot com builds fixas/randomicas deterministicas, relatorio HTML, JSON, CSVs, JSON compacto de UI, amostras de replay completas em `docs/battle-lab/generated/`, scratch runs locais e historico versionado em `docs/battle-lab/runs/`.
- `dev/battle_lab/battle_lab_screen.gd` adiciona a tela dev-only do Battle Lab no Godot editor: gera runs via Deno, edita builds, mostra analytics e reproduz `battle_log_v1` em arena debug 2D pelo `t` dos eventos sem calcular resultado no cliente, com controle de velocidade mostrando porcentagem do tempo normal.
- `tools/progression_lab/` gera estados saudaveis por perfil/milestone, checks de recurso/recompensa/premium, recomendacoes de poder, bot pool e relatorio em `docs/progression-lab/generated/`.
- `tools/progression_lab/seed_supabase.ts` cria contas dev em Supabase local e grava caches de sessao em `.progression_lab_scratch/`.
- `dev/progression_lab/progression_lab_screen.gd` adiciona a tela dev-only do Progression Lab no Refugio para gerar relatorio, preparar save local, carregar cache no `SessionStore` e abrir checklist manual; fallback local-only nao cria token valido.
- `server/schema/` e `server/functions/` preservam a organizacao backend espelhada/documental durante o alpha local.

---

## Read Next

1. `../AGENTS.md`
2. `tracks/track-03-internal-alpha-v0/current-status.md`
3. `tracks/track-03-internal-alpha-v0/scope.md`
4. `tracks/track-03-internal-alpha-v0/implementation-plan.md`
5. `../docs/internal-alpha-v0.md`
6. `../docs/design-pending.md`
7. `../docs/contracts/`
7. `../docs/contracts/`

---

## Validation

Godot client:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_alpha_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_labs.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_dev_lab_ui.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Ultimo resultado local:

- `tools/validate.gd`: passou.
- `tools/smoke_session_shell.gd`: passou com Auth anonimo, conta guest e account/state.
- `tools/smoke_dev_labs.gd`: passou, executando Battle Lab bridge e Progression Lab generate pelo `OS.execute` do Godot.
- `tools/smoke_dev_lab_ui.gd`: passou em headless validando cache local-only sem token online; screenshots sao pulados no renderer headless.
- `tools/smoke_exports.gd`: passou para Android Alpha, PC Windows Alpha e PC Browser Alpha.
- GUT integrado: `41/41` testes, `253` asserts.
- `npx -y deno test tools/battle_lab tools/progression_lab server/tests/first_slice_simulator_test.ts`: passou, `20/20`.
- `npx -y deno run --allow-read --allow-write tools/progression_lab/generate.ts`: passou, gerando `25` saves, `75` bots e status `REVIEW` para calibracao manual.
- `npx -y deno run --allow-read tools/progression_lab/seed_supabase.ts --dry-run --all`: passou, selecionando `25/25` saves.
- `npx -y deno run --allow-read --allow-write tools/battle_lab/generate.ts --archive-run 2026-05-25_source_identity_balance_v02 --compare-with 2026-05-25_initial_balance_v01`: passou, gerando `3132` batalhas, `212` builds, matriz Progression Lab, checks de identidade de fonte e status `PASS`.

Server standalone:

```powershell
cd D:\Estudio\Projetos\draxos-mobile\server\functions
npx -y deno task check
npx -y deno task lint
npx -y deno run --allow-net healthcheck/index.ts
cd D:\Estudio\Projetos\draxos-mobile
npx -y deno test server/tests/first_slice_simulator_test.ts
npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/base_manager_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/social_competition_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/monetization_rewards_smoke.ts
npx -y deno run --allow-net --allow-env server/tests/client_telemetry_smoke.ts
```

Supabase runtime validado localmente:

- Docker Desktop local ativo.
- Supabase CLI via `npx -y supabase`, versao `2.100.1`.
- Deno via `npx -y deno`, versao `2.7.14`.
- `supabase db reset`: passou.
- `GET http://127.0.0.1:54321/functions/v1/healthcheck`: passou.
- `POST http://127.0.0.1:54321/functions/v1/account/guest`: convite invalido falha, convite valido cria conta guest e repeticao do mesmo `request_id` retorna o mesmo player.
- `GET http://127.0.0.1:54321/functions/v1/account/state`: recupera player/resources/build.
- Smoke P06 via Godot HTTPRequest: Auth anonimo -> `account/guest` -> `account/state` retornou player guest; fixture inicial atual usa build `varinha_cinzas`.
- `POST http://127.0.0.1:54321/functions/v1/battle/request`: retorna `battle_log_v1`, grava `battles` e aplica recompensa `MVP_ONLY`.
- Repetir `battle/request` com o mesmo `request_id`: retorna o mesmo `battle_id`; estado permanece `xp=5`, `ossos=1`.
- `GET http://127.0.0.1:54321/functions/v1/battle/latest`: retorna o ultimo `battle_log_v1`.
- Smoke P08/P10 via Godot HTTPRequest: guest -> `battle/request` `FIRST_SLICE_SIM` -> replay rico formatado -> `battle/latest` passou com 30 eventos e sem calculo client-side.
- Smoke P11 via Supabase runtime: `base/state` exige auth, inicializa 6 estruturas, `base/collect` e idempotente, `base/upgrade` rejeita falta de Energia com erro controlado.
- Smoke P12 via Supabase runtime: `social/state` exige auth, `guild/create` e `chat/send` sao idempotentes, `competition/matchmaking/preview` retorna bot nao ranqueado, `competition/ranking/current` cria linha propria e insert direto em `guilds` com JWT anonimo e bloqueado.
- Smoke P13 via Supabase runtime: `monetization/state` exige auth, Battle Pass ativo existe, reward diario e idempotente, novo request no mesmo periodo nao duplica claim, `alpha_diamante_500` e idempotente, premium alpha libera reward premium e insert direto em `reward_claims` com JWT anonimo e bloqueado.
- Smoke Track 01 via Supabase runtime: `telemetry/client-event` exige auth, aceita evento pre-conta com `player_id = null`, aceita evento apos `account/guest`, rejeita schema desconhecido e insert direto em `telemetry_events` com JWT anonimo e bloqueado.
- Smoke Track 01 via Godot HTTPRequest: guest -> `account/state` -> `battle/request` -> `base/state`/`base/collect` -> `social/state`/`guild/create`/`chat/send` -> `competition/matchmaking/preview`/`ranking/current` -> `monetization/state`/claim -> telemetria final.
- Insert direto em `public.players` com JWT anonimo: bloqueado com `403`.

---

## Next

1. Executar `T03-P01 - Design Lock Da Build Interna`, resolvendo `DMOB-D048` a `DMOB-D055`.
2. Preparar Supabase remoto Free, email/senha e ambiente seguro sem commitar secrets.
3. Implementar dois saves por conta e isolamento do Progression Lab antes de expandir Base/Social/Loja.
