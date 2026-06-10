# Codex - JogoDaCopa Arcade Arena Boost V1

Status: Done

Branch: `codex/jogodacopa/arcade-arena-boost-v1`
Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--arcade-arena-boost-v1`

## Objective

Reverter o feel de camera/bola presa e transformar `Futebol 1x1` em uma arena arcade fechada inspirada em Rocket League, com menos verticalidade extrema, bola solta, paredes altas, teto, estadio e boost com stamina.

## Delivered

- Bola sem possession lock: o antigo dribble control nao empurra mais a bola automaticamente.
- Chute assistido ficou mais curto e menos magnetico.
- Bola mais arcade: mais quique, menos damp, maior velocidade vertical/horizontal e material fisico bouncy.
- Campo aumentado para 38x54, gols maiores/profundos e arena fechada com paredes de vidro e teto com colisao.
- Estadio ao redor por primitivas e painels coloridos.
- Player ganhou `Shift` boost com stamina, gasto/recharge e barra no HUD.
- Camera TPS manteve visao do jogador, mas reduziu muito o foco dinamico na bola.
- Bot adaptado aos novos limites do campo.
- Docs vivos e portfolio atualizados para `JOGO_DA_COPA_ARCADE_ARENA_BOOST_V1_COMPLETE`.

## Validation

- One-time headless editor import: PASS.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, 23/23 tests.
- `git diff --check`: PASS.

Known accepted noise: GUT UID/text-path warnings in fresh worktree imports.

## Handoff

Next manual smoke should focus on:

- Bola solta e quicando em paredes/teto.
- Campo/gol maiores.
- `Shift` boost e leitura da stamina.
- Chute LMB/RMB com lift e rebote.
- Bot atacando/defendendo no campo maior.
