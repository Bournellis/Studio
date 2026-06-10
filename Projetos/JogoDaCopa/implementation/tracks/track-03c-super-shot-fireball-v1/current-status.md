# Track 03C - Super Shot & Fireball V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_03C_SUPER_SHOT_FIREBALL_V1_COMPLETE`
- Branch: `codex/jogodacopa/track03-arcade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03-arcade-series-v1`

## Goal

Adicionar chute carregado, barra de SUPER e fireball cosmetica com histerese, preservando tap LMB/RMB e mantendo paridade de bot.

## Delivered

- LMB agora inicia carga no press e solta no release; tap curto preserva forca/lift do chute normal.
- Chute carregado escala forca ate `1.55x` e adiciona lift leve sem alterar o caminho rapido de tap.
- Barra de SUPER enche por toque na bola e por gol sofrido.
- RMB usa Super Shot quando a barra esta cheia e ainda nao foi usado no kickoff atual.
- Super Shot zera a barra, aplica forca/lift maximos via `FootballBall3D.kick()` e e limitado a 1 por kickoff.
- Bot acumula e usa SUPER pelos mesmos criterios; dificuldade `hard` ganha SUPER mais rapido.
- Bola recebeu fireball cosmetica acima de 24 m/s com histerese de desligamento abaixo de 21 m/s.
- HUD mostra carga de chute e barra SUPER.
- Regressao explicita cobre tap LMB, RMB normal, Super Shot 1x/kickoff e fireball com histerese.

## Validation

- `tools/validate.gd`: PASS, 36 tests, 333 asserts.
- Known noise: GUT UID/text-path warnings during validation.

## Out Of Scope

- Boost pads, rampas e jump pads.
- Timer/golden goal/announcer flavor.
- Toon look experiment.
- Assets externos, audio real ou authored scene edits.

## Next Step

Implementar `Track 03B - Arcade Field V1`.
