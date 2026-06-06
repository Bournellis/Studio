# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-06`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`BOSQUE_DURABLE_BAU_MOCHILA_V1_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://39198a35.draxos-mobile-internal-alpha.pages.dev`, publicado em `main`, forcando APK/manifest `0.0.6-alpha.0`/version code `6` e persistindo `Bau`, `Mochila/Bolso`, upgrades e estruturas do Bosque por save; preserva Arena PVE Menu Flow Simplification v1 como pacote anterior de Arena (`internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`), Bosque Offline-First Checkpoint v1 como politica runtime anterior (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`), Bosque Sync Responsiveness v1, Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops)
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

- Status: **P2_IMPLEMENTACAO - BOSQUE_DURABLE_BAU_MOCHILA_V1_PUBLISHED_INTERNAL_ALPHA**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Bosque Durable Bau Mochila v1 publicado como Internal Alpha no release root `internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` e deployment evidence `https://39198a35.draxos-mobile-internal-alpha.pages.dev`. O pacote forca APK/manifest `0.0.6-alpha.0`/version code `6`, publica Web/APK novos, aplica migration remota `202606060002_openworld_bosque_durable_progress_v1.sql`, persiste `Bau`, `Mochila/Bolso`, upgrades e estruturas do Bosque por save em `mode_progress.progress_payload` e preserva runtime local/offline-first com reward server-authoritative. Arena PVE Menu Flow Simplification v1 (`internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`) segue preservado como pacote anterior de Arena; Bosque Offline-First Checkpoint v1 (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`) segue preservado como politica runtime anterior do Openworld; Bosque Sync Responsiveness v1, Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync e `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA` seguem preservados como baselines anteriores. Export, Storage upload publico, Cloudflare Pages branch `main`, manifest remoto, deploy das Edge Functions `modes`/`release`, smoke Web no preview e smokes remotos read-only passaram; stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing fica adiado para distribuicao Android mais ampla.
- Cadeia preservada: Arena PVE Menu Flow Simplification v1 (`internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, preview `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`), Bosque Offline-First Checkpoint v1 (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`), Bosque Sync Responsiveness v1 (`internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Visible V2 (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Regression Hotfix (`internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, preview `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Season 1 Loop v1 (`internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview `https://d7333659.draxos-mobile-internal-alpha.pages.dev`), Arena Duel Flow Hotfix (`internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview `https://0536635b.draxos-mobile-internal-alpha.pages.dev`), Arena PVE First Real Run + Update Recovery (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`), Bosque v3 UX/Feel (`internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`), Openworld Main Menu Sync (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`) e FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA (`internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`).
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation` e Supabase/Cloudflare CLI autenticada. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, PVP, tuning numerico amplo, novas armas, novas spells, economia ampla, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: playtest humano do pacote Bosque Durable Bau Mochila v1 a partir de `main`; validar `Bau`, `Mochila/Bolso`, upgrades e estruturas apos sair/reabrir, completar visita, atualizar APK/Web e reentrar. Manter regressao de Arena PVE Menu Flow Simplification v1 e nao reabrir microeventos revisionados como loop normal do Bosque sem nova decisao.

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
