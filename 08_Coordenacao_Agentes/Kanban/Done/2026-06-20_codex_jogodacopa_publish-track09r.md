# Publish Track 09R - Foot And Camera Hotfix

- Data: 2026-06-20
- Agente: Codex
- Branch: `codex/jogodacopa/publish-track09r`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09r`
- Base local: `33ba1a2b` (`merge(jogodacopa): track09r foot camera hotfix`)
- Resultado: publicado no Cloudflare Pages; gates remotos automatizados PASS; reteste humano pendente.

## Escopo

- Publicou `Super Campeao v1.2.1+33ba1a2b`.
- Release root: `web/v1-copa-arena-futebol-20260619-33ba1a2b`.
- URL publica estavel: `https://copa-arena-futebol.pages.dev/`.
- Preview do deploy: `https://8fedfdea.copa-arena-futebol.pages.dev`.
- Preservou a separacao do merge FpsPlayground 14D em andamento na `main`; esta worktree limpa publicou somente o commit 09R ja mergeado.

## Validacao

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `106/106` testes, `1831` asserts, `60` fontes.
- Package/export Web: PASS.
- Web gzip: PASS, `30.61 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Full publish: PASS.
- Remote menu: PASS, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.33%`, peak `+13.68%`, `total_js_heap_growth +8.04%`, `wasmSampleCount=0`, pior janela 5s `136.6 FPS`.
- Remote night luma: PASS, `6.525 < 90`.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.

## Evidencias

- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-09r-publication.md`.
- Evidencias brutas: `Projetos/JogoDaCopa/docs/playtest-reports/track-09r-data/`.
- Package: `09r-package-artifacts-33ba1a2b.json`.
- Publication: `09r-publication-report-33ba1a2b.json`.
- Remote menu: `09r-remote-menu-33ba1a2b.json/png`.
- Remote first minute: `09r-remote-first-minute-33ba1a2b.json/png`.
- Remote stability: `09r-remote-stability-5min-33ba1a2b.json/png`.
- Remote luma: `09r-remote-night-luma-gate-33ba1a2b.json`.

## Handoff

- 09R esta publicada e automatizada verde, mas ainda nao e baseline humano aprovado.
- Fabio/tester deve retestar a URL publica com foco em pe/boot acima do campo, camera lateral A/D, horizonte, fluxo normal de partida, gols, restart, ESC, chute normal, chute carregado e SUPER.
- Ate a aprovacao humana da 09R, 09Q permanece o fallback humano aprovado.
- `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
