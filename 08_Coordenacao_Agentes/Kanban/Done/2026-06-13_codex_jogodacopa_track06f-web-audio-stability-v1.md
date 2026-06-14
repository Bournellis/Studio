# Track 06F - Web Audio Stability V1

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/JogoDaCopa/track06f-web-audio-stability-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track06f-web-audio-stability-v1`
- Base: `main` em `f90a97e3`
- Merge em main: `22850c06`
- Status: `DONE_PUBLICADO_RETEST_HUMANO_PENDENTE`

## Objetivo

Corrigir a falha do gate remoto da 06E sem alterar gameplay: impedir inicializacao/aplicacao prematura de audio no Web antes de ativacao do usuario e corrigir o probe para medir heap retido pos-GC.

## Resultado

- 06F aprovada por Claude/Fabio e mergeada em `main`.
- `v1.1.0+22850c06` publicado em `https://copa-arena-futebol.pages.dev/`.
- Release root: `web/v1-copa-arena-futebol-20260613-22850c06`.
- Preview Cloudflare: `https://6e95ff95.copa-arena-futebol.pages.dev`.
- Rodape publico confirmado visualmente como `Copa Arena Futebol v1.1.0+22850c06 | sem logos oficiais`.

## Validacao

- `tools/validate.gd` pos-merge: PASS, `101` testes / `1735` asserts.
- `tools/publish_web.ps1 -Mode Plan`: PASS.
- `tools/publish_web.ps1 -Mode Package -ReleaseRoot web/v1-copa-arena-futebol-20260613-22850c06`: PASS.
- `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-22850c06 -ConfirmRemoteMutation`: PASS.
- Primeiro minuto remoto: `06f-remote-first-minute-22850c06.json`, PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Estabilidade remoto 5min: `06f-remote-stability-5min-22850c06.json`, PASS, heap retido `+1.14%`, nodes/caches estaveis, pior janela 5s `105.2 FPS`.
- Luminancia remota: `06f-remote-night-luma-gate-22850c06.json`, PASS, `10.3 < 90`.

## Proximo Passo

Retest humano do Fabio + tester externo na URL publica `v1.1.0`, cobrindo menu broadcast, ESC completo, HUD scorebug e primeiro minuto de partida.

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin
