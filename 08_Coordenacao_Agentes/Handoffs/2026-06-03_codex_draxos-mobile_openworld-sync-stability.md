# DraxosMobile Hardening Handoff: openworld - Sync Stability

## Metadata

- from: `Codex`
- to: `Usuario | Codex`
- date: `2026-06-03`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `mode-scaffolds | platform-v1 | backend-schema | client-shell | validation-release`
- mode_scope: `openworld | multi-mode`
- branch: `codex/draxos-mobile/openworld-sync-stability`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-sync-stability`
- commits: `HEAD - Fix openworld event ack sync stability`

## Contexto

Handoff da correcao local para o rollback constante do Openworld Bosque apos o
hardening v1. A analise indicou que o evento integrado recebia ACK do servidor
e o client hidratava o snapshot completo durante gameplay ativo, permitindo que
uma resposta antiga sobrescrevesse posicao, coleta em andamento e estado visual
ja confirmado na tela. Este pacote revisa tambem o contrato generico de modos
para evitar que futuros modos herdem o mesmo padrao.

Este handoff nao registra publicacao. Nenhum upload, deploy, manifest remoto,
migration remota ou comando com `-ConfirmRemoteMutation` foi executado.

## Current State

- latest Arena loop package considered: `Track 21 - Arena Loop Unlock And Friction Pass`
- runtime touched: `yes`
- remote mutation/publication run: `no`
- worktree clean at handoff: `yes`
- latest published package remains: `First Access Runtime Fix`,
  `internal-alpha/v0-first-access-runtime-20260602-4608977`.

## Changed Files

- `08_Coordenacao_Agentes/Kanban/Done/2026-06-03_codex_draxos-mobile_openworld-sync-stability.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-03_codex_draxos-mobile_openworld-sync-stability.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-platform-v1.md`
- `Projetos/draxos-mobile/docs/contracts/minigame-integration.md`
- `Projetos/draxos-mobile/docs/minigames/openworld.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/server/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/server/functions/modes/mode_handler.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/supabase/functions/modes/mode_handler.ts`
- `Projetos/draxos-mobile/server/tests/modes_domain_test.ts`
- `Projetos/draxos-mobile/server/tests/modes_platform_schema_test.ts`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_model.gd`
- `Projetos/draxos-mobile/modes/openworld/openworld_forest_screen.gd`
- `Projetos/draxos-mobile/tests/client/test_openworld_mode_dev.gd`

## Decisions Made

- `event_ack_not_snapshot`: ACK comum de evento de modo usa `mode_event_ack`
  com `snapshot_patch`; nao deve hidratar snapshot completo durante gameplay.
- `client_visual_authority`: em gameplay ativo, posicao do jogador e coleta em
  andamento sao autoridade visual do client ate resume/state/resync explicito.
- `server_economy_authority`: bolso, bau, upgrades, nodes coletados, score e
  payload de recompensa continuam autoritativos pelo servidor.
- `stale_resync`: conflito de revisao continua forçando resync, mas com mensagem
  discreta de produto.
- `compat_response`: a resposta preserva campos legados no envelope, mas o
  client novo aplica apenas `snapshot_patch` em ACK de evento.

## Validation

- `git diff --check`: `PASS`
- `npx -y deno task --cwd server/functions check`: `PASS`
- `npx -y deno task --cwd supabase/functions check`: `PASS`
- `npx -y deno test --allow-read server/tests/modes_domain_test.ts server/tests/modes_platform_schema_test.ts`: `PASS`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --import --path .`: `PASS`
- GUT `test_openworld_mode_dev`: `PASS` (`25/25`, `107` asserts)
- `tools/smoke_openworld_forest.gd`: `PASS`
- `tools/smoke_modes_visual_layout.gd`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ClientQuick`: `PASS`
  on rerun. First run had an unrelated `tools/validate.gd` navigation flake;
  the same run's GUT matrix passed.
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ModePlatform`: `PASS`
- `tools/validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun`: `PASS`

## Blockers

- No technical blocker found in local validation.
- `ReleaseDryRun` first attempt failed only because the active Doing card still
  existed, which was expected before handoff closure; final rerun passed.
- Remote migration/live proof/publication were not run by design.

## Future Publication Commands - Not Executed

Run only after human review and explicit publication approval.

```powershell
cd D:\Estudio-worktrees\draxos-mobile--codex--openworld-sync-stability\Projetos\draxos-mobile

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

Owner seguro: Usuario/Codex. Menor proximo passo: revisar a branch local,
confirmar o comportamento do Bosque em playtest e, se aprovado, abrir uma janela
separada para package/publicacao sem misturar novas melhorias de mapa, economia
ou conteudo.
