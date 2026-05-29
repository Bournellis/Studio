# DraxosMobile - Foundation Responsive Guardrails

- Data: `2026-05-28`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/foundation-responsive-guardrails`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-app-v0-audit`
- Status: `DONE`

## Objetivo

Corrigir regressao visual observada no build Foundation Loop UX Pass 01: ferramentas dev sumiram do menu inicial, Refugio e Batalha nao respeitam limites de tela em web/mobile, e faltavam guardrails documentados/testaveis para evitar novas quebras em reformulacoes visuais.

## Entregue

- Restaurados `Battle Lab` e `Progression Lab` no menu inicial quando `draxos_mobile/internal_alpha/dev_tools_enabled=true`.
- Entry passa a construir UI em full rect quando instanciado por teste/smoke.
- Refugio usa `RefugeSafeFrame` para manter controles interativos dentro de uma area segura.
- Batalha usa `BattleSafeFrame` para conter replay, resumo e logs em Android portrait e Web/desktop.
- `DraxosMobileUiContract.immersive_safe_rect()` centraliza margem/cap de largura para surfaces imersivas.
- Criado `docs/foundation-responsive-layout-contract.md`.
- Criado `tools/smoke_responsive_layout.gd` e integrado ao `validate_foundation.ps1`.
- Replicado espelho SQL ausente `202605270003_internal_alpha_private_downloads.sql` em `server/schema/migrations` para destravar o gate Quick.
- Atualizados docs vivos e snapshots de coordenacao para tornar o contrato responsivo obrigatorio antes de publicacao visual.
- Publicado hotfix Web/APK/PC/manifest apos aprovacao explicita do Fabio.
- APK/PC foram publicados em links publicos unlisted para evitar o erro `Bearer token is required` no download mobile.
- Cloudflare Pages recebeu novo deploy `https://c8dc997b.draxos-mobile-internal-alpha.pages.dev`.

## Validacao

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
```

Resultado:

- `smoke_responsive_layout.gd`: `OK`
- `smoke_foundation_loop.gd`: `OK`
- `validate_foundation.ps1 -Profile Quick`: `OK`
- GUT client: `111/111` testes passando, `1799` asserts
- `smoke_exports.gd`: `OK`
- `export_internal_alpha.ps1`: `OK`, Android mode `debug_fallback`
- `publish_internal_alpha.ps1 -Mode Upload -PublicDownloads -ConfirmRemoteMutation`: `OK`
- `wrangler pages deploy`: `OK`, preview `https://c8dc997b.draxos-mobile-internal-alpha.pages.dev`
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: `OK`
- `release_manifest_smoke.ts`: `OK`
- `release_artifacts_remote_smoke.ts`: `OK`
- `internal_alpha_remote_smoke.ts` com `DRAXOS_REMOTE_RELEASE_SMOKE=1`: `OK`
- `HEAD` anonimo APK: `200`, `application/vnd.android.package-archive`, `31563411` bytes
- `HEAD` anonimo PC ZIP: `200`, `application/zip`, `40032213` bytes

## Handoff

Hotfix publicado. Proximo passo e revisao manual em Android/Windows/Web: Labs Dev visiveis no Entry interno, Refugio/Batalha contidos, APK baixa no celular sem erro de Bearer token, e loop pos-login segue claro.
