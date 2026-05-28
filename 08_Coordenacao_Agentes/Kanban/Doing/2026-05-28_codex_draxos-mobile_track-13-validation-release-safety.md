# Track 13 - DraxosMobile Validation Release Safety

- Data: `2026-05-28`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/track-13-validation-release-safety`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-13-validation-release-safety`
- Base: `codex/draxos-mobile/track-12-boot-decomposition`
- Status: `DOING`

## Objetivo

Transformar validacao, readiness e publicacao Internal Alpha em uma fundacao segura, repetivel e auditavel, sem adicionar feature jogavel e sem publicar nada por padrao.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/tools/check_release_safety.ps1`
- `Projetos/draxos-mobile/tools/check_track13_readiness.ps1`
- `Projetos/draxos-mobile/tools/publish_internal_alpha.ps1`
- `Projetos/draxos-mobile/docs/track-13-manual-walkthrough-gate.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/tools/README.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `AGENTS.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/tools/README.md`

## Plano De Validacao

Baseline antes de alterar:

- `tools/validate.gd`
- GUT client completo
- Deno check dos smokes de release
- `git diff --check`

Validacao final:

- `tools/validate_foundation.ps1 -Profile Full -RequireClean:$false`
- `tools/validate.gd`
- GUT client completo
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `npx -y deno check server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/internal_alpha_remote_smoke.ts`
- parse PowerShell dos scripts de release/foundation
- `git diff --check`

Remote read-only so sera executado com `-IncludeRemoteReadOnly` e env publico presente.

## Proximo Handoff

Mover para `Done` com commits logicos, relatorio de validacao e worktree limpa.
