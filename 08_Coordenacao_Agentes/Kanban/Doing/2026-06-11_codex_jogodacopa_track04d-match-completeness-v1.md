# Track 04D - Match Completeness V1

- Data: `2026-06-11`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track04d-match-completeness-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04d-match-completeness-v1`
- Projeto: `Projetos/JogoDaCopa`
- Objetivo: completar o fluxo do modo atual antes do web publish com pause real, resultado rico, transicoes curtas, hero shot do menu e consistencia de ESC/foco/restart.
- Pre-condicao verificada: `main` limpa em `b715f743`, 04B3 marcada como aprovada e mergeada, 04C rodando em worktree paralela `D:\Estudio-worktrees\JogoDaCopa--codex--track04c-stadium-visual-v1`.
- Arquivos pretendidos: `modes/football/football_root.gd`, `modes/menu/main_menu_root.gd`, `presentation/hud/football_hud.gd`, `presentation/camera/**`, `gameplay/football/football_match_rules.gd`, testes proprios e docs/evidencias proprias da track.
- Arquivos proibidos nesta thread: `field_builder/**`, shaders de arena/avatar, `gameplay/avatar/**` e qualquer arquivo da 04C paralela.
- Docs lidos: `Prioridades_Estudio.md`, `Projetos/README.md`, `Estado_Atual.md`, `AGENTS.md` raiz, `Projetos/JogoDaCopa/AGENTS.md`, `implementation/current-status.md`, `docs/release-plan.md`.
- Validacao planejada: import headless inicial da worktree nova, testes GUT/validate, testes de clique real nas resolucoes 1920x1080, 1366x768 e 1280x720, capturas de pause/resultado/hero/fade, `git diff --check`, `git status --short`, doc da track e handoff para review de Claude + aprovacao visual de Fabio.
- Handoff esperado: branch parada em review pre-merge, sem merge em main e com `WORKTREE_VERIFIED`.
