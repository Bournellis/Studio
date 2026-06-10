# Multi-Agent Doing: FpsShooter Editor Input Fix

## Metadata

- data: `2026-06-09`
- agente: `Codex`
- projeto: `FpsShooter`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/fpsshooter/editor-input-fix`
- worktree: `D:\Estudio-worktrees\FpsShooter--codex--editor-input-fix`

## Objetivo

Corrigir avisos reportados no editor Godot e melhorar o input de mouse do jogador FPS para o bootstrap ficar testavel no editor.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/validation.md`

## Escopo

- Corrigir `INT_AS_ENUM_WITHOUT_CAST` em `autoloads/app_bootstrap.gd`.
- Corrigir shadowing em `modes/arena/arena_root.gd`.
- Avaliar e corrigir sensacao/captura de mouse em `gameplay/player/fps_player_controller.gd` e arena se necessario.
- Atualizar testes e docs locais se o contrato mudar.

## Validacao

- `git diff --check`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsShooter--codex--editor-input-fix\Projetos\FpsShooter -s res://tools/validate.gd`
- Smoke manual recomendado no editor apos merge.

## Resultado Da Rodada

- `app_bootstrap.gd` usa cast explicito para `Key` e `MouseButton`.
- `arena_root.gd` removeu shadowing do parametro `position`.
- HUD passou a ignorar mouse para nao consumir eventos sobre a tela inteira.
- Player passou a aplicar mouse look por `_input`, com sensibilidade bootstrap maior.
- Validacao headless passou com GUT `5/5`, `44` asserts.
- Importacao headless do editor nao encontrou os warnings reportados: `INT_AS_ENUM_WITHOUT_CAST`, `SHADOWED_VARIABLE_BASE_CLASS`, `app_bootstrap.gd` ou `arena_root.gd:152`.

## Proximo Handoff

Fabio deve abrir `D:\Estudio\Projetos\FpsShooter\project.godot`, pressionar Play e testar captura/look do mouse, WASD, pulo, tiro, dano e reinicio.
