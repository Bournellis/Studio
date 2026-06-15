# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-15`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia de pacotes/validacoes vai para os arquivos de historico do projeto (`implementation/tracks/`, `docs/release-history.md`, Kanban Done), nunca para este snapshot.

## Prioridade Do Estudio

- Foco operacional ativo: `Projetos/JogoDaCopa/` (`Super Campeao v1.2.1+ff9cb389` publicado; retest humano aceito; Track 09C local validada) + `Projetos/draxos-mobile/` (Arena UX/readability/recovery publicado Web/APK; aguardando prova humana)
- Pausados temporariamente (poucos dias): `Projetos/draxos-roguelike-cardgame/`, `Projetos/FpsPlayground/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - TRACK09C_LOCAL_VALIDADO`
- Marker: `JOGO_DA_COPA_TRACK09C_LOCAL_VALIDADO`
- Baseline publico: `Super Campeao v1.2.1+ff9cb389` (`web/v1-copa-arena-futebol-20260615-ff9cb389`) em `https://copa-arena-futebol.pages.dev/`; gates remotos 09A PASS e retest humano aceito.
- Refator atual: Track 09C extraiu spawn/wiring runtime para `football_runtime_spawner.gd`; `FootballRoot` medido nesta base `1739 -> 1588`; validate/export/Web boot local PASS.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: decidir publish da 09C ou continuar a proxima reducao estreita do `FootballRoot`.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO - retomada prevista em poucos dias`
- Track ativa preservada: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline: Track 02 completa em Godot 4.6.2 (rota de 29 mapas, save v5, keywords, AI/intent, labs Card Impact V5 e Design Lab V1, `validate.gd` 220/220). Detalhes em `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`.
- Meta preservada: expansao de conteudo via Design Lab antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: retomar quando o foco temporario do JogoDaCopa encerrar.

## DraxosMobile

- Status: `P2_IMPLEMENTACAO` - Arena UX/readability/recovery publicado Web/APK em 2026-06-15; aguardando prova humana
- Marker: `ARENA_UX_READABILITY_RECOVERY_V1_PUBLISHED_INTERNAL_ALPHA`
- Pacote publicado: `Arena UX Readability Recovery v1`, Web/APK `0.0.24-alpha.0` / vc `24`, preview `https://101e1ff7.draxos-mobile-internal-alpha.pages.dev`. Historico: `Projetos/draxos-mobile/docs/release-history.md`.
- Programa de hardening: hardening integrado + docs/client hardening pass 2 preservados; pacote atual formaliza o roteiro Arena UX Proof para validacao humana.
- Resultado de produto Arena PVE: `ARENA_CORE_NEEDS_UX_FIX` + `ARENA_CORE_NOT_PROVEN`; decisao em `08_Coordenacao_Agentes/Decisoes/2026-06-14_draxos-mobile_arena-core-ux-fix-not-proven.md`.
- Guardrails preservados: Track 13 release safety, Track 14 agent ops; fundacao server-authoritative/idempotencia/RLS NAO deve ser refatorada.
- Restricao operacional: ver `Projetos/draxos-mobile/AGENTS.md` (Hard Stops); secrets nunca no cliente; publicacao remota exige `-ConfirmRemoteMutation`; sem tuning numerico/PVP/economia/visual final sem decisao.
- Proximo passo: Fabio/tester executar a prova humana do pacote Arena seguindo `docs/arena-pve-product-proof.md`; registrar veredito antes de tuning, economia, PVP, conteudo novo, visual final ou expansao Openworld.

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
