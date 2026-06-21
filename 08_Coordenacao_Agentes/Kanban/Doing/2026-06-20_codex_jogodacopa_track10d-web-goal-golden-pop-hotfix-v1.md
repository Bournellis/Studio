# Track 10D - Web Goal Golden Pop Hotfix V1

- Data: 2026-06-20
- Agente: Codex
- Branch: `codex/jogodacopa/track10d-web-goal-golden-pop-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track10d-web-goal-golden-pop-hotfix-v1`
- Base local: `f7935376` (`merge(jogodacopa): publish track10c web goal feedback`)
- Objetivo: corrigir a percepcao humana de que o gol Web 10C quase nao tem diferenca visual/sonora perceptivel.

## Escopo

- Tornar o feedback visual de gol Web mais obvio com um `golden pop` maior, mais alto e mais duradouro.
- Reduzir a cama de ambiente do estadio e o boost de ambiente no gol para deixar o evento respirar.
- Preservar o caminho heap-safe da 10C: sem `goal_jingle`, sem `crowd_goal`, sem particle burst e sem dynamic light no Web default.
- Preservar gameplay, fisica, bot, bola, scoring, SUPER, HUD, camera e tuning de partida.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/JogoDaCopa/tests/unit/test_render_profile.gd` se for necessario reforcar contrato.
- `Projetos/JogoDaCopa/docs/playtest-reports/track-10d-web-goal-golden-pop-hotfix.md`
- Docs de status/publicacao se a track for publicada.

## Validacao Planejada

- Import headless editor da worktree nova.
- `tools/validate.gd`.
- Web export/gzip.
- `node --check tools/track04f_chrome_probe.mjs`.
- Chrome local 90s Web smoke.
- Chrome local 5min Web stability antes da publicacao.
- `git diff --check`.
- `D:\Estudio\tools\check_doc_drift.ps1`.
- Se local passar: commit, merge em `main`, publish Cloudflare com `-ConfirmRemoteMutation`.
- Pos-publicacao: remote menu, first-minute, 5min stability, luma e confirmacao da URL estavel.

## Handoff Esperado

- Se passar gates: publicar como Track 10D e aguardar reteste humano.
- Se falhar performance/heap: nao manter publicacao; registrar bloqueio e recomendar rollback/hotfix.
- `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.

## Resultado Local

- Implementacao aplicada em `presentation/feedback/fps_feedback_controller.gd`.
- Web default continua `goal_visual` sem `goal_jingle`, sem `crowd_goal`, sem particle burst e sem dynamic light.
- Golden pop Web ampliado para esfera principal dourada `0.86m`, altura `1.18m`, lifetime `0.76s`, com dois marcadores secundarios maiores.
- Ambiente de estadio reduzido: play `-18.0 dB`, goal lift `-15.0 dB`.
- Contrato GUT reforcado em `tests/unit/test_render_profile.gd`.

## Validacao Local

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `108/108` testes, `1844` asserts, `62` fontes checadas.
- Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Chrome local 90s Web golden-pop: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Chrome local 5min Web golden-pop: PASS, `js_heap_growth +9.42%`, peak `+15.85%`, pior janela 5s FPS `127.6`, `firstMinuteHitches=0`.
- Eventos de gol Web: `visual=true audio=false` em `5` gols observados.

## Observacao De Risco

- O 5min local passou, mas `js_heap_growth +9.42%` ficou perto do limite de `10%`.
- A publicacao so deve ser considerada segura se o remote 5min stability tambem passar.
