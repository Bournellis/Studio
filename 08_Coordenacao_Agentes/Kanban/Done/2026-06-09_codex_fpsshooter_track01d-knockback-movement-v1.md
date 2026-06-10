# FpsShooter - Track 01D Knockback Movement Combat V1

- Data: `2026-06-09`
- Agente: `codex`
- Branch: `codex/fpsshooter/track01d-knockback-movement-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track01d-knockback-movement-v1`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `COMPLETE_LOCAL_PENDING_COMMIT`

## Objetivo

Implementar a Track 01D como um passe focado de knockback e movimento de combate sobre o mapa `Duel Pit V1`, deixando tiros, dano recebido e deslocamento forcado mais legiveis e mais uteis para playtest de duelo FPS.

## Escopo Pretendido

- Ajustar knockback de player e bot para preservar direcao horizontal, lift controlado e leitura visual.
- Melhorar contratos/debug de impulso em `FpsCombatant3D` sem adicionar novas armas, reload, ammo, jump pads, void ou plataformas suspensas.
- Integrar resolucao de tiros da arena com os novos parametros de impulso.
- Reutilizar efeitos runtime existentes para feedback de knockback quando fizer sentido.
- Adicionar cobertura automatizada para impulso, hit/miss e reset.
- Atualizar status local, docs de track e portfolio do estudio ao concluir.

## Arquivos Pretendidos

- `Projetos/FpsShooter/gameplay/combat/combatant_3d.gd`
- `Projetos/FpsShooter/gameplay/player/fps_player_controller.gd`
- `Projetos/FpsShooter/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-01d-knockback-movement-combat-v1/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`
- `AGENTS.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`

## Validacao Planejada

- Rodar bootstrap/import headless se a worktree nova precisar regenerar `.godot`.
- Rodar `Projetos/FpsShooter/tools/validate.gd`.
- Rodar `git diff --check`.
- Rodar editor headless filtrado para warnings GDScript nos scripts tocados.
- Conferir `git status --short`.

## Resultado Local

- One-time editor import headless executado porque a worktree nova ainda nao tinha GUT global classes importadas.
- `tools/validate.gd`: PASS.
- GUT: `20/20` tests, `203` asserts.
- `git diff --check`: PASS.
- Editor headless filtrado para scripts da track: `NO_TARGET_SCRIPT_WARNINGS`.
- Merge final depende da `main` estar limpa; no inicio da tarefa havia conflitos alheios ao FpsShooter em `D:\Estudio`.

## Proximo Handoff

Ao concluir, registrar validacao, commit da branch e tentativa de merge. Se a `main` continuar com conflitos alheios ao FpsShooter, nao resolver manualmente nesta track e reportar bloqueio de merge.
