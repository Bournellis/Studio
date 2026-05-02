# Track 02 Progress Log

## 2026-04-25 - F11-E Extra Mode Framing And Progression Cleanup Implemented

- Reframed `Survival` as a resistance challenge, `Boss` as mastery/execution practice, and `Arena Bot` as kit-training simulation across mode metadata, frontend copy, HUD text, result summaries, and smoke docs.
- Added explicit `extra_mode` result scope for Survival, Boss, and Arena Bot so score/mastery outcomes state that permanent progression remains campaign-owned.
- Updated the shared result overlay so extras read as `RESULTADO DO EXTRA`, include an `Extra` section, and return through `Voltar a Campanha e Extras`.
- Updated automated frontend, shared-presentation, Survival, and Boss coverage for the new extra-mode framing.
- Updated `tools/validate.gd` to run GUT in-process, avoiding the Windows subprocess hang that left orphaned Godot validators during this slice.

## 2026-04-25 - F11-D Free Campaign Replay Implemented

- Added `blacksmith_campaign / free` as `Campanha Livre`, ordered after `Easy` and `Normal` in the campaign route catalog and gated behind `Easy` completion.
- Updated the frontend so `Livre` opens post-Classic kit preparation instead of authored Classic launch, using account-unlocked content and the canonical 4 skills / 2 potions contract.
- Updated the campaign runtime so Free uses the launch kit, skips Classic tutorial prompts, shows replay-specific briefing/reward/result copy, and does not apply permanent stage rewards.
- Expanded automated campaign, frontend, product-profile, and content-pipeline coverage for Free availability, launch parameters, unlock filtering, route resolution, and non-permanent replay rewards.

## 2026-04-25 - F11-C Kit And Loadout UX Implemented

- Reframed the frontend free-selection surface from loadout-first wording to kit preparation: `Preparar kit`, `Kit para ...`, saved kits, and kit-ready launch copy.
- Preserved the canonical `Race -> Weapon -> 4 Skills -> 2 Potions` validation for Survival, Boss, and Arena Bot while keeping Classic campaign authored and free of pre-run builder pressure.
- Updated locked skill and potion copy so missing content points back to campaign learning instead of reading as a generic permanent-pool failure.
- Updated automated frontend/loadout expectations plus active smoke docs around the kit-first runtime language.

## 2026-04-23 - F09 Second Authored Campaign Route Implemented And Validated

- Added `blacksmith_campaign / normal` as a second public authored route in the generated campaign catalog, with a distinct 5-stage Normal stage set produced through the existing `SceneGenerator` pipeline.
- Updated the frontend so `Campanha do Troll` now exposes inline `Easy` and `Normal` difficulty chips under the same campaign entry, with `Normal` visible from the start but locked until `Easy` is completed.
- Switched campaign suspended runs to route-specific keys built from campaign plus difficulty, and added a compatibility bridge that migrates legacy `Easy` suspend data into the new key on first compatible resume.
- Preserved the approved F05 and F07 contracts: stage rewards remain payload-based, Stage 5 remains the boss stage on both routes, `Boss` still unlocks only from `Easy`, and `Normal` grants no new permanent unlocks in this phase.
- Revalidated the full Godot baseline through `tools/validate.gd`, including campaign route catalog coverage, frontend difficulty selection, route-specific suspend persistence, legacy Easy migration, and the accepted Arena / Survival / Boss / Campaign regression set.

## 2026-04-23 - F07 Campaign Content Expansion Implemented And Validated

- Moved the public `blacksmith_campaign / easy` route into `definitions/campaigns/*.json` and a generated campaign catalog so campaign stage order now comes from authored data instead of a hardcoded scene array.
- Updated `CampaignStageManager` and `CampaignRoot` so route resolution, stage-count sanitation, HUD labeling, and stage loading all respect the catalog-backed route contract while keeping the current frontend surface unchanged.
- Added automated coverage for generated campaign catalogs plus a synthetic alternate route proof so F07 validates the non-hardcoded seam without exposing a second public campaign route.
- Formally adopted `Godot Content Candidate C1` as the implementation-local `Lane C` note that deepens the current Heroic / Hammer baseline before any broader race or weapon expansion.
- Revalidated the full Godot baseline through `tools/validate.gd`, including route catalog coverage and the accepted Arena / Survival / Boss / Campaign regression set.

## 2026-04-23 - Gate F09 Second Authored Campaign Route Opened

- Opened `Gate F09 - Second Authored Campaign Route` as the next official phase after the validated catalog-backed campaign surface.
- Framed the next problem as adding `Normal` as a second public route for `blacksmith_campaign` instead of opening a brand-new campaign id or broader content breadth.
- Declared route-specific suspend keys, frontend difficulty selection, and legacy suspend compatibility as required seams before the two-route campaign surface can be implemented safely.

## 2026-04-23 - F05 Reward And Expansion Implemented And Validated

- Moved the active campaign reward contract into authored `CampaignStageScene` data so each mission now owns its reward title, permanent unlocks, menu unlock messaging, and pending level-up context.
- Extended `CampaignRewardPayload` plus `PlayerProfile` with stable reward ids and an internal applied-reward ledger so suspend/resume and replay keep permanent rewards idempotent.
- Updated the campaign runtime so reward overlays, next-stage level-up flow, and the stage-4 potion auto-equip all read the authored payload instead of stage-number-specific branches.
- Kept free-loadout modes in the official F05 posture where locked content stays visible but disabled with campaign guidance copy instead of disappearing from the builder.
- Revalidated the full Godot baseline through `tools/validate.gd`, including GUT coverage for scene-authored reward payloads, reward resume idempotency, builder unlock filtering, and Boss unlock persistence.

## 2026-04-21 - Gate F05 Reward And Expansion Opened

- Opened `Gate F05 - Reward And Expansion` as the next proposed phase after the accepted campaign framework.
- Framed the next problem as reward-contract consolidation plus builder-mode unlock posture, instead of immediately broadening authored map count.
- Declared the first expansion seam around staged reward payloads, permanent account unlock communication, and suspend-safe reward persistence.

## 2026-04-21 - Direct Menu Shell And Grouped Frontend Landed

- Reframed the canonical shell so boot now lands directly in the frontend and `Campanha do Troll` routes first-time players into Mission 1 / Tutorial.
- Split the frontend into `Aventura` and `Versus`, exposing `Campanha do Troll`, `Survival`, `Boss`, `Arena Bot`, and `Arena PvP` with updated product gating.
- Introduced authored-campaign frontend behavior so the campaign no longer depends on the free loadout builder while `Survival`, `Boss`, and `Arena Bot` still do.
- Added a development-only `Liberar tudo (dev)` toggle to speed up local testing without redefining the product-facing lock state.
- Updated canon, gate notes, smoke docs, and automated coverage around the new direct-menu contract.

## 2026-04-21 - Track 02 Opened

- Opened `Track 02 - Canonical Product Foundation` to reframe the accepted local baseline as `B0` internal foundation instead of the product roadmap.
- Introduced a per-phase gate model as the default operational rule for future product work.
- Declared the parallel art track as proxy-first and phase-coupled rather than a separate ungoverned stream.

## 2026-04-21 - Meta Foundation And Tutorial Bootstrap Landed

- Added a canonical bootstrap scene that routes the first boot into the mandatory tutorial and returns later boots to the frontend.
- Added `PlayerProfile`, `ProfileStore`, `ProgressionResolver`, and `ModeAvailabilityResolver` as the first persisted product-meta layer.
- Added a first tutorial-authored runtime slice using the existing hammer or troll baseline, with first-skill unlock and profile completion.
- Updated the current frontend so product lock state keeps `Survival` available after tutorial while `Boss` and `Arena` remain blocked.
- Expanded automated coverage for boot routing, profile persistence, tutorial completion, and the updated frontend lock posture.

## 2026-04-21 - Campaign Framework Landed

- Added `Gate F03 - Campaign Framework` as the approved campaign-phase contract for Track 02.
- Added a first local `Campanha` mode that runs `Campaign 1 / Classic - Easy` through a staged three-step runtime on the shared combat shell and result flow.
- Extended `ProfileStore`, `ProgressionResolver`, and `ModeAvailabilityResolver` so campaign completion persists locally and unlocks `Boss` in the product frontend.
- Updated the frontend so `Campanha` becomes the default post-tutorial journey while `Survival` remains available and `Arena` stays internal.
- Expanded automated coverage for campaign launch, campaign completion persistence, Boss unlock gating, and the shared presentation contract around the new mode.
