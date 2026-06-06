# DraxosMobile - Arena Menu Flow Simplification v1

- Data: `2026-06-06`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/arena-menu-flow-simplification-v1`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--arena-menu-flow-simplification-v1`
- Base: `main` @ `9f162d4`
- Objetivo: simplificar a hierarquia do menu Arena PVE mantendo informacoes/funcoes, corrigindo ordem de apresentacao, CTAs duplicados e posicao de Preparacao/comportamento.

## Escopo Pretendido

- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/docs/arena-pve-season1-loop-v1.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- registros de portfolio/coordenacao apos publicacao, se status observavel mudar

## Docs Lidos

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/arena-pve-season1-loop-v1.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`

## Validacao Planejada

- GUT direcionado em `tests/client/test_boot_mobile_ui.gd`
- `tools/validate.gd`
- `validate_foundation.ps1 -Profile ClientQuick`
- `git diff --check`
- `publish_internal_alpha.ps1` em modos Package/Upload/DeployManifest com release root versionado
- `wrangler pages deploy` para Cloudflare Pages production branch `main`
- `validate_foundation.ps1 -Profile RemoteReadOnly` contra preview publicado

## Handoff

- Proximo ponto seguro: apos presenter/testes verdes, documentar pacote, commit, merge em `main`, exportar/publicar Web/APK e mover este card para Done.
