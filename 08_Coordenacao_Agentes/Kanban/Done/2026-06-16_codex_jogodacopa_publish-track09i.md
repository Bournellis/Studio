# Done: JogoDaCopa Publish Track 09I

- Data: `2026-06-16`
- Agente: `Codex`
- Branch: `codex/jogodacopa/publish-track09i`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09i`
- Status: `CONCLUIDO`

## Resultado

Publicada a Track 09I como `Super Campeao v1.2.1+7995b06c` em `https://copa-arena-futebol.pages.dev/`, release root `web/v1-copa-arena-futebol-20260616-7995b06c`, preview `https://76b6f219.copa-arena-futebol.pages.dev`.

## Validacao

- Import headless: PASS.
- Web export + `tools/validate.gd`: PASS, `104` testes / `1826` asserts, Web gzip `30.60 MiB / 50.00 MiB`.
- Menu remoto: PASS, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: PASS, heap final `+9.30%`, counters/caches estaveis, pior janela 5s `132.6 FPS`.
- Luma remota: PASS, `6.525 < 90`.
- Doc drift: PASS.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09i-publication.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09i-data/09i-publication-report-7995b06c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09i-data/09i-remote-menu-7995b06c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09i-data/09i-remote-first-minute-7995b06c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09i-data/09i-remote-stability-5min-7995b06c.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09i-data/09i-remote-night-luma-gate-7995b06c.json`

## Proximo Passo

Fabio/tester fazer reteste humano da build publica 09I. Depois da aprovacao, abrir Track 09J como reducao local. PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
