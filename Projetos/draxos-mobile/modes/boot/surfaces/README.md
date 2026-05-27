# Boot Surface Presenters

Render-only presenters for the Internal Alpha Boot hub.

- `shell_surface_presenter.gd` owns app chrome rendering: background, header, nav, content stack, scroll body and confirmation dialog.
- `hub_surface_presenter.gd` composes the Hub surface by delegating account/session sections.
- `hub_account_surface_presenter.gd` owns login, quick test, active save, session status, update gate and screen links.
- `battle_replay_presenter.gd` owns Battle tab visual replay rendering and timeline updates while the simulator/reward flow stays in `boot.gd`.
- `base_surface_presenter.gd`, `social_surface_presenter.gd`, `competition_surface_presenter.gd` and `shop_surface_presenter.gd` own render-only tab state, panels and controls.
- `battle_surface_presenter.gd` remains as the initial scaffold wrapper for the battle tab and will be retired once replay extraction stabilizes.

Presenters may create controls and assign host UI references. Actions, network calls, Auth, Supabase configuration, SessionStore mutations, manifest fetching and BackendConfig remain host-owned.
