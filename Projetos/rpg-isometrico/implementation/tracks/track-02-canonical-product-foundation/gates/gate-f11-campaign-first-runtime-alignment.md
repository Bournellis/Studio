# Gate F11 - Campaign-First Runtime Alignment

- Phase: `Phase 11 - Campaign-First Runtime Alignment`
- Status: `COMPLETED`
- Type: `Runtime and UX implementation backlog`

## Supersession Note

F11 is complete through F11-E. It is preserved as completed implementation context, not as the active gate. No implementation gate is active until `implementation/current-status.md` names the next gate explicitly.

## Canon Review

- F10 is authoritative: the product is campaign PvE first.
- `Classic` is the main authored progression, lore, and unlock path.
- `Free` is replay/buildcraft after Classic progression.
- Survival, Boss, and Arena Bot are complementary extras, not equal pillars beside Campaign.
- Private Duel / Arena PvP is experimental or development-only until a future gate promotes or removes it.
- Co-op is optional for Release 1 only if it preserves the solo-first campaign baseline.

## Implementation Order

F11 must not be implemented as one large undifferentiated change. Split it into the following implementation slices and validate each slice before opening the next one.

## Slice Status

- `F11-A - Frontend Campaign-First`: implemented in runtime, automated frontend/product-profile coverage, and smoke docs.
- `F11-B - Classic Campaign Authority`: implemented in runtime, campaign/frontend/product-profile coverage, and smoke docs.
- `F11-C - Kit And Loadout UX`: implemented in runtime, frontend/loadout coverage, and smoke docs.
- `F11-D - Free Campaign Replay`: implemented in runtime, campaign/frontend/product-profile coverage, and smoke docs.
- `F11-E - Extra Mode Framing And Progression Cleanup`: implemented in runtime, shared-presentation/frontend/extra-mode coverage, smoke docs, and validation tooling.

## Implementation Slices

### F11-A - Frontend Campaign-First

Purpose:

- make the first playable product surface read as campaign-first before deeper gameplay changes

Scope:

- make `Campanha do Troll` visually and functionally read as the primary entry
- reframe Survival, Boss, and Arena Bot as extras, challenges, mastery, or training surfaces
- remove, hide, or dev-gate `Arena PvP` from normal public navigation
- stop presenting `Aventura` and `Versus` as equivalent product pillars
- update frontend copy to avoid public competitive, matchmaking, or live-service implications

Acceptance:

- a fresh profile naturally points the player to Campaign first
- extra modes remain accessible according to current unlock rules but do not compete with Campaign as equal pillars
- Arena PvP is no longer presented as a normal public-facing promise
- automated frontend tests and relevant smoke docs are updated only where runtime behavior changed

### F11-B - Classic Campaign Authority

Purpose:

- make Classic feel like the product spine instead of a technical route inside a multi-mode menu

Scope:

- keep Classic as the default first-player journey
- preserve authored kit progression instead of forcing a complete pre-run build choice
- strengthen campaign briefing, objectives, reward beats, and return flow
- make permanent rewards feel like journey progression rather than only technical unlock messages

Acceptance:

- Classic remains the first-player progression and unlock path
- campaign start, stage completion, rewards, and result return communicate authored journey progress
- no new Free, Hard, co-op, or PvP behavior is introduced in this slice

### F11-C - Kit And Loadout UX

Purpose:

- align builder and locked-state language with kit-first progression

Scope:

- present the player fantasy as learning, unlocking, and mastering a kit
- keep full builder behavior for modes that intentionally expose free selection
- avoid requiring full `Race -> Weapon -> 4 Skills -> 2 Potions` selection before the early Classic campaign experience
- adjust copy away from "complete loadout required" when the mode is authored or progression-gated

Acceptance:

- authored campaign routes do not read as if they require free-build setup
- free-selection modes still expose and validate the canonical loadout contract
- lock messaging consistently points back to campaign progression when content is missing

Implementation note:

- Runtime copy now presents free-selection builders as `Preparar kit` / `Kit para ...`, locked skills and potions as campaign-learned resources, and saved selections as saved kits while preserving the internal `LoadoutData` contract.

### F11-D - Free Campaign Replay

Purpose:

- introduce Free as post-Classic replay/buildcraft, not as a parallel first-entry campaign

Scope:

- implement or prepare Free campaign replay only after Classic progression is stable
- use permanent account unlocks
- expose freer buildcraft through the canonical loadout contract
- keep Free rewards secondary unless canon explicitly changes that rule

Acceptance:

- Free is gated behind the appropriate Classic progression
- Free uses unlocked account content coherently
- Free does not become the primary permanent unlock source
- tests cover Free availability, launch parameters, and unlock filtering before the slice closes

Implementation note:

- Runtime now adds `blacksmith_campaign / free` as `Campanha Livre`, visible beside `Easy` and `Normal` but locked until `Easy` completion; after unlock it uses `Preparar kit`, profile-unlocked content, the canonical 4 skills / 2 potions contract, replay-specific briefing/reward/result copy, route-specific suspend keys, and no permanent reward application.

### F11-E - Extra Mode Framing And Progression Cleanup

Purpose:

- reposition Survival, Boss, and Arena Bot as complementary surfaces after Campaign and Free responsibilities are clear

Scope:

- position Survival as an endurance challenge
- position Boss as mastery/execution practice
- position Arena Bot as kit training or combat testing
- add light diegetic framing such as training, trials, simulations, or challenge arenas
- separate account progression from score, mastery, and extra-mode results

Acceptance:

- extra modes use permanent unlocks coherently
- extra modes do not read as campaign replacements
- UI/result copy avoids implying ranked competition, matchmaking, or equal mode pillars
- smoke docs are updated after runtime behavior changes

Implementation note:

- Runtime now frames `Survival` as a resistance challenge, `Boss` as mastery/execution practice, and `Arena Bot` as kit-training simulation; extra-mode results use `RESULTADO DO EXTRA`, record an explicit non-permanent `extra_mode` result scope, and return through `Voltar a Campanha e Extras`.

### Deferred Beyond F11

The following require separate future gates:

- co-op implementation or feasibility prototype
- Private Duel / Arena PvP networking
- Steam lobby/invite implementation
- public matchmaking, ranked PvP, or dedicated servers
- new race, new weapon, Hard route, or broader content package

## Scope Out

- Implementing co-op in this gate.
- Implementing Private Duel / Arena PvP networking.
- Adding public matchmaking, ranked PvP, or dedicated servers.
- Adding a new race, new weapon, Hard route, or broader content package unless a future gate chooses it explicitly.
- Rewriting historical phase documents.

## Acceptance

- A fresh player is visually and functionally guided toward Campaign first.
- Classic campaign remains the first-player progression and unlock path.
- Free is documented and/or implemented only as post-Classic replay/buildcraft.
- Survival, Boss, and Arena Bot no longer read as product pillars equal to Campaign.
- Arena PvP is not presented as a normal public-facing promise.
- UI copy consistently uses campaign-first and kit-first language.

## Validation

- `tools/validate.gd` remains green after runtime changes.
- GUT coverage expands when each runtime slice changes.
- Manual smoke docs are updated only after matching runtime behavior exists.
- No test should require Steam, co-op, matchmaking, ranked PvP, or dedicated servers for this gate.
