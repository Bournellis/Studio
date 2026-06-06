# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-06`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`ARENA_PVE_MENU_FLOW_SIMPLIFICATION_V1_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`, publicado em `main`, forcando APK/manifest `0.0.5-alpha.0`/version code `5` e simplificando o fluxo de menus da Arena PVE; preserva Bosque Offline-First Checkpoint v1 como politica Openworld atual (`internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22`, preview `https://fa84e109.draxos-mobile-internal-alpha.pages.dev`), Bosque Sync Responsiveness v1 (`internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Visible V2 (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`), Arena/Bosque Regression Hotfix (`internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, preview `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops)
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, save/snapshot v5, recompensas/reliquias/Souls shop expandida, keywords completas, AI/intent, modos e formatos de encontro, field effects, boss hooks, UI polida, descarte marcado na fase principal, testes modulares, diretores/servicos internos de fundacao incluindo enemy AI/intent, combate/dano, reward/shop e BattleRoot presenters, geracao idempotente do catalogo, simulador compartilhado de pacing, checklist de playtest, AutoRun Gate Pack V1 com presets/matriz/politicas macro/golden comparison/baselines oficiais smoke e quick/gate explicito/scorecards JSON-Markdown, Scenario Fixtures V1 com pacote `track02_core_v1`, 12 cenarios deterministicos nomeados, expectativas PASS/WARN/FAIL, gate explicito e relatorios JSON/CSV/Markdown, Gameplay Lab V1 com pacote `track02_battle_core_v1`, 12 batalhas isoladas via BattleEngine real, policies legais deterministicas, expectativas PASS/WARN/FAIL, gate explicito e relatorios JSON/CSV/Markdown, Lab Diff Reporter V1 para comparar outputs before/after de AutoRun/Scenario/Battle, Card Impact Pack V1/V2/V3/V4/V4.1/V4.2/V5 com V4/V4.1/V4.2/V5 cobrindo 108 cartas ativas de jogador, 30 cartas inimigas e 15 `elemental_*` legado auditadas, assinaturas de efeito exigidas para cartas de jogador, familias non-damage, utility, card-flow e enemy-causal derivadas de logs/snapshots incluindo `temporary_ability_power`, `cards_drawn`, `deck_delta`, `hand_delta`, `discard_delta`, `enemy_summoned_attack_total`, `enemy_summoned_health_total`, `enemy_keywords_added`, `enemy_combat_damage_to_player_hero` e qualidade `card_flow_expected/observed`/`enemy_signature_confidence`, expectativas explicitas V4.2 para Colheita card-flow, V5 com 30/30 assinaturas inimigas required, metadados de contaminacao por suporte, policy `card_focus_isolated`, before/after/compare gate explicito e relatorios JSON/CSV/Markdown, Card Impact Smoke Tuning V1, Card Redesign Batch 01, Player Card Redesign Batch 02, Reward Card Redesign Batch 01 Using V4, Reward Card Redesign Batch 02 Utility Using V4 e Card Flow Redesign Batch 01 Using V4.1 aplicados em lotes pequenos, V4.2 protegendo card-flow em 3 cartas com 21/21 checks passando sem regressao estrutural, arquitetura/closeout de fundacao documentados, validacao verde 211/211 e telemetria de rota completa 29/29.
- Baseline addendum: Card Impact V5 Enemy Causal Signatures passou em 2026-06-06 com `track02_card_impact_v5` before/after/compare em `user://card_impact/track02_card_impact_v5_enemy_causal_signatures`, 108 cartas de jogador, 30 cartas inimigas required, 15 legadas inativas, 3 cartas card-flow esperadas, zero structural errors, zero new failures, zero removed records e zero status changes. O compare reportou 30/30 cartas inimigas jogadas, 30/30 assinaturas inimigas presentes, 30 limpas, 0 ambiguas, 0 missing e 21/21 Card Flow Expectations passando; V4.2 historico, Battle Lab 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick verdes e `validate.gd` 211/211.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar Enemy Card Redesign Batch 01 Using V5 com before/change/after/compare. Track 02 segue pronta para playtest de usuario da rota completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - ARENA_PVE_MENU_FLOW_SIMPLIFICATION_V1_PUBLISHED_INTERNAL_ALPHA**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Arena PVE Menu Flow Simplification v1 publicado como Internal Alpha no release root `internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` e deployment evidence `https://fdf44707.draxos-mobile-internal-alpha.pages.dev`. O pacote forca APK/manifest `0.0.5-alpha.0`/version code `5`, publica Web/APK novos, simplifica a hierarquia/ordem dos menus da Arena PVE, remove CTAs duplicados e preserva Preparacao antes de iniciar e comportamento entre lutas. Bosque Offline-First Checkpoint v1 segue preservado como politica Openworld atual: active runtime local/offline-first; servidor autoritativo para checkpoint, conclusao, reward, caps, ledger e audit. Bosque Sync Responsiveness v1 (`internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95`, preview `https://60e2d4be.draxos-mobile-internal-alpha.pages.dev`) segue preservado como pacote Bosque sync anterior; Arena/Bosque Visible V2 (`internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5`, preview `https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev`) segue preservado como pacote visivel anterior; Arena/Bosque Regression Hotfix, Arena PVE Season 1 Loop v1, Arena Duel Flow Hotfix, Arena PVE First Real Run + Update Recovery, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync e `FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA` seguem preservados como baselines anteriores. Export, Storage upload publico, Cloudflare Pages branch `main`, manifest remoto, deploy da Edge Function `release`, smoke Web no preview e smokes remotos read-only passaram; stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing fica adiado para distribuicao Android mais ampla.
- Cadeia preservada: Arena/Bosque Regression Hotfix (`internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f`, preview `https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev`), Arena PVE Season 1 Loop v1 (`internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32`, preview `https://d7333659.draxos-mobile-internal-alpha.pages.dev`), Arena Duel Flow Hotfix (`internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, preview `https://0536635b.draxos-mobile-internal-alpha.pages.dev`), Arena PVE First Real Run + Update Recovery (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`), Bosque v3 UX/Feel (`internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`), Openworld Main Menu Sync (`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`, preview `https://aeec7403.draxos-mobile-internal-alpha.pages.dev`) e FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA (`internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`).
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation` e Supabase/Cloudflare CLI autenticada. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, PVP, tuning numerico amplo, novas armas, novas spells, economia ampla, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: playtest humano do pacote Arena PVE Menu Flow Simplification v1 a partir de `main`; validar ordem/posicao dos botoes, Preparacao e comportamento entre lutas. Nao reabrir microeventos revisionados como loop normal do Bosque sem nova decisao.

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
