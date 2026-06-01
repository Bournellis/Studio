# DraxosMobile Hardening Doing: integrator - Foundation Hardening V2

## Metadata

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `integrator`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/foundation-hardening-v2`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2`

## Objetivo

Executar Foundation Hardening V2 como pacote de enforcement puro para preparar DraxosMobile para expansao pesada multi-modo e multiagente, com nova Internal Alpha publicada somente se Android release keystore e gates locais/remotos permitirem.

## Latest Context

- current platform baseline: `Hardening Platform V1`
- current release root: `internal-alpha/v0-hardening-platform-v1-20260601-19eb80d`
- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/hardening-platform-v1-readiness-report.md`

## Lanes Registradas

| Lane | Branch | Worktree |
|---|---|---|
| `coord-canon-docs` | `codex/draxos-mobile/foundation-hardening-v2-coord-canon-docs` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-coord-canon-docs` |
| `backend-mode-enforcement` | `codex/draxos-mobile/foundation-hardening-v2-backend-mode-enforcement` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-backend-mode-enforcement` |
| `client-session-enforcement` | `codex/draxos-mobile/foundation-hardening-v2-client-session-enforcement` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-client-session-enforcement` |
| `validation-security-gates` | `codex/draxos-mobile/foundation-hardening-v2-validation-security-gates` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-validation-security-gates` |
| `data-labs-mode-decisions` | `codex/draxos-mobile/foundation-hardening-v2-data-labs-mode-decisions` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-data-labs-mode-decisions` |
| `release-ops-keystore` | `codex/draxos-mobile/foundation-hardening-v2-release-ops-keystore` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-release-ops-keystore` |

## Escopo

- Incluir:
  - canon/live-doc drift enforcement;
  - `/modes` backend modularity and mutating endpoint idempotency;
  - session/client mutation boundaries;
  - strict mode data schemas and decision packs;
  - validation/security gates;
  - read-only ops CLI;
  - backend proprio boundary inventory;
  - Android release keystore gate and release readiness report.
- Fora do escopo:
  - gameplay novo;
  - conteudo jogavel novo;
  - tuning numerico;
  - PVP/social expansion;
  - visual redesign;
  - remote publish before FullLocal and ReleaseDryRun pass.

## Arquivos Pretendidos

- `canon/canon-brief.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/`

## Validation Plan

- `git diff --check`
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`

## Handoff Point

Handoff final deve registrar commits, validações, publicação ou blocker de keystore, release root, worktrees limpas/pendentes e próximos checks humanos.
