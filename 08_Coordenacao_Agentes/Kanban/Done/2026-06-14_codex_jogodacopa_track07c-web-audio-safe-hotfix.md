# Track 07C - Web Audio Safe Hotfix

- Data: 2026-06-14
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track07c-web-audio-safe-hotfix`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track07c-web-audio-safe-hotfix`
- Base: `main` em `65cf4ced`

## Objetivo

Corrigir a falha remota da Track 07B sem mudar gameplay: manter a protecao Web Audio que evita `AbortError: Unable to load a worklet's module.` e recuperar margem de heap por caminhos Web-safe.

## Hipotese

A Track 07B reabriu o AudioWorklet global e recuperou heap local, mas falhou no menu remoto por `audioWorklet.addModule()`. A proxima correcao deve voltar a bloquear o worklet global no Web publicado e buscar margem em caches/alocacoes de apresentacao que nao dependam do sistema de audio.

## Escopo Pretendido

- `Projetos/JogoDaCopa/tools/publish_web.ps1`
- Arquivos de apresentacao/performance Web estritamente necessarios apos analise
- Evidencias em `Projetos/JogoDaCopa/docs/playtest-reports/track-07c-data/`
- Historico/status local do projeto e coordenacao apos validacao

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`

## Plano De Validacao

1. Import headless do editor na worktree nova.
2. `tools/validate.gd`.
3. `tools/publish_web.ps1 -Mode Plan` e `-Mode Package`.
4. Probes locais: menu 30s, primeiro minuto e estabilidade curta/5min conforme necessidade.
5. Somente se local verde: merge local em `main`, publicar via `tools/publish_web.ps1 ... -ConfirmRemoteMutation` e repetir gates remotos.
6. Se qualquer gate remoto falhar apos publicacao: rollback imediato para `web/v1-copa-arena-futebol-20260613-be453dc3`.

## Handoff

Track concluida e publicada.

Resultados locais:

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `103` testes / `1844` asserts.
- Package local: PASS em `web/v1-copa-arena-futebol-20260614-65cf4ced`.
- Menu local 30s: `pageErrors=0`, `consoleErrorCount=0`, `menu.ready.end` visto, release root conferiu.
- Primeiro minuto local: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade local 5min: PASS, heap retido `44,467,395 -> 48,295,305` bytes (`+8.61%`, limite `<10%`), counters/caches estaveis.

Resultado de merge/publicacao:

- Merge local em `main`: `fa82cb7d`.
- Release publicado: `v1.2.0+fa82cb7d`.
- URL publica: `https://copa-arena-futebol.pages.dev/`.
- Release root: `web/v1-copa-arena-futebol-20260614-fa82cb7d`.
- Publicacao remota via `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260614-fa82cb7d -ConfirmRemoteMutation`.

Gates remotos:

- Menu remoto: PASS operacional, `pageErrors=0`, `consoleErrorCount=0`, `menu.ready.end` visto, release root conferiu, rodape `v1.2.0+fa82cb7d`.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: PASS, heap retido `44,847,036 -> 48,303,228` bytes (`+7.71%`, limite `<10%`), counters/caches estaveis, pior janela 5s `130.2 FPS`.
- Luminancia remota: PASS, `luma_0_255=6.69 < 90`.

Proximo passo: retest humano do Fabio + tester externo na URL publica.
