# DraxosMobile Hardening Handoff: validation-security-gates - Foundation Hardening V2 validation/security gates

## Metadata

- data: `2026-06-01`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `validation-security-gates`
- mode_scope: `multi-mode`
- branch: `codex/draxos-mobile/foundation-hardening-v2-validation-security-gates`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-validation-security-gates`
- base_commit: `2f33c03`
- remote_mutation: `nao autorizada / nao executar`

## Objetivo

Expandir os gates locais de validacao para Foundation Hardening V2 strict checks sem publicar, mutar remoto ou tocar worktrees alheias.

## Latest Context

- latest platform baseline: `Hardening Platform V1`
- latest Arena loop package: `Track 21 - Arena Loop Unlock And Friction Pass`
- Arena contract source: `docs/pve-arena-v1.md`
- behavior/potion/crafting source: `docs/behavior-potion-crafting-v1.md`
- platform/modes source: `docs/contracts/minigame-platform-v1.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/release-safety-contract.md`
- `Projetos/draxos-mobile/implementation/tracks/track-13-validation-release-safety/validation-matrix.md`
- `Projetos/draxos-mobile/docs/release-ops-checklist.md`
- `Projetos/draxos-mobile/tools/README.md`
- `Projetos/draxos-mobile/docs/foundation-expansion-readiness.md`
- `Projetos/draxos-mobile/docs/foundation-app-v0-audit.md`
- `Projetos/draxos-mobile/docs/hardening-platform-v1-readiness-report.md`

## Escopo

- Incluir:
  - `Projetos/draxos-mobile/tools/validate_foundation.ps1`
  - `Projetos/draxos-mobile/tools/check_foundation_expansion_readiness.ps1`
  - `Projetos/draxos-mobile/README.md`
  - esta nota de handoff/registro
- Fora do escopo:
  - runtime Godot/client/server exceto testes e smokes locais necessarios;
  - worktrees de outros agentes;
  - remote mutation/publicacao;
  - tuning, economia, PVP, conteudo novo ou schema runtime.

## Validation Results

- `git diff --check`: PASS.
- PowerShell parser para `tools/validate_foundation.ps1` e `tools/check_foundation_expansion_readiness.ps1`: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile DocsOnly`: FAIL esperado por novo strict gate V2 de dependency/lock sanity.
  - Blocker: remote Deno imports exigem `deno.lock` em `server\tests\foundation_admin_rls_live_smoke.ts`, `server\tests\lab_runner_contract_test.ts`, `server\tests\modes_platform_live_test.ts`, `server\tests\transactional_edge_rpc_smoke.ts`, `server\tests\transactional_rpc_live_test.ts`.
  - Passes relevantes antes/depois do blocker: schema strictness, hot file budgets, baseline drift, live-doc release root, legacy terms e secrets/client safety scan.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`: FAIL esperado com 7 issues V2.
  - `server\functions\modes\mode_handler.ts` e `supabase\functions\modes\mode_handler.ts` ainda contem `method: "PATCH"` direto.
  - Remote Deno imports ainda nao possuem `deno.lock`.
  - CORS helper ainda usa wildcard origin e nao declara `draxos-mobile-internal-alpha.pages.dev`, `localhost`, `127.0.0.1`.
  - Passes relevantes: schema strictness, mode modularity markers, hot file budgets, live-doc Hardening Platform V1, Deno config mirror, Node package/lock sanity e secret scan.
- `ReleaseDryRun`: nao executado porque o novo `DocsOnly` strict gate ja bloqueia por dependency/lock sanity; nenhum remoto foi executado.

## Arquivos Alterados

- `Projetos/draxos-mobile/tools/validate_foundation.ps1`
- `Projetos/draxos-mobile/tools/check_foundation_expansion_readiness.ps1`
- `Projetos/draxos-mobile/README.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-01_codex_draxos-mobile_foundation-hardening-v2-validation-security-gates.md`

## Gates V2 Adicionados

- Canon/live-doc drift e stale release roots para Hardening Platform V1.
- Strict mode descriptor schema hook.
- Mode handler modularity e forbidden direct mode mutations.
- Hot file budgets para server, client e session.
- Dependency/lock sanity para Deno/Node/tracked dependencies.
- CORS/allowed origins.
- Secret scan parity no readiness.
- RemoteReadOnly ampliado no `validate_foundation.ps1` com manifest smoke, artifacts smoke e Internal Alpha remote smoke read-only.

## Handoff Point

Commit logico criado nesta branch com a mensagem `Add foundation hardening v2 validation gates`.
