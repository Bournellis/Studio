# Track 04E - Web Export Spike & Render Profile V1

- Data: `2026-06-11`
- Agente: Codex
- Projeto: `Projetos/JogoDaCopa/`
- Branch: `codex/jogodacopa/track04e-web-spike-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track04e`
- Base: `main` local em `72c22d1a`
- Status: `DOING`

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

## Observacoes Iniciais

- `git status --short` em `D:\Estudio` estava limpo antes da worktree.
- Nao havia docs untracked da Claude em main para incluir no commit de registro.
- Operacoes remotas seguem proibidas para agentes; `PUSH PENDENTE` fica com Fabio via GitHub Desktop.
