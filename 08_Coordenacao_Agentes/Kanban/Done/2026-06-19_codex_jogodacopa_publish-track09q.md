# Publish Track 09Q - Football Presentation FX Controller

- Data: 2026-06-19
- Agente: Codex
- Branch: `codex/jogodacopa/publish-track09q`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09q`
- Status: concluido localmente; Cloudflare Pages publicado; gates remotos automatizados PASS; reteste humano pendente.

## Resultado

- Publicado `Super Campeao v1.2.1+bb604c77` no projeto Cloudflare Pages `copa-arena-futebol`.
- URL publica estavel: `https://copa-arena-futebol.pages.dev/`.
- Preview do deploy final: `https://38e6cc7d.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260619-bb604c77`.
- 09P permanece o fallback aprovado mais recente ate Fabio/tester aprovar o reteste humano da 09Q.

## Gates

- Local import headless: PASS.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `60` fontes.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Web package/export: PASS, single-threaded, gzip `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.41%`, peak `+12.61%`, `total_js_heap_growth +7.42%`, `wasmSampleCount=0`, pior janela 5s `116.0 FPS`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-publication.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/09q-package-artifacts-bb604c77.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/09q-publication-report-bb604c77.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/09q-remote-menu-bb604c77.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/09q-remote-first-minute-bb604c77.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/09q-remote-stability-5min-bb604c77.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/09q-remote-night-luma-gate-bb604c77.json`

## Arquivos Atualizados

- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-publication.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09q-data/`

## Handoff

- Proximo passo: Fabio/tester retestar a URL publica.
- Se aprovado: marcar 09Q como baseline publica aprovada.
- Se reprovado: manter ou restaurar 09P como fallback aprovado.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
