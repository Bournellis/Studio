# Track 03L.1 - Facing Evidence V1

- Data: `2026-06-11`
- Status: `FIX_VALIDATED`
- Branch: `codex/jogodacopa/track03l1-facing-evidence-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03l1-facing-evidence-v1`
- Marker alvo: `JOGO_DA_COPA_TRACK_03L1_FACING_EVIDENCE_V1_COMPLETE`

## Objetivo

Complementar a evidencia da Track 03L sem tocar em codigo de gameplay, fechando as lacunas apontadas no code review da Claude: teste automatizado de facing, capturas de movimento/parada/rebote e relatorio de playtest.

## Entregas

- Code review da Claude preservado em `docs/code-review-track03l-arena-seal-facing-v2.md`.
- Teste novo em `tests/unit/test_avatar_system.gd`: avatar com `movement_facing` habilitado gira para `+X`, gira para `-Z` e mantem frente correta apos parar.
- `tools/capture_track03l_arena.gd` agora gera tambem evidencia complementar de facing e rebote.
- Novas capturas em `docs/screenshots/track-03l-arena/`: `facing-curve-frame-01.png` a `facing-curve-frame-04.png`, `facing-stopped-forward-back-to-camera.png` e `ball-old-gap-upper-wall-rebound.png`.
- Relatorio criado em `docs/playtest-reports/track-03l-arena.md`.

## Validacao

- Preparacao da worktree: import headless do editor Godot para registrar classes globais/GUT.
- Full validation final: PASS, `64/64` tests, `773` asserts, source integrity `28` `.gd/.gdshader` files outside `addons/`.

## Proximo Passo

Playtest de confirmacao geral por Fabio: confirmar feel visual do facing, arena sem fuga, rebote alto e quina simples sem rodape.
