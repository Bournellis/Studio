# Handoff - JogoDaCopa Track 06E Release v1.1.0 Rollback

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch mergeada localmente: `codex/jogodacopa/track06e-release-v1-1-0`
- Merge local em `main`: `ea15d5dd`
- Status: `BLOQUEADO_REMOTE_GATE_ROLLBACK_EXECUTADO`

## Resumo

06E foi aprovada no pre-merge, mergeada localmente em `main`, validada e publicada como tentativa `v1.1.0+ea15d5dd`, mas o gate remoto de estabilidade 5min falhou. Conforme a instrucao da release, a URL publica foi revertida imediatamente para a baseline boa `v1.0.3+ef9c5baa`.

## O Que Passou

- Merge local: PASS, commit `ea15d5dd`.
- `tools/validate.gd` pos-merge: PASS, `101` testes / `1735` asserts.
- Publicacao 06E: PASS via `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-ea15d5dd -ConfirmRemoteMutation`.
- Primeiro minuto remoto 06E: PASS, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## O Que Falhou

- Estabilidade remota 5min 06E: FAIL.
- Evidencia: `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-remote-stability-5min-ea15d5dd.json`.
- Numeros: `pageErrors=2`, `consoleErrorCount=0`, `stabilityPassed=false`.
- Excecao: `AbortError: Unable to load a worklet's module.`
- Heap JS/WASM: `44,640,329 -> 53,313,183` bytes, crescimento `19.43%` contra limite `<10%`.
- Counters Godot estaveis: `object_node_count 814 -> 814`, `object_count 3309 -> 3309`, caches estaveis, `render_video_mem_used` estavel.
- FPS 5s: PASS, pior janela `123 FPS`.

## Rollback

- Rollback executado a partir de worktree detached em `ef9c5baa`.
- Comando remoto permitido usado: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-ef9c5baa -ConfirmRemoteMutation`.
- Preview rollback: `https://88e414d3.copa-arena-futebol.pages.dev`.
- URL estavel verificada: `https://copa-arena-futebol.pages.dev/`.
- Evidencia de rollback: `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/06e-rollback-release-root-ef9c5baa.json`.
- Resultado da verificacao: release root `web/v1-copa-arena-futebol-20260612-ef9c5baa`, `pageErrors=0`, `consoleErrorCount=0`.

## Proximo Passo

Investigar a falha remota da 06E antes de qualquer nova publicacao ou retest humano de `v1.1.0`. O retest humano Fabio + tester externo nao deve rodar contra `v1.1.0` ainda; a URL publica voltou para `v1.0.3+ef9c5baa`.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
