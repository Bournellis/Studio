# Boot Surface Presenters

Render-only presenters for the Internal Alpha Boot hub.

- `shell_surface_presenter.gd` owns app chrome rendering: background, header, nav, content stack, scroll body and confirmation dialog.
- `hub_surface_presenter.gd` composes the Hub surface by delegating account/session sections.
- `hub_account_surface_presenter.gd` owns login, quick test, active save, session status, update gate and screen links.
- `battle_replay_presenter.gd` owns Battle tab visual replay rendering and timeline updates while the simulator/reward flow stays in `boot.gd`.
- `base_surface_presenter.gd`, `social_surface_presenter.gd`, `competition_surface_presenter.gd` and `shop_surface_presenter.gd` own render-only tab state, panels and controls.

T05-C retired the obsolete `battle_surface_presenter.gd` scaffold after `battle_replay_presenter.gd` became the active Battle tab renderer.

Presenters may create controls, read already-loaded `SessionStore` snapshots, wire UI controls to host helpers and assign host UI references. Actions, network calls, Auth, Supabase configuration, SessionStore mutations, manifest fetching, telemetry and BackendConfig remain host-owned.
