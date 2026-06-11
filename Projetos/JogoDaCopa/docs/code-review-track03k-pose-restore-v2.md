# Code Review - Track 03K Animation Pose Restore V2

- Date: `2026-06-11`
- Reviewer: Claude (Fable 5)
- Scope: commits `92bc67e..38ab21f` (+231/-92). Validacao: 59 tests/733 asserts.
- Incidente de fechamento #5: truncamento pos-fechamento (4 ins/94 del), restaurado no ritual. Padrao inalterado; mitigacao definitiva segue sendo a espera humana + ritual de Claude.

## Causa raiz (mais profunda que o diagnosticado)

O doc da track confirma TRES camadas zerando o quadril: (1) `ROOT_MOTION_BONES` incluia `pelvis`; (2) `_strip_root_motion()` editava keyframes na mao; (3) um lock deferred em RUNTIME continuava zerando X/Z e yaw de root e pelvis a cada troca - este ultimo era o que enterrava o personagem (`pelvis.y = 0.0`). A v2 removeu as tres.

## Verificado

- **Fix por remocao**: zero manipulacao de keyframes restante (sem `_strip_root_motion`, sem `track_set_key_value`, sem locks de runtime). `_remove_root_motion_tracks` deleta a track inteira apenas do bone `root`, iterando DE TRAS PARA FRENTE (`range(count-1, -1, -1)`) - o bug classico de indices deslocados foi evitado.
- **Teste em-pe** (`test_real_avatar_idle_pose_stays_upright_after_one_full_loop`): todos os criterios do prompt - tronco acima do pelvis, pelvis > 0.5, nenhum joint principal abaixo da base (tolerancia -0.05), verticalidade do skeleton dentro de 15 graus. **Falha confirmada antes do fix e registrada com valores** (`pelvis.y = 0.0`; spine/hand abaixo da base) - capturou exatamente o sintoma reportado por Fabio. Teste permanente: deitado/enterrado nunca mais passa.
- **Guarda anti-drift**: `test_real_avatar_strips_root_motion_and_does_not_accumulate_drift` assegura clipes sem tracks de root + estabilidade apos sequencia de acoes.
- **Pelvis e demais bones 100% originais** - vida da animacao restaurada na fonte.
- Bonus de processo: review da 03I commitado e branches mergeadas limpas (pedido no registro da track).

## Verdict

**Aprovado.** -83 linhas liquidas no avatar e a estrategia fragil inteira substituida por uma operacao binaria segura. Juiz final e o playtest de Fabio: personagem em pe, corrida com balanco, chute com peso. Com a pose confirmada, a fila e: Track 03L (arena estanque + vidro do gol, prompt ja entregue) -> playtest de confirmacao geral -> decisao das portas (docs/next-series-options.md) + Track 03J (Quality Gates) quando Fabio quiser.
