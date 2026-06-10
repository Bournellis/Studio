# Track 02C-bis - Real Character V1

- Date: `2026-06-10`
- Status: `COMPLETE`
- Marker: `JOGO_DA_COPA_TRACK_02CBIS_REAL_CHARACTER_V1_COMPLETE`

## Goal

Substituir o avatar procedural de caixas por personagem real skinned usando os assets Quaternius UBC/UAL baixados manualmente por Fabio, preservando os contratos publicos do avatar.

## Delivered

- Spike headless PASS para `Superhero_Male_FullBody.gltf`, `Superhero_Female_FullBody.gltf` e `UAL1_Standard.glb`.
- Male e Female carregam com `Skeleton3D` de 65 bones.
- UAL carrega 45 animacoes reais; o runtime copia os clipes para um `AnimationPlayer` local e usa `AnimationTree` state machine.
- Player usa modelo Male; bot usa modelo Female.
- Mapeamento aplicado: `Idle`, `Jog_Fwd`, `Sprint`, `Jump_Start`, `Jump`, `Jump_Land`, `Roll`, `Push`, `Hit_Chest`, `Dance`, `Idle_Talking`.
- Chute autoral curto `JogoDaCopa_Kick` criado em codigo sobre o mesmo rig, afetando torso, bracos e perna direita.
- Contratos preservados: `apply_appearance`, `set_move_state`, `play_kick`, `play_celebrate`.
- Track 03 integrada por clipes reais para slide/flip/stun/ombrada/SUPER/emote.

## Validation

- `tools/real_asset_import_spike.gd` PASS.
- `tools/validate.gd` PASS: 47 tests, 443 asserts.
- Performance sample Windows/Forward+ headless: average `146.1fps`, min warmed instant `107.4fps`, `0/360` frames below 60.

## Notes

- Os nomes importados do UAL vieram sem sufixo `_Loop`; o runtime usa os nomes reais (`Idle`, `Jog_Fwd`, `Sprint`, `Dance`, etc.) mantendo a intencao do mapeamento aprovado.
- Os arquivos `.import` seguem a regra atual do workspace e permanecem ignorados; o import headless/editor gera a cache local antes da execucao.
