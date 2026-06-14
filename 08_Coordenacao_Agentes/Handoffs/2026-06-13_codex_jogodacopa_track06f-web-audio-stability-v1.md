# Handoff - JogoDaCopa Track 06F Web Audio Stability V1

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track06f-web-audio-stability-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track06f-web-audio-stability-v1`
- Status: `REVIEW_READY_LOCAL`

## Resumo

06F corrige a investigacao aberta pela 06E sem publicar remoto. A tentativa local removeu os `AbortError`/page errors do Web automatizado ao adiar `AudioServer`/volumes persistidos ate ativacao do navegador e ajustou o probe para medir heap retido pos-GC no sample final.

## Mudancas

- `GameSettings` nao toca `AudioServer` no Web antes de gesto do usuario.
- Menu/HUD deixam aplicacao de volume Web para gesto real.
- Primeiro clique de audio do menu reaplica volumes persistidos apos unlock.
- `track04f_chrome_probe.mjs` coleta GC antes da amostra final do stability gate; `--final-heap-gc=0` preserva comparacao antiga.

## Validacao

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `101` testes / `1735` asserts.
- Export Web release: PASS.
- Primeiro minuto local: `docs/playtest-reports/track-06f-data/06f-local-first-minute-web-audio-gate.json`, PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Stability local pre-GC diagnostico: `docs/playtest-reports/track-06f-data/06f-local-stability-5min-web-audio-gate.json`, sem page errors, mas heap final pre-GC `+15.24%`.
- Stability local pos-GC final: `docs/playtest-reports/track-06f-data/06f-local-stability-5min-final-gc-web-audio-gate.json`, PASS, heap retido `+9.33%`, counters Godot estaveis, pior janela 5s `129.2 FPS`, `pageErrors=0`, `consoleErrorCount=0`.

## Proximo Passo

Review de Claude + aprovacao de Fabio para merge local. Depois do merge, executar nova publicacao controlada `v1.1.0` pela decisao Cloudflare e repetir gates remotos completos contra `https://copa-arena-futebol.pages.dev/`.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
