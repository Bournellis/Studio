# Multi-Agent Doing: DraxosMobile Hardening Validation Release

## Metadata

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/hardening-validation-release`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-validation-release`

## Objetivo

Expandir a fundacao de validacao/release do DraxosMobile para cobrir perfis operacionais granulares, drift de baseline, mirrors/registry, budgets, termos legados, secrets, dry-run de release e relatorios locais sem publicar remoto.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/`
- `Projetos/draxos-mobile/implementation/tracks/track-14-agent-ops-foundation/`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/`
- `Projetos/draxos-mobile/implementation/tracks/track-18-pve-arena-initial/`

## Escopo

- Incluir: perfis novos em `validate_foundation.ps1`, checks read-only locais, relatorio JSON/Markdown ampliado, docs/runbooks do runner.
- Fora do escopo: publicar remoto, deploy Supabase/Cloudflare, mudar schema/backend/client gameplay, tuning, economia, PVP, social expandido ou assets.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/tools/README.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/validation-matrix.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-01_codex_draxos-mobile_hardening-validation-release.md`

## Plano De Commit

- `coordination: register hardening validation release lane`
- `validation: expand foundation validation profiles`
- `docs: update validation release runbooks`

## Validacao

- `git diff --check`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`
- `git status --short`

## Proximo Handoff

Handoff para o integrador apos commits locais e relatorio das validacoes; publicacao remota continua bloqueada para o integrador apos merge.
