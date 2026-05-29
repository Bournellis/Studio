# Preparacao de Batalha v1

- Data: `2026-05-29`
- Projeto: `Projetos/draxos-mobile`
- Agente coordenador: Codex
- Branch integracao: `codex/draxos-mobile/battle-preparation-v1-integration`
- Worktree integracao: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-v1-integration`
- Branch UX: `codex/draxos-mobile/battle-preparation-v1-ux`
- Worktree UX: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-v1-ux`
- Branch comportamento: `codex/draxos-mobile/battle-preparation-v1-behavior`
- Worktree comportamento: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-v1-behavior`
- Base: `master` em `84ff844`
- Status: `DOING`

## Objetivo

Implementar Preparacao de Batalha v1 como pacote client-first sobre o comportamento ja existente do Track 16, deixando claro o que o jogador leva para a luta, quando pocao/spells entram e por que a preparacao importa, sem backend, endpoint, schema, migration, simulador, tuning, armas, spells ou economia novos.

## Arquivos Previstos

- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/flows/surface_action_flow.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/docs/battle-preparation-v1.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Validacao Planejada

- GUT `tests/client`
- `tools/smoke_foundation_loop.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_responsive_layout.gd`
- `tools/validate.gd`
- `validate_foundation.ps1 -Profile Client`
- `git diff --check`
- Export/package/upload/deploy Internal Alpha com release root versionado
- Verificacao HTTP de Web preview, `index.pck`, APK e ZIP

## Handoff

Merge esperado: UX -> comportamento -> integracao -> `master`. Fechar com docs/status atualizados, card movido para Done, worktrees limpas e publicacao Internal Alpha validada.
