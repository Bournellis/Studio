# Handoff - JogoDaCopa Track 09F Publication v1

Data: 2026-06-15
Agente: Codex
Branch: `codex/jogodacopa/publish-track09f`
Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09f`
Status: `PUBLICADO_RETEST_PENDENTE`

## Objetivo

Publicar a baseline cumulativa Track 09F de `JogoDaCopa` no Cloudflare Pages e registrar evidencias locais/remotas para o release publico `v1.2.1+a75cfe57`.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-09-footballroot-reduction/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-15_codex_jogodacopa_track09f-publication-v1.md`
- `08_Coordenacao_Agentes/Kanban/Done/2026-06-15_codex_jogodacopa_track09f-publication-v1.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/*`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `AGENTS.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `Projetos/JogoDaCopa/tools/publish_web.ps1`
- Documentacao oficial Cloudflare Pages/Wrangler para direct upload.

## Plano De Validacao

- Import headless Godot.
- `tools/validate.gd`.
- Export Web release.
- `tools/validate.gd` com build Web e gate gzip.
- `tools/publish_web.ps1 -Mode FullPublish ... -ConfirmRemoteMutation`.
- Gate remoto menu.
- Gate remoto first minute.
- Gate remoto estabilidade 5 minutos.
- Gate remoto luma noturna.
- `tools/check_doc_drift.ps1`.
- `git diff --check`.

## Proximo Handoff

## Resultado

- Publicacao Cloudflare Pages concluida para `Super Campeao v1.2.1+a75cfe57`.
- URL publica estavel: `https://copa-arena-futebol.pages.dev/`.
- Preview do deploy: `https://e3c82abc.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260615-a75cfe57`.
- Publication evidence: `Projetos/JogoDaCopa/docs/playtest-reports/track-09f-data/09f-publication-report-a75cfe57.json`.

## Validacao Executada

- Import headless Godot: PASS apos ciclo normal de reimport da worktree.
- `tools/validate.gd`: PASS, `104` testes, `1826` asserts, `54` fontes.
- Export Web release: PASS.
- `tools/validate.gd` com build Web: PASS, gzip `30.59 MiB / 50.00 MiB`.
- Remote menu: PASS, `09f-remote-menu-a75cfe57.json`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `09f-remote-first-minute-a75cfe57.json`.
- Remote stability 5min: primeira tentativa borderline FAIL por heap `+10.26%`; rerun PASS por heap `+9.88%`, counters/FPS PASS, `09f-remote-stability-5min-rerun-a75cfe57.json`.
- Remote night luma: PASS, `6.501 < 90`, `09f-remote-night-luma-gate-a75cfe57.json`.

## Estado Atual

- `Estado_Atual.md` e `Prioridades_Estudio.md` atualizados para `JOGO_DA_COPA_TRACK09F_PUBLICADO_RETEST_PENDENTE`.
- Proximo passo: Fabio/tester retestar a URL publica 09F; depois escolher a proxima reducao estreita do `FootballRoot`.
- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
