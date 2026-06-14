# Handoff - JogoDaCopa Track 07B Web Heap Margin Hotfix Rollback

- Data: 2026-06-14
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch da hotfix: `codex/jogodacopa/track07b-web-heap-margin-hotfix`
- Merge local em `main`: `6de8d6b7`
- URL publica: `https://copa-arena-futebol.pages.dev/`

## Resultado

Track 07B foi mergeada localmente e publicada como candidata `v1.2.0+6de8d6b7`, mas falhou no primeiro gate remoto. Rollback remoto foi executado imediatamente para a baseline boa `v1.1.0+be453dc3`.

## Evidencia Da Falha

- Release root tentado: `web/v1-copa-arena-futebol-20260614-6de8d6b7`
- Probe: `Projetos/JogoDaCopa/docs/playtest-reports/track-07b-data/07b-remote-menu-user-url-6de8d6b7.json`
- Screenshot: `Projetos/JogoDaCopa/docs/playtest-reports/track-07b-data/07b-remote-menu-user-url-6de8d6b7.png`
- Gate: menu remoto 30s
- Resultado: FAIL
- `pageErrors=1`
- `consoleErrorCount=0`
- `menu.ready.end` visto
- Release root conferiu
- Erro: `AbortError: Unable to load a worklet's module.`

## Rollback

- Rollback publicado via `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260613-be453dc3 -ConfirmRemoteMutation` a partir de worktree destacada no commit `be453dc3`.
- Evidencia do rollback preservada em `Projetos/JogoDaCopa/docs/playtest-reports/track-07b-data/07b-rollback-publication-report-be453dc3.json`.
- Confirmacao pos-rollback: `https://copa-arena-futebol.pages.dev/index.html` voltou a servir `web/v1-copa-arena-futebol-20260613-be453dc3`.
- Nao houve nova tentativa de primeiro minuto, estabilidade 5min ou luminancia apos a falha do menu, por regra de gate.

## Diagnostico Inicial

A tentativa 07B recuperou margem local de heap (`+5.77%` em 5min local), mas reabrir o AudioWorklet global fez a URL publica voltar a falhar no carregamento de modulo worklet. A proxima correcao deve manter a protecao Web Audio da baseline 06G/Track 07, ou capturar/tratar explicitamente a promessa rejeitada de `audioWorklet.addModule()` sem page error, antes de repetir publicacao.

## Proximo Passo

Abrir nova track cirurgica para Web Audio-safe hotfix. Nao pedir retest humano de `v1.2.0` ainda; a URL publica segue na baseline `v1.1.0+be453dc3`.

## Atencao Operacional

O `main` local contem Track 07 e Track 07B mergeadas, ambas nao publicadas. Nao fazer push do `main` ate decidir se a proxima acao sera nova hotfix em cima do estado local ou revert/squash da serie bloqueada.
