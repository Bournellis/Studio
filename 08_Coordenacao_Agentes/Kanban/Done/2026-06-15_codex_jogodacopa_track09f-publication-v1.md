# Done - JogoDaCopa Track 09F Publication v1

Data: 2026-06-15
Agente: Codex
Branch: `codex/jogodacopa/publish-track09f`
Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09f`
Status: `PUBLICADO_RETEST_PENDENTE`

## Resultado

- `Super Campeao v1.2.1+a75cfe57` publicado em Cloudflare Pages.
- URL publica estavel: `https://copa-arena-futebol.pages.dev/`.
- Preview do deploy: `https://e3c82abc.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260615-a75cfe57`.
- Escopo publicado: rollup cumulativo Track 09B-09F da reducao do `FootballRoot`, mantendo gameplay/input/bot/fisica/scoring/tuning/assets sem mudanca intencional.

## Evidencias

- Publication report: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-publication-report-a75cfe57.json`.
- Remote menu: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-remote-menu-a75cfe57.json`.
- Remote first minute: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-remote-first-minute-a75cfe57.json`.
- Remote stability rerun: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-remote-stability-5min-rerun-a75cfe57.json`.
- Remote luma: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-remote-night-luma-gate-a75cfe57.json`.

## Validacao

- Import Godot headless: PASS apos ciclo normal de reimport da worktree.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `54` fontes verificadas.
- Web export release: PASS.
- Web gzip: `30.59 MiB / 50.00 MiB`.
- Remote menu: PASS, release root conferiu, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: primeira tentativa borderline FAIL por heap retido `+10.26%`; rerun PASS com heap retido `+9.88%`, counters Godot estaveis e pior janela 5s `138 FPS`.
- Remote night luma: PASS, `6.501 < 90`.

## Handoff

- Handoff final: `08_Coordenacao_Agentes/Handoffs/2026-06-15_codex_jogodacopa_track09f-publication-v1.md`.
- Proximo passo: Fabio/tester retestar a URL publica 09F; depois escolher a proxima reducao estreita do `FootballRoot`.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
