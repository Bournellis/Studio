# Track 02 Implementation Map

This file summarizes the stable implementation surface opened by the canonical-product shift.

## Owned Outcomes

- one canonical bootstrap scene that always lands in the frontend
- one persisted player profile that owns campaign tutorial completion plus future unlock state
- one mode-availability resolver that keeps product gating outside raw UI copy
- one campaign-entry tutorial scene that can complete and update profile state
- one first campaign framework mode that records completion locally and unlocks Boss
- one completed campaign-first runtime alignment pass that makes Campaign the primary product surface
- one clear separation between Classic progression, Free replay/buildcraft, and complementary extra modes
- one explicit gate model per implementation phase
- one parallel art track that works on proxy-first deliverables without blocking gameplay validation

## Current Delivered Slice

- `boot` now routes directly into the frontend
- `frontend` now groups public modes into `Campanha` and `Extras`
- `tutorial` now exists as the first entry point for `Campanha do Troll`
- `ProfileStore` and `PlayerProfile` now persist canonical product progress independently from saved loadouts
- `campaign` now exists as the first staged local journey and persists completion into the product profile
- current frontend now respects product lock state for `Campanha do Troll`, `Survival`, `Boss`, and `Arena Bot`
- `Arena PvP / Private Duel` remains internally defined but is hidden from public navigation until a future explicit gate
- `campaign` now opens Classic stages with a campaign briefing before control is released
- campaign rewards now describe journey progress, kit learning, and extra-mode openings instead of only technical unlock messages
- campaign results now use campaign-specific return copy and next-step guidance
- free-selection modes now present the builder as kit preparation, point locked skills/potions back to campaign learning, and still validate the canonical 4 skills / 2 potions contract
- `Campanha Livre` now exists as the post-`Easy` replay/buildcraft campaign route, launches through kit preparation, uses account-unlocked content, and keeps replay rewards secondary/non-permanent
- `Survival`, `Boss`, and `Arena Bot` now have explicit extra-mode roles and non-permanent result framing separated from campaign progression

## Guardrails

- keep B0 regression coverage alive while product bootstrap evolves
- F11 is complete; no implementation gate is active until a new explicit gate is selected before opening broader content or online work
- do not broaden campaign scope, add Hard, promote PvP, or open online work without a new explicit gate
- keep tutorial or meta progress writes at clear completion boundaries
- treat art deliverables as parallel manifests, not blockers for proxy validation
