# FpsPlayground - Track 04 Arena Movement Flow And Bot Navigation V1

- Data: `2026-06-15`
- Agente: `Codex`
- Projeto: `Projetos/FpsPlayground/`
- Branch: `codex/fpsplayground/track04-arena-movement-flow-bot-navigation-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track04-arena-movement-flow-bot-navigation-v1`
- Status: `DOING`

## Objetivo

Reconstruir o fluxo de movimento das arenas e ajustar o bot para navegar por rotas explicitas, nao por destinos verticais soltos.

O smoke humano da Track 03 indicou que a mira do bot melhorou, mas a movimentacao e o mapa nao estao bons: o bot tenta usar geometria como jump pad, fica preso em tetos/paredes e o `Relay Foundry V1` tem jump pad/plataforma posicionados com feeling ruim.

## Arquivos Pretendidos

- `Projetos/FpsPlayground/docs/work-plan.md`
- `Projetos/FpsPlayground/docs/arena-tactical-layouts.md`
- `Projetos/FpsPlayground/docs/bot-tactical-context.md`
- `Projetos/FpsPlayground/docs/validation.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-04-arena-movement-flow-bot-navigation-v1/current-status.md`
- `Projetos/FpsPlayground/modes/arena/arena_layout_catalog.gd`
- `Projetos/FpsPlayground/modes/arena/*layout_builder.gd`
- `Projetos/FpsPlayground/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsPlayground/tests/unit/test_bootstrap.gd`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsPlayground/AGENTS.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/docs/documentation-index.md`
- `Projetos/FpsPlayground/docs/architecture-overview.md`
- `Projetos/FpsPlayground/docs/work-plan.md`
- `Projetos/FpsPlayground/docs/arena-tactical-layouts.md`
- `Projetos/FpsPlayground/docs/bot-tactical-context.md`
- `Projetos/FpsPlayground/docs/validation.md`
- `Projetos/FpsPlayground/implementation/tracks/track-02-bot-tactical-movement-v1/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-03-arena-tactical-context-proof-v1/current-status.md`

## Plano De Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path Projetos\FpsPlayground -s res://tools/validate.gd
git diff --check
git status --short
.\tools\check_doc_drift.ps1
```

## Proximo Handoff

Track pronta para smoke humano quando:

- validacao local passar;
- docs de smoke forem atualizadas;
- bot nao escolher ponto alto direto a partir do chao quando a rota exige jump pad/rampa;
- `Relay Foundry` tiver fluxo reconstruido com jump pads legiveis e plataformas menos coladas;
- `Duel Pit` permanecer jogavel dentro do novo contrato de movimento.
