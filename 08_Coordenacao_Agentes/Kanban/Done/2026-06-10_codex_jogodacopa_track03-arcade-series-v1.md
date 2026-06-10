# Tarefa: JogoDaCopa Track 03 Arcade Series V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track03-arcade-series-v1`
- owner: `Codex`
- status: `Done`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track03-arcade-series-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03-arcade-series-v1`

## Goal

Implementar a Serie Track 03 Arcade V1 completa em `Copa Arena Futebol`, seguindo `Projetos/JogoDaCopa/docs/arcade-upgrade-plan.md` na ordem `03A -> 03C -> 03B -> 03D -> 03E`, com paridade de bot, validacao por track e registros de status.

## Technical Scope

- `Arcade Movement & Actions V1`
- `Super Shot & Fireball V1`
- `Arcade Field V1`
- `Arcade Match Flavor V1`
- `Toon Look Experiment V1`
- `FootballBall3D.kick()`
- `football_match_rules.gd`
- `tools/validate.gd`

## Out of Scope

- Power-ups classicos de campo.
- Assets externos.
- Multiplayer, backend, Web/mobile ou novo export.
- Hand-edit de `.tscn` gerado.
- Alterar fisica base da bola fora de impulsos via `FootballBall3D.kick()`.

## Expected Files

- `docs/arcade-upgrade-plan.md`
- `docs/documentation-index.md`
- `docs/work-plan.md`
- `implementation/current-status.md`
- `implementation/tracks/track-03a-arcade-movement-actions-v1/current-status.md`
- `implementation/tracks/track-03c-super-shot-fireball-v1/current-status.md`
- `implementation/tracks/track-03b-arcade-field-v1/current-status.md`
- `implementation/tracks/track-03d-arcade-match-flavor-v1/current-status.md`
- `implementation/tracks/track-03e-toon-look-experiment-v1/current-status.md`
- `gameplay/football/`
- `modes/football/`
- `presentation/hud/`
- `tests/`

## Acceptance Criteria

- [x] Plano arcade commitado e indexado antes da worktree de implementacao.
- [x] `03A`, `03C`, `03B`, `03D` e `03E` implementadas na ordem solicitada.
- [x] `tools/validate.gd` PASS apos cada track antes de avancar.
- [x] Performance medida apos `03A` e `03B`, mantendo 60fps.
- [x] Bot tem paridade na mesma track para dash/flip/stun, super/carga e coleta de boost pads.
- [x] Tap LMB e RMB preservados com regressao explicita de forca/lift.
- [x] Todo impulso novo na bola passa por `FootballBall3D.kick()`.
- [x] `03E` fica atras de `RENDER_TOON_ENABLED` default OFF e gera screenshots comparativos ON/OFF.
- [x] Nenhum segredo ou credencial foi salvo no projeto.
- [x] Handoff foi criado se outro agente precisar continuar.

## Validation Log

- `03A`: `tools/validate.gd` PASS (33 tests, 316 asserts). Performance Windows/Forward+: average `1275.8fps`, min warmed instant `787.4fps`, `0/360` frames below 60.
- `03C`: `tools/validate.gd` PASS (36 tests, 333 asserts).
- `03B`: `tools/validate.gd` PASS (39 tests, 358 asserts). Performance Windows/Forward+: average `1097.6fps`, min warmed instant `607.2fps`, `0/360` frames below 60.
- `03D`: `tools/validate.gd` PASS (45 tests, 403 asserts).
- `03E`: `tools/validate.gd` PASS (46 tests, 426 asserts). Screenshots ON/OFF gerados em `Projetos/JogoDaCopa/docs/screenshots/track-03e-toon/`.
- Known validation noise: GUT UID/text-path warnings.

## Handoff Needed

`No`

## Notes

O diff inesperado de `Projetos/JogoDaCopa/project.godot` encontrado no gate inicial foi preservado em stash com aprovacao de Fabio antes da retomada.
