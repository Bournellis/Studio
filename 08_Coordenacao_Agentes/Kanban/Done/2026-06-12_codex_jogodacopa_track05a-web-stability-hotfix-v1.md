# Track 05A - Web Stability Hotfix V1

- Projeto: `Projetos/JogoDaCopa/`
- Agente: Codex
- Branch: `codex/jogodacopa/track05a-web-stability-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track05a`
- Base local: `main` em `3ec98bbe77af12bc9729565553ae560241bb0e6d`
- Prioridade: urgente, hotfix de producao Web
- Objetivo: reproduzir os ciclos de travamento continuo no Web publicado/local, instrumentar memoria por pelo menos 5 minutos de partida continua, documentar causa raiz antes do fix, corrigir o vazamento confirmado, adicionar gate permanente de estabilidade Web e republicar o hotfix autorizado.
- Escopo previsto:
  - `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`
  - `Projetos/JogoDaCopa/**/jdc_perf_probe.gd`
  - arquivos de gameplay/VFX/audio/material cache relacionados a causa raiz confirmada
  - `Projetos/JogoDaCopa/tools/validate.gd` e testes se necessario
  - `Projetos/JogoDaCopa/docs/playtest-reports/track-05a-web-stability.md`
  - `Projetos/JogoDaCopa/docs/release-history.md`
  - `Projetos/JogoDaCopa/implementation/current-status.md`
  - `08_Coordenacao_Agentes/Estado_Atual.md`
- Docs base lidos:
  - `08_Coordenacao_Agentes/Prioridades_Estudio.md`
  - `AGENTS.md`
  - `Projetos/README.md`
  - `08_Coordenacao_Agentes/Estado_Atual.md`
  - `Projetos/JogoDaCopa/AGENTS.md`
  - `Projetos/JogoDaCopa/implementation/current-status.md`
- Validacao planejada:
  - import headless do editor 1x na worktree nova
  - baseline Web local/remote com probe de 5 minutos antes do fix
  - causa raiz escrita no relatorio antes da correcao
  - `validate.gd` completo PASS
  - export Web release PASS
  - smoke Chrome local com gate de estabilidade de 5 minutos PASS
  - publish Web com `tools/publish_web.ps1 FullPublish -ConfirmRemoteMutation`
  - smoke remoto em `https://copa-arena-futebol.pages.dev/` com gate de estabilidade de 5 minutos PASS
  - `git diff --check`, `git status --short`, `WORKTREE_VERIFIED`
- Handoff: parar na branch limpa para review pre-merge da Claude; declarar `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
- Observacao inicial: main local estava limpo antes da worktree; nenhum doc untracked de Claude apareceu em `git status --short` no momento da abertura.

## Resultado Para Review

- Hotfix local commitado em `a850045a`: instrumentacao de estabilidade, causa raiz documentada, throttling de HUD/placares, gate Chrome 5 min e rodape `v1.0.1+hash`.
- Publicado em Cloudflare Pages com release root `web/v1-copa-arena-futebol-20260612-a850045a`; URL publica validada com cache-buster em `https://copa-arena-futebol.pages.dev/`.
- Validacao: `validate.gd --profile=full` PASS (86/86), export Web PASS, smoke local 5 min PASS, smoke remoto 5 min PASS.
- Evidencia principal: `Projetos/JogoDaCopa/docs/playtest-reports/track-05a-web-stability.md`, `track-05a-data/05a-local-stability-gate-5min-pass.json`, `track-05a-data/05a-remote-stability-gate-5min-pass.json`.
- Handoff: revisar antes de merge; `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Closeout

- Review Claude: aprovado em `Projetos/JogoDaCopa/docs/code-review-track05a-web-stability-v1.md`.
- Merge local em `main`: `ea1f0df0`.
- Validacao integrada pos-merge: `tools/validate.gd --profile=full` PASS, 86 testes, 1272 asserts.
- Proximo passo: retest humano da `v1.0.1+a850045a` publica nas maquinas do relato; se ainda oscilar, abrir `Track 05B` com o plano B do review.
- `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.
