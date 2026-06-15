# Handoff: JogoDaCopa Track 09H Web Heap Hotfix V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track09h-web-heap-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09h-web-heap-hotfix-v1`
- Status: `LOCAL_VALIDADO`

## Resumo

Investiguei a falha remota de heap da 09G e apliquei um hotfix minimo: `update_match_clock()` nao aloca mais um `Dictionary` por frame para resolver estado de timer. A regra de partida permanece igual e a reducao do `FootballRoot` foi pausada nesta track.

## Resultado Tecnico

- Fonte de churn removida: chamada per-frame de `FootballMatchRulesScript.resolve_timer_state(...)` no clock do timer.
- `FootballRoot` ficou inalterado em `1178` linhas.
- `football_match_resolution_controller.gd` caiu de `174` para `168` linhas.
- Sem mudanca intencional de gameplay, input, bot, fisica, scoring, tuning, assets, HUD ou publicacao.

## Validacao

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts.
- Web export release: PASS.
- `tools/validate.gd` pos-export: PASS, Web gzip `30.60 MiB / 50.00 MiB`.
- Chrome local short stability 120s: PASS, `firstMinuteHitches=0`, heap final `+0.26%`.
- Chrome local stability 5min: PASS, heap final `+6.81%`, limite `10%`; counters/caches Godot estaveis; pior janela 5s `140.2 FPS`.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-web-heap-hotfix.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-local-short-stability.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-local-short-stability.png`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-local-stability-5min.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-local-stability-5min.png`

## Proximo Passo Recomendado

Publicar uma candidata 09H e rodar menu remoto, primeiro minuto remoto, estabilidade remota 5min e luma remota. So retomar nova reducao do `FootballRoot` depois desse gate remoto passar.
