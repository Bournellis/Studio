# DraxosMobile - T08-F Service/Asset Contract Checks

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t08-service-asset-contracts`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-service-asset-contracts`
- Objetivo: adicionar checagens leves para docs/contracts, feature registry e `AssetIds` sem criar endpoint, schema, migration, asset final ou servico novo.
- Status: `COMPLETE`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-05-27_codex_draxos-mobile_t08-coordenacao.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/agent-prompts.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/agent-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/foundation-gap-report.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/*`
- `Projetos/draxos-mobile/tools/` ou `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/tests/client/test_content_foundation.gd` se `AssetIds` precisar de cobertura client

## Validacao Planejada

- Deno checks se houver novo teste TypeScript.
- `tools/validate.gd` e GUT se houver toque em client/GDScript.
- `git diff --check`.

## Handoff

Entregas:

- `server/tests/foundation_contracts_test.ts` adiciona teste Deno sem rede para a matriz atual de endpoints em `docs/contracts/api-endpoints.md` e os cards do feature registry.
- `server/tests/README.md` documenta o comando do teste de fundacao.
- `tests/client/test_content_foundation.gd` reforca que ids opcionais sem arte continuam registrados, retornam `null` e ficam fora do Pack 01 instalado.
- Track 08 e `implementation/current-status.md` marcados com `T08_F_READY_FOR_INTEGRATION`.

Validacao executada:

- `npx -y deno fmt server/tests/foundation_contracts_test.ts`
- `npx -y deno check server/tests/foundation_contracts_test.ts`
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts`
- `npx -y deno lint server/tests/foundation_contracts_test.ts`
- `Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path <WORKTREE>\Projetos\draxos-mobile` para inicializar cache de classes da worktree nova.
- `tools/validate.gd`
- GUT client completo
- `git diff --check`

Proximo ponto: T08-H deve integrar esta branch com as demais trilhas Track 08 e manter o teste Deno na matriz de validation harness.
