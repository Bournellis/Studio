# Track 02B - Pitch & Arena Material Pass V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02B_PITCH_ARENA_MATERIAL_PASS_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`

## Goal

Remover a leitura de campo/arena montados por caixas soltas e trocar os pontos mais visiveis por materiais procedurais, preservando tamanho de campo, colisao, gols e feel aprovado.

## Delivered

- Pitch deixou de usar caixas de faixas/linhas e passou a usar um unico `FootballPitch` com `ShaderMaterial`.
- Shader do pitch desenha faixas de grama, ruido sutil, linha central, circulo central, bordas, areas, spots e boca do gol.
- Redes dos gols passaram de painel solido para grid translúcido em shader, mantendo o nó `NorthNetTint`/`SouthNetTint`.
- Blocos de torcida agora usam shader com variacao por celula e oscilacao sutil por `TIME`.
- Banners ganharam `Label3D` com nomes de paises inspiracionais, sem marcas oficiais.
- Scoreboards do estadio ganharam `SubViewport` funcional com placar real `BRA x FRA`, fase da partida e display emissivo no mesh.
- `FootballRoot` atualiza os scoreboards a cada frame junto do HUD.
- Testes cobrem remocao de caixas antigas do pitch, materiais shaderizados, labels de banners e placar funcional.

## Validation

- `tools/validate.gd`: PASS, 24 tests, 230 asserts.
- Known noise: GUT UID/text-path warnings after fresh worktree import, accepted by `docs/validation.md`.

## Out Of Scope

- Authored assets de bola/personagem e licencas (Track 02C).
- VFX/game feel, countdown, slow-mo e audio (Track 02D).
- HUD/menu 2D, bot flow, export ou identidade final.
