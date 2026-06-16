# FpsPlayground - Track 05B Long Jump Pad First Try V1

- Data: `2026-06-15`
- Agente: Codex
- Status: `READY_FOR_HUMAN_SMOKE`
- Branch: `codex/fpsplayground/track05b-long-jump-pad-first-try-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track05b-long-jump-pad-first-try-v1`
- Base: `main` em `4dbd5320` (`Merge FpsPlayground Track 05 quake duel route control bot`)

## Objetivo

Corrigir o bug observado por Fabio no `Relay Foundry V1`: o bot falhava o jump pad longo na primeira tentativa e acertava na segunda. A track torna o primeiro uso confiavel sem voltar a strafe/cover dominante e sem tornar o pad ruim para o player.

## Entregue

- Launch do jump pad calculado por posicao real do ator no trigger e distancia da rota.
- Velocidade horizontal derivada da geometria da rota, com clamp para manter pads curtos controlados.
- Approach lock do bot perto do pad para nao cortar a entrada com strafe/dodge local.
- Air steer reduzido durante voo comprometido de jump pad.
- Testes cobrindo launch por distancia e primeira tentativa do jump pad longo no `Relay Foundry V1`.
- Documentacao de validacao/smoke atualizada para Track 05B.

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 30/30, 238 asserts
```

```powershell
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
git status --short
```

## Review Humano

- Em `Relay Foundry V1`, observar o bot entrando no jump pad longo pela primeira vez.
- Confirmar que ele alcanca o landing sem cair/resetar/tentar de novo.
- Confirmar que o player ainda usa os pads sem overlaunch ou snap estranho.
- Confirmar que tiro em overlay continua funcionando sem cancelar rota.

## Handoff

- PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
