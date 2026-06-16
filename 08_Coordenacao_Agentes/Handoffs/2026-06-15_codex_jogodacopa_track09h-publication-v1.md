# Handoff: JogoDaCopa Track 09H Publication V1

- Data: `2026-06-15`
- Agente: `Codex`
- Branch: `codex/jogodacopa/publish-track09h`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09h`
- Status: `CONCLUIDO`

## Objetivo

Publicar/retestar a Track 09H como candidata Web depois do hotfix local de heap, substituindo a baseline publica 09F somente se os gates remotos passarem.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/work-plan.md`

## Validacao Planejada

- Import headless da worktree nova.
- Web export release.
- `tools/validate.gd` com build Web presente.
- `tools/publish_web.ps1 -Mode FullPublish -ConfirmRemoteMutation`.
- Remote menu gate.
- Remote first-minute gate.
- Remote 5-minute stability gate.
- Remote night luma gate.
- Atualizacao de publication readiness, current-status, release history, Estado_Atual/Prioridades se publicado.

## Handoff Point

Se qualquer gate remoto falhar, executar rollback para 09F e registrar bloqueio antes de encerrar.

## Resultado

- Publicacao Cloudflare Pages: PASS.
- Release publicado: `Super Campeao v1.2.1+4a323fab`.
- Release root: `web/v1-copa-arena-futebol-20260615-4a323fab`.
- URL publica: `https://copa-arena-futebol.pages.dev/`.
- Preview: `https://7f8dcde1.copa-arena-futebol.pages.dev`.
- Rollback: nao executado; todos os gates remotos passaram.

## Evidencias

- Publicacao: `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-publication-report-4a323fab.json`.
- Menu remoto: `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-menu-4a323fab.json`.
- Primeiro minuto remoto: `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-first-minute-4a323fab.json`.
- Estabilidade remota 5min: `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-stability-5min-4a323fab.json`.
- Luma remota: `Projetos/JogoDaCopa/docs/playtest-reports/track-09h-data/09h-remote-night-luma-gate-4a323fab.json`.

## Gates

- `tools/validate.gd`: PASS, `104` testes / `1826` asserts.
- Web export: PASS, Web gzip `30.60 MiB / 50.00 MiB`.
- Menu remoto: PASS, release root conferiu, erros `0`.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, erros `0`.
- Estabilidade 5min: PASS, heap `43,664,158 -> 48,016,205` bytes (`+9.97%`, limite `<10%`), counters/caches estaveis, pior janela 5s `129.8 FPS`.
- Luma noturna: PASS, `6.525 < 90`.

## Proximo Passo

Fabio/tester fazer reteste humano da URL publica 09H antes de qualquer nova reducao do `FootballRoot`.
