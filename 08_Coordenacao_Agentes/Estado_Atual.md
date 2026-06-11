# Estado Atual - Estudio

- Ultima atualizacao: `2026-06-11`
- Fonte de verdade de portfolio: `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- Painel visual local: `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- Regra de tamanho: maximo ~12 linhas por projeto. Historia de pacotes/validacoes vai para os arquivos de historico do projeto (`implementation/tracks/`, `docs/release-history.md`, Kanban Done), nunca para este snapshot.

## Prioridade Do Estudio

- Foco operacional temporario unico: `Projetos/JogoDaCopa/`
- Pausados temporariamente (poucos dias): `Projetos/draxos-roguelike-cardgame/`, `Projetos/draxos-mobile/`, `Projetos/FpsPlayground/`
- Arquivo de design: `Projetos/_conceitos/mobile-universe/`
- Pausados por tempo indeterminado: `Projetos/rpg-isometrico/`, `Projetos/rpg-turnos/`

## JogoDaCopa

- Status: `P2_IMPLEMENTACAO - FOCO TEMPORARIO UNICO`
- Marker: `JOGO_DA_COPA_TRACK_03L1_FACING_EVIDENCE_V1_COMPLETE`
- Baseline: `Copa Arena Futebol`, 1x1 vs bot TPS, arena noturna de vidro estanque ate o teto, gols com painel frontal alto, quina simples sem rodape/rampas, personagem real skinned/audio real, bola com CCD/trail/fireball/squash, dash/slide/stun/flip, chute carregado/SUPER sem gasto em whiff, boost/jump pads, timer 3min default com golden goal/vale-2, HUD/menu arcade com clique real em 3 resolucoes, bot defensivo/aereo, camera/reset de kickoff protegidos, avatar real com root track removido e facing visual por movimento; 03L.1 fechou teste/capturas/playtest-report de evidencia de facing. Detalhes em `Projetos/JogoDaCopa/implementation/current-status.md`.
- Trabalho permitido: codigo, design, validacao, playtest no editor e documentacao local.
- Proximo passo: playtest de confirmacao geral por Fabio - arena sem fuga, gol alto rebatendo, quina simples e facing visual do player com evidencia 03L.1 ja registrada.

## draxos-roguelike-cardgame

- Status: `PAUSADO_TEMPORARIO - retomada prevista em poucos dias`
- Track ativa preservada: `Track 02 - Complete Run Evolution` (T02-P09_COMPLETE)
- Baseline: Track 02 completa em Godot 4.6.2 (rota de 29 mapas, save v5, keywords, AI/intent, labs Card Impact V5 e Design Lab V1, `validate.gd` 220/220). Detalhes em `Projetos/draxos-roguelike-cardgame/implementation/current-status.md`.
- Meta preservada: expansao de conteudo via Design Lab antes de playtests completos de sensacao.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: retomar quando o foco temporario do JogoDaCopa encerrar.

## DraxosMobile

- Status: `PAUSADO_TEMPORARIO`
- Marker: `BOSQUE_OVERLAY_LAYER_READINESS_AUTHORITY_V1_PUBLISHED_INTERNAL_ALPHA`
- Pacote publicado atual: `Bosque Overlay Layer And Readiness Authority v1` (2026-06-10), Web/APK `0.0.23-alpha.0` / vc `23`. Historico completo de pacotes, URLs e endpoints: `Projetos/draxos-mobile/docs/release-history.md`.
- Guardrails preservados: Track 13 release safety e Track 14 agent ops.
- Restricao operacional: ver `Projetos/draxos-mobile/AGENTS.md` (Hard Stops); secrets nunca no cliente; publicacao remota exige `-ConfirmRemoteMutation`.
- Trabalho permitido: consulta historica; retomada apenas com pedido explicito.
- Proximo passo: ao retomar, playtest humano focado do pacote publicado (Web/APK).

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
