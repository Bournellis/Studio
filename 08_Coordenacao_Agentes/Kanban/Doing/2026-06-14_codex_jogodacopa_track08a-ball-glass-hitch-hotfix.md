# Track 08A - Ball Glass Hitch Hotfix

## Branch / Worktree

- Branch: `codex/jogodacopa/track08a-ball-glass-hitch-hotfix`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track08a-ball-glass-hitch-hotfix`
- Base: `main` at `993d0643`

## Objective

Diagnose and eliminate the remote first-minute hitch observed after publishing Track 08 (`v1.2.1+2f537628`), where the probe reported one `333.5ms` hitch near `feedback.play_sfx_3d.begin key=ball_glass`.

## Guardrails

- No gameplay changes: no physics, rules, bot, timer, goals, controls or camera behavior changes.
- Keep Track 08 rebrand/UI cleanup intact.
- No Git network operations. Fabio handles push/fetch/pull through GitHub Desktop.
- Remote mutation only through `tools/publish_web.ps1 ... -ConfirmRemoteMutation`.
- If a remote gate fails after republishing, rollback immediately to `web/v1-copa-arena-futebol-20260614-fa82cb7d`.

## Intended Files

- `Projetos/JogoDaCopa/presentation/feedback/*`
- `Projetos/JogoDaCopa/modes/football/*`
- `Projetos/JogoDaCopa/tools/*`
- `Projetos/JogoDaCopa/tests/*`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/*`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- this Kanban card and final handoff/done record

## Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-14_codex_jogodacopa_track08-super-campeao-ui-rollback.md`

## Validation Plan

- Import headless once for the new worktree.
- Reproduce/inspect the `ball_glass` first-use path.
- Add a minimal technical hotfix and regression coverage.
- Run `tools/validate.gd`.
- Run `git diff --check`.
- Export Web locally.
- Run local Chrome first-minute probe against the branch package.
- If local gates pass, merge to main and publish using the approved Cloudflare script.
- Remote gates after publish: menu sanity, first minute, stability 5 min, night luma.

## Local Progress

- Import headless: PASS.
- `tools/validate.gd`: PASS (`104` tests / `1825` asserts).
- Local Web export: PASS.
- Local first-minute probe after lightweight Web confetti: PASS (`firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`).
- Local 5-minute stability probe after lightweight Web confetti: PASS (`stabilityPassed=true`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`).
- Evidence: `Projetos/JogoDaCopa/docs/playtest-reports/track-08a-data/`.

## Next Handoff Point

- Handoff if the hitch cannot be reproduced/mitigated locally after focused iterations, or if any remote gate fails after rollback.
