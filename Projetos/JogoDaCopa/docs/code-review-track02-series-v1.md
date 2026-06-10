# Code Review - Track 02 Quality Upgrade Series V1 (02A-02G)

- Date: `2026-06-10`
- Reviewer: Claude (Fable 5)
- Branch: `codex/jogodacopa/track02-quality-upgrade-series-v1` (7 commits, 1 por track, ~2.4k linhas)
- Method: revisao estatica do diff `main...branch` + validacao reportada pelo Codex (nao foi possivel rodar Godot headless neste ambiente de review; numeros de validate.gd/perf sao os reportados nos docs de track).

## Summary

Serie grande, disciplinada e com qualidade tecnica acima da media: ambiente noturno ACES/glow/SSAO bem tunado, shaders de pitch/rede/torcida config-driven que eliminam o look "lego", placares de estadio funcionais, bot com predicao correta, juice de camera/particulas, menu com preview 3D, validacao fortalecida (24 tests/198 asserts -> 28/279) e perf medida (144fps avg, 0/360 frames <60). Contratos de feel preservados (fisica da bola intocada). Porem: o coracao da decisao hibrida aprovada - personagem com animacao real - nao foi entregue (rig decorativo), e ha 2 bugs visiveis + 1 problema de perf + 2 cortes silenciosos de escopo.

## Issues

### Major

| # | Arquivo | Issue | Detalhe |
|---|---|---|---|
| H1 | `gameplay/avatar/player_avatar_3d.gd` | **Avatar da 02C e um rig decorativo** | `CopaAssetSkeleton` (8 bones) nao esta ligado a nenhum mesh (sem skinning) e `_create_marker_animation` cria animacoes **sem tracks**. O `AnimationTree` viaja entre clipes vazios; o visual continua 100% o sistema antigo de pivos. Zero ganho visual + processamento morto por frame em 2 avatares. Os testes (`debug_has_asset_skeleton`) validam estrutura, nao comportamento. O doc da track e honesto ("clipes logicos") e declara GLB externo como out-of-scope - mas isso desfaz unilateralmente a decisao central do caminho hibrido aprovado. Causa raiz provavel: agente nao consegue baixar asset do itch/quaternius. **Acao: Fabio baixa manualmente 1 pack CC0 (Quaternius Universal Base Characters ou Kenney Animated Characters 3) para `assets/characters/` e uma track 02C-bis integra com skinning real, mantendo os contratos. Ate la, remover ou desativar o rig morto.** |

### Medium

| # | Arquivo | Issue | Detalhe |
|---|---|---|---|
| M1 | `modes/football/football_root.gd` `_update_stadium_scoreboards` | Placar do estadio hardcoded `"BRA %d - %d FRA"` | Ignora os kits selecionados; `_get_kit_code()` existe no mesmo arquivo e ja alimenta o HUD. Troque para `"%s %d - %d %s"` com os codigos de player/bot. |
| M2 | `presentation/hud/football_hud.gd` `_update_ball_indicator` | Indicador off-screen usa eixos do mundo | `E/D/FRENTE/TRAS` derivam de `ball_relative_x/z` em world-space, assumindo jogador virado para -Z. Com mouse-look o indicador mente. Transformar o vetor relativo para o basis do player (ou da camera) antes de classificar; o snapshot precisa passar o yaw. |
| M3 | `presentation/feedback/fps_feedback_controller.gd` `play_boost_trail`/`play_skid_dust` | Alocacao de `GPUParticles3D` + materiais por chamada | Boost trail roda a cada 0.08s => ~12.5 alocacoes/s de node+ParticleProcessMaterial+SphereMesh+StandardMaterial3D, com setup de pipeline por node novo. Risco de hitch/churn em runs longas. Usar emissor persistente no player ligando/desligando `emitting` (padrao ja aplicado corretamente no `BallSpeedTrail`). Bursts raros (gol/chute) podem continuar como estao. |
| M4 | Track 02D (plano) | Audio CC0 silenciosamente cortado | O plano pedia SFX CC0 (chute, quique, vidro, crowd loop, apito, stinger de gol); o jogo segue 100% tom sintetico via `_spawn_tone`. O doc da 02D nao declara o corte no Out Of Scope. Mesmo bloqueio de download da H1. **Acao: Fabio baixa SFX CC0 (ex. Kenney Audio packs) e uma track curta integra.** |
| M5 | `modes/menu/` + `football_root.gd` | Dificuldade do bot sem UI | 3 dificuldades implementadas e testadas, mas o unico acesso e `debug_set_bot_difficulty()`; menu nao expoe selecao. Jogador real nao consegue trocar. Adicionar seletor no menu (ja existe padrao de seletor de kit) e promover o setter para API nao-debug. |

### Minor / Nits

| # | Arquivo | Issue |
|---|---|---|
| L1 | `football_root.gd` slow-mo | `goal_slowmo_remaining` decrementa com delta ja escalado por `Engine.time_scale` (0.38) => 0.4s viram ~1.05s reais, e o `goal_reset_timer` tambem estica. Se o resultado em playtest for bom, so documentar a intencao; senao dividir delta por `time_scale`. |
| L2 | `football_ball.gd` | Trail liga/desliga em threshold unico (10.5) => flicker na fronteira. Histerese (liga >10.5, desliga <9.0). |
| L3 | `football_ball.gd` | Squash sempre achata o eixo Y local, independente da direcao do impacto. Aceitavel arcade; alinhar ao vetor de velocidade seria upgrade. |
| L4 | `football_root.gd` | `_get_stadium_scoreboard_*` faz `get_node_or_null` com string format 4x/frame em `_process`. Cachear as referencias apos o build. |
| L5 | `football_field_builder.gd` | SubViewports dos placares em `UPDATE_ALWAYS` (512x192 x2). Custo baixo, mas e re-render continuo de UI estatica; aceitavel, registrar como custo conhecido. |
| L6 | Design | Kickoff alterna por gol (como o plano pediu); regra classica de futebol da a saida a quem sofreu o gol. Decidir no playtest. |

## Plan vs Delivered (gaps alem dos issues)

- 02A: entregue completo (sky/ACES/glow/SSAO/fog/spots/sombras). Nota: `msaa_3d=2` ja significava MSAA 4x (enum), entao o item "MSAA 4x" ja estava satisfeito - nenhum erro.
- 02B: entregue completo, inclusive placares funcionais (nomes de nos conferem com o lookup do root) e Label3D nos banners.
- 02C: bola entregue (shader de gomos + trail + squash, fisica intocada); personagem NAO (H1).
- 02D: VFX/camera/countdown/slow-mo entregues; audio nao (M4). Perf medida e reportada.
- 02E: HUD broadcast, indicador (com bug M2), resultado/rematch e menu com preview 3D entregues.
- 02F: predicao/dificuldades/boost/kickoff alternado entregues; sem UI de dificuldade (M5).
- 02G: rename "Copa Arena Futebol", icone/splash autorais, export preset sane (exclui gut/tests/docs/implementation, embed_pck), export smoke reportado PASS. `validate.gd` so ganhou checks (nao foi enfraquecido).

## What Looks Good

- Disciplina de processo exemplar: 1 commit por track, validacao apos cada track com numeros crescentes, doc de track por entrega, card movido para Done com registro, licencas documentadas, sem binario externo nao autorizado, sem hand-edit de `.tscn` gerado, sem logos FIFA.
- Predicao do bot tecnicamente correta: range de chute usa posicao real (nao predita), alvo predito clampado ao campo, defend target clampado.
- `Engine.time_scale` restaurado em todos os caminhos visiveis (`_restart_play`, `_return_to_main_menu`, debug helper) com guard para headless nos testes.
- Input lock do countdown limpo (player/bot/bola), sem vazamento para o fluxo de pause/intro existente.
- Shaders inline competentes (fwidth no grid da rede, SDF box outline nas linhas do campo, hash por celula na torcida) e parametrizados pela config do builder.

## Merge Hygiene (worktree principal)

O worktree principal `D:\Estudio` tem copias NAO-commitadas minhas (plano, card no Backlog, edits de Estado_Atual/work-plan/documentation-index/current-status) que a branch ja incorpora e supersede (plano identico + secao Progress; card identico + registro de execucao, em Done). Antes/apos a merge: descartar essas copias locais e deletar `Kanban/Backlog/2026-06-10_codex_jogodacopa_track02-quality-upgrade-series-v1.md` para nao duplicar com a versao em Done.

## Verdict

**Aprovar com ressalvas.** Mergear a serie (qualidade geral alta, contratos preservados, nada quebra o jogo) e, antes do playtest "para valer", rodar uma track curta de hotfix com M1 + M2 + M3 + M5 (todas pequenas e localizadas). H1 (personagem real) e M4 (audio real) dependem de Fabio baixar os packs CC0 manualmente - agentes nao conseguem passar pelo fluxo de download do itch - e devem virar a track 02C-bis/02D-bis seguinte.
