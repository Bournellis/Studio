# Done: JogoDaCopa Track 09H Publication V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/publish-track09h`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09h`
- Status: `CONCLUIDO`

## Resultado

Publicada a Track 09H como `Super Campeao v1.2.1+4a323fab` em `https://copa-arena-futebol.pages.dev/`, release root `web/v1-copa-arena-futebol-20260615-4a323fab`, preview `https://7f8dcde1.copa-arena-futebol.pages.dev`.

## Validacao

- Import headless: PASS.
- Web export + `tools/validate.gd`: PASS, `104` testes / `1826` asserts, Web gzip `30.60 MiB / 50.00 MiB`.
- Menu remoto: PASS.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`.
- Estabilidade remota 5min: PASS, heap final `+9.97%`, counters/caches estaveis, pior janela 5s `129.8 FPS`.
- Luma remota: PASS, `6.525 < 90`.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-publication-report-4a323fab.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-menu-4a323fab.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-first-minute-4a323fab.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-stability-5min-4a323fab.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-night-luma-gate-4a323fab.json`

## Proximo Passo

Fabio/tester fazer reteste humano da build publica 09H antes de nova reducao do `FootballRoot`.
