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
- Hotfix 04E.1 aplicado apos review da Claude: capturas lavadas eram bug no caminho de evidencia, nao no environment real. A causa raiz foi a camera de gameplay (`FootballChaseCamera`, FOV 82) usada pela captura, amostrando vidro/teto/fog claro no lugar do ceu noturno.
- Captura de evidencia agora usa `Track04ECaptureCamera` com constantes nomeadas, assert de `WorldEnvironment` e gate de luminancia do ceu `< 90`.
- Source integrity agora rejeita UTF-8 BOM em `.gd`/`.gdshader`; BOM removido dos arquivos afetados, incluindo um extra encontrado pelo gate.

## Evidencia

- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-04e-web-spike.md`
- Screenshots: `Projetos/JogoDaCopa/docs/screenshots/track-04e-web-spike/`
- Chrome local: canvas 1920x1080, `crossOriginIsolated=false`, `SharedArrayBuffer=false`, no page errors, no unexpected console errors.
- Night luma gate: desktop kickoff/goal/result/play `60.2`, `64.0`, `75.8`, `60.2`; Web `10.9`, `29.5`, `6.4`, `10.9`; all below `90`.
- Desktop perf: average `600.2fps`, min warmed instant `374.1fps`, `0/360` frames below 60.
- Web rAF sample: average `142.3fps`, mean `7.03ms`, p95 `7.0ms`, max `13.9ms`, `180` samples.

## Validacao

- Import headless inicial da worktree: PASS.
- Red-first capture gate: FAIL as expected before fix, captured sky luma `180.2` against `< 90`.
- `tools/validate.gd`: PASS, 86 tests, 1264 asserts, source integrity 33 `.gd/.gdshader` with UTF-8 BOM rejection.
- Web export release: PASS, `GODOT_THREADS_ENABLED=false`.
- Chrome smoke/screenshot Web: PASS, final CDP screenshot `1345589` bytes.
- `git diff --check` e verificacao final serao rodados no fechamento da branch.

## Review Pedido

- Claude: revisar mudanca de plataforma/render e Hotfix 04E.1 antes do merge.
- Fabio: julgar paridade visual desktop vs Web pelas imagens lado a lado.
- Depois do merge local: `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
