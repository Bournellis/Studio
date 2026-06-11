# Tarefa: JogoDaCopa Track 03H Avatar Parity & Animation Drift Fix V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track03h-avatar-parity-drift-v1`
- owner: `Codex`
- status: `Doing`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track03h-avatar-parity-drift-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03h-avatar-parity-drift-v1`

## Goal

Corrigir os dois bugs de playtest do avatar real da 02C-bis: bot deve renderizar o mesmo pipeline de modelo humanoide real do player, e as animacoes nao podem acumular drift de rotacao/posicao no mesh ou skeleton.

## Technical Scope

- `PlayerAvatar3D` real model fallback diagnostics
- `set_character_variant` initialization order
- `Superhero_Female_FullBody.gltf` real model build path
- `UAL1_Standard.glb` animation copy/root motion stripping
- `AnimationTree` state travel pose reset
- scene-level avatar parity test through `football.tscn`
- animation drift debug hooks and regression tests

## Out of Scope

- Alterar fisica, forcas, massa, bounce, drag ou limites da bola.
- Alterar contratos de chute/tap/RMB, dash, boost ou bot fora da paridade do avatar.
- Introduzir novos assets externos.
- Reabrir decisoes de produto das Tracks 02C-bis, 03F ou 03G.

## Expected Files

- `Projetos/JogoDaCopa/gameplay/avatar/player_avatar_3d.gd`
- `Projetos/JogoDaCopa/modes/football/football_root.gd`
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-03h-avatar-parity-drift-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Acceptance Criteria

- [ ] Pre-condicao confirmada: Track 03G mergeada em `main` e card em `Done`.
- [ ] Bot e player em `football.tscn` retornam `debug_has_real_model() == true`.
- [ ] Bot e player em `football.tscn` retornam `debug_get_animation_count() >= 40`.
- [ ] Qualquer fallback de modelo real emite `push_error`/log permanente com causa.
- [ ] Root motion horizontal e rotacao Y de root/hips sao removidos ao copiar clipes reais.
- [ ] Troca de estados de animacao reseta pose/local transform sem drift cumulativo.
- [ ] Teste de drift cobre ~20 acoes alternadas e mantem rotacao Y/local position dentro da tolerancia.
- [ ] `validate.gd` PASS.
- [ ] Causa raiz dos dois bugs documentada na track.
- [ ] `quality-upgrade-plan.md`, `implementation/current-status.md` e `Estado_Atual.md` atualizados no fechamento.
- [ ] Worktree principal verificada pos-merge com `WORKTREE_VERIFIED`.

## Handoff Needed

`No`

## Notes

Docs lidos na Fase 1: `Projetos/JogoDaCopa/AGENTS.md`, `implementation/current-status.md`, `docs/code-review-track02cbis-02dbis-v1.md`, `implementation/tracks/track-02cbis-real-character-v1/current-status.md`, `docs/quality-upgrade-plan.md`, alem do gate de portfolio (`Prioridades_Estudio.md`, `Projetos/README.md`, `Estado_Atual.md`).
