# Track 04F - Web Performance & Load V1

- Data: `2026-06-11`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track04f-web-performance-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04f`
- Projeto: `Projetos/JogoDaCopa/`

## Objetivo

Reduzir a trava longa ao apertar Play no Web e estabilizar quedas drasticas de FPS durante a partida, sem mudanca estetica intencional. Meta de load local Chrome: Play -> partida jogavel em ate 3s com loading/progresso real visivel. Gate de smoothness: amostra Chrome >= 120s com p99 < 33ms e zero hitch > 100ms apos warmup.

## Escopo Permitido

- Instrumentacao de load/hitches e relatorio baseline/before/after.
- Otimizacoes comprovadas por medicao em carregamento, shaders/VFX, audio, SubViewports, assets e recursos web.
- Ajustes de importacao/compressao/remocao de duplicatas orfas confirmadas.
- Build/export/validate/capturas web noturnas com gate de luminancia.

## Fora De Escopo

- Mudanca estetica intencional.
- Mudancas de gameplay/feel sem relacao medida com performance.
- `push`, `fetch`, `pull` ou `git clean`.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/code-review-track04e-web-spike-v1.md`

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-web-performance.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-04f-web-performance/`
- `Projetos/JogoDaCopa/tools/*`
- `Projetos/JogoDaCopa/modes/football/*`
- `Projetos/JogoDaCopa/gameplay/avatar/*`
- `Projetos/JogoDaCopa/presentation/*`
- `Projetos/JogoDaCopa/assets/*` e imports associados, apenas quando medicao/referencias justificarem
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Handoffs/*`

## Plano De Validacao

- Import headless do editor uma vez antes de julgar runtime.
- Baseline Chrome e desktop por etapa de load.
- Amostra >= 120s Chrome com frame times e top hitches correlacionados com eventos.
- Top 20 recursos do `pck` por tamanho.
- Medicao isolada apos cada otimizacao.
- `validate.gd` completo PASS.
- Export Web release PASS.
- Smoke Chrome local, capturas noturnas e captura F1 da chase camera em gameplay web.
- `git diff --check`, `git status --short`, `WORKTREE_VERIFIED`.

## Fechamento

Claude aprovou o review pre-merge em `Projetos/JogoDaCopa/docs/code-review-track04f-web-performance-v1.md`. A branch foi mergeada localmente em `main` no commit `9366f072`; o residual de primeiro render/upload WebGL foi promovido para `Track 04F.2 - WebGL First-Render Stall`. `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.

## Resultado

- Status: `DONE_LOCAL_MERGED`.
- Review: `Projetos/JogoDaCopa/docs/code-review-track04f-web-performance-v1.md`.
- Merge: `9366f072` (`merge(jogodacopa): track04f web performance`).
- Handoff: `08_Coordenacao_Agentes/Handoffs/2026-06-11_codex_jogodacopa_track04f-web-performance-v1.md`.
- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-04f-web-performance.md`.
- Validate integrado pos-merge: PASS, `86` tests, `1264` asserts, build gzip gate `30.29 MiB / 50.00 MiB`.
- Export Web integrado pos-merge: PASS.
- Smoothness Chrome pos-warmup 120s: PASS, p99 `7.1ms`, max `62.5ms`, zero hitch `>100ms`.
- Residual para review: primeiro render/upload WebGL ainda fica em `~16.8s-18.1s`, mas com loading/progresso visivel.
