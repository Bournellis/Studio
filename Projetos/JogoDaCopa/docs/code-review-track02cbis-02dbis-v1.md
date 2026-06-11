# Code Review - Tracks 02C-bis Real Character V1 + 02D-bis Real Audio V1

- Date: `2026-06-10`
- Reviewer: Claude (Fable 5)
- Scope: commits `95805d2..e28b7b3` mergeados em main (390 files, ~17.5k insercoes - maioria assets), revisao pos-merge.
- Validacao reportada: 48 tests/459 asserts; perf `145-146fps avg`, min `107-124fps`, `0/360 < 60` (numeros plausiveis e coerentes com a serie 02, ao contrario dos da serie 03).

## Incidente de fechamento (resolvido)

Apos a merge, o working tree principal ficou com 29 arquivos TRUNCADOS (4.210 linhas perdidas, arquivos cortados no meio de expressoes - shader, bootstrap, root, testes, docs de coordenacao). A main commitada estava integra; restaurei tudo com `git restore --worktree` e validei integridade (fins de arquivo + `git diff --check`). Causa provavel: interrupcao de operacao git em massa durante o fechamento da thread. Recomendacao de processo: todo fechamento deve terminar com `git status --short` E spot-check de integridade (tail de 2-3 arquivos criticos) antes de encerrar; se o working tree estiver sujo apos merge, restaurar antes de sair. Acao para Fabio: fechar e reabrir o Godot (pode ter carregado scripts truncados durante o playtest).

## Summary

As duas tracks entregam o que a 02C original prometeu e nao cumpriu: personagem humanoide REAL (Quaternius UBC, ~13k tris, skeleton de 65 bones) com 45 clipes reais do UAL + 1 chute autorado de verdade (6 bone tracks com arco de chute coerente), state machine cobrindo todas as mecanicas arcade da Track 03 (slide->Roll, stun->Hit_Chest, ombrada->Push, emote->Idle_Talking), contratos de API 100% preservados, e audio real com pooling, buses dedicados (SFX/UI/Ambience), ambience dinamica e sliders no menu. Licencas exemplares: registro por clipe Pixabay com contributor/ID e License Rule atualizada com a decisao de Fabio. 362 arquivos `.import` commitados (import reproduzivel). Um issue visual real no meio disso.

## Issues

### Medium

| # | Arquivo | Issue | Detalhe |
|---|---|---|---|
| M1 | `gameplay/avatar/player_avatar_3d.gd:352-360` `_apply_real_materials` | **Material override descarta as texturas PBR do modelo** | Todos os meshes do corpo recebem `material_override` com `StandardMaterial3D` de cor unica (`shirt_primary.lerp(skin_color, 0.22)`). Isso joga fora BaseColor/Normal/Roughness do pack Quaternius (a razao de usar modelo real) e elimina distincao visual camisa/shorts/meias - o personagem renderiza monocromatico. Os testes de cor (`debug_get_part_albedo_color`) leem o dicionario logico `logical_part_colors`, entao passam enquanto o render diverge - mesmo padrao "teste passa, visual mente" do H1 da 02C original, em escala menor. Fix: duplicar o material PBR original de cada surface e modular `albedo_color` (tint sobre a textura, preservando normal/roughness); distincao por regiao de roupa exigiria texture mask custom - registrar como melhoria futura, tint global de kit e aceitavel agora. |

### Minor / Nits

| # | Arquivo | Issue |
|---|---|---|
| L1 | `ANIMATION_BY_STATE` | Flip aereo usa o clipe `Roll` (mesmo do slide de chao). Funciona, mas pode ler estranho no ar - validar no playtest; alternativa barata: `Jump_Start` re-timed. |
| L2 | `default_bus_layout.tres` + `_ensure_audio_buses()` | Buses definidos em duas fontes (resource + criacao via codigo). Redundancia defensiva inofensiva; escolher uma fonte quando conveniente. |
| L3 | `_apply_real_materials` | Sobrancelha tingida com `shirt_secondary.darkened(0.38)` - sobrancelha da cor do kit e escolha estetica questionavel; trivial de ajustar junto do M1. |

## What Looks Good

- `_build_authorial_kick_animation`: chute autorado REAL - rotacao de spine_02/thigh_r/calf_r/foot_r/upperarms com windup->strike->recover em 0.32s. Exatamente o que foi pedido como unico clipe autoral.
- Integracao UAL->UBC sem retarget gambiarra: as animacoes do GLB sao copiadas para a AnimationLibrary do AnimationPlayer do modelo base; mesmo rig universal => bone paths batem (confirmado por testes de animacao e perf estavel).
- Contratos intactos: `apply_appearance`/`set_move_state`/`play_kick`/`play_celebrate` + hooks novos (`play_slide`/`play_flip`/`play_push`/`play_emote`); `LOGICAL_PARTS` preservado para compat de testes.
- Audio com pooling round-robin (`sfx_pool`/`ui_pool` + cursor), buses SFX/UI/Ambience com send para Master, ambience dinamica e sliders no menu. Nada de alocar player por evento.
- Licencas: Pixabay Clip Registry por arquivo (contributor + source ID + uso), License Rule atualizada (`CC0 | CC-BY com atribuicao | Pixabay Content License`), apito sintetico mantido por design e registrado.
- Perf re-medida com numeros criveis (145-146fps vs os 1.097-1.275fps ficticios da serie 03) - o M2 do review da Track 03 parece corrigido na pratica; confirmar metodologia (janela/resolucao) na proxima medicao.

## Verdict

**Aprovado.** M1 (texturas PBR descartadas) e o unico item que segura o salto visual completo do personagem - recomendo incluir na track de hotfix consolidada `03F` junto com o super-em-whiff (M1 do review da Track 03) e a documentacao da metodologia de perf. Depois do 03F: playtest completo de Fabio decide tuning e o destino do toon toggle.

## Backlog consolidado para a Track 03F (hotfix)

1. Super consumido em whiff (`football_root.gd` - review Track 03, M1).
2. Tint sobre textura PBR no avatar real em vez de material flat (este review, M1; incluir L3 sobrancelha).
3. Metodologia de performance documentada no sampler (janela real, resolucao fixa registrada) - review Track 03, M2.
4. Validar no playtest: latencia do tap no release, stun 0.5s, flip com clipe Roll, toon ON/OFF.
5. Processo de fechamento: checagem de integridade do working tree antes de encerrar thread (incidente desta serie).
