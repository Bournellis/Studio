# Handoff: JogoDaCopa Track 09G Publication V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/publish-track09g`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09g`
- Status: `PUBLICACAO_BLOQUEADA_ROLLBACK_EXECUTADO`

## Resumo

A Track 09G foi publicada como candidata, mas nao ficou publica. Menu remoto e primeiro minuto passaram sem erros, porem o gate remoto de estabilidade 5min falhou duas vezes apenas em crescimento de JS/WASM heap. Executei rollback para a baseline aprovada 09F e confirmei o URL estavel novamente em `web/v1-copa-arena-futebol-20260615-a75cfe57`.

## Evidencias Chave

- Candidato: `docs/playtest-reports/track-09g-data/09g-publication-report-d1784ff9.json`
- Menu remoto PASS: `docs/playtest-reports/track-09g-data/09g-remote-menu-d1784ff9.json`
- Primeiro minuto PASS: `docs/playtest-reports/track-09g-data/09g-remote-first-minute-d1784ff9.json`
- Estabilidade FAIL: `docs/playtest-reports/track-09g-data/09g-remote-stability-5min-d1784ff9.json`
- Estabilidade rerun FAIL: `docs/playtest-reports/track-09g-data/09g-remote-stability-5min-rerun-d1784ff9.json`
- Rollback report: `docs/playtest-reports/track-09g-data/09g-rollback-publication-report-a75cfe57.json`
- Rollback confirm: `docs/playtest-reports/track-09g-data/09g-rollback-confirm-a75cfe57.json`

## Numeros Do Bloqueio

- Primeiro gate 5min: heap `43,906,213 -> 50,677,795` bytes, `+15.42%`, pico `+20.23%`.
- Rerun 5min: heap `43,998,789 -> 50,751,663` bytes, `+15.35%`, pico `+19.80%`.
- Nos dois gates: `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`, counters/caches Godot estaveis e pior janela 5s `129.8 FPS`.

## Proximo Passo Recomendado

Abrir track tecnica de investigacao/hotfix de heap remoto da 09G antes de qualquer nova reducao ou republicacao. Nao tratar 09G como baseline publica.
