# Track 06F - Web Audio Stability V1

- Data: `2026-06-13`
- Agente: `Codex`
- Projeto: `Projetos/JogoDaCopa`
- Branch: `codex/jogodacopa/track06f-web-audio-stability-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track06f-web-audio-stability-v1`
- Base: `main` em `f90a97e3`
- Status: `REVIEW_READY_LOCAL`

## Objetivo

Corrigir a falha do gate remoto da 06E sem alterar gameplay: impedir inicializacao/aplicacao prematura de audio no Web antes de ativacao do usuario e corrigir o probe para medir heap retido pos-GC.

## Contexto Lido

- `D:\Estudio\AGENTS.md`
- `D:\Estudio\08_Coordenacao_Agentes\Prioridades_Estudio.md`
- `D:\Estudio\08_Coordenacao_Agentes\Estado_Atual.md`
- `D:\Estudio\Projetos\README.md`
- `D:\Estudio\Projetos\JogoDaCopa\AGENTS.md`
- `D:\Estudio\Projetos\JogoDaCopa\implementation\current-status.md`
- `D:\Estudio\Projetos\JogoDaCopa\docs\documentation-index.md`
- `D:\Estudio\Projetos\JogoDaCopa\docs\architecture-overview.md`
- `D:\Estudio\Projetos\JogoDaCopa\docs\work-plan.md`
- `D:\Estudio\Projetos\JogoDaCopa\docs\release-history.md`
- `D:\Estudio\08_Coordenacao_Agentes\Handoffs\2026-06-13_codex_jogodacopa_track06e-release-v1-1-0-rollback.md`

## Arquivos Alterados

- `Projetos/JogoDaCopa/autoloads/game_settings.gd`
- `Projetos/JogoDaCopa/modes/menu/main_menu_root.gd`
- `Projetos/JogoDaCopa/presentation/hud/football_hud.gd`
- `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06f-web-audio-stability.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-06f-data/`
- `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06f-web-audio-stability-v1.md`

## Validacao

- Import headless do editor na worktree nova: PASS.
- `tools/validate.gd`: PASS, `101` testes / `1735` asserts.
- Export Web release: PASS.
- Primeiro minuto local: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Stability 5min local pos-GC: PASS, heap retido `+9.33%`, counters estaveis, pior janela 5s `129.2 FPS`.

## Handoff

Review de Claude + aprovacao de Fabio antes de merge/publicacao. Nao houve publicacao remota nesta track.
