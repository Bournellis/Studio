# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-14`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia de pacotes/validacoes vai para os arquivos de historico do projeto (`implementation/tracks/`, `docs/release-history.md`, Kanban Done), nunca para este snapshot.

## Prioridade Do Estudio

- Foco operacional ativo: `Projetos/JogoDaCopa/` (`Super Campeao v1.2.1` publicado; aguardando retest humano) + `Projetos/draxos-mobile/` (hardening integrado; Arena core precisa UX fix e nao esta provado)
- Pausados temporariamente (poucos dias): `Projetos/draxos-roguelike-cardgame/`, `Projetos/FpsPlayground/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - TRACK08A_PUBLICADO_AGUARDANDO_RETEST`
- Marker: `JOGO_DA_COPA_SUPER_CAMPEAO_V1_2_1_PUBLICADO_RETEST`
- Baseline: `Super Campeao` Web publico em `v1.2.1+6ef3074c` (`web/v1-copa-arena-futebol-20260614-6ef3074c`) na URL `https://copa-arena-futebol.pages.dev/`; gates remotos 08A PASS.
- Publicacao: Track 08A corrigiu o hitch Web de feedback de gol sem mudar gameplay; menu, primeiro minuto, estabilidade 5min e luma remotos passaram.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: retest humano do Fabio + tester externo na URL publica, cobrindo loading/menu, ESC, HUD/scorebug e primeiro minuto.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO - retomada prevista em poucos dias`
- Track ativa preservada: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline: Track 02 completa em Godot 4.6.2 (rota de 29 mapas, save v5, keywords, AI/intent, labs Card Impact V5 e Design Lab V1, `validate.gd` 220/220). Detalhes em `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`.
- Meta preservada: expansao de conteudo via Design Lab antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: retomar quando o foco temporario do JogoDaCopa encerrar.

## DraxosMobile

- Status: `P2_IMPLEMENTACAO` - hardening integrado localmente em 2026-06-14 (pos-analise de arquitetura)
- Marker: `BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
- Pacote publicado (baseline preservado): `Bosque Overlay Layer And Readiness Authority v1` (2026-06-10), Web/APK `0.0.23-alpha.0` / vc `23`. Historico: `Projetos/draxos-mobile/docs/release-history.md`.
- Programa de hardening: hardening integrado + rodada docs/client hardening pass 2 concluidos localmente em 2026-06-14; sem publicacao remota.
- Resultado de produto Arena PVE: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`; decisao em `08_Coordenacao_Agentes/Decisoes/2026-06-14_draxos-mobile_arena-core-ux-fix-not-proven.md`.
- Guardrails preservados: Track 13 release safety, Track 14 agent ops; fundacao server-authoritative/idempotencia/RLS NAO deve ser refatorada.
- Restricao operacional: ver `Projetos/draxos-mobile/AGENTS.md` (Hard Stops); secrets nunca no cliente; publicacao remota exige `-ConfirmRemoteMutation`; sem tuning numerico/PVP/economia/visual final sem decisao.
- Proximo passo: abrir pacote estreito de UX/readability/recovery da Arena; sem tuning numerico, economia, PVP, conteudo novo, visual final ou expansao Openworld.

## FpsPlayground

- Status: `PAUSADO_TEMPORARIO`
- Marker: `FPS_PLAYGROUND_PROJECT_SPLIT_FOUNDATION_COMPLETE`
- Baseline: laboratorio FPS separado do antigo `FpsShooter` em 2026-06-10; preserva `Arena Shooter`/`Duel Pit V2` com rifle hitscan, Plasma Bolt, jump pads e bot vertical-aware. Detalhes em `Projetos/FpsPlayground/implementation/current-status.md`.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: ao retomar, regressao/playtest humano de `Arena Shooter`.

## rpg-isometrico

- Status: `PAUSADO_INDEFINIDO` (current-status de `2026-04-26`)
- Baseline preservada: B0 interno com Arena / Survival / Boss jogaveis e frontend campaign-first.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar nem expandir escopo.

## rpg-turnos

- Status: `PAUSADO_INDEFINIDO` (current-status de `2026-05-13`)
- Baseline preservada: slice Godot 4.6.2 jogavel com runtime C1, modos de batalha, 3 classes, 13 encontros e save/load JSON v2.
- Trabalho permitido: consulta historica com pedido explicito; nao implementar, nao regenerar `.tres`.

## Kanban Rapido

- Backlog / Doing / Review / Done: `08_Coordenacao_Agentes/Kanban/`
- Handoffs: `08_Coordenacao_Agentes/Handoffs/`
- Decisoes: `08_Coordenacao_Agentes/Decisoes/`

## Canon

- Fonte compartilhada estavel: `canon/` (brief rapido: `canon/canon-brief.md`)
