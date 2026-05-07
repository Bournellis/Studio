# Track 01 Current Status

- Last Updated: `2026-05-07`
- Status: `P03_PLACEHOLDER_REWARD_VALIDATED`
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
- Battle victory records node completion, last result, and remaining commander health in `RunSession`.
- Battle return button becomes `Continuar no Mapa` after victory.
- RunMap shows selected class, health, completed nodes, last completed node, and newly available nodes.
- ShipHub shows active run state, selected class, health, completed nodes, and last completed node.
- P02 validation green with 27/27 GUT tests and 217 asserts.
- Battle victory creates a pending placeholder reward in `RunSession`.
- RunMap exposes reward choices for adding `Pulso Astral` to the current deck or reinforcing health by +2.
- Applying a reward mutates the current run immediately and records the applied reward id.
- ShipHub shows pending/applied reward counts.
- P03 validation green with 29/29 GUT tests and 238 asserts.

## Current Risk

Soul currency and paid healing are not implemented yet. P04 owns the first placeholder version of that ship economy.

## Next

Continue with `P04 - Soul Currency And Paid Healing Placeholder`.
