# Boot Surface Presenters

Render-only presenters for the Internal Alpha Boot hub.

- `shell_surface_presenter.gd` owns app chrome rendering: background, header, nav, content stack, scroll body and confirmation dialog.
- `hub_surface_presenter.gd` composes the Hub surface by delegating account/session sections.
- `hub_account_surface_presenter.gd` owns login, quick test, active save, session status, update gate and direct screen/mode links, including Bosque via `open_mode_shell:openworld`.
- The old player-facing mode hub surface is retired; the shell keeps mode descriptors/registry technical, but no Mode Hub route/menu/card surface is owned here.
- `battle_replay_presenter.gd` owns Battle tab visual replay rendering and timeline updates while `battle_replay_summary.gd` owns pure summary/reward/history/log text formatting; the simulator/reward flow stays in `boot.gd`.
- `base_surface_presenter.gd`, `social_surface_presenter.gd`, `competition_surface_presenter.gd` and `shop_surface_presenter.gd` own render-only tab state, panels and controls.
- `surface_ui_helpers.gd` is the shared presenter-facing helper facade for labels, panels, responsive layout, resource/cost formatting and small visual compositions that should not live in the app shell.

T05-C retired the obsolete `battle_surface_presenter.gd` scaffold after `battle_replay_presenter.gd` became the active Battle tab renderer.

Track 12 boundary:

- `boot.gd` is the app shell host. It owns busy state, notices, visible errors, navigation, route refresh and presenter callbacks.
- `modes/boot/ui/app_shell_action_contract.gd` owns action ids, action payloads, prefix parsing, replay/update gate checks and telemetry payload classification.
- `modes/boot/flows/account_session_flow.gd` owns guest/email auth, session refresh, local reset, save selection/creation and update manifest checks.
- `modes/boot/flows/account_form_contract.gd` owns auth/signup form parsing, validation and alpha username/invite normalization without network or SessionStore mutation beyond read-only defaults/session-id fallback.
- `modes/boot/flows/surface_action_flow.gd` owns online Base, Social, Competition and Shop orchestration through Supabase/client services while keeping server authority intact.
- `modes/boot/flows/battle_lifecycle_flow.gd` owns battle requests, history/latest fetches, replay entry/skip and summary/log routing without simulating combat on the client.
- `modes/boot/ui/mode_shell_launcher.gd` owns Mode Shell screen instantiation and fullscreen fallback while preserving `open_mode_shell:<mode_id>` routes/actions.

Presenters may create controls, read already-loaded `SessionStore` snapshots, wire UI controls to host helpers and assign host UI references. They must stay render-only: no actions, network calls, Auth, Supabase configuration, SessionStore mutations, manifest fetching, telemetry or BackendConfig access.
