# Track 01A - Arcade Arena Boost V1

- Last updated: `2026-06-10`
- Branch: `codex/jogodacopa/arcade-arena-boost-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--arcade-arena-boost-v1`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_ARCADE_ARENA_BOOST_V1_COMPLETE`

## Objective

Reverter o feel recente de camera/bola presa e transformar `Futebol 1x1` em uma arena arcade fechada, com bola fisica solta, quique forte, paredes altas, teto, vidro/estadio, campo/gol maiores e boost de velocidade com stamina.

## Delivered

- Removido o dribble/possession lock que empurrava a bola sem chute.
- Mantido assist curto de chute, mas com alcance direto mais estreito e kick assist menos magnetico.
- Bola `RigidBody3D` ficou mais solta: menos damp, mais bounce, velocidades maxima horizontal/vertical maiores e material fisico bouncy.
- Campo aumentado para 38x54, gols maiores e mais profundos.
- Arena fechada com paredes de vidro altas, back glass nos gols, teto com colisao e arquibancadas primitivas ao redor.
- Chutes ficaram mais arcade: LMB mais forte e com lift; RMB mais forte e alto.
- Camera TPS mantida, mas com foco da bola bem mais sutil para devolver leitura ao corpo do jogador.
- Player ganhou boost com `Shift`, stamina, gasto/recharge e HUD com barra de boost.
- Bot agora recebe limites do campo maior para perseguir e atacar dentro da nova arena.
- HUD e intro atualizados com `Shift boost`, estado de bola solta/alcance/contato e stamina.

## Validation

- One-time headless editor import: PASS.
- `tools/validate.gd`: PASS, 23/23 tests.
- Known noise: GUT UID/text-path warnings after fresh worktree import, accepted by `docs/validation.md`.

## Manual Smoke

- Abrir `Projetos/JogoDaCopa/project.godot` no Godot 4.6.2.
- Play -> `Futebol 1x1`.
- Confirmar que a bola nao fica presa no jogador, quica em paredes/teto/goal glass e responde a LMB/RMB.
- Confirmar `Shift` boost, gasto/recharge da barra e aumento de velocidade.
- Confirmar que gols maiores funcionam e que o bot ainda ataca/defende.
