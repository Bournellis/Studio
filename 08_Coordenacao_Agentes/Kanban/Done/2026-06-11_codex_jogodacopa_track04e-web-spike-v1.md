# Track 04E - Web Export Spike & Render Profile V1

- Data: `2026-06-11`
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Base: `main` local em `72c22d1a`
- Status: `DONE`

## Objetivo

Executar o spike Web do jogo completo com export single-threaded, criar `RenderProfile` central para desktop/web, inventariar divergencias do renderer Compatibility com evidencia desktop vs web e promover o gate permanente de build web + boot smoke + screenshot web.

## Decisoes Travadas

- Web export single-threaded: thread support OFF.
- Sem SharedArrayBuffer.
- Sem headers COOP/COEP.
- Compatibilidade maxima de browsers/hosts.
- Sem fork de gameplay para Web; fallbacks centralizados em perfil de render.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/project.godot`
- `Projetos/JogoDaCopa/autoloads/` ou util central equivalente para `RenderProfile`
- `Projetos/JogoDaCopa/gameplay/`, `modes/`, `presentation/` somente para aplicar perfil visual sem fork de gameplay
- `Projetos/JogoDaCopa/tests/`
- `Projetos/JogoDaCopa/tools/`
- `Projetos/JogoDaCopa/docs/validation.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-04e-web-spike.md`
- `Projetos/JogoDaCopa/docs/screenshots/track-04e-web-spike/`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Review/` no fechamento

## Base Lida

- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/release-plan.md` secao `ROTA FINAL PRE-RELEASE`
- `Projetos/JogoDaCopa/docs/code-review-track04c-04d-v1.md`

## Validacao Planejada

- Import headless inicial da worktree nova: `--headless --editor --quit`.
- Export Web completo para `builds/web/`.
- Servir localmente via HTTP e rodar no Chrome.
- Capturar screenshots padronizados desktop vs web: menu hero, kickoff, gol, resultado.
- Testes unitarios do `RenderProfile`.
- `tools/validate.gd` completo PASS.
- Perf sample desktop padrao windowed `1920x1080`, vsync off.
- `git diff --check`.
- Verificacao de integridade e `WORKTREE_VERIFIED` no fechamento.

## Handoff Point

Parar na branch em Review com handoff completo para review pre-merge da Claude, porque a mudanca de plataforma/render afeta o projeto inteiro.

## Resultado

- `RenderProfile` central criado como autoload, com desktop Forward+ preservado e Web Compatibility single-threaded com fallbacks nomeados.
- Preset Web exporta o jogo completo para `builds/web/` com thread support OFF, extensions OFF, `GODOT_THREADS_ENABLED=false`, sem SharedArrayBuffer e sem COOP/COEP.
- Chrome local boot smoke PASS: canvas 1920x1080, `crossOriginIsolated=false`, `SharedArrayBuffer=false`, sem page errors e sem console errors inesperados.
- Evidencias desktop vs Web: `Projetos/JogoDaCopa/docs/playtest-reports/track-04e-web-spike.md`.
- Validacao: `tools/validate.gd` PASS, 85 tests, 1250 asserts, source integrity 33 `.gd/.gdshader`.
- Perf desktop padrao: average `738.1fps`, min warmed instant `451.3fps`, `0/360` frames abaixo de 60.
- Web rAF sample: average `102.0fps`, p95 `8.1ms`; houve pico isolado de `552.3ms`, sem travar o boot/capturas.
- Gate permanente registrado em `Projetos/JogoDaCopa/AGENTS.md` e `Projetos/JogoDaCopa/docs/validation.md`.

## Review Necessario

- Claude: review pre-merge aprovado em `Projetos/JogoDaCopa/docs/code-review-track04e-web-spike-v1.md` apos Hotfix 04E.1.
- Fabio: paridade visual segue registrada para decisao de polish da Track 04F Web RC.

## Observacoes Iniciais

- `git status --short` em `D:\Estudio` estava limpo antes da worktree.
- Nao havia docs untracked da Claude em main para incluir no commit de registro.
- Operacoes remotas seguem proibidas para agentes; `PUSH PENDENTE` fica com Fabio via GitHub Desktop.

## Fechamento

- Review aprovado pela Claude em 2026-06-11.
- Merge local em main concluido.
- Hotfix 04E.1 integrado: camera de evidencia noturna, gate de luminancia `< 90`, BOM rejection e recapturas desktop/Web.
- Proximo passo operacional: `Track 04F - Web RC`.
