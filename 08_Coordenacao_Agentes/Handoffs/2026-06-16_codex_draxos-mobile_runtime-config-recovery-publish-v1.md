# DraxosMobile Publish Handoff: Runtime Config Recovery Retest v1

## Metadata

- from: `Codex`
- to: `Codex | Fabio`
- date: `2026-06-16`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `main`
- worktree: `D:\Estudio`
- objective: merge `codex/draxos-mobile/runtime-config-recovery-ux-v1` and publish a fresh Internal Alpha Web/APK retest package.
- remote mutation/publication: `approved by Fabio in chat; requires -ConfirmRemoteMutation`
- push: `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`

## Contexto

Fabio confirmou que o tester precisa retestar o fix da Arena com pacote publicado. A publicacao deve preservar a restricao de produto: Arena core segue `ARENA_CORE_NOT_PROVEN` e `ARENA_CORE_NEEDS_UX_FIX` ate veredito humano.

## Intended Files

- `Projetos/draxos-mobile/core/project_info.gd`
- `Projetos/draxos-mobile/export_presets.cfg`
- `Projetos/draxos-mobile/tests/client/test_project_info.gd`
- `Projetos/draxos-mobile/server/functions/release/index.ts`
- `Projetos/draxos-mobile/supabase/functions/release/index.ts`
- `Projetos/draxos-mobile/server/tests/release_manifest_smoke.ts`
- `Projetos/draxos-mobile/tools/export_internal_alpha.ps1`
- `Projetos/draxos-mobile/tools/publish_internal_alpha.ps1`
- `Projetos/draxos-mobile/tools/smoke_web_overlay_controls.ps1`
- `Projetos/draxos-mobile/tools/smoke_web_overlay_menu_actions.ps1`
- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/portal/internal-alpha/manifest.example.json`
- `Projetos/draxos-mobile/docs/release-history.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/docs/release-history.md`
- `Projetos/draxos-mobile/tools/README.md`

## Validation Plan

- `git diff --check`
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`
- export internal alpha with `AllowAndroidDebugFallback`
- publish `Upload` and `DeployManifest`/Cloudflare Pages with `-ConfirmRemoteMutation`
- remote manifest/artifact/Web launch smokes after deploy

## Handoff Point

After publication, update this file with release root, preview URL, validation results and final commit hash.
