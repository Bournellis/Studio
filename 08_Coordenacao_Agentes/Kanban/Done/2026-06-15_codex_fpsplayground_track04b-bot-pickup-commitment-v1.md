# FpsPlayground - Track 04B Bot Pickup Commitment V1

- Data: `2026-06-15`
- Agente: `Codex`
- Projeto: `Projetos/FpsPlayground/`
- Branch: `codex/fpsplayground/track04b-bot-pickup-commitment-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track04b-bot-pickup-commitment-v1`
- Status: `DONE`

## Objetivo

Corrigir a prioridade local de pickups do bot apos smoke da Track 04.

Fabio aprovou o mapa e reportou que o bot esta melhor, mas as vezes ignora HP/boost mesmo estando do lado.

## Escopo

- Dar prioridade curta e local a HP/boost quando o bot esta perto o suficiente.
- Manter combate justo: o bot nao deve abandonar tudo por boost distante.
- Cobrir HP proximo e boost proximo com testes automatizados.
- Atualizar status da Track 04/04B para smoke humano.

## Arquivos Pretendidos

- `Projetos/FpsPlayground/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsPlayground/tests/unit/test_bootstrap.gd`
- `Projetos/FpsPlayground/docs/validation.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-04-arena-movement-flow-bot-navigation-v1/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-04b-bot-pickup-commitment-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
git status --short
.\tools\check_doc_drift.ps1
```

## Resultado

- Bot agora prioriza HP proximo quando esta danificado, mesmo sem estar critico.
- Bot agora prioriza boost/overcharge proximo mesmo com linha de tiro.
- Rotas de pickup proximo sao mantidas enquanto o item segue util e perto.
- Itens distantes continuam com decisao tatica conservadora.

## Validacao Final

- `tools/validate.gd`: PASS, GUT `25/25`, `211 asserts`.
- `git diff --check`: PASS.
- `tools/check_doc_drift.ps1`: PASS.

## Fechamento

- Fechado em micro-track documental de 2026-06-20.
- Track incorporada ao baseline aprovado posterior de bot route-control e pickups.
