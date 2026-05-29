# Battle Preparation v1

- Status: `PUBLISHED`
- Date: `2026-05-29`
- Project stage: `BATTLE_PREPARATION_V1_PUBLISHED`
- Release root: `internal-alpha/v0-battle-preparation-v1-20260529`
- Verified preview: `https://e2a7393d.draxos-mobile-internal-alpha.pages.dev`

## Summary

Battle Preparation v1 is a client-first readability package on top of the Track 16 behavior and potion systems. It keeps the existing backend/API/schema/simulator/economy contracts and turns the current Refugio preparation popup into a clear pre-battle check: the player can see the ritual instrument, level/power when available, equipped potion, potion behavior, equipped spells, familiar and doctrine before asking for a battle.

The package does not add new endpoints, migrations, tuning, weapons, spells, potion types, advanced priorities, direct enemy rules or win prediction.

## Player Experience

- Refugio keeps the existing `Preparacao` hotspot; no new route was added.
- Opening Preparation requests the existing build state through the current shell action flow.
- The panel starts with `Pronto para batalha` and explains what the account is carrying into the next fight.
- Potion text is player-facing:
  - `Pocao de Vida equipada`
  - `Nenhuma pocao equipada`
  - `Usa automaticamente com vida baixa`
  - `Pocao pausada`
- Spell text is player-facing:
  - `Usa quando estiver pronta`
  - `Pausada para batalha`
- Empty states stay readable for no potion, no stock and no equipped spells.
- The visible panel avoids technical implementation vocabulary.

## Actions

The package only uses existing client actions and existing server routes:

- `Equipar Pocao de Vida`
- `Remover pocao`
- `Usar com vida baixa`
- `Pausar pocao`
- `Usar na batalha`
- `Pausar`

Success and error messages are mapped to public copy for missing session, missing potion stock, missing equipped spell, network failure and unavailable preparation.

## Contracts

- Public API: unchanged.
- Supabase/schema/migration: unchanged.
- Simulator/reward/ranking/economy: unchanged.
- Existing routes used:
  - `GET /build/state`
  - `POST /build/spell-behavior`
  - `POST /build/potion/equip`
  - `POST /build/potion-behavior`

## Validation

Local validation on `2026-05-29`:

- GUT `tests/client`: PASS (`121/121`, `1926` asserts).
- `tools/smoke_foundation_loop.gd`: PASS.
- `tools/smoke_responsive_layout.gd`: PASS.
- `tools/validate.gd`: PASS.
- `validate_foundation.ps1 -Profile Client`: PASS.
- `git diff --check`: PASS.
- `tools/smoke_foundation_surfaces.gd`: BLOCKED at anonymous auth with `NETWORK_UNAVAILABLE`; this smoke depends on available local/remote backend state outside the client-only package.

Publication validation:

- `export_internal_alpha.ps1 -AllowAndroidDebugFallback`: PASS; Android export mode `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan -PublicDownloads`: PASS.
- `publish_internal_alpha.ps1 -Mode Package -PublicDownloads`: PASS.
- Supabase Storage upload: PASS for 25 files through CLI `2.98.0` after CLI `2.102.0` stalled on `storage cp`.
- `build_cloudflare_pages_package.ps1`: PASS.
- Cloudflare Pages deploy: PASS, preview `https://e2a7393d.draxos-mobile-internal-alpha.pages.dev`.
- `publish_internal_alpha.ps1 -Mode DeployManifest -PublicDownloads -ConfirmRemoteMutation`: BLOCKED before remote secret mutation because `SUPABASE_ACCESS_TOKEN` was not available.
- Preview GET: PASS for `/portal/index.html` and `/web/index.html`.
- Versioned artifact HEAD checks: PASS for Web `index.js`, `index.pck`, `index.wasm`, Android APK and PC ZIP.
- Web preview contains the versioned asset root and `GODOT_CONFIG.fileSizes.index.pck = 4230572`, matching the remote `index.pck`.

## Release Snapshot

| Artifact | Bytes | SHA256 |
|---|---:|---|
| Android APK | `31637525` | `6160dd7cb6d8e7c9bf935e955dc2420b0eb7e253cb11e09fea02b7fa7b4e2d07` |
| PC Windows ZIP | `40104099` | `97e24d82c758a9889ffa6f5f96e0e88d0158c6eaa8ac1a6d1d74859c8fa42809` |
| Web index | `5442` | `348217a4464e0d7903477473440e51a2f02120cc96149db95749f8abfe222e54` |

Links:

- Preview: `https://e2a7393d.draxos-mobile-internal-alpha.pages.dev`
- Stable portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Web asset root: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-v1-20260529/web`
- APK: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-v1-20260529/downloads/draxos-mobile-alpha.apk`
- PC ZIP: `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-battle-preparation-v1-20260529/downloads/draxos-mobile-alpha.zip`

## Next Step

Manually review the published Internal Alpha on Android, Windows and Web. The next package should be chosen after confirming whether players understand the pre-battle setup and whether the Refugio battle CTA feels naturally connected to preparation.
