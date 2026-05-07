# Track 01 Current Status

- Last Updated: `2026-05-07`
- Status: `P01_RUN_START_CLASS_PLACEHOLDER_VALIDATED`
- Scope: `First coherent playable run loop after Track 00 checkpoint`

## Completed

- Track 00 checkpoint committed and closed.
- Catalog exposes exactly 3 placeholder class options.
- ShipHub shows class placeholder buttons before starting a run.
- RunSession records selected class id, display name, deck, health, and active run state.
- RunMap no longer auto-starts an empty run.
- RunMap nodes remain blocked until the player starts a run from ShipHub.
- Battle uses the current run deck when available.
- P01 validation green with 24/24 GUT tests and 185 asserts.

## Current Risk

Class options are intentionally placeholders. Final class mechanics, mana profiles, starter decks, and class-specific resources still require the planned design session.

## Next

Continue with `P02 - Battle Return And Visible Run State`.
