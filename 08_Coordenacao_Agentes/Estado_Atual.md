# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-05`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`ARENA_DUEL_FLOW_HOTFIX_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, deployment evidence `https://0536635b.draxos-mobile-internal-alpha.pages.dev`, publicado em `main`, corrigindo Preparacao/comportamento no menu ativo do duelo e buff selecionado -> Resolver duelo; preserva Arena PVE First Real Run + Update Recovery como pacote Arena anterior, Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Bosque Mecanico Basico v2, First Access Runtime Fix, Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`), Hardening Platform V1, Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops)
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, save/snapshot v5, recompensas/reliquias/Souls shop expandida, keywords completas, AI/intent, modos e formatos de encontro, field effects, boss hooks, UI polida, descarte marcado na fase principal, testes modulares, diretores/servicos internos de fundacao incluindo enemy AI/intent, combate/dano, reward/shop e BattleRoot presenters, geracao idempotente do catalogo, simulador compartilhado de pacing, checklist de playtest, AutoRun Gate Pack V1 com presets/matriz/politicas macro/golden comparison/baselines oficiais smoke e quick/gate explicito/scorecards JSON-Markdown, Scenario Fixtures V1 com pacote `track02_core_v1`, 12 cenarios deterministicos nomeados, expectativas PASS/WARN/FAIL, gate explicito e relatorios JSON/CSV/Markdown, Gameplay Lab V1 com pacote `track02_battle_core_v1`, 12 batalhas isoladas via BattleEngine real, policies legais deterministicas, expectativas PASS/WARN/FAIL, gate explicito e relatorios JSON/CSV/Markdown, Lab Diff Reporter V1 para comparar outputs before/after de AutoRun/Scenario/Battle, Card Impact Pack V1 e V2 com 84 cartas ativas cobertas, 54 assinaturas de efeito exigidas para cartas de jogador em V2, 30 cartas inimigas em modo report-only para assinatura, 15 `elemental_*` legado auditadas, policy `card_focus_legal`, before/after/compare gate explicito e relatorios JSON/CSV/Markdown, Card Impact Smoke Tuning V1 aplicado em pequeno lote de cartas com impacto metricamente visivel em `enemy_ar_rajada`, arquitetura/closeout de fundacao documentados, validacao verde 154/154 e telemetria de rota completa 29/29.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar o primeiro lote real de redesign de cartas de jogador usando Card Impact V2 before -> alteracao -> after -> compare; depois retomar playtest de usuario da Track 02 completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - ARENA_DUEL_FLOW_HOTFIX_PUBLISHED_INTERNAL_ALPHA**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Arena Duel Flow Hotfix publicado como Internal Alpha no release root `internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174`, official Portal URL `https://draxos-mobile-internal-alpha.pages.dev/`, direct Web URL `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` e deployment evidence `https://0536635b.draxos-mobile-internal-alpha.pages.dev`, mantendo o dominio production como URL oficial e o hash como evidencia tecnica. O pacote preserva Arena PVE First Real Run + Update Recovery e corrige dois bloqueios do fluxo ativo: Preparacao/comportamento aparece dentro do menu ativo do duelo e uma oferta de buff ja escolhida volta para `Resolver duelo` em vez de repetir `Escolher buff`. Arena PVE First Real Run + Update Recovery (`internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a`, preview `https://2c020d09.draxos-mobile-internal-alpha.pages.dev`) segue preservado como pacote Arena anterior com retomar/abandonar/encerrar tentativa antiga e primeira arena real de 3 duelos. Hotfix `track23-online-actions-hotfix` em `release/config` libera acoes online server-authoritative de progressao (`read_only=false`, `mutable_gameplay_state=true`) e mantem fallback conservador quando a configuracao remota falha. Export, Storage upload publico, Cloudflare Pages branch `main`, manifest remoto, RemoteReadOnly e smoke Web no preview passaram; stable Portal/Web ficam Cloudflare Access protected. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing fica adiado para distribuicao Android mais ampla. Bosque v3 UX/Feel, Technical Hardening, Openworld Main Menu Sync, Bosque Mecanico Basico v2, First Access Runtime Fix, Foundation Hardening V2 e Hardening Platform V1 seguem preservados como baselines anteriores. Track 13 release safety e Track 14 agent ops seguem preservados. Track 23 Arena recovery, Track 21 Arena Loop Unlock/Friction e Track 20 Season 1 Arena Calibration seguem como contexto preservado do Autobattler/Arena PVE; Remote Lab Runner segue como contexto preservado de Labs no Web export.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation` e Supabase/Cloudflare CLI autenticada. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, PVP, tuning numerico amplo, novas armas, novas spells, economia ampla, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: retomar playtest humano do pacote Arena Duel Flow Hotfix focando tutorial -> primeira arena real de 3 duelos, buff entre duelos, retomar/abandonar/encerrar tentativa antiga, Preparacao no menu ativo, buff escolhido -> Resolver duelo e regressao Bosque/menu antes de abrir tuning amplo ou novas expansoes.

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
