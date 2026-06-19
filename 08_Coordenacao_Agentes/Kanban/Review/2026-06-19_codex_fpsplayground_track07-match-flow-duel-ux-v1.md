# FpsPlayground - Track 07 Match Flow And Duel UX V1

- Data: `2026-06-19`
- Agente: Codex
- Status: `READY_FOR_HUMAN_SMOKE`
- Branch: `codex/fpsplayground/track07-match-flow-duel-ux-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track07-match-flow-duel-ux-v1`
- Base: `main` em `d6bd2223` (`merge(fpsplayground): plan track07 duel ux`)

## Entrega

- Estado de duelo com rounds, score player/bot, first-to-3 e match over.
- HUD persistente com score, arena/round e resultado.
- `R` avanca round ou inicia novo duelo conforme estado.
- Pause menu ganhou `Novo duelo`.
- Testes cobrem score, duplicate round-end, match reset e clean starts nas tres arenas.

## Validacao

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 34/34, 340 asserts
```

## Handoff

Fabio/tester: fazer smoke humano da Track 07 usando `Projetos/FpsPlayground/docs/validation.md`.

`PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`
