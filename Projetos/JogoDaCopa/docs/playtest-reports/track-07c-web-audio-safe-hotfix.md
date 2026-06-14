# Track 07C - Web Audio Safe Hotfix

Data: 2026-06-14

## Objetivo

Corrigir a regressao remota da Track 07B, que publicou o pacote com `AudioWorklet` global reabilitado e falhou no menu publico com `AbortError: Unable to load a worklet's module.`.

Escopo cirurgico:

- Manter zero mudanca de gameplay.
- Restaurar o bloqueio global do `AudioWorklet` no pacote Web publicado.
- Preservar o fallback tolerante para o position worklet.
- Recuperar margem de heap Web adiando o carregamento dos streams reais de audio ate a ativacao do audio pelo usuario.

## Mudancas

- `tools/publish_web.ps1`
  - `Write-WebAudioWorkletFallback` volta a trocar `_godot_audio_has_worklet()` para `return 0`.
  - O position worklet continua protegido por `.catch(...)` e `audioPositionWorkletAvailable`.
  - Evidencias da publicacao passam para `docs/playtest-reports/track-07c-data/`.
- `presentation/feedback/fps_feedback_controller.gd`
  - No Web, `_ready()` nao carrega os streams reais de audio.
  - `feedback.web_audio_streams_deferred` registra que os streams ficaram aguardando ativacao do navegador.
  - O carregamento real acontece de forma lazy depois de `_can_play_web_audio(...)` permitir audio.
  - Desktop continua carregando streams e pools no caminho anterior.

## Gates Locais

| Gate | Resultado |
| --- | --- |
| Import headless editor | PASS |
| `tools/validate.gd` | PASS, `103` testes / `1844` asserts |
| `publish_web.ps1 -Mode Plan` | PASS |
| `publish_web.ps1 -Mode Package -ReleaseRoot web/v1-copa-arena-futebol-20260614-65cf4ced` | PASS |
| Verificacao do pacote | PASS, `_godot_audio_has_worklet(){return 0}` e position worklet fallback presentes |
| Menu Web local 30s | PASS operacional: `pageErrors=0`, `consoleErrorCount=0`, `menu.ready.end` visto, release root conferiu |
| Primeiro minuto Web local | PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`, release root conferiu |
| Estabilidade Web local 5min | PASS, heap retido `44,467,395 -> 48,295,305` bytes (`+8.61%`, limite `<10%`), counters/caches estaveis, pior janela 5s `141.2 FPS` |

Nota: o JSON do sanity de menu sem `--first-minute-gate` ou `--stability-gate` ainda marca a agregacao interna `passed=false` porque esses gates formais estavam desligados. Os criterios usados para publicar - erros zerados, estagio esperado e release root - passaram.

## Evidencias

- `docs/playtest-reports/track-07c-data/07c-package-artifacts.json`
- `docs/playtest-reports/track-07c-data/07c-publication-report.json`
- `docs/playtest-reports/track-07c-data/07c-local-menu-audio-safe.json`
- `docs/playtest-reports/track-07c-data/07c-local-menu-audio-safe.png`
- `docs/playtest-reports/track-07c-data/07c-local-first-minute.json`
- `docs/playtest-reports/track-07c-data/07c-local-first-minute.png`
- `docs/playtest-reports/track-07c-data/07c-local-stability-5min.json`
- `docs/playtest-reports/track-07c-data/07c-local-stability-5min.png`
- `docs/playtest-reports/track-07c-data/07c-remote-menu-user-url-fa82cb7d.json`
- `docs/playtest-reports/track-07c-data/07c-remote-menu-user-url-fa82cb7d.png`
- `docs/playtest-reports/track-07c-data/07c-remote-first-minute-fa82cb7d.json`
- `docs/playtest-reports/track-07c-data/07c-remote-first-minute-fa82cb7d.png`
- `docs/playtest-reports/track-07c-data/07c-remote-stability-5min-fa82cb7d.json`
- `docs/playtest-reports/track-07c-data/07c-remote-stability-5min-fa82cb7d.png`
- `docs/playtest-reports/track-07c-data/07c-remote-night-evidence-fa82cb7d.png`
- `docs/playtest-reports/track-07c-data/07c-remote-night-luma-gate-fa82cb7d.json`

## Observacao De Audio Web

O probe local de estabilidade registrou:

- `feedback.web_audio_streams_deferred waiting_for_browser_user_activation=true`
- `feedback.audio_load.end ... streams=0`
- `feedback.audio_pools.end ... sfx_pool=0 ui_pool=0`
- `feedback.web_audio_locked waiting_for_browser_user_activation=true`

Isso confirma que o caminho Web sem interacao do usuario nao aloca os 12 streams reais no boot, preservando o contrato de audio travado ate input do navegador.

## Proximo Passo

Merge local em `main` concluido como `fa82cb7d`.

Publicacao remota concluida por `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260614-fa82cb7d -ConfirmRemoteMutation`.

## Gates Remotos

| Gate | Resultado |
| --- | --- |
| Menu Web remoto 30s | PASS operacional: `pageErrors=0`, `consoleErrorCount=0`, `menu.ready.end` visto, release root conferiu, rodape `v1.2.0+fa82cb7d` |
| Primeiro minuto Web remoto | PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`, release root conferiu |
| Estabilidade Web remota 5min | PASS, heap retido `44,847,036 -> 48,303,228` bytes (`+7.71%`, limite `<10%`), counters/caches estaveis, pior janela 5s `130.2 FPS` |
| Luminancia noturna remota | PASS, `luma_0_255=6.69 < 90` |

## Handoff

Proximo passo: retest humano do Fabio + tester externo na URL publica `https://copa-arena-futebol.pages.dev/`, cobrindo menu broadcast, ESC completo, HUD scorebug, primeiro minuto e sensacao geral do visual polish `v1.2.0`.
