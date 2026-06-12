# Track 05B - First-Minute Smoothness V1

- Data: `2026-06-12`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track05b-first-minute-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05b`
- Projeto: `Projetos/JogoDaCopa/`
- Objetivo: eliminar travadas dos primeiros segundos/minuto e impedir montagem visual/decorativa depois da entrada em campo no Web, mantendo loading local primeira visita `<= 8s`.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/code-review-track05a-web-stability-v1.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04f2-webgl-stall.md`
- `08_Coordenacao_Agentes/Decisoes/2026-06-12_jogodacopa_publicacao-web-cloudflare.md`

## Arquivos Pretendidos

- Probe Web: `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`
- Loading/warmup/runtime: `Projetos/JogoDaCopa/modes/football/*`, `Projetos/JogoDaCopa/presentation/feedback/*`
- Docs/evidencias: `Projetos/JogoDaCopa/docs/playtest-reports/`, `Projetos/JogoDaCopa/docs/release-history.md`, `Projetos/JogoDaCopa/implementation/current-status.md`
- Coordenacao: este card, handoff de review e `08_Coordenacao_Agentes/Estado_Atual.md`

## Validacao Planejada

- Fase 0: probe RED do primeiro minuto com primeiros usos provocados em ordem conhecida e hitches por evento.
- Fase 1: diagnostico por evento sem repetir C8-C11; testar warmup com emissao real dentro do frustum e camera ativa.
- Fase 2: loading so libera campo apos ondas completas, estabilidade visual e warmup VFX/audio bem-sucedido.
- Fase 3: gate novo de primeiro minuto, gate 5min, luminancia, `validate.gd` completo e export Web.
- Fase 4: `publish_web.ps1 FullPublish -ConfirmRemoteMutation`, smoke remoto e release-history.

## Handoff

- Parar na branch para review pre-merge da Claude.
- Fechamento esperado: `git status --short`, `git diff --check`, `WORKTREE_VERIFIED`.
- Rede git proibida; `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Resultado Para Review

- Branch implementada e publicada como `web/v1-copa-arena-futebol-20260612-ad82384b` / `v1.0.2+ad82384b`.
- RED confirmado: primeiro minuto falhava com `18` hitches `>100ms` e max frame `2194.8ms`.
- Final local/remoto: primeiro minuto com todos os primeiros usos provocados PASS, `0` hitches `>100ms`, runtime errors `0`.
- Estabilidade 5min local/remota PASS; luminancia PASS; `validate.gd` full PASS; export Web PASS.
- Residual de decisao: loading local primeira visita ficou em `~13.5s-13.7s`, acima do teto solicitado `<=8s`; remoto ficou `~5.3s`.
- Handoff de review: `08_Coordenacao_Agentes/Handoffs/2026-06-12_codex_jogodacopa_track05b-first-minute-smoothness-v1.md`.
