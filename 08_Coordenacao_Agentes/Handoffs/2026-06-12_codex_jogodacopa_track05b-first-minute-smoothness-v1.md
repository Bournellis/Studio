# Handoff - JogoDaCopa Track 05B First-Minute Smoothness V1

Data: 2026-06-12  
Autor: Codex  
Branch: `codex/jogodacopa/track05b-first-minute-v1`  
Worktree: `D:\Estudio-worktrees\jogodacopa-track05b`  
Status: aguardando review pre-merge da Claude

## Pedido

Executar Track 05B apos retest humano da v1.0.1: a oscilacao ciclica foi resolvida pela 05A, mas restavam travadas nos primeiros segundos e montagem visivel de decorativos/sombras ja dentro da partida.

## Commits Principais

- `89287b74` - registro inicial da track no Kanban.
- `71c82724` - probe RED de primeiro minuto e sequencia deterministica.
- `bca086eb` - warmup/loading completo e smoothness de primeiro minuto.
- `1e829185` - bloqueio do caminho Web de `AudioStreamPlayer3D` / `PositionWorklet`.
- `ad82384b` - versao visivel Web ajustada para `v1.0.2`.
- Commit final de docs/evidencias/handoff: conferir `git log --oneline` apos o fechamento.

## Resultado

- Publicado em Cloudflare Pages como `web/v1-copa-arena-futebol-20260612-ad82384b` (`v1.0.2+ad82384b`).
- URL publica validada: `https://copa-arena-futebol.pages.dev/`.
- Preview Cloudflare: `https://09ed848a.copa-arena-futebol.pages.dev`.
- RED mensuravel confirmado: `05b-red-sequence-corrected.json` falhou com `18` hitches `>100ms`, max frame `2194.8ms`.
- Final remoto: primeiro minuto PASS com `0` hitches `>100ms`, estabilidade 5min PASS, runtime errors `0`.
- Final local: primeiro minuto PASS com `0` hitches `>100ms`, estabilidade 5min PASS, runtime errors `0`.

## Mudancas Relevantes

- `tools/track04f_chrome_probe.mjs`: gate de primeiro minuto, hitches por evento, flags `jdc_perf_detail`/`jdc_perf_stability`.
- `modes/football/football_root.gd`: overlay so sai depois do warmup completo, warmup de primeiro uso dentro do frustum e settle de frames.
- `presentation/feedback/fps_feedback_controller.gd`: caminho Web corta feedback transiente de VFX/audio e nao cria `AudioStreamPlayer3D`.
- `presentation/hud/football_hud.gd`: simplificacoes Web de animacoes/pulsos.
- `gameplay/football/football_ball.gd`: marcadores de primeiro uso do fireball.

## Evidencias

- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b-first-minute-smoothness.md`.
- RED: `Projetos/JogoDaCopa/docs/playtest-reports/track-05b-data/05b-red-first-minute-baseline.json`, `05b-red-sequence-corrected.json`, `05b-diagnostic-first-minute-baseline.json`.
- Local final: `05b-local-first-minute-gate-pass19.json`, `05b-local-stability-5min-pass3.json`.
- Remoto final: `05b-remote-first-minute-gate.json`, `05b-remote-stability-5min.json`.
- Publicacao: `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05c-publication-report.json`.

## Validacao Executada

- Headless editor import 1x: PASS.
- Luminancia via `tools/capture_track04e_web_spike.gd`: PASS, kickoff/play `58.8`, goal `63.2`, result `75.4`, teto `90`.
- `tools/validate.gd --profile=full`: PASS, 86/86 testes, 1272 asserts, Web gzip `30.32 MiB / 50.00 MiB`.
- Export Web release: PASS.
- Chrome local first-minute gate: PASS, `0` hitches `>100ms`.
- Chrome local stability 5min: PASS.
- `publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-ad82384b -ConfirmRemoteMutation`: PASS.
- Chrome remoto first-minute gate: PASS, release root conferiu, runtime errors `0`.
- Chrome remoto stability 5min: PASS, release root conferiu, runtime errors `0`.

## Pontos Para Review

- O objetivo de nao montar nada visivel depois da entrada foi cumprido nos probes, mas o loading local primeira visita ficou em `~13.5s-13.7s`, acima do teto solicitado `<=8s`; remoto ficou `~5.3s`.
- A smoothness Web foi obtida desativando feedback transiente de VFX/audio nessa superficie. Se Fabio quiser recuperar esses efeitos, recomendo follow-up com budget por efeito e o mesmo gate de primeiro minuto.
- `RenderProfile` ainda emite warnings documentais no console; runtime errors ficaram em `0`.

## Proximo Passo

- Claude revisar a branch antes de merge.
- Se aprovar: merge local, mover card para Done e declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
- Git remoto nao usado por Codex; sem push/fetch/pull.
