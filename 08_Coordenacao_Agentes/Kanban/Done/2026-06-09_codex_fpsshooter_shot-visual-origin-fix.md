# FpsShooter Shot Visual Origin Fix - Codex

- Data: `2026-06-09`
- Agente: `Codex`
- Branch: `codex/fpsshooter/shot-visual-origin-fix`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--shot-visual-origin-fix`
- Projeto: `Projetos/FpsShooter/`
- Objetivo: separar a origem visual do muzzle/tracer da origem mecanica do raycast para evitar que o flash do tiro ocupe a tela.

## Arquivos Pretendidos

- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`

## Validacao Planejada

- `res://tools/validate.gd`
- Godot editor headless para warnings GDScript relevantes.
- `git diff --check`

## Handoff

- Implementado deslocamento visual do tiro para muzzle lower-right-forward sem alterar raycast mecanico da camera.
- `res://tools/validate.gd`: passou em `11/11` testes, `99` asserts.
- Godot editor headless filtrado para GDScript: `NO_TARGET_SCRIPT_WARNINGS_FOUND`.
- `git diff --check`: passou.
- Proximo passo: commit e merge em `main`.
