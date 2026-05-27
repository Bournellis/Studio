# Track 07 - Mobile Presentation Loop And Layout Rework

- Status: `ACTIVE_PRESENTATION_REWORK`
- Started: `2026-05-27`
- Depends On: `T06_INTEGRATED_FEATURE_SLICES_READY`

## Goal

Rework the DraxosMobile presentation loop around the real mobile app shape.

The app should open on the Refugio as a full-screen home, present the player around an altar/refuge scene instead of a list of tabs, support portrait and landscape for all non-gameplay app surfaces, and run the autobattler as a full-screen landscape gameplay moment.

## Locked Decisions

- App outside gameplay supports both portrait and landscape.
- The first active gameplay mode, the autobattler, is locked to landscape while battle/replay is running on Android.
- PC executable and PC browser remain functional test targets and should not depend on physical rotation.
- Progression Lab remains dev/internal and appears in the Refugio when dev tools/editor are enabled.
- Backend, schema, economy, rewards, ranking, combat simulator and HTTP contracts are unchanged in this track.

## In Scope

- Route/back-stack foundation for app screens.
- Mobile scroll/touch comfort, including drag gestures that can begin over buttons while preserving tap behavior.
- Larger and easier scroll affordances.
- Refugio full-screen home with altar/ambient center and diegetic hotspots.
- Account/login as a focused panel/drawer/modal instead of a redundant full-page list.
- Internal app screens for Base, Social, Competition and Shop with portrait/landscape layouts and clear Back behavior.
- Battle running full-screen in landscape with skip in the lower-right corner.
- Battle summary full screen after completion/skip, with stats and return actions.
- PC/Web responsive fallback for the same loop.
- Focused GUT and smoke coverage for presentation routes, Refugio, scroll/tap, battle full-screen and PC/Web compatibility.

## Out Of Scope

- Backend changes.
- Supabase schema or migration changes.
- Economy, power, bot, reward, shop, ranking or combat tuning.
- New gameplay modes.
- Real payment, realtime social, iOS, mobile browser as a primary target, remote publication or final asset rework.
- Editing `.tscn` as raw text.

## Completion Criteria

- Track 07 docs, Kanban entry, agent registry and portfolio snapshots are current.
- Global tab/list navigation is replaced by a route shell/back stack.
- Refugio is the first full-screen home and is no longer just a tab.
- App surfaces outside gameplay are usable in portrait and landscape.
- Scroll/touch behavior is comfortable on mobile and covered by tests.
- Autobattler runs as full-screen landscape gameplay with skip and final summary.
- Existing Track 06 functionality remains reachable.
- Final integration validates the client matrix plus the new mobile presentation smoke.
