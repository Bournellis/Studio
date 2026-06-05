# Done - DraxosMobile Bosque v3 UX/Feel

## Metadata

- data: `2026-06-05`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/bosque-v3-ux-feel`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v3-ux-feel`
- status: `BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`
- remote publication: completed on the Internal Alpha principal URL
- release root: `internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45`
- official URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- preview evidence: `https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev`

## Objetivo

Fechar o gate de playtest OK do Technical Hardening e entregar Bosque v3 UX/Feel: colisao/spawn mais confiavel, feedback visual e textual mais claro, resumo de visita melhor, sessao/resync player-facing e landmarks leves sem expandir Openworld alem do Bosque.

## Entregue Localmente

- `DMOB-D074` tratado como decisao operacional: playtest do Technical Hardening ficou OK e o proximo pacote escolhido e Bosque v3 UX/Feel.
- Resource node `node_inseto_01` reposicionado para fora de bloqueadores; arvores/pedras bloqueantes tiveram area de colisao reduzida levemente para diminuir falso positivo de spawn/contato.
- Teste de ruleset garante que resource nodes fiquem fora de bloqueadores e bordas perigosas.
- Bosque ganhou estados visuais de proximidade/coleta, marcadores de pickup, diferenca visual entre bloqueadores e decoracao, glow de fogueira e landmarks procedurais nao bloqueantes.
- HUD, inventory sheet, deposito, craft, resumo de visita e mensagens de sessao/resync ficaram player-facing, com menos texto tecnico.
- Deposito agora exige estar perto do bau e ter itens no bolso; craft informa pronto/faltante de forma legivel.

## Validacao Local Ja Executada

- `git diff --check`: PASS.
- `npx -y deno test --allow-read server/tests/openworld_ruleset_definition_test.ts`: PASS, 5 tests.
- `npx -y deno check server/tests/openworld_ruleset_definition_test.ts`: PASS.
- `Godot --headless --path . -s res://tools/smoke_openworld_forest.gd`: PASS.
- `Godot --headless --path . -s res://tools/smoke_modes_visual_layout.gd`: PASS.
- `Godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`: PASS, 226 tests.
- `validate_foundation.ps1 -Profile ServerQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ClientQuick -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ModePlatform -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile ReleaseDryRun -NoProjectWrites`: PASS.
- `validate_foundation.ps1 -Profile FullLocal -NoProjectWrites`: BLOCKED only in `DatabaseLocal`; Docker Desktop/Supabase local is not running (`127.0.0.1:54321/54322` refused, Docker pipe missing). DocsOnly, ServerQuick, ClientQuick, ModePlatform and ReleaseDryRun stages inside the same run passed before the DatabaseLocal failures.

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

## Estado Final

Bosque v3 UX/Feel fica publicado para playtest humano. O proximo trabalho deve partir de `master` atualizado e escolher um pacote pequeno a partir do feedback: novo ajuste estreito de Bosque/menu ou Arena PVE/tuning, sem abrir Openworld continuo por implicacao.
