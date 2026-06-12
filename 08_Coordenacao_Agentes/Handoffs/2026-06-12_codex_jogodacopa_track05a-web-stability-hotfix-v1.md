# Handoff - Track 05A Web Stability Hotfix V1

- Projeto: `Projetos/JogoDaCopa/`
- Agente: Codex
- Branch: `codex/jogodacopa/track05a-web-stability-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05a`
- Base local: `main` em `3ec98bbe77af12bc9729565553ae560241bb0e6d`
- Commits: `c5bd4d92` registro da track, `a850045a` hotfix funcional/publicavel
- Status: aguardando review pre-merge da Claude

## Resumo

- Instrumentei o probe Chrome e `jdc_perf_probe.gd` para amostrar estabilidade por 5 minutos.
- Material caches, nodes, recursos, particulas e transients ficaram estaveis; o vazamento retido suspeito nao se confirmou nesses contadores.
- Corrigi o churn continuo do loop quente de partida: HUD snapshot e placares do estadio agora atualizam em cadencia de `0.1s`, com flush imediato em mudancas de estado.
- O HUD evita reatribuir labels/ProgressBar sem mudanca de valor.
- O modo de captura/probe nao tenta pointer lock, removendo `WrongDocumentError` dos smokes.
- O menu mostra `Copa Arena Futebol v1.0.1+a850045a | sem logos oficiais` no pacote publicado.

## Publicacao

- Comando: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-a850045a -ConfirmRemoteMutation`
- URL publica validada: `https://copa-arena-futebol.pages.dev/`
- Release root: `web/v1-copa-arena-futebol-20260612-a850045a`
- Preview gerado: `https://a8305492.copa-arena-futebol.pages.dev`
- Observacao: a primeira checagem na URL publica sem cache-buster ainda retornou o release antigo; com `t=a850045a`, a URL publica serviu o release novo e o smoke remoto oficial passou.

## Validacao

- `node --check Projetos\JogoDaCopa\tools\track04f_chrome_probe.mjs`: PASS
- `validate.gd --profile=full`: PASS, 86/86 testes, 1272 asserts
- Export Web release: PASS
- Smoke Chrome local 5 min: PASS, `track-05a-data/05a-local-stability-gate-5min-pass.json`
- Smoke Chrome remoto 5 min: PASS, `track-05a-data/05a-remote-stability-gate-5min-pass.json`
- Smoke remoto: `pageErrors=0`, `consoleErrorCount=0`, heap retido `+3.77%`, `object_node_count 766 -> 766`, `static_cache_total_entries 144 -> 144`, pior janela 5s `126.0 FPS`

## Review Notes

- O gate de heap usa crescimento retido final apos warmup; o pico de heap fica registrado como diagnostico de GC. Isso evita reprovar sawtooth normal de V8 quando FPS e contadores permanecem estaveis.
- `jdc_perf=1` continua acumulando amostras no harness por desenho; o jogo publicado normal nao ativa esse caminho.
- `publish_web.ps1` gera temporariamente `build/release_info.json` antes do export e remove o arquivo ao final, mantendo a worktree limpa.

## Proximo Passo

- Claude revisar a branch antes de merge.
- Apos aprovacao: merge local, mover card para Done e declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
