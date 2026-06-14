# Handoff - JogoDaCopa Track 08 Super Campeao UI Rollback

## Contexto
- Track 08 foi implementada e mergeada localmente em `main` como `2f537628`.
- Escopo entregue localmente: rebrand para `Super Campeao`, novo splash, menu principal limpo, intro da partida sem resumo/troca de avatar e remocao completa do Toon ativo.
- Gameplay nao foi alterado.

## Validacao Local
- Import headless da worktree: PASS.
- `tools/validate.gd`: PASS (`104` testes / `1825` asserts).
- Export Web local: PASS.
- Chrome local: loading/menu/intro/primeiro minuto PASS.
- Evidencias locais: `Projetos/JogoDaCopa/docs/playtest-reports/track-08-data/08-local-*.json|png`.

## Publicacao E Falha
- Publicacao tentada via `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260614-2f537628 -ConfirmRemoteMutation`.
- Sanity menu remoto PASS:
  - `docs/playtest-reports/track-08-data/08-remote-menu-2f537628.json`
  - release root `web/v1-copa-arena-futebol-20260614-2f537628`
  - `pageErrors=0`, `consoleErrorCount=0`
  - rodape visual `Super Campeao v1.2.1+2f537628`
- Primeiro minuto remoto FAIL:
  - `docs/playtest-reports/track-08-data/08-remote-first-minute-2f537628.json`
  - `firstMinuteHitches=1`
  - hitch `dt=333.5ms`
  - `elapsedFromStartMs=11909.82`
  - evento mais proximo: `feedback.play_sfx_3d.begin`, `key=ball_glass`
  - `pageErrors=0`, `consoleErrorCount=0`

## Rollback
- Rollback executado imediatamente via `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260614-fa82cb7d -ConfirmRemoteMutation` em worktree detached de `fa82cb7d`.
- Confirmacao da URL publica:
  - `docs/playtest-reports/track-08-data/08-rollback-confirm-fa82cb7d.json`
  - release root `web/v1-copa-arena-futebol-20260614-fa82cb7d`
  - `pageErrors=0`, `consoleErrorCount=0`
- Resultado publico atual: `https://copa-arena-futebol.pages.dev/` voltou para `v1.2.0+fa82cb7d`.

## Proximo Passo Recomendado
- Abrir hotfix tecnica focada em reproduzir e eliminar o hitch remoto associado a `ball_glass` no primeiro minuto.
- Nao pedir retest humano de `v1.2.1` enquanto os gates remotos nao passarem.
- Ao republicar, repetir menu remoto, primeiro minuto remoto, estabilidade 5min e luma antes de encerrar a track.
