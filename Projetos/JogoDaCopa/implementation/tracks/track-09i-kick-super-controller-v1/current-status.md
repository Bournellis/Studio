# Track 09I - Kick Super Controller V1

- Date: `2026-06-16`
- Status: `PUBLICADO_RETEST_HUMANO_PENDENTE`
- Branch: `codex/jogodacopa/track09i-kick-super-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09i-kick-super-controller-v1`

## Objective

Reduce `FootballRoot` by extracting kick and SUPER orchestration into a dedicated helper without changing gameplay, input, physics, bot decisions, HUD or assets, then publish the validated no-gameplay package.

## Implementation

- Added `modes/football/football_kick_super_controller.gd`.
- Moved player kick request routing, charged kick scaling, strong/SUPER decision, connected kick side effects, bot kick handling and SUPER meter helpers into the controller.
- Kept compatibility wrappers in `football_root.gd` for existing signal connections and Web warmup call sites.
- Kept loose-ball contact, arcade dash contact, ball collision audio and `_physics_process` ordering in `football_root.gd`.

## Measurement

- `football_root.gd`: `995 -> 943` lines in the current base.
- `football_kick_super_controller.gd`: `76` lines.

## Validation

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `56` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` files.
- Chrome local Web boot: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidence: `docs/playtest-reports/track-09i-data/09i-local-web-boot.json`, `docs/playtest-reports/track-09i-data/09i-local-web-boot.png`.
- Cloudflare Pages publication: PASS as `Super Campeao v1.2.1+7995b06c`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Preview URL: `https://76b6f219.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Remote menu: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, heap retained `43,925,492 -> 48,010,927` bytes (`+9.30%`, limit `<10%`), counters/caches stable, worst 5s `132.6 FPS`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.
- Publication evidence: `docs/playtest-reports/track-09i-publication.md`, `docs/playtest-reports/track-09i-data/09i-publication-report-7995b06c.json`, `docs/playtest-reports/track-09i-data/09i-remote-menu-7995b06c.json`, `docs/playtest-reports/track-09i-data/09i-remote-first-minute-7995b06c.json`, `docs/playtest-reports/track-09i-data/09i-remote-stability-5min-7995b06c.json`, `docs/playtest-reports/track-09i-data/09i-remote-night-luma-gate-7995b06c.json`.

## Next Step

Fabio/tester should retest the public 09I build. After approval, open Track 09J to extract the remaining ball-contact/possession surface with the same no-gameplay-change discipline.
