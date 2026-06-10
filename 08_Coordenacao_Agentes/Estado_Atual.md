# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-10`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`BOSQUE_ARENA_ABANDON_RECOVERY_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-bosque-arena-abandon-recovery-authority-v1-20260610-a252241`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://b149da8f.draxos-mobile-internal-alpha.pages.dev`, publicado Web/APK, APK/manifest `0.0.22-alpha.0`/version code `22`; Bosque permanece vivo e visivel atras de Arena/Base/Shop/Social/Profile em overlay, com input pausado, Social digitavel, Shop confirmavel, Arena retomar/abandonar e retorno por `Fechar`, `Voltar` e Esc sem rebootstrap, validado por smoke real Web/canvas, mantem minimum supported version code `13`, proximo passo operacional: playtest humano focado do pacote publicado)
- Tech probe P2 de implementacao: `Projetos/FpsShooter/` (`FPS_PLAYGROUND_TRACK_04A_MENU_GOAL_FIX_V2_COMPLETE`; PC Windows editor-first FPS Playground independente com tema Draxos leve; proximo passo: playtest humano de 5 minutos do menu centralizado por painel, `Arena Shooter`, retorno ao menu, `Futebol`, `Como Jogar`/`Comecar`, chutes LMB/RMB, gols sem buraco/queda inclusive nas laterais internas, gols ate 3, bot futebol, restart, pause e sensibilidade)
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa em Godot 4.6.2 com rota fixa de 29 mapas, save/snapshot v5, recompensas/reliquias/Souls shop expandida, keywords completas, AI/intent, modos e formatos de encontro, field effects, boss hooks, UI polida, descarte marcado na fase principal, testes modulares, diretores/servicos internos de fundacao incluindo enemy AI/intent, combate/dano, reward/shop e BattleRoot presenters, geracao idempotente do catalogo, simulador compartilhado de pacing, checklist de playtest, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1/V2/V3/V4/V4.1/V4.2/V5 com 108 cartas ativas de jogador, 30 cartas inimigas e 15 `elemental_*` legado auditadas, V4.2 protegendo card-flow em 3 cartas com 21/21 checks, V5 com 30/30 assinaturas inimigas required, Design Lab V1 para transformar proposal packs JSON em variantes lab-only ranqueadas com promotion manifest, arquitetura/closeout de fundacao documentados, validacao verde 220/220 e telemetria de rota completa 29/29.
- Baseline addendum: Enemy Card Redesign Batch 02 Using V5 Terra passou em 2026-06-06 com `track02_card_impact_v5` before/change/after/compare em `user://card_impact/enemy_card_redesign_batch_02_v5_terra`, 108 cartas de jogador, 30 cartas inimigas required, 15 legadas inativas, 3 cartas card-flow esperadas, zero structural errors, zero new failures, zero removed records e zero status changes. O compare reportou 2 changed enemy records, 4 effect changes, 30/30 assinaturas inimigas preservadas, 30 clean signatures, 0 missing/not-played e 21/21 Card Flow Expectations passando. V4.2 historico, Battle Lab 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick verdes e `validate.gd` 211/211.
- Tooling addendum: Design Lab V1 passou em 2026-06-06 com `design_lab_sample_v1` em `user://design_lab/design_lab_sample_v1_gate`, 36 candidatos, 3 recomendacoes, 0 mecanicas bloqueadas, outputs JSON/CSV/Markdown/gate/promotion manifest e sem alterar `data/definitions/slice_catalog.json`. Regressao preservada: `validate.gd` 220/220, Card Impact V5 official before gate PASS, Run Lab smoke/quick gates PASS.
- Meta ativa: expansao de conteudo via Design Lab para cartas/mecanicas/encontros antes de playtests completos de sensacao.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: criar proposal packs no Design Lab para novas cartas de jogador/inimigo e mecanicas; promover manualmente apenas candidatos viaveis/recomendados, depois proteger com Card Impact V4.2/V5 e Run Lab smoke/quick.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - BOSQUE_ARENA_ABANDON_RECOVERY_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Bosque Arena Abandon Recovery Authority v1 publicado como Internal Alpha no release root `internal-alpha/v0-bosque-arena-abandon-recovery-authority-v1-20260610-a252241`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` e deployment evidence `https://b149da8f.draxos-mobile-internal-alpha.pages.dev`. O pacote publica Web/APK `0.0.22-alpha.0`/version code `22`, mantem minimum supported version code `13`, redeploya `release`, mantem o Bosque vivo e visivel atras de Arena/Base/Shop/Social/Profile em overlay, com input pausado, sem rebootstrap ao fechar e com Social typing, Shop cancel/confirm, Arena retomar/abandonar e `Fechar`/`Voltar`/Esc validados por smoke real Web/canvas. Bosque Overlay Interactive Controls Authority v1 segue preservado como pacote anterior de controles interativos; Bosque Overlay Menu Action Authority v1 segue preservado como pacote anterior de botoes internos; Bosque Overlay Navigation Hotfix v1 segue preservado como hotfix de interacao anterior; Bosque Diegetic Launcher Foundation v1 segue preservado como pacote launcher anterior; Bosque Bootstrap Authority v1 segue preservado como pacote bootstrap anterior; Arena PVE Bonus Visual v1 segue preservado como pacote Arena anterior; Bosque Node Cooldown ACK v1 segue preservado como pacote Bosque anterior; Bosque Resume Exit Lifecycle v1, Bosque Feel & Spawn Authority v1 e Bosque Persistence Rebase v1 seguem preservados como baselines anteriores com migrations remotas `202606080001_openworld_bosque_persistence_rebase_v1.sql` e `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Cadeia preservada: Bosque Durable Bau Mochila v1 (`internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, preview `https://39198a35.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Menu Flow Simplification v1 (`internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`), Bosque Offline-First Checkpoint v1 (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`), Bosque Sync Responsiveness v1 (`internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Visible V2 (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Regression Hotfix (`internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, preview `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Season 1 Loop v1 (`internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview `https://d7333659.draxos-mobile-internal-alpha.pages.dev`), Arena Duel Flow Hotfix (`internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview `https://0536635b.draxos-mobile-internal-alpha.pages.dev`), Arena PVE First Real Run + Update Recovery (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`), Bosque v3 UX/Feel (`internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`), Openworld Main Menu Sync (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`) e FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA (`internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`).
- Guardrails preservados: Track 13 release safety e Track 14 agent ops continuam ativos para validacao, publicacao e operacao multiagente.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation` e Supabase/Cloudflare CLI autenticada. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, PVP, tuning numerico amplo, novas armas, novas spells, economia ampla, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: playtest humano focado do `Bosque Arena Abandon Recovery Authority v1` publicado em Web/APK, validando prompts/landmarks do Bosque, abertura de Arena/Base/Shop/Social/Profile, Social digitavel, Shop confirmavel, Arena retomar/abandonar e retorno via `Fechar`, `Voltar` e Esc. Bugs futuros voltam ao fluxo normal se aparecerem. Nao abrir tuning amplo, PVP, economia, conteudo, novas armas/spells, visual final ou mutacoes remotas sem decisao propria.

## FpsShooter

- Status: **P2_IMPLEMENTACAO - FPS_PLAYGROUND_TRACK_04A_MENU_GOAL_FIX_V2_COMPLETE**
- Fase: `Implementacao - FPS Playground Tech Probe`
- Local: `Projetos/FpsShooter/`
- Baseline atual: projeto oficial implementavel criado para testar Godot 4.6.2 em gameplay 3D primeira pessoa, PC Windows editor-first. Track 04A FPS Playground Menu & Futebol V1 completa com a segunda correcao de playtest sobre Track 03B e baselines anteriores: o projeto agora apresenta `FPS Playground` como identidade local, abre em menu principal centralizado por container/painel e oferece `Arena Shooter` e `Futebol`. `Arena Shooter` preserva `Duel Pit V2` com spawns protegidos, cover, plataformas, jump pads, pickups elevados com micro-commit, rifle hitscan, RMB Plasma Bolt, feedback/HUD de combate, bot vertical-aware, rotas por jump pads, dodge de plasma, salto simples e knockback aceito, sem void/fall zones no mapa atual. `Futebol` adiciona modo em primeira pessoa 1x1 contra bot, sem armas, inicia pausado em `Como Jogar`/`Comecar`, LMB chute, RMB chute forte, bola `RigidBody3D` arcade solta, campo festivo por primitivas, gols fechados com piso e paredes laterais internas, gols ate 3, bot que ataca/defende, score HUD, feedback/audio sintetico de chute/gol e retorno ao menu pelo pause.
- Trabalho permitido: codigo, validacao, playtest no editor e documentacao local.
- Restricao operacional: tech probe independente com tema Draxos leve; nao herdar sistemas de gameplay/economia/progressao/backend dos projetos Draxos. Sem export/Web/mobile, multiplayer, matchmaking, Ricochet, ammo/reload, recoil/spread amplo ou novas armas ate track explicita.
- Proximo passo: playtest humano de 5 minutos do `FPS Playground`: menu inicial centralizado por painel, `Arena Shooter` preservado, retorno ao menu, `Futebol`, `Como Jogar`/`Comecar`, LMB/RMB chute, confirmar que os gols nao tem buraco/queda inclusive nas laterais internas, gols ate 3, bot futebol, restart, pause, sensibilidade e retorno ao menu.

## rpg-isometrico

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Ultima atualizacao do current-status: `2026-04-26`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, expandir gates, selecionar Next Gate ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto pausado.

## rpg-turnos

- Status: **PAUSADO_INDEFINIDO**
- Fase: `Pausado`
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros, ranks de operacao e save/load JSON v2.
- Ultima atualizacao do current-status: `2026-05-13`
- Trabalho permitido: consulta historica e leitura de contexto quando o usuario pedir explicitamente.
- Restricao operacional: nao implementar, selecionar proxima track/gate, regenerar `.tres` ou alterar escopo sem pedido explicito.
- Proximo passo: nenhum enquanto pausado.

## Kanban Rapido

- Backlog: `08_Coordenacao_Agentes/Kanban/Backlog/`
- Doing: `08_Coordenacao_Agentes/Kanban/Doing/`
- Review: `08_Coordenacao_Agentes/Kanban/Review/`
- Done: `08_Coordenacao_Agentes/Kanban/Done/`

## Canon

- Fonte de verdade compartilhada: `canon/`
- Brief rapido: `canon/canon-brief.md`
