# Gate F10 - Campaign-First Product Realignment

- Phase: `Phase 10 - Campaign-First Product Realignment`
- Status: `APPROVED`
- Type: `Documentation and product-direction alignment`

## Canon Review

- The product direction is now campaign PvE first.
- The original PvP/loadout-first design legacy is reinterpreted as kit-first: race, weapon, skills, and potions remain central, but the main campaign may teach and unlock the kit gradually.
- `Classic` is the authored campaign progression path and primary source of permanent gameplay unlocks.
- `Free` is replay/buildcraft after Classic progression, not the primary unlock path.
- Survival, Boss, and Arena Bot are complementary replay, mastery, or pass-time surfaces.
- Co-op is optional for Release 1 only if it preserves the solo-first campaign baseline.
- Private Duel / Arena PvP is experimental or development-only until a future gate deliberately promotes or removes it.

## Scope In

- Align shared canon around campaign PvE as the commercial spine.
- Reframe loadout language toward kit-first progression.
- Reframe PvP as direct-invite private duel only, with no public matchmaking, ranking, or dedicated server requirement.
- Record that extra modes may use light diegetic framing, while lore evolves primarily through campaign content.
- Update active implementation status to point future work through this realignment.

## Scope Out

- Implementing co-op.
- Implementing Steam networking, Steam lobbies, invites, or transport.
- Implementing Private Duel / Arena PvP.
- Adding public matchmaking, ranked PvP, or dedicated servers.
- Changing runtime menu behavior, mode IDs, scene routing, tests, or smoke docs.
- Choosing the next content package, Hard route, Free replay implementation, or weapon/race breadth.

## Acceptance

- `canon/product/product-vision.md` presents the game as campaign PvE first.
- `canon/design/game-design-document.md` places campaigns before PvP/MOBA in product reading and defines Classic versus Free responsibilities.
- `canon/design/progression-design.md` defines Classic as the main progression path and Free as replay/buildcraft after Classic.
- `canon/roadmap/release-horizons.md` states Release 1 is campaign PvE first, with co-op optional only if it preserves solo quality.
- `canon/architecture/shared-architecture.md` and `canon/platform/steam-platform.md` state that co-op/private duel do not require dedicated servers in the current plan.
- Active status docs record that Arena PvP / Private Duel is not a public product promise and must stay experimental or development-only until a later gate promotes or removes it.

## Validation

- Run textual review with `rg` for old product-language drift:
  - `loadout-first`
  - `competitive`
  - `matchmaking`
  - `dedicated server`
  - `PvP at launch`
  - `MOBA`
  - `Arena PvP visible placeholder`
- No GUT or headless runtime validation is required for this gate unless runtime files are changed later.

## Follow-Up Decision

The next implementation gate must choose one direction explicitly:

- Free campaign replay/buildcraft
- same-race content breadth
- co-op feasibility
- deeper campaign content
- further runtime/menu alignment for the experimental Private Duel / Arena PvP posture

Do not default to Hard route, PvP promotion, or broader online work without a new gate.
