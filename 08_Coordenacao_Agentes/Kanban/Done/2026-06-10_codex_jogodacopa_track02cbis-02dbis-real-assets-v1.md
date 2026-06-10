# Tarefa: JogoDaCopa Track 02C-bis/02D-bis Real Assets V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track02cbis-02dbis-real-assets-v1`
- owner: `Codex`
- status: `Done`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track02cbis-02dbis-real-assets-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02cbis-02dbis-real-assets-v1`

## Gate Inicial

- Fase 0: PASS.
- Track 03 Arcade Series V1 esta completa em `main`.
- Card confirmado em `Kanban/Done/2026-06-10_codex_jogodacopa_track03-arcade-series-v1.md`.
- Branch/worktree da Track 03 Arcade Series V1 nao permanecem ativos.

## Goal

Implementar `Track 02C-bis - Real Character V1` e `Track 02D-bis - Real Audio V1` integrando os assets CC0/Pixabay baixados manualmente por Fabio e organizados em `Projetos/JogoDaCopa/assets/`.

## Intended Files

- `Projetos/JogoDaCopa/assets/characters/`
- `Projetos/JogoDaCopa/assets/audio/`
- `Projetos/JogoDaCopa/gameplay/avatar/`
- `Projetos/JogoDaCopa/presentation/feedback/`
- `Projetos/JogoDaCopa/modes/football/`
- `Projetos/JogoDaCopa/modes/menu/`
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/tools/validate.gd`
- `Projetos/JogoDaCopa/docs/asset-licenses.md`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-02cbis-real-character-v1/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-02dbis-real-audio-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Base Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/quality-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/arcade-upgrade-plan.md`
- `Projetos/JogoDaCopa/docs/code-review-track02-series-v1.md`

## Validation Plan

- Import spike headless dos assets Quaternius `Superhero_Male_FullBody.gltf`, `Superhero_Female_FullBody.gltf` e `UAL1_Standard.glb`, listando bone count e animacoes antes de implementar.
- `tools/validate.gd` PASS apos Track 02C-bis.
- Performance sample com 2 modelos reais, mantendo 60fps.
- `tools/validate.gd` PASS apos Track 02D-bis.
- `git diff --check` e `git status --short` limpos antes do fechamento.

## Acceptance Criteria

- [x] Assets reais registrados em `main` antes da worktree de implementacao.
- [x] Spike de import PASS antes da integracao de personagem.
- [x] Avatar usa modelo Superhero skinned real, skeleton >= 60 bones e `AnimationTree` com clipes reais do UAL.
- [x] Contratos `apply_appearance`, `set_move_state`, `play_kick`, `play_celebrate` preservados.
- [x] Track 03 integra os clipes mapeados para dash/slide/stun/SUPER/emote.
- [x] Audio sintetico do feedback controller substituido por SFX reais com pooling de `AudioStreamPlayer`.
- [x] Loop de estadio e buses `Master/SFX/UI/Ambience` com sliders no menu.
- [x] Licencas dos packs novos registradas em `docs/asset-licenses.md`.
- [x] `tools/validate.gd` PASS e docs/status atualizados.

## Delivery

- Asset registration commit on `main`: `95805d2 chore(jogodacopa): register real asset packs`.
- Track 02C-bis implementation commit: `03a22f5 feat(jogodacopa): add real character avatars`.
- Track 02D-bis implementation commit: `656a5ee feat(jogodacopa): add real audio feedback`.
- `tools/real_asset_import_spike.gd` PASS: Quaternius male/female + UAL loaded, 65-bone skeletons, 45 imported animation clips.
- `tools/validate.gd` PASS after 02D-bis: 48 tests, 459 asserts.
- Performance sample after 02D-bis: average `145.4fps`, min warmed instant `124.0fps`, `0/360` frames below 60.
- Next handoff: playtest humano completo - visual arcade + personagem real + audio real.
