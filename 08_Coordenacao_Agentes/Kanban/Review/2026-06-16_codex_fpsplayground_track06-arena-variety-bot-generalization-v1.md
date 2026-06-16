# FpsPlayground - Track 06 Arena Variety And Bot Generalization V1

- Data: `2026-06-16`
- Agente: Codex
- Branch: `codex/fpsplayground/track06-arena-variety-bot-generalization-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track06-arena-variety-bot-generalization-v1`
- Base: `main` em `1b84126c` (`Merge FpsPlayground Track 06 plan sequence`)
- Status: `READY_FOR_HUMAN_SMOKE`

## Objetivo

Executar a Track 06: adicionar uma terceira arena com ritmo distinto e provar que o bot aprovado generaliza via contratos de layout/contexto, sem codigo especifico por mapa.

## Entregue

- `Crossfire Crucible V1` adicionada como terceira arena selecionavel.
- Arena compacta com loop baixo, rota alta diagonal, nucleo central de quebra de sightline, rotas separadas de vida/overcharge e dois jump pads com comprimentos distintos.
- Catalogo, menu, `ArenaRoot` e builder runtime atualizados sem editar `.tscn` manualmente.
- Tactical points publicados para pressure, cover, flank, retreat, health, overcharge, jump pad entry, jump pad landing e high ground.
- Bot preservado sem condicionais por mapa; generalizacao vem dos contratos de layout.
- Testes adicionados para menu, catalogo, runtime da nova arena e contratos de rotas.

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 32/32, 289 asserts
```

Validacoes finais:

```powershell
git diff --check
# PASS
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
# PASS
git status --short
# somente alteracoes da Track 06 antes do commit de docs
```

## Handoff

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.

Smoke humano recomendado:

- abrir as tres arenas pelo menu;
- correr o loop baixo completo da `Crossfire Crucible V1`;
- usar os dois jump pads da nova arena em velocidade natural;
- confirmar que vida e overcharge puxam decisoes de rota diferentes;
- observar o bot rotacionando pelas rotas sem travar, bater parede ou repetir uma unica rota;
- confirmar que o bot continua atirando como overlay de combate sem cancelar o objetivo de movimento.
