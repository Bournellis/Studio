# FpsShooter - Remove Void From Duel Pit V2

- Data: `2026-06-10`
- Agente: `codex`
- Branch: `codex/fpsshooter/remove-void-from-duel-pit-v2`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--remove-void-from-duel-pit-v2`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `DONE`

## Objetivo

Remover o void/fall pressure do mapa atual `Duel Pit V2`, preservando jump pads, plataformas altas, pickups elevados, bot vertical-aware e knockback. Void/queda ficam reservados para mapas futuros.

## Escopo Pretendido

- Remover zonas de void/fall do layout runtime atual.
- Remover dano/recuperacao/feedback de void do fluxo ativo da arena atual.
- Remover awareness de fall zones do bot no mapa atual.
- Ajustar HUD/feedback apenas se ficar codigo morto ou teste quebrado.
- Atualizar testes e documentacao/status para refletir que `Duel Pit V2` tem verticalidade sem void.
- Validar com `tools/validate.gd`, `git diff --check` e headless curto.

## Fora Do Escopo

- Redesenhar geometria ampla do mapa.
- Remover jump pads, plataformas altas ou pickups elevados.
- Remover knockback.
- Adicionar novos sistemas de armas, reload, ammo, recoil/spread, multiplayer/export/backend.

## Arquivos Pretendidos

- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-03a-vertical-arena-fall-pressure-v1/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`

## Validacao Planejada

- `tools/validate.gd`
- `git diff --check`
- Godot headless curto
- `git status --short`

## Entrega

- `Duel Pit V2` nao cria mais `NorthVoidWell`/`SouthVoidWell`.
- Fluxo ativo da arena nao processa mais fall zones, dano de void, recuperacao segura por queda ou awareness de fall zones para o bot.
- Jump pads, plataformas altas, pickups elevados, bot vertical-aware, plasma, pickups, dodge, salto simples e knockback foram preservados.
- Testes agora cobrem a ausencia dos void wells no mapa atual e removem os contratos de penalty/recovery de void desta baseline.
- Documentacao viva e portfolio foram atualizados para `FPS_SHOOTER_TRACK_03A_VERTICAL_ARENA_NO_VOID_COMPLETE`.

## Validacao

- `tools/validate.gd`: PASS, GUT `33/33`, `279` asserts.
- `git diff --check`: PASS.
- Godot headless curto: PASS.

## Proximo Handoff

Hotfix entregue. Proxima recomendacao: uma etapa de polimento de fluxo/rotas do `Duel Pit V2` sem adicionar armas ou sistemas grandes.
