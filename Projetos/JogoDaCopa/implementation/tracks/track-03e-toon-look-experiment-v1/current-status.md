# Track 03E - Toon Look Experiment V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_03E_TOON_LOOK_EXPERIMENT_V1_COMPLETE`
- Branch: `codex/jogodacopa/track03-arcade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03-arcade-series-v1`

## Goal

Adicionar experimento visual toon atras de toggle OFF por padrao, garantindo que o render com OFF permaneça igual ao atual e gerando screenshots comparativos para decisao de Fabio.

## Delivered

- `FootballRoot.RENDER_TOON_ENABLED` fica `false` por padrao.
- Menu principal ganhou toggle `Toon` em settings, tambem default OFF.
- Com OFF, nenhum outline e ativado em avatar/bola e o shader da bola usa `toon_intensity = 0.0`.
- Com ON, player, bot e bola recebem outline procedural; avatar usa material flat/toon; bola usa uniform de quantizacao leve no shader.
- Estadio/arena nao recebem toon, mantendo o neon noturno como base visual.
- Script `tools/capture_toon_comparison.gd` gera screenshots ON/OFF.
- Screenshots gerados:
  - `docs/screenshots/track-03e-toon/track-03e-toon-off.png`
  - `docs/screenshots/track-03e-toon/track-03e-toon-on.png`

## Validation

- `tools/validate.gd`: PASS, 46 tests, 426 asserts.
- Screenshot capture: PASS, PNGs ON/OFF gerados em Windows/Forward+.
- Known noise: GUT UID/text-path warnings during validation.

## Out Of Scope

- Aplicar toon no estadio.
- Trocar direcao de arte definitiva antes do playtest.
- Assets externos ou shaders authored fora do repo.

## Next Step

Fechar a serie Track 03 e preparar playtest humano arcade + decisao 02C-bis/02D-bis com assets baixados manualmente por Fabio.
