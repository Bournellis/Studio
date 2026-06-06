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

- Status: implementacao local concluida e commits preparados.
- Entregue:
  - fluxo de selecao reordenado como progresso S1 -> desafio recomendado -> Preparacao -> outras arenas;
  - CTA recomendado unico `Iniciar desafio recomendado`;
  - remocao do botao duplicado `Iniciar proximo desta arena`;
  - tentativa ativa/recuperacao antes de comportamento;
  - `Resolver duelo`/`Escolher buff` antes de `Carregar comportamento`;
  - escolha de buff antes de comportamento;
  - APK/manifest atualizado para `0.0.5-alpha.0` / version code `5`;
  - doc vivo `docs/arena-pve-menu-flow-simplification-v1.md`.
- Validacao local:
  - GUT client suite: PASS, 236 tests / 3741 asserts, com warnings conhecidos de teardown orphan/ObjectDB.
  - `npx -y deno task --cwd server/functions check`: PASS.
  - `npx -y deno task --cwd supabase/functions check`: PASS.
  - `deno test --allow-read --allow-run --allow-env server/tests/ops_readonly_cli_test.ts`: PASS, 3 tests.
  - `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- Proximo ponto seguro: merge em `main`, publicacao Web/APK e registro de evidencia final.
