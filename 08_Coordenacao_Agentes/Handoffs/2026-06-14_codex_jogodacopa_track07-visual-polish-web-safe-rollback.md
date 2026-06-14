# Handoff - JogoDaCopa Track 07 Visual Polish Web-Safe Rollback

- Data: `2026-06-14`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branches locais: `codex/jogodacopa/track07-visual-polish-web-safe`, `codex/jogodacopa/track07a-web-audio-worklet-hotfix`
- Merge local em `main`: `138cf4f7`
- Status: `BLOQUEADO_REMOTE_GATE_ROLLBACK_EXECUTADO`

## Resumo

Track 07 foi implementada, validada, mergeada localmente em `main` e publicada como tentativa `v1.2.0+138cf4f7`, mas o gate remoto de estabilidade 5min falhou por heap JS/WASM retido acima do limite. Conforme a regra de release, a URL publica foi revertida imediatamente para a baseline boa `v1.1.0+be453dc3`.

## O Que Passou

- Merge local final: PASS, commit `138cf4f7`.
- `tools/validate.gd` pos-merge: PASS, `103` testes / `1844` asserts.
- Pacote Web: PASS, release root `web/v1-copa-arena-futebol-20260614-138cf4f7`, PCK Brotli `20,706,600` bytes, WASM Brotli `6,608,968` bytes, zip `27,447,942` bytes.
- Publicacao tentativa: PASS via `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260614-138cf4f7 -ConfirmRemoteMutation`.
- Preview tentativa: `https://09258c86.copa-arena-futebol.pages.dev`.
- Menu remoto URL publica: PASS, root `web/v1-copa-arena-futebol-20260614-138cf4f7`, `pageErrors=0`, `consoleErrorCount=0`.
- Primeiro minuto remoto: PASS, root conferiu, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Checks estaveis no gate 5min: counters Godot, caches, `render_video_mem_used` e FPS 5s (`120.8 FPS` pior janela) passaram.

## O Que Falhou

- Estabilidade remota 5min: FAIL.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-07-data/07-remote-stability-5min-138cf4f7.json`.
- Numeros: `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=false`.
- Heap JS/WASM retido: `44,636,600 -> 49,252,604` bytes, crescimento `10.34%` contra limite `<10%`.
- Pico de heap: `52,517,169` bytes, `+17.65%`.
- Counters Godot estaveis: `object_node_count 817 -> 817`, `object_count 3327 -> 3327`, caches estaveis, `render_video_mem_used 242,157,894 -> 242,157,894`.

## Rollback

- Rollback executado a partir de worktree detached em `be453dc3`.
- Comando remoto permitido usado: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-be453dc3 -ConfirmRemoteMutation`.
- Preview rollback: `https://46eaf36e.copa-arena-futebol.pages.dev`.
- URL estavel verificada por HTML: `https://copa-arena-futebol.pages.dev/` voltou a declarar `web/v1-copa-arena-futebol-20260613-be453dc3`.
- Evidencia compacta de rollback: `Projetos/JogoDaCopa/docs/playtest-reports/track-07-data/07-rollback-release-root-be453dc3.json`.

## Proximo Passo

Investigar e reduzir o heap retido da Track 07 antes de qualquer nova publicacao `v1.2.0` ou retest humano nessa versao. Hipoteses iniciais: comparar o delta visual contra `be453dc3`, medir se o patch de Web Audio altera baseline de heap, e repetir gate curto/5min somente apos uma reducao clara.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
