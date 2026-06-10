# JogoDaCopa - Ball Goal Kick Tuning V1

## Status

Done

## Branch / Worktree

- Branch: `codex/jogodacopa/ball-goal-kick-tuning-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--ball-goal-kick-tuning-v1`

## Objetivo

Aplicar tuning arcade curto no modo Futebol: mais grip da bola no chao sem matar velocidade no ar, gol mais estreito e mais alto, bola com mais quique, chute esquerdo mais forte e chute direito com lift claro.

## Entregue

- Bola com menor damping no ar, maior bounce e drag horizontal aplicado apenas quando esta rolando perto do chao.
- Gol 20% mais estreito e 50% mais alto.
- LMB de `18.5` para `20.5`, com lift levemente maior.
- RMB mantendo forca `29.0`, agora com lift alto para levantar a bola.
- Track local `track-01b-ball-goal-kick-tuning-v1`.
- Docs locais e portfolio atualizados para `JOGO_DA_COPA_BALL_GOAL_KICK_TUNING_V1_COMPLETE`.

## Validacao

- `tools/validate.gd`: PASS, 24 testes, 178 asserts.
- `git diff --check`: PASS.
- Observacao: primeira execucao em worktree nova exigiu import headless do Godot para registrar `GutUtils`; warnings de UID/text-path do GUT permanecem como ruido conhecido.

## Handoff

Pronto para playtest humano no editor focado em bola no chao versus ar, quique, gols mais estreitos/altos e leitura dos chutes LMB/RMB.
