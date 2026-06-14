# DraxosMobile Hardening Doing: coord-docs - docs-state-governance

## Metadata

- data: `2026-06-14`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `coord-docs`
- mode_scope: `none`
- branch: `codex/draxos-mobile/hardening-docs-state`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-docs-state`

## Objetivo

Corrigir a governanca de estado operacional para que pacote atual, release root,
URLs e version codes vivam apenas em `implementation/current-status.md` e
`docs/release-history.md`, mantendo `DocsOnly` alinhado com essa regra.

## Latest Context

- Current published package: ver `Projetos/draxos-mobile/implementation/current-status.md`.
- Current local implemented stage: pacote publicado preservado como baseline.
- Preserved Arena context: `Arena PVE remains the first approved core; see docs below`.
- Open decision: `none for expansion; hardening/docs only`.
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `AGENTS.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/hardening-program.md`
- `Projetos/draxos-mobile/docs/foundation-hardening-v2-readiness-report.md`

## Escopo

- Incluir:
  - `validate_foundation.ps1` DocsOnly drift guard.
  - docs vivos que duplicam estado operacional atual.
  - contratos/runbooks citados pelo pedido quando declararem pacote atual.
- Fora do escopo:
  - runtime fora da lane;
  - worktrees de outros agentes;
  - remote mutation/publicacao;
  - push/fetch/pull;
  - tuning, economia, PVP, conteudo novo ou expansao Openworld.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/README.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/product-vision.md`
- `Projetos/draxos-mobile/docs/product-brief.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/hardening-program.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/docs/contracts/update-manifest.md`
- `Projetos/draxos-mobile/implementation/current-status.md`, se necessario.

## Validation Plan

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_doc_drift.ps1`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`

## Validation Result

- `git diff --check`: PASS
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_doc_drift.ps1`: PASS
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -Profile DocsOnly -NoProjectWrites`: PASS

## Remote Mutation / Publication

- remote mutation/publication run: `no`
- if yes, evidence: `n/a`
- if no, preserved boundary: `no deploy, no Supabase/Cloudflare mutation, no export/publication`

## Handoff Point

Commit local pronto para handoff depois dos checks essenciais. Declarar arquivos
alterados, validacoes, commit SHA e `PUSH PENDENTE: Fabio - GitHub Desktop -
Push origin`.
