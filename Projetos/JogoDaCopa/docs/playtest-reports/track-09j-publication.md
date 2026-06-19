# Track 09J Publication Attempt - Ball Contact Controller V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Candidate version: `v1.2.1+4678fbea`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Candidate preview URL: `https://ff5e2d51.copa-arena-futebol.pages.dev`
- Candidate release root: `web/v1-copa-arena-futebol-20260619-4678fbea`
- Status: `REMOTE_STABILITY_HEAP_FAIL_ROLLBACK_TO_09I`
- Restored public baseline: `v1.2.1+7995b06c`, `web/v1-copa-arena-futebol-20260616-7995b06c`

## Scope

Attempted to publish the already validated Track 09J reduction. The gameplay code change extracted player ball-control/contact state, passive player-ball contact, ball collision audio routing and arcade dash/body contact from `football_root.gd` into `modes/football/football_ball_contact_controller.gd`.

No gameplay, input, bot decision, physics, scoring, HUD, tuning, asset or branding change was intended.

## Local Gates

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `57` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`, raw `63.07 MiB`, `9` files.
- Chrome local Web boot: PASS with `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## Publication

Command:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260619-4678fbea -VisibleVersion v1.2.1 -EvidenceSubdir track-09j-data -EvidencePrefix 09j -DeployMessage "JogoDaCopa Track 09J Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260619-4678fbea" -ConfirmRemoteMutation -SkipExport
```

Result: deploy completed, but the candidate did not pass the full remote gate set.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Stability 5min gate: FAIL, retained JS/WASM heap `43,740,045 -> 50,719,101` bytes (`+15.96%`, limit `<10%`), peak `64,046,786` bytes (`+46.43%`).
- Stability 5min rerun: FAIL, retained JS/WASM heap `44,045,553 -> 50,751,097` bytes (`+15.22%`, limit `<10%`), peak `64,104,862` bytes (`+45.54%`).
- Godot counters/caches: PASS, stable object/node counts and material/mesh caches.
- Worst 5s FPS windows: PASS, `136.6 FPS` and `119.8 FPS`.
- Night luma gate: not run because the stability gate blocked the release.

## Rollback

Cloudflare refused deletion of the active production deployment, so the approved 09I package was redeployed as production.

Rollback command ran from the 09I commit/worktree:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260616-7995b06c -VisibleVersion v1.2.1 -EvidenceSubdir track-09j-data -EvidencePrefix 09j-rollback-to-09i -DeployMessage "Rollback JogoDaCopa to approved Track 09I baseline after Track 09J remote heap gate failure" -ConfirmRemoteMutation
```

Rollback result:

- Production deployment URL: `https://0bed6091.copa-arena-futebol.pages.dev`.
- Stable URL confirmation: PASS, `https://copa-arena-futebol.pages.dev/` served `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Menu stage after rollback: PASS, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.

## Evidence

- Package: `track-09j-data/09j-package-artifacts-4678fbea.json`.
- Candidate publication: `track-09j-data/09j-publication-report-4678fbea.json`.
- Menu: `track-09j-data/09j-remote-menu-4678fbea.json` and `track-09j-data/09j-remote-menu-4678fbea.png`.
- First minute: `track-09j-data/09j-remote-first-minute-4678fbea.json` and `track-09j-data/09j-remote-first-minute-4678fbea.png`.
- Stability fail: `track-09j-data/09j-remote-stability-5min-4678fbea.json` and `track-09j-data/09j-remote-stability-5min-4678fbea.png`.
- Stability fail rerun: `track-09j-data/09j-remote-stability-5min-rerun-4678fbea.json` and `track-09j-data/09j-remote-stability-5min-rerun-4678fbea.png`.
- Rollback publication: `track-09j-data/09j-rollback-to-09i-publication-report-7995b06c.json`.
- Rollback confirmation: `track-09j-data/09j-rollback-remote-menu-7995b06c.json` and `track-09j-data/09j-rollback-remote-menu-7995b06c.png`.

## Interpretation

Track 09J is locally green and its remote menu/first-minute behavior is clean, but it is not safe as the public Web baseline until the remote JS/WASM heap growth is understood and brought back below the `<10%` gate. The Godot counters remained stable, so the first suspect is retained browser/WASM-side memory rather than leaked scene nodes or runtime material/mesh caches.

## Next Gate

Open a focused heap investigation/hotfix track before republication or further `FootballRoot` reduction.
