# Track 06F - Web Audio Stability V1

- Data: `2026-06-13`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track06f-web-audio-stability-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track06f-web-audio-stability-v1`
- Status: `REVIEW_READY_LOCAL`

## Objetivo

Desbloquear a investigacao da falha remota da 06E sem alterar gameplay: remover page errors de AudioWorklet/Worklet no Web automatizado e tornar o gate de heap coerente com a regra de heap retido.

## Causa Raiz

A falha da 06E tinha duas partes:

- `GameSettings` foi introduzido depois da baseline publica boa e aplicava `AudioServer`/volumes no `_ready()` do autoload. No Web automatizado isso acontecia antes de qualquer ativacao do navegador, enquanto menu/HUD tambem chamavam a aplicacao de audio via settings. Isso reabriu a familia de erro `AbortError: Unable to load a worklet's module.`
- O probe chamava o gate de heap retido, mas usava o ultimo `performance.memory.usedJSHeapSize` sem forcar coleta. A baseline 05B.1 ja tinha pico acima de 10% e passou porque o Chrome coletou lixo antes do fim; na 06E/06F o ultimo sample podia cair antes da coleta e falhar mesmo com contadores Godot estaveis.

## Mudancas

- `GameSettings` agora carrega e salva volumes, mas no Web so toca `AudioServer` apos ativacao real do usuario.
- Menu principal e HUD nao inicializam buses de audio no Web durante `_ready()`; sliders continuam aplicando volumes por gesto do usuario.
- O primeiro clique de audio do menu aplica os volumes persistidos apos o navegador estar ativado.
- `tools/track04f_chrome_probe.mjs` agora forca `HeapProfiler.collectGarbage` antes do sample final do stability gate e registra uma ultima amostra pos-GC; pode ser desativado com `--final-heap-gc=0` para comparar o comportamento antigo.

## Evidencia

| Gate | Evidencia | Resultado |
| --- | --- | --- |
| Import headless | editor `--headless --editor --quit` | PASS |
| `tools/validate.gd` | console local | PASS, `101` testes / `1735` asserts |
| Export Web release | `builds/web/index.html` | PASS |
| Primeiro minuto local | `docs/playtest-reports/track-06f-data/06f-local-first-minute-web-audio-gate.json` + `.png` | PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0` |
| Stability 5min local, diagnostico pre-GC | `docs/playtest-reports/track-06f-data/06f-local-stability-5min-web-audio-gate.json` + `.png` | `pageErrors=0`, `consoleErrorCount=0`, heap final pre-GC `+15.24%` |
| Stability 5min local, heap retido pos-GC | `docs/playtest-reports/track-06f-data/06f-local-stability-5min-final-gc-web-audio-gate.json` + `.png` | PASS, `pageErrors=0`, `consoleErrorCount=0`, heap retido `45,657,870 -> 49,918,551` (`+9.33%`), counters Godot estaveis, pior janela 5s `129.2 FPS` |

## Conclusao

Localmente, a familia `AbortError` sumiu e o gate de estabilidade passa quando medimos heap retido de fato. A proxima etapa deve ser review de Claude/Fabio, merge local e nova tentativa controlada de publicacao `v1.1.0`, repetindo os gates remotos contra a URL publica.

Nao houve mudanca de gameplay, fisica, bot, camera ou tuning.
