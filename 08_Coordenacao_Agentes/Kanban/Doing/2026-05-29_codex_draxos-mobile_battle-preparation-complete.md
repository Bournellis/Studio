# DraxosMobile - Battle Preparation Complete v1

- Data: 2026-05-29
- Agente coordenador: Codex
- Branch integracao: `codex/draxos-mobile/battle-preparation-complete-integration`
- Worktree integracao: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-complete-integration`
- Branch backend: `codex/draxos-mobile/battle-preparation-complete-backend`
- Worktree backend: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-complete-backend`
- Branch client: `codex/draxos-mobile/battle-preparation-complete-client`
- Worktree client: `D:\Estudio-worktrees\draxos-mobile--codex--battle-preparation-complete-client`

## Objetivo

Implementar Preparacao de Batalha Completa v1 como editor real de loadout antes da batalha: instrumento ritual, spells equipadas, doutrina, familiar, pocao e comportamento basico, com publicacao Internal Alpha apos validacao.

## Arquivos Previstos

- Backend/contratos: `server/functions/build/index.ts`, `supabase/functions/build/index.ts`, `docs/contracts/api-endpoints.md`, `docs/contracts/database-schema.md`, testes server.
- Cliente: `online/supabase_client.gd`, `modes/boot/flows/surface_action_flow.gd`, `modes/boot/ui/app_shell_action_contract.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`, `tests/client/`.
- Status/docs/release: `docs/battle-preparation-complete-v1.md`, `implementation/current-status.md`, `docs/documentation-index.md`, `../README.md`, `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`, `../../08_Coordenacao_Agentes/Estado_Atual.md`, release artifacts.

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Validacao Planejada

- Deno check/tests para `server/functions` e `supabase/functions`.
- GUT `tests/client`.
- `tools/validate.gd`.
- `tools/smoke_foundation_loop.gd`.
- `tools/smoke_foundation_surfaces.gd` quando ambiente permitir.
- `tools/smoke_responsive_layout.gd`.
- `validate_foundation.ps1 -Profile Client`.
- `git diff --check`.
- Export/package/upload Internal Alpha com release root versionado e verificacao Web/APK/ZIP.

## Handoff

Integrar backend e client em `battle-preparation-complete-integration`, validar, atualizar status/docs, mover este card para Done e publicar se os gates locais passarem.
