# Track 01B - Ball Goal Kick Tuning V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_BALL_GOAL_KICK_TUNING_V1_COMPLETE`
- Branch: `codex/jogodacopa/ball-goal-kick-tuning-v1`

## Goal

Refinar a sensacao arcade do modo `Futebol` sem adicionar sistemas novos: bola com mais grip quando rola no chao, velocidade preservada melhor no ar, gols mais estreitos e altos, mais quique e chutes com leitura melhor.

## Delivered

- Bola `RigidBody3D` com bounce maior, menor damping no ar e drag horizontal aplicado apenas quando esta rolando perto do chao.
- Gol 20% mais estreito: meia largura de `5.4m` para `4.32m`.
- Gol 50% mais alto: frame de `2.3m` para `3.45m`.
- Chute esquerdo mais forte: forca de `18.5` para `20.5`, com lift levemente maior.
- Chute direito preserva forca atual, mas ganha lift alto para levantar a bola com clareza.
- Testes atualizados para cobrir contrato de dimensoes, grip no chao sem drag no ar, chute esquerdo e lift do chute direito.

## Validation

- `tools/validate.gd`
- `git diff --check`
- Godot headless import/script reload, se necessario em worktree limpa.

## Out Of Scope

- Novos modos.
- Mudancas no bot.
- Novos assets finais.
- Export/Web/mobile/backend/multiplayer.
