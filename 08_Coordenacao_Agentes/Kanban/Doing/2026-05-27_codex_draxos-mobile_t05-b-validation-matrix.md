# T05-B - DraxosMobile Validation Matrix

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t05-validation-matrix`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-validation-matrix`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Transformar a validacao atual do DraxosMobile em fundacao reproduzivel para Track 05, formalizando matriz `quick`, `full`, `release` e `remote` e adicionando smokes pequenos apenas se a cobertura existente nao proteger Base, Shop, Social e Competition de forma direta.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-05-27_codex_draxos-mobile_t05-coordenacao.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md`
- `Projetos/draxos-mobile/tools/README.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/validation-matrix.md`
- `Projetos/draxos-mobile/tools/`
- Este registro Doing.

## Validacao Planejada

- `tools/validate.gd`
- GUT client completo
- Smokes novos T05-B, se criados
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `git diff --check`

## Proximo Handoff

Entregar matriz executavel, justificativa de cobertura para Base/Shop/Social/Competition e commit final para integracao futura em T05-H.

## Resultado

- Matriz `quick/full/release/remote` criada em `validation-matrix.md`.
- Smoke focado `tools/smoke_foundation_surfaces.gd` adicionado para Base, Shop, Social e Competition usando fluxos existentes.
- `tools/validate.gd` passou a verificar o recurso do novo smoke.
- Validado com `tools/validate.gd`, GUT client, `smoke_foundation_surfaces.gd`, `smoke_session_shell.gd`, `smoke_battle_replay.gd` e `git diff --check`.
