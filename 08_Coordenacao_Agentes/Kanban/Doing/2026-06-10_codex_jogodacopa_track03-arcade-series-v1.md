# Tarefa: JogoDaCopa Track 03 Arcade Series V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track03-arcade-series-v1`
- owner: `Codex`
- status: `Doing`
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

- [ ] Plano arcade commitado e indexado antes da worktree de implementacao.
- [ ] `03A`, `03C`, `03B`, `03D` e `03E` implementadas na ordem solicitada.
- [ ] `tools/validate.gd` PASS apos cada track antes de avancar.
- [ ] Performance medida apos `03A` e `03B`, mantendo 60fps.
- [ ] Bot tem paridade na mesma track para dash/flip/stun, super/carga e coleta de boost pads.
- [ ] Tap LMB e RMB preservados com regressao explicita de forca/lift.
- [ ] Todo impulso novo na bola passa por `FootballBall3D.kick()`.
- [ ] `03E` fica atras de `RENDER_TOON_ENABLED` default OFF e gera screenshots comparativos ON/OFF.
- [ ] Nenhum segredo ou credencial foi salvo no projeto.
- [ ] Handoff foi criado se outro agente precisar continuar.

## Handoff Needed

`No`

## Notes

O diff inesperado de `Projetos/JogoDaCopa/project.godot` encontrado no gate inicial foi preservado em stash com aprovacao de Fabio antes da retomada.
