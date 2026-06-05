# Handoff - DraxosMobile Bosque v3 UX/Feel

## Estado

- status: `BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`
- branch: `codex/draxos-mobile/bosque-v3-ux-feel`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v3-ux-feel`
- release root: `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`
- official URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- preview evidence: `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`

## Resumo

Bosque v3 UX/Feel esta implementado, mergeado e publicado como Internal Alpha. O pacote melhora colisao/spawn de resource nodes, feedback visual de proximidade/coleta, leitura do HUD, inventory sheet, deposito/craft, resumo de visita e mensagens de sessao/resync. O escopo nao adiciona inimigos, NPCs, quests, cidade, mundo continuo, economia ampla ou tuning novo.

## Validacao Ja Concluida

- `git diff --check`: PASS.
- `server/tests/openworld_ruleset_definition_test.ts`: PASS.
- `smoke_openworld_forest.gd`: PASS.
- `smoke_modes_visual_layout.gd`: PASS.
- GUT client suite: PASS, 226 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile FullLocal -NoProjectWrites`: BLOCKED only in `DatabaseLocal`; Docker Desktop/Supabase local is unavailable on this machine (`127.0.0.1:54321/54322` refused, Docker pipe missing). The non-Docker stages in that same run passed.

## Publicacao E Validacao Remota

- Android APK: SHA256 `4455af96d285a2ac3f5d8268d5d044ff4933eb10303dfbe113d3aba0811efaa5`.
- PC ZIP: SHA256 `bd2ce982a4bba80eedbd8ff165537dbe4bdc49183139d6e5b8e7e598cff85f93`.
- Web Index: SHA256 `75b9d6e532b78dbe9a6cdb8caee3a6794ab2ae0c4e2aaf8e7ac619022a20d11f`.
- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS.
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: PASS after retrying an intermittent Supabase CLI `502`.
- `wrangler pages deploy build/internal-alpha/cloudflare-pages --project-name draxos-mobile-internal-alpha --branch main`: PASS, preview `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: PASS.
- `validate_foundation.ps1 -Profile RemoteReadOnly -ExpectedReleaseRoot internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45 -RemoteWebUrl https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev/web/index.html -AllowCloudflareAccess -NoProjectWrites -KeepDiagnostics`: PASS.
- Remote Web launch smoke loaded the game, matched release root/asset root and reported no runtime errors.

## Proximos Passos

Playtest humano do pacote Bosque v3 UX/Feel publicado. A decisao seguinte deve ser tomada a partir do feedback: novo ajuste estreito de Bosque/menu ou Arena PVE/tuning. Openworld continuo, inimigos, NPCs, quests, cidade, economia ampla e tuning novo continuam bloqueados sem pacote proprio.
