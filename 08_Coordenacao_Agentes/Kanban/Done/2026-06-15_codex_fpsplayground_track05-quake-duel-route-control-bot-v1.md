# FpsPlayground - Track 05 Quake Duel Route Control Bot V1

- Data: `2026-06-15`
- Agente: `Codex`
- Projeto: `Projetos/FpsPlayground/`
- Branch: `codex/fpsplayground/track05-quake-duel-route-control-bot-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track05-quake-duel-route-control-bot-v1`
- Base: `codex/fpsplayground/track04b-bot-pickup-commitment-v1`
- Status: `DONE`

## Objetivo

Reestruturar a IA do bot para parecer mais com duelo de arena/Quake:

- rota, stack e item control governam a movimentacao;
- tiro acontece sempre que existe alvo valido, mas como overlay de combate;
- strafe/cover deixam de sequestrar a movimentacao geral;
- jump pad longo deve ser completado ate a landing antes de voltar a duelo/strafe.

## Feedback De Entrada

Fabio reportou:

- bot prioriza muito luta em relacao a movimentacao;
- bot nao sabe usar jump pad longo, faz strafe no ar e nao completa a movimentacao;
- bot deve sempre atirar no alvo se existir um, mas movimentacao de mapa, boost e vida devem governar a movimentacao geral;
- vida alta deve focar boost de dano;
- vida baixa deve focar vida;
- bot esta preocupado demais com strafe/cover em vez de mover corretamente pelo mapa.

## Arquivos Pretendidos

- `Projetos/FpsPlayground/docs/bot-route-control.md`
- `Projetos/FpsPlayground/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsPlayground/tests/unit/test_bootstrap.gd`
- `Projetos/FpsPlayground/docs/validation.md`
- `Projetos/FpsPlayground/docs/documentation-index.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-05-quake-duel-route-control-bot-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
.\tools\check_doc_drift.ps1
git status --short
```

## Handoff

Fechar em Review com foco de smoke humano em item control, jump pad longo e combate durante rota.

## Resultado

- Bot agora trata movimento de mapa como camada principal.
- Tiro visivel roda como overlay e nao cancela rotas de item/jump.
- Vida alta passa a favorecer overcharge/boost de dano.
- Vida baixa preserva prioridade de health/reset.
- Jump pad longo recebe compromisso de flight/landing antes de voltar ao strafe.

## Validacao Final

- `tools/validate.gd`: PASS, GUT `28/28`, `229 asserts`.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.

## Fechamento

- Fechado em micro-track documental de 2026-06-20.
- Track aprovada/incorporada ao baseline posterior de bot route-control.
