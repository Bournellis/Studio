# DraxosMobile Doing: Bosque Node Cooldown ACK v1

## Metadata

- data: `2026-06-08`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds` + `backend-schema` + `validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-node-cooldown-ack-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-node-cooldown-ack-v1`

## Objetivo

Corrigir o bug em que nodes do Bosque parecem respawnar instantaneamente ao sair/voltar e a segunda coleta fica presa em "aguardando o servidor". O contrato do pacote e: node coletado so pode reaparecer por `node_state.next_spawn_at` calculado a partir da coleta confirmada pelo servidor, e rejeicoes de cooldown devem ser terminais para a operacao local, nunca retry infinito.

## Intended Files

- `Projetos/draxos-mobile/modes/openworld/openworld_integrated_session_bridge.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/server/functions/modes/*`
- `Projetos/draxos-mobile/supabase/functions/modes/*`
- `Projetos/draxos-mobile/tests/client/*openworld*`
- `Projetos/draxos-mobile/server/tests/*openworld*`
- version/release files, release smoke tests and live docs after implementation.

## Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`

## Validation Plan

- Targeted GUT Openworld bridge/screen tests.
- Targeted Deno Openworld/modes tests.
- `npx -y deno task --cwd server/functions check`
- `npx -y deno task --cwd supabase/functions check`
- `validate_foundation.ps1 -Profile ClientQuick`
- `validate_foundation.ps1 -Profile ServerQuick`
- `validate_foundation.ps1 -Profile ReleaseDryRun`
- Release smokes after publication.
- `git diff --check`

## Handoff Point

After implementation and validation, move this card to Done with release root, preview evidence, artifact hashes and remote smoke status.

## Result

- Status: implemented, merged into `main` and published as Internal Alpha.
- Release package: `Bosque Node Cooldown ACK v1`.
- Release root: `internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad`.
- Preview evidence: `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`.
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`.
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`.
- Version: `0.0.13-alpha.0` / version code `13`.
- Android APK SHA256: `c2167096aa2ab0df5c2d4d9e4740e1dd8fa7676bc54ae7af9254d87a2d6e540f`.
- PC Windows ZIP SHA256: `5bf641d228425f9d47e91b3e7fab20774b21864ac3cd0227a72bb188afb72477`.
- Web Index SHA256: `4b015300456471c94859406612b22326076ced4f787e458cc6d8f3776461bb73`.

Validation and release evidence:

- Targeted OpenWorld GUT/client suite passed during implementation.
- Targeted OpenWorld/modes Deno tests passed during implementation.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad -ConfirmRemoteMutation`: PASS.
- `build_cloudflare_pages_package.ps1`: PASS.
- `wrangler pages deploy build\internal-alpha\cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://5cce952e.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot internal-alpha/v0-bosque-node-cooldown-ack-v1-20260608-626b4ad -ConfirmRemoteMutation`: PASS.
- Remote manifest smoke: PASS.
- Remote artifact smoke: PASS; canonical Portal/Web are Cloudflare Access protected as expected.
- Internal alpha release/CORS smoke: PASS.
- Preview Web launch smoke: PASS, game loaded and matched release root.
