# FpsPlayground - Track 05B Long Jump Pad First Try V1

- Data: `2026-06-15`
- Agente: Codex
- Branch: `codex/fpsplayground/track05b-long-jump-pad-first-try-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track05b-long-jump-pad-first-try-v1`
- Base: `main` em `4dbd5320` (`Merge FpsPlayground Track 05 quake duel route control bot`)

## Objetivo

Corrigir o bug observado por Fabio no `Relay Foundry V1`: o bot falha o jump pad longo na primeira tentativa e acerta na segunda. A track deve tornar o primeiro uso confiavel sem voltar a strafe/cover dominante e sem tornar o pad ruim para o player.

## Diagnostico Inicial

- O segundo mapa tem gap de jump pad muito maior que o baseline antigo.
- O launch horizontal atual e fixo para todos os pads.
- O trigger aceita entrada pela borda do pad, mas o vetor de launch e calculado do centro do pad.
- O teste atual valida compromisso pos-launch, mas nao simula aproximacao real, trigger real, voo e landing.

## Arquivos Pretendidos

- `Projetos/FpsPlayground/modes/arena/arena_root.gd`
- `Projetos/FpsPlayground/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsPlayground/tests/unit/test_bootstrap.gd`
- `Projetos/FpsPlayground/tests/unit/test_rule_helpers.gd`
- `Projetos/FpsPlayground/docs/bot-route-control.md`
- `Projetos/FpsPlayground/docs/validation.md`
- `Projetos/FpsPlayground/docs/documentation-index.md`
- `Projetos/FpsPlayground/implementation/current-status.md`
- `Projetos/FpsPlayground/implementation/tracks/track-05b-long-jump-pad-first-try-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`

## Validacao Planejada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
git status --short
```

## Handoff Planejado

Mover para Kanban/Review com status `READY_FOR_HUMAN_SMOKE` quando os testes passarem e a documentacao indicar smoke focado em primeira tentativa do jump pad longo.
