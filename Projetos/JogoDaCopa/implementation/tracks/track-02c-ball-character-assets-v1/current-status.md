# Track 02C - Ball & Character Assets V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02C_BALL_CHARACTER_ASSETS_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02-quality-upgrade-series-v1`

## Goal

Substituir os elementos mais prototipais da bola/personagem por assets autorais CC0 ou assets carregaveis pelo Godot, preservando os contratos de avatar e o feel aprovado de bola/chute/boost.

## Delivered

- Spike de import/load executado antes da troca: `res://assets/football/football_ball_panels.gdshader` carregou com sucesso no Godot headless.
- Bola passou a usar shader asset de painéis de futebol, com mais segmentos no mesh.
- Bola ganhou `BallSpeedTrail` via `GPUParticles3D`, ativado automaticamente acima de velocidade alvo.
- Bola ganhou squash visual curto ao receber chute, sem alterar massa, bounce, drag ou limites de velocidade.
- Avatar manteve os 17 parts e os contratos `apply_appearance`, `set_move_state`, `play_kick` e `play_celebrate`.
- Avatar ganhou `CopaAssetSkeleton`, `AssetAnimationPlayer` e `AssetAnimationTree` com clipes lógicos `idle`, `run`, `kick` e `celebrate`.
- Bot usa o mesmo avatar/rig com kit diferente, preservando o fluxo existente.
- Licenças registradas em `docs/asset-licenses.md`; nenhum binario externo foi commitado.
- Fontes externas CC0 verificadas e registradas como candidatas futuras: Kenney Animated Characters 3 e Quaternius Universal Base Characters.

## Validation

- Asset import spike: PASS (`football_ball_panels.gdshader` loaded).
- `tools/validate.gd`: PASS, 24 tests, 240 asserts.
- Known noise: GUT UID/text-path warnings after fresh worktree import, accepted by `docs/validation.md`.

## Out Of Scope

- Substituir o avatar por GLB/FBX externo pesado.
- VFX/game feel, countdown, slow-mo e audio (Track 02D).
- HUD/menu, bot flow, export ou identidade final.
