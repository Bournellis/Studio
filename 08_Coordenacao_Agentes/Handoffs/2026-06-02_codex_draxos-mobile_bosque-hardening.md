# DraxosMobile Hardening Handoff: openworld - Bosque Hardening

## Metadata

- from: `Codex`
- to: `Usuario | Codex`
- date: `2026-06-02`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds | backend-schema | session-data | client-shell | validation-release`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-hardening`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-hardening`
- commits: `none - local implementation not committed`

## Contexto

Handoff do hardening tecnico do Openworld Bosque aprovado em playtest. O pacote
prepara `openworld/forest` como modo `active` no canal `internal_alpha`, com
`openworld_forest_ruleset_v1`, snapshot remoto retomavel, eventos revisionados,
Reward Bridge autoritativo por snapshot do servidor e UI sem rotulos tecnicos
para jogador.

Este handoff nao registra publicacao. Nenhum upload, deploy, manifest remoto,
migration remota ou comando com `-ConfirmRemoteMutation` foi executado.

## Current State

- latest Arena loop package considered: `Track 21 - Arena Loop Unlock And Friction Pass`
- runtime touched: `yes`
- remote mutation/publication run: `no`
- worktree clean at handoff: `no - dirty by intended implementation files`
- dependency gate: esperar `codex/draxos-mobile/app-responsiveness` virar
  baseline ou ser explicitamente superseded; depois rebasear e revisar
  conflitos em `SessionStore`, `SupabaseClient`, envelopes, cache e latencia.
- non-blocking reference: `arena-backend` continua apenas informativo enquanto
  estiver sujo/unmerged.

## Changed Files

- `Projetos/draxos-mobile/data/definitions/openworld/forest_ruleset_v1.json`
- `Projetos/draxos-mobile/data/definitions/modes/openworld/metadata.json`
- `Projetos/draxos-mobile/modes/boot/ui/mode_shell_registry.gd`
- `Projetos/draxos-mobile/modes/openworld/`
- `Projetos/draxos-mobile/online/supabase_client.gd`
- `Projetos/draxos-mobile/server/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/server/functions/modes/`
- `Projetos/draxos-mobile/supabase/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/supabase/functions/modes/`
- `Projetos/draxos-mobile/server/schema/migrations/202606020001_openworld_bosque_hardening_v1.sql`
- `Projetos/draxos-mobile/supabase/migrations/202606020001_openworld_bosque_hardening_v1.sql`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/mode_definitions/schema.ts`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/docs/minigames/`
- `Projetos/draxos-mobile/docs/design-pending.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Decisions Made

- `official_internal_alpha`: "oficial" significa `active` em
  `internal_alpha`, nao publicacao publica.
- `snapshot_authority`: retomada e recompensa usam snapshot do servidor.
- `revision_gate`: stale write e completion com revisao errada sao rejeitados.
- `event_bridge`: `POST /modes/session/event` cobre heartbeat, coleta, deposito,
  craft, complete e abandon.
- `preview_only_offline`: sem rede/auth continua jogavel sem recompensa e sem
  ledger.
- `ruleset_v1`: `openworld_forest_ruleset_v1` e ativo; v0 fica historico.
- `no_expansion`: sem novo mapa, risco, combate, economia ou mundo continuo.

## Validation

- `git diff --check`: `PASS`
- `npx -y deno check server/functions/modes/index.ts supabase/functions/modes/index.ts server/tests/modes_platform_live_test.ts server/tests/internal_alpha_remote_smoke.ts`: `PASS`
- `npx -y deno test --allow-read server/tests/modes_domain_test.ts server/tests/openworld_reward_bridge_test.ts server/tests/openworld_ruleset_definition_test.ts server/tests/modes_rate_limit_test.ts server/tests/modes_platform_schema_test.ts server/tests/mode_descriptors_contract_test.ts`: `PASS`
- `npx -y deno test --allow-read server/tests/mode_definitions_schema_test.ts server/tests/modes_registry_contract_test.ts server/tests/mode_descriptors_contract_test.ts`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: `PASS`

Notes:

- `ModePlatform` passou `smoke_mode_hub.gd`,
  `smoke_openworld_forest.gd`, `smoke_modes_visual_layout.gd` e
  `smoke_modes_ops_panel.gd`.
- `ClientQuick` passou GUT `174/174`, `3182` asserts, com warnings conhecidos de
  ObjectDB leaked at exit.
- `ReleaseDryRun` gerou plano local e reportou bloqueios esperados para Package:
  Supabase URL e artefatos APK/ZIP/Web ausentes. Isso e esperado porque esta
  entrega nao publica.

## Blockers

- Rebase obrigatorio depois de `codex/draxos-mobile/app-responsiveness` virar
  baseline ou ser explicitamente descartada.
- Migration remota nao aplicada.
- Local DB/Edge live proof nao executado porque a tarefa proibiu mutacao remota
  e nao abriu uma janela local Supabase com migrations aplicadas.
- Package/Upload/DeployManifest nao executados por design.

## Future Publication Commands - Not Executed

Executar somente apos rebase, revisao humana, migration window e aprovacao
explicita de publicacao.

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--bosque-hardening\Projetos\draxos-mobile

powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ModePlatform
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun

powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\export_internal_alpha.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -Mode Plan -ReleaseRoot <release-root> -PublicDownloads
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -Mode Package -ReleaseRoot <release-root> -PublicDownloads
```

Remote mutation commands remain prohibited until explicitly approved:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -Mode Upload -ReleaseRoot <release-root> -PublicDownloads -ConfirmRemoteMutation
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\publish_internal_alpha.ps1 -Mode DeployManifest -ReleaseRoot <release-root> -StaticSiteBaseUrl <stable-or-preview-url> -PublicDownloads -ConfirmRemoteMutation
```

## Recommended Next Step

Owner seguro: Codex em novo turno. Menor proximo passo: aguardar a baseline de
responsividade, rebasear `codex/draxos-mobile/bosque-hardening`, resolver
conflitos de client/session/backend envelope, aplicar migration local para live
proof e repetir os quatro perfis de validacao antes de qualquer publicacao.
