# Track 01C - Arena Stadium Visual Rework V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_01C_ARENA_STADIUM_VISUAL_REWORK_COMPLETE`
- Branch: `codex/jogodacopa/track01c-arena-stadium-visual-rework-v1`

## Goal

Fechar corretamente a parte superior dos gols e elevar a apresentacao da arena de vidro/estadio para uma leitura mais clara, festiva e inspirada em Copa do Mundo, preservando o feel aprovado de bola, chutes, bot e camera.

## Delivered

- Gols receberam roof glass com colisao, tint visual, frames front/back e ribs laterais, fechando a parte superior da caixa do gol.
- Regra de gol agora respeita a altura do gol para evitar gol fantasma em chute acima da travessa.
- Campo ganhou faixas de grama, circulo central segmentado, linhas de area e spots.
- Arena de vidro ganhou molduras, posts, rails horizontais, corner posts, roof frames e ribs para leitura de parede/teto.
- Estadio ao redor ganhou arquibancadas em camadas, blocos de torcida, banners inspirados em paises, placares decorativos e quatro rigs de luz.
- Testes cobrem roof/collision dos gols, molduras de vidro, arquibancada, banners, placar, luzes e contrato de altura do gol.

## Validation

- `tools/validate.gd`: PASS, 24 tests, 198 asserts.
- `git diff --check`: planned before commit.
- Known noise: GUT UID/text-path warnings after fresh worktree import.

## Out Of Scope

- Assets finais externos.
- Logos oficiais de Copa/FIFA.
- Mudancas em bola, chutes, bot ou camera.
- Novos modos, export, Web/mobile, multiplayer/backend.
