# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-10`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco operacional temporario unico: `Projetos/JogoDaCopa/` (`JOGO_DA_COPA_TRACK_02_QUALITY_UPGRADE_V1_COMPLETE`; produto `Copa Arena Futebol`; PC Windows editor-first futebol/minigames independente; proximo passo: playtest humano no editor e no debug export Windows)
- Pausados temporariamente por poucos dias: `Projetos/draxos-roguelike-cardgame/`, `Projetos/draxos-mobile/`, `Projetos/FpsPlayground/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **PAUSADO_TEMPORARIO - retomada prevista em poucos dias**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa em Godot 4.6.2 com rota fixa de 29 mapas, save/snapshot v5, recompensas/reliquias/Souls shop expandida, keywords completas, AI/intent, modos e formatos de encontro, field effects, boss hooks, UI polida, descarte marcado na fase principal, testes modulares, diretores/servicos internos de fundacao incluindo enemy AI/intent, combate/dano, reward/shop e BattleRoot presenters, geracao idempotente do catalogo, simulador compartilhado de pacing, checklist de playtest, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1/V2/V3/V4/V4.1/V4.2/V5 com 108 cartas ativas de jogador, 30 cartas inimigas e 15 `elemental_*` legado auditadas, V4.2 protegendo card-flow em 3 cartas com 21/21 checks, V5 com 30/30 assinaturas inimigas required, Design Lab V1 para transformar proposal packs JSON em variantes lab-only ranqueadas com promotion manifest, arquitetura/closeout de fundacao documentados, validacao verde 220/220 e telemetria de rota completa 29/29.
- Baseline addendum: Enemy Card Redesign Batch 02 Using V5 Terra passou em 2026-06-06 com `track02_card_impact_v5` before/change/after/compare em `user://card_impact/enemy_card_redesign_batch_02_v5_terra`, 108 cartas de jogador, 30 cartas inimigas required, 15 legadas inativas, 3 cartas card-flow esperadas, zero structural errors, zero new failures, zero removed records e zero status changes. O compare reportou 2 changed enemy records, 4 effect changes, 30/30 assinaturas inimigas preservadas, 30 clean signatures, 0 missing/not-played e 21/21 Card Flow Expectations passando. V4.2 historico, Battle Lab 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick verdes e `validate.gd` 211/211.
- Tooling addendum: Design Lab V1 passou em 2026-06-06 com `design_lab_sample_v1` em `user://design_lab/design_lab_sample_v1_gate`, 36 candidatos, 3 recomendacoes, 0 mecanicas bloqueadas, outputs JSON/CSV/Markdown/gate/promotion manifest e sem alterar `data/definitions/slice_catalog.json`. Regressao preservada: `validate.gd` 220/220, Card Impact V5 official before gate PASS, Run Lab smoke/quick gates PASS.
- Meta ativa: expansao de conteudo via Design Lab para cartas/mecanicas/encontros antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica e retomada explicita apenas enquanto durar o foco temporario do JogoDaCopa.
- Proximo passo: retomar em poucos dias quando o foco temporario do JogoDaCopa for encerrado; o plano de Design Lab permanece preservado.

## DraxosMobile

- Status: **PAUSADO_TEMPORARIO - BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA preservado**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Bosque Overlay Layer And Readiness Authority v1 publicado como Internal Alpha no release root `internal-alpha/v0-bosque-overlay-layer-readiness-authority-v1-20260610-181861c`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` e deployment evidence `https://a9e3b2f9.draxos-mobile-internal-alpha.pages.dev`. O pacote publica Web/APK `0.0.23-alpha.0`/version code `23`, mantem minimum supported version code `13`, redeploya `release`, mantem o Bosque vivo e visivel atras de Arena/Base/Shop/Social/Profile em overlay, com input pausado, Arena active/replay fullscreen acima do menu, modal global/topmost, menu readiness e `Fechar`/`Voltar`/Esc validados por smoke real Web/canvas. Bosque Arena Abandon Recovery Authority v1 segue preservado como pacote anterior de recuperacao de abandono; Bosque Overlay Interactive Controls Authority v1 segue preservado como pacote anterior de controles interativos; Bosque Overlay Menu Action Authority v1 segue preservado como pacote anterior de botoes internos; Bosque Overlay Navigation Hotfix v1 segue preservado como hotfix de interacao anterior; Bosque Diegetic Launcher Foundation v1 segue preservado como pacote launcher anterior; Bosque Bootstrap Authority v1 segue preservado como pacote bootstrap anterior; Arena PVE Bonus Visual v1 segue preservado como pacote Arena anterior; Bosque Node Cooldown ACK v1 segue preservado como pacote Bosque anterior; Bosque Resume Exit Lifecycle v1, Bosque Feel & Spawn Authority v1 e Bosque Persistence Rebase v1 seguem preservados como baselines anteriores com migrations remotas `202606080001_openworld_bosque_persistence_rebase_v1.sql` e `202606080002_openworld_bosque_jsonb_object_length_hotfix_v1.sql`.
- Cadeia preservada: Bosque Durable Bau Mochila v1 (`internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, preview `https://39198a35.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Menu Flow Simplification v1 (`internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`), Bosque Offline-First Checkpoint v1 (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`), Bosque Sync Responsiveness v1 (`internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Visible V2 (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Regression Hotfix (`internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, preview `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Season 1 Loop v1 (`internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview `https://d7333659.draxos-mobile-internal-alpha.pages.dev`), Arena Duel Flow Hotfix (`internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview `https://0536635b.draxos-mobile-internal-alpha.pages.dev`), Arena PVE First Real Run + Update Recovery (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`), Bosque v3 UX/Feel (`internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`), Openworld Main Menu Sync (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`) e FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA (`internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`).
- Guardrails preservados: Track 13 release safety e Track 14 agent ops continuam ativos para validacao, publicacao e operacao multiagente.
- Trabalho permitido: consulta historica e retomada explicita apenas enquanto durar o foco temporario do JogoDaCopa.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation` e Supabase/Cloudflare CLI autenticada. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, PVP, tuning numerico amplo, novas armas, novas spells, economia ampla, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: retomar em poucos dias quando o foco temporario do JogoDaCopa for encerrado; o playtest humano do pacote publicado permanece preservado como proximo passo do projeto.

## FpsPlayground

- Status: **PAUSADO_TEMPORARIO - FPS_PLAYGROUND_PROJECT_SPLIT_FOUNDATION_COMPLETE preservado**
- Fase: `Implementacao - FPS Playground Tech Probe`
- Local: `Projetos/FpsPlayground/`
- Baseline atual: projeto oficial implementavel separado do antigo `FpsShooter/FPS Playground` para manter somente o laboratorio FPS em Godot 4.6.2, PC Windows editor-first. Preserva `Arena Shooter` com `Duel Pit V2`, spawns protegidos, cover, plataformas, jump pads, pickups elevados com micro-commit, rifle hitscan, RMB Plasma Bolt, feedback/HUD de combate, bot vertical-aware, rotas por jump pads, dodge de plasma, salto simples e knockback aceito, sem void/fall zones no mapa atual. O menu agora expõe apenas `Arena Shooter`.
- Trabalho permitido: consulta historica e retomada explicita apenas enquanto durar o foco temporario do JogoDaCopa.
- Restricao operacional: tech probe independente com tema Draxos leve; nao herdar sistemas de gameplay/economia/progressao/backend dos projetos Draxos. Sem futebol/minigames, export/Web/mobile, multiplayer, matchmaking, Ricochet, ammo/reload, recoil/spread amplo ou novas armas ate track explicita.
- Proximo passo: retomar em poucos dias quando o foco temporario do JogoDaCopa for encerrado; a regressao/playtest humano de `Arena Shooter` permanece preservada.

## JogoDaCopa

- Status: **P2_IMPLEMENTACAO - FOCO TEMPORARIO UNICO - JOGO_DA_COPA_TRACK_02_QUALITY_UPGRADE_V1_COMPLETE**
- Fase: `Implementacao - Football Minigames Tech Probe`
- Local: `Projetos/JogoDaCopa/`
- Baseline atual: projeto oficial implementavel separado do antigo `FPS Playground` para futebol e minigames de copa em Godot 4.6.2, PC Windows editor-first. O produto jogavel se chama `Copa Arena Futebol` e preserva o modo `Futebol`: 1x1 contra bot em terceira pessoa, arena noturna de vidro com glow/SSAO/fog, pitch em shader, redes grid, placares de estadio vivos, campo 38x54, gols roofed/fechados com regra de altura, bola `RigidBody3D` arcade solta com shader de paineis/trail/squash, LMB/RMB com feel aprovado, boost em `Shift`, avatares humanoides com rig/AnimationTree e contratos preservados, selecao de pele/camisa inspirada em paises, countdown de kickoff, slow-mo de gol, VFX de chute/gol/boost/freada, HUD broadcast, indicador da bola, menu 3D com preview, resultado/rematch, bot com predicao/defesa/boost/dificuldades e kickoff alternado. Nome/icone/splash/preset Windows criados; `tools/validate.gd` PASS 28 tests / 279 asserts; debug export Windows smoke PASS.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Restricao operacional: tech probe independente para minigames de futebol; nao herdar sistemas de gameplay/economia/progressao/backend dos projetos Draxos. Sem armas/FPS shooter, Web/mobile, multiplayer, matchmaking ou economia ate track explicita.
- Proximo passo: playtest humano de `Copa Arena Futebol` no editor e no debug export Windows, focado em menu -> partida -> resultado -> revanche, leitura dos gols/vidro/estadio, tuning de bola/chute/boost, bot e kickoff alternado.

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
