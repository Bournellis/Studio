# Track 09H - Web Heap Hotfix V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track09h-web-heap-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09h-web-heap-hotfix-v1`
- Status: `PUBLICADO_RETEST_HUMANO_APROVADO`

## Objetivo

Investigar e corrigir de forma curta a falha de heap remoto observada na publicacao candidata da 09G, antes de qualquer nova reducao de `FootballRoot`.

## Diagnostico

- A publicacao candidata 09G falhou duas vezes apenas no gate remoto `js_wasm_heap_growth`: `+15.42%` e `+15.35%`.
- Nos dois runs remotos, `pageErrors=0`, `consoleErrorCount=0`, counters/caches Godot estaveis e FPS PASS; o problema ficou isolado em margem de heap JS/WASM, nao em vazamento de nodes/recursos Godot.
- O diff 09F -> 09G era estrutural: `football_root.gd` passou a delegar para `football_match_resolution_controller.gd`.
- A revisao encontrou um ponto de churn por frame no caminho do timer: `update_match_clock()` chamava `FootballMatchRulesScript.resolve_timer_state(...)`, que materializava um `Dictionary` a cada `_physics_process` em modo timer.
- Essa chamada ja existia antes da extracao, portanto a causa mais provavel e margem de heap insuficiente em um caminho per-frame ja borderline, amplificada pela variancia/forma do build remoto da 09G. A 09H remove esse churn sem mudar gameplay.

## Mudanca

- `modes/football/football_match_resolution_controller.gd`
  - `update_match_clock()` agora decide diretamente o fim do tempo:
    - retorna se ainda ha tempo;
    - ativa `golden_goal` quando o placar esta empatado;
    - finaliza a partida com `player_score > bot_score` quando ha vencedor.
  - Remove a alocacao de `Dictionary` por frame no clock do timer.
- Sem mudanca intencional de gameplay, input, bot, fisica, scoring, tuning, assets, HUD ou publicacao.
- `FootballRoot` permanece em `1178` linhas; esta track nao continuou a reducao.
- `football_match_resolution_controller.gd`: `174 -> 168` linhas.

## Validacao

- Import Godot headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `55` fontes `.gd/.gdshader` verificadas.
- Web export release: PASS.
- `tools/validate.gd` com build Web presente: PASS, Web gzip `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` arquivos.
- Chrome local short stability 120s: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`, heap final `+0.26%` no gate oficial, counters/caches Godot estaveis.
- Chrome local stability 5min: PASS, `pageErrors=0`, `consoleErrorCount=0`, heap final `+6.81%` contra limite `10%`, pico transitorio `+12.73%`, counters/caches Godot estaveis, pior janela 5s `140.2 FPS`.
- Cloudflare Pages publicacao: PASS como `web/v1-copa-arena-futebol-20260615-4a323fab` / `Super Campeao v1.2.1+4a323fab`.
- Chrome remoto menu: PASS, release root conferiu, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Chrome remoto primeiro minuto: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Chrome remoto stability 5min: PASS, heap final `43,664,158 -> 48,016,205` bytes (`+9.97%`, limite `<10%`), pico `50,091,222` bytes (`+14.72%`), counters/caches Godot estaveis, pior janela 5s `129.8 FPS`.
- Luma remota noturna: PASS, `6.525 < 90`.

## Evidencias

- `docs/playtest-reports/track-09h-data/09h-local-short-stability.json`
- `docs/playtest-reports/track-09h-data/09h-local-short-stability.png`
- `docs/playtest-reports/track-09h-data/09h-local-stability-5min.json`
- `docs/playtest-reports/track-09h-data/09h-local-stability-5min.png`
- `docs/playtest-reports/track-09h-data/09h-publication-report-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-menu-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-first-minute-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-stability-5min-4a323fab.json`
- `docs/playtest-reports/track-09h-data/09h-remote-night-luma-gate-4a323fab.json`
- `docs/playtest-reports/track-09h-web-heap-hotfix.md`

## Risco Residual

- A causa remota exata da 09G segue tratada como margem Web apertada, nao como vazamento comprovado de nodes/recursos Godot.
- A 09H passou no limite remoto por margem estreita (`+9.97%` contra `<10%`); o reteste humano foi aprovado antes da 09I, e o gate 5min segue obrigatorio para a proxima publicacao.
