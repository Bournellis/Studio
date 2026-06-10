# Track 02A - Render & Lighting Foundation V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02A_RENDER_LIGHTING_FOUNDATION_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`

## Goal

Transformar a imagem global do modo `Futebol` com fundacao de render/luz noturna, sem alterar geometria jogavel, feel de bola/chute/boost ou regras.

## Delivered

- `WorldEnvironment` trocado de cor flat para sky procedural noturno com gradiente e cobertura procedural de estrelas.
- Tonemap `ACES`, bloom/glow, SSAO leve e fog sutil de profundidade configurados por constantes de custo.
- Luz principal fria com sombra direcional, distancia/fade/bias tunados para a arena.
- Quatro rigs de estadio agora usam `SpotLight3D` quentes apontados para o campo, sem sombras para controlar custo.
- Materiais runtime ganharam suporte a metallic, rim e clearcoat.
- Vidros da arena/gol ganharam material com rim/clearcoat e emissao leve.
- Frames de vidro, ribs, traves e barras dos refletores ganharam emissao para alimentar o bloom.
- `project.godot` explicita MSAA 4x (`msaa_3d=2` no enum do Godot) e qualidade de sombras.
- Testes estruturais cobrem environment, key light, spotlights, emissao de frame e material de vidro.

## Validation

- One-time headless editor import: PASS after fresh worktree GUT import.
- `tools/validate.gd`: PASS, 24 tests, 219 asserts.
- Known noise: GUT UID/text-path warnings after fresh worktree import, accepted by `docs/validation.md`.

## Performance

- Command: renderer sample via Godot normal Windows display, Forward+, 120 warmup frames + 360 measured frames.
- Hardware reported by Godot: `NVIDIA GeForce RTX 4070 Ti`.
- Result: average `143.9fps`, minimum warmed instant `63.6fps`, `0/360` measured frames below 60fps.

## Out Of Scope

- Pitch shader/line replacement, crowd shader and functional scoreboards (Track 02B).
- Ball/character authored assets (Track 02C).
- VFX/game feel, countdown, slow-mo and audio pass (Track 02D).
- HUD/menu, bot flow, export or product identity.
