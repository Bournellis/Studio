# Handoff - JogoDaCopa Track 04E Web Export Spike & Render Profile V1

- Data: `2026-06-11`
- Agente: Codex
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Status: `REVIEW_PRE_MERGE`

## Objetivo

Executar o spike Web do jogo completo, manter o contrato Web single-threaded decidido por Fabio, criar perfil central de render para desktop/Web e entregar evidencia desktop vs Web para review.

## Resultado

- Web export preset em `builds/web/index.html`.
- Thread support OFF, extensions OFF, no SharedArrayBuffer, no COOP/COEP.
- `RenderProfile` autoload criado para preservar desktop Forward+ e aplicar fallbacks Web Compatibility sem fork de gameplay.
- Fallbacks centralizados para environment, emissivos, fake AO, SubViewports, particulas, audio/browser policy e `user://` Web.
- Runtime emite warnings de fallback conhecido e `push_error` para contrato Web invalido.
- Gate permanente de fechamento Web registrado em `Projetos/JogoDaCopa/AGENTS.md` e `Projetos/JogoDaCopa/docs/validation.md`.

## Evidencia

- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-04e-web-spike.md`
- Screenshots: `Projetos/JogoDaCopa/docs/screenshots/track-04e-web-spike/`
- Chrome local: canvas 1920x1080, `crossOriginIsolated=false`, `SharedArrayBuffer=false`, no page errors, no unexpected console errors.
- Desktop perf: average `738.1fps`, min warmed instant `451.3fps`, `0/360` frames below 60.
- Web rAF sample: average `102.0fps`, p95 `8.1ms`, one isolated max `552.3ms` during headless sampling.

## Validacao

- Import headless inicial da worktree: PASS.
- `tools/validate.gd`: PASS, 85 tests, 1250 asserts, source integrity 33 `.gd/.gdshader`.
- Web export release: PASS, `GODOT_THREADS_ENABLED=false`.
- Chrome smoke/screenshot Web: PASS.
- `git diff --check` e verificacao final serao rodados no fechamento da branch.

## Review Pedido

- Claude: revisar mudanca de plataforma/render antes do merge.
- Fabio: julgar paridade visual desktop vs Web pelas imagens lado a lado.
- Depois do merge local: `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
