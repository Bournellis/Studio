# Track 03A - Arcade Movement & Actions V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_03A_ARCADE_MOVEMENT_ACTIONS_V1_COMPLETE`
- Branch: `codex/jogodacopa/track03-arcade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03-arcade-series-v1`

## Goal

Adicionar o nucleo de movimento arcade de `Copa Arena Futebol` com dash, carrinho/ombrada, double jump/flip e paridade de bot na mesma track, preservando contratos de chute e fisica base da bola.

## Delivered

- Nova input action `arcade_dash` registrada em `autoloads/app_bootstrap.gd` (`E`/`Ctrl`).
- Player controller recebeu dash com custo de stamina, cooldown, duracao curta e indicador no HUD.
- Player controller recebeu double jump/flip uma vez por airtime, com reset ao pousar.
- Player e bot receberam stun arcade curto sem dano de vida e usando knockback da base combat.
- Carrinho/slide no root rouba a bola via `FootballBall3D.kick()` e aplica knockback + stun em contato.
- Ombrada sem bola aplica knockback mutuo sem stun.
- Bot recebeu dash defensivo quando a bola ameaca o gol e flip em bolas altas, modulados por dificuldade.
- Avatar procedural recebeu poses de `slide` e `flip`.
- Regressao explicita de tap LMB/RMB preserva forca e lift atuais.
- `tools/performance_sample.gd` criado para amostras repetiveis de performance apos 03A/03B.

## Validation

- One-time headless editor import run after fresh worktree reported `GutUtils` not imported.
- `tools/validate.gd`: PASS, 33 tests, 316 asserts.
- Performance sample Windows/Forward+: average `1275.8fps`, min warmed instant `787.4fps`, `0/360` frames below 60.
- Known noise: GUT UID/text-path warnings during validation.

## Out Of Scope

- Super Shot, charge meter and fireball.
- Boost pads, ramps and jump pads.
- Timer/golden goal/announcer flavor.
- Toon look experiment.
- External assets or authored scene edits.

## Next Step

Implementar `Track 03C - Super Shot & Fireball V1`.
