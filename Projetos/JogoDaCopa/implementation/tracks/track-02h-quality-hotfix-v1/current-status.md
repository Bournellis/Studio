# Track 02H - Quality Hotfix V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02H_QUALITY_HOTFIX_V1_COMPLETE`
- Branch: `codex/jogodacopa/track02h-quality-hotfix-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track02h-quality-hotfix-v1`

## Goal

Corrigir as ressalvas da revisao da Track 02 antes do playtest humano principal, sem alterar fisica da bola, forcas de chute, boost do player ou regras de gol.

## Delivered

- M1: placares do estadio agora usam `_get_kit_code()` dos kits selecionados de player/bot.
- M2: indicador offscreen da bola agora usa vetor relativo transformado para o basis do player.
- M3: boost trail e skid dust viraram `GPUParticles3D` persistentes no avatar do player, alternando `emitting` sem alocacao por chamada.
- M5: menu principal expoe seletor `easy`/`normal`/`hard`; `FootballRoot.set_bot_difficulty()` virou API nao-debug; dificuldade escolhida permanece na partida e aparece no HUD.
- H1 mitigacao: removido rig decorativo `CopaAssetSkeleton`/`AssetAnimationPlayer`/`AssetAnimationTree`, animacoes vazias, sync morto e testes de debug associados.
- L2: trail da bola recebeu histerese (`on > 10.5`, `off < 9.0`).
- L4: referencias de labels dos placares do estadio agora sao cacheadas apos lookup inicial.
- `docs/asset-licenses.md` atualizado para refletir que nao ha asset/rig humano real comprometido nesta etapa.

## Validation

- One-time headless editor import was run because the first validation stopped before GUT with `GutUtils` not imported.
- `tools/validate.gd`: PASS, 30 tests, 289 asserts.
- `git diff --check`: PASS before validation.
- Known noise: GUT UID/text-path warnings during validation.

## Out Of Scope

- Real skinned character asset integration.
- Real CC0 audio/SFX integration.
- Ball physics, kick forces, player boost tuning and goal rules.
- Web/mobile/multiplayer/backend/economy.

## Next Step

Human editor/debug-export playtest, then Fabio decides whether to manually download CC0 assets for 02C-bis character and 02D-bis audio.
