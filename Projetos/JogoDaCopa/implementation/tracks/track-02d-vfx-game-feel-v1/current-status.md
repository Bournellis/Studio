# Track 02D - VFX & Game Feel V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02D_VFX_GAME_FEEL_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`

## Goal

Adicionar o juice de arena arcade aprovado para a Track 02: particulas, camera shake/FOV, slow-mo de gol e countdown de kickoff, sem alterar os contratos de feel de bola/chute/boost.

## Delivered

- Kickoff ganhou countdown `3-2-1/VAI!` no HUD com lock de input do jogador, bot e bola.
- `FpsPlayerController` ganhou `set_input_locked()` para travar rodada sem quebrar os fluxos de movimento existentes.
- Gols ganharam slow-mo curto, foco temporario da chase camera e shake de impacto.
- Chutes ganharam shake curto de camera; chute forte usa amplitude maior.
- Boost ganhou FOV kick na chase camera e trail de particulas no jogador.
- Frenagem em alta velocidade ganhou poeira curta de skid.
- `FpsFeedbackController` ganhou bursts de gol, faiscas de chute, boost trail e skid dust usando particulas procedurais.
- HUD passou a expor countdown pelo mesmo canal visual de eventos.
- Debug/test hooks cobrem countdown lock, slow-mo/foco de gol e contadores de VFX.

## Validation

- `tools/validate.gd`: PASS, 26 tests, 250 asserts.
- Performance sample Windows/Forward+ after warmup with VFX spawned: average `144.2fps`, min warmed instant `63.3fps`, `0/360` frames below 60.
- Known noise: GUT UID/text-path warnings after fresh worktree import, accepted by `docs/validation.md`.

## Out Of Scope

- HUD/menu polish and result/rematch flow (Track 02E).
- Bot difficulty and match-flow intelligence (Track 02F).
- Product identity, export preset and build smoke test (Track 02G).
