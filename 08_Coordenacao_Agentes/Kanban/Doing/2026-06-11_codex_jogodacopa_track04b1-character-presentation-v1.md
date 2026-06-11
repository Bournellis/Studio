# Track 04B1 - Character Presentation & Animation V1

- Data: `2026-06-11`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track04b1-character-presentation-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track04b1-character-presentation-v1`
- Objetivo: entregar personagem com camisa, shorts, pele, cabelo, chuteira e meia em regioes claras; corrigir toon sem corpo duplicado; reautorizar chute com amplitude humana.
- Area permitida desta thread: `Projetos/JogoDaCopa/gameplay/avatar/**`, `Projetos/JogoDaCopa/assets/characters/**` somente leitura, shaders novos de avatar, `Projetos/JogoDaCopa/tests/unit/test_avatar_system.gd`, docs proprios da track.
- Area proibida por paralelismo 04B2: controller/root/HUD/menu e qualquer arquivo fora da area permitida.
- Docs base lidos: `08_Coordenacao_Agentes/Prioridades_Estudio.md`, `AGENTS.md`, `Projetos/README.md`, `08_Coordenacao_Agentes/Estado_Atual.md`, `Projetos/JogoDaCopa/AGENTS.md`, `Projetos/JogoDaCopa/implementation/current-status.md`, `Projetos/JogoDaCopa/docs/release-plan.md`.
- Plano de validacao: import headless inicial da worktree; testes unitarios de avatar; `tools/validate.gd`; `git diff --check`; evidencias visuais com screenshots e playtest-report.
- Proximo handoff: mover para Review/Done conforme ritual local, registrar doc da track e handoff para review de Claude com `WORKTREE_VERIFIED`, sem merge em main e sem `git clean`.
