# Track 05B.1 - Sensory Feedback Re-Introduction V1

- Data: `2026-06-12`
- Branch: `codex/jogodacopa/track05b1-sensory-feedback-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05b1`
- Objetivo: devolver ao Web os efeitos sensoriais cortados na 05B sem reabrir hitches `>100ms` no primeiro minuto.

## Contexto

A Track 05B publicou `v1.0.2+ad82384b` com primeiro minuto e estabilidade PASS, mas cortou feedback transiente Web para eliminar hitches de primeiro uso e erros `PositionWorklet`. Fabio aprovou este follow-up para reintroduzir os efeitos um por vez.

Metodo aplicado:

- Iteracao curta por efeito com gate de `60s` de partida real, provocando a sequencia `apito -> gol/confetti -> chute -> countdown -> jump pad -> result/rematch`.
- Web permanece sem `AudioStreamPlayer3D`; apito/SFX transientes usam audio 2D e streams pre-aquecidos no loading.
- Warmup de primeiro uso roda dentro do frustum atras do overlay opaco, incluindo caminhos reais de gol/confetti e jump pad.
- Gates longos ficaram somente para validacao final.

## Implementacao

- `fps_feedback_controller.gd`: reintroduz efeitos Web-safe para `whistle`, `confetti`, `kick`, `countdown`, `jump_pad` e `result`; audio transiente Web usa players 2D nos buses `SFX`/`UI`.
- `football_root.gd`: filtro `jdc_web_feedback` para ligar/desligar efeitos no probe, warmup real atras do overlay e sequencia de primeiro minuto por efeito.
- `track04f_chrome_probe.mjs`: aceita `--web-feedback`, registra stages novos e mede hitches por janela de evento com pre-window de `250ms`.
- `publish_web.ps1`: versao publica atualizada para `v1.0.3`.

## Diagnostico Por Efeito

| Ordem | Efeito | Evidencia curta | Custo maximo medido | Status |
| --- | --- | --- | ---: | --- |
| 1 | APITO | `track-05b1-data/05b1-local-short-01-whistle-pass.json` | `14.0ms` | Reativado |
| 2 | CONFETTI de gol | `track-05b1-data/05b1-local-short-02-whistle-confetti-pass3.json` | `20.9ms` | Reativado |
| 3 | VFX/audio de chute | `track-05b1-data/05b1-local-short-03-kick.json` | `55.6ms` | Reativado |
| 4 | Countdown tick | `track-05b1-data/05b1-local-short-04-countdown.json` | `13.9ms` no evento, max run `48.7ms` | Reativado |
| 5 | Jump pad | `track-05b1-data/05b1-local-short-05-jump-pad-pass2.json` | `14.0ms` | Reativado apos warmup do caminho real |
| 6 | Result/rematch | `track-05b1-data/05b1-local-short-06-result.json` | result `14.0ms`, rematch `7.1ms`, max run `41.7ms` | Reativado |

Falhas uteis durante a iteracao:

| Tentativa | Resultado | Diagnostico | Correcao |
| --- | --- | --- | --- |
| `05b1-local-short-02-whistle-confetti.json` | FAIL, `1889.3ms` | Confetti estava acoplado ao pacote Web pesado de gol (`goal` flash/jingle/crowd). | Manter pacote `goal` desativado no default Web e reativar somente confetti de gol. |
| `05b1-local-short-05-jump-pad.json` | FAIL, `694.6ms` | Warmup isolado do VFX passava, mas o caminho real de jump pad movendo jogador/camera ainda tinha primeiro uso. | Adicionar warmup do jogador no pad real com camera ativa atras do overlay. |

Observacao: o pacote Web pesado de `goal` (flash + jingle + crowd boost) continua fora do default publico; o requisito desta track era `CONFETTI de gol`, que voltou.

## Gates Locais

| Gate | Evidencia | Resultado |
| --- | --- | --- |
| Primeiro minuto final local | `track-05b1-data/05b1-local-final-first-minute.json` | PASS, `0` hitches `>100ms`, runtime errors `0`, max frame `55.6ms` |
| Estabilidade local 5min | `track-05b1-data/05b1-local-final-stability-5min.json` | PASS, 338 browser samples, 328 Godot samples, runtime errors `0`, max frame `48.6ms` |
| Luminancia | `tools/capture_track04e_web_spike.gd` | PASS: kickoff/play `58.8`, goal `63.2`, result `75.4`, teto `90` |
| Validate full | `tools/validate.gd` | PASS, 86/86 testes, 1272 asserts, Web gzip `30.32 MiB / 50.00 MiB` |
| Export Web | `--export-release "Web" "builds/web/index.html"` | PASS |

Loading local primeira visita medido:

- Primeiro minuto final local: `17.81s`.
- Estabilidade local 5min: `18.32s`.

Esse custo aumentou em relacao a 05B por causa do warmup real dos efeitos reintroduzidos. A suavidade do primeiro minuto foi preservada.

## Publicacao

Pendente ate o commit local da implementacao: publicar `v1.0.3` via:

```powershell
.\tools\publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-<shortsha> -ConfirmRemoteMutation
```

Depois da publicacao, completar este relatorio com o release root final e smokes remotos.
