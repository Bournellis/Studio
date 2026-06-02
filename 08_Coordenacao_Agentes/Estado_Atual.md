# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-02`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`

## Prioridade Do Estudio

- Foco P0 de implementacao: `Projetos/draxos-roguelike-cardgame/`
- Foco P2 de implementacao: `Projetos/draxos-mobile/` (`REFUGIO_VISUAL_CLEANUP_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`, production URL `https://draxos-mobile-internal-alpha.pages.dev`, deployment evidence `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`, preservando Openworld QoL regression fix (`OPENWORLD_QOL_REGRESSION_FIX_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`), Foundation Hardening V2 (`FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA`, release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`) e Hardening Platform V1 como baselines anteriores, Track 21 Arena Loop Unlock/Friction como contexto do Autobattler, Track 20 Season 1 Arena Calibration, Remote Lab Runner, Track 13 release safety e Track 14 agent ops)
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Projetos pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## draxos-roguelike-cardgame

- Status: **P0_IMPLEMENTACAO - ativo**
- Fase: `Implementacao`
- Track ativa: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline atual: Track 02 completa para playtest de usuario em Godot 4.6.2 com rota fixa de 29 mapas, recompensas/reliquias/loja, keywords, AI/intent, modos, field effects, boss hooks, UI polida, validacao verde 94/94, telemetria de rota completa e screenshots obrigatorias capturadas.
- Meta ativa: playtest manual da Track 02 completa e coleta de feedback de balanceamento.
- Trabalho permitido: codigo, validacao, playtest e documentacao local.
- Proximo passo: executar playtest de usuario da Track 02 completa.

## DraxosMobile

- Status: **P2_IMPLEMENTACAO - REFUGIO_VISUAL_CLEANUP_PUBLISHED_INTERNAL_ALPHA**
- Fase: `Implementacao`
- Local: `Projetos/draxos-mobile/`
- Arquivo de conceito: `Projetos/_conceitos/mobile-universe/` (preservado como referencia de design)
- Nao confundir com: Draxos Roguelike Cardgame (projeto Steam separado)
- Baseline atual: Refugio Visual Cleanup publicado como Internal Alpha no release root `internal-alpha/v0-refugio-visual-cleanup-20260602-03f3fb0`, production URL `https://draxos-mobile-internal-alpha.pages.dev` e deployment evidence `https://f183cd39.draxos-mobile-internal-alpha.pages.dev`, removendo siglas visiveis dos icones do Refugio, titulo superior, altar/paineis centrais e barras persistentes de loop/progressao, mantendo CTA e feedback oculto. O pacote nao altera gameplay, backend, schema, migrations, endpoints, economia, tuning, conteudo ou Reward Bridge. Android APK usa `debug_fallback`, aceito para playtest funcional; release signing fica adiado para distribuicao Android mais ampla. Openworld QoL regression fix segue preservado como baseline funcional anterior no release root `internal-alpha/v0-openworld-node2d-qol-hotfix-20260601-ba6f129`; Foundation Hardening V2 segue preservado como baseline anterior de hardening/multi-mode gates no release root `internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4`, preview `https://ca946749.draxos-mobile-internal-alpha.pages.dev`; Hardening Platform V1 segue preservado como baseline anterior. Track 13 release safety e Track 14 agent ops seguem preservados. Track 21 Arena Loop Unlock/Friction e Track 20 Season 1 Arena Calibration seguem como contexto preservado do Autobattler/Arena PVE; Remote Lab Runner segue como contexto preservado de Labs no Web export.
- Trabalho permitido: codigo, design, documentacao local, configuracao de infraestrutura.
- Restricao operacional: iOS sem pedido explicito. Mobile browser fora do escopo. Secrets e service role nunca entram no cliente/export. Publicacao remota exige `-ConfirmRemoteMutation` e Supabase/Cloudflare CLI autenticada. Mudancas visuais em Entry/Refugio/Batalha exigem `foundation-responsive-layout-contract.md` + `smoke_responsive_layout.gd`. Novas features devem respeitar `account_profiles/game_saves`, ruleset registry, idempotencia v1 e RPC transacional v1 para mutations economicas/social. Direct chat, ajudas, contribuicoes, moderacao, PVP, tuning numerico amplo, novas armas, novas spells, economia ampla, visual final, previsao de vitoria, contra-escolha por oponente, thresholds customizados, comportamento por inimigo e controles avancados de replay ficam bloqueados ate decisao propria.
- Proximo passo: playtest humano do pacote Refugio Visual Cleanup publicado, revisando Refugio sem siglas/altar/barras persistentes e uma regressao rapida dos atalhos preservados; depois decidir proximo polish visual dedicado ou voltar ao playtest funcional do Openworld, mantendo tuning fino da Arena apenas apos confirmacao manual do loop tutorial -> primeira Arena real completa -> proxima dificuldade desbloqueada.

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
