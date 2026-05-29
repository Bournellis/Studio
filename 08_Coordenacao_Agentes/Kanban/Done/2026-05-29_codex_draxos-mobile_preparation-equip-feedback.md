# DraxosMobile - Preparation Equip Feedback Hotfix

- Branch: `codex/draxos-mobile/preparation-equip-feedback`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--preparation-equip-feedback`
- Objective: fix the published Battle Preparation Complete v1 issue where `Equipar` appeared to do nothing from the Web/mobile preparation popup.
- Result: delivered and published. Equip/build/potion/spell behavior actions now keep/reopen the Preparation popup, show `Ultima escolha: ...`, refresh the equipped state immediately and prune stale popup action buttons during popup refresh.
- Files changed: `modes/boot/flows/surface_action_flow.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`, `modes/boot/boot.gd`, `tests/client/test_boot_mobile_ui.gd`, plus status/portfolio docs.
- Validation: GUT client `122/122` passed; `validate_foundation.ps1 -Profile Client` passed; `smoke_responsive_layout.gd` passed; `smoke_foundation_loop.gd` passed; `git diff --check` passed.
- Known validation note: `smoke_foundation_surfaces.gd` returned `NETWORK_UNAVAILABLE` while trying Supabase local auth; not a regression from this client hotfix.
- Publication: exported Internal Alpha with Android debug fallback, uploaded `internal-alpha/v0-battle-preparation-complete-v1-20260529-hotfix4`, verified public HEAD for PCK/APK/ZIP, deployed Cloudflare Pages preview `https://0fee1018.draxos-mobile-internal-alpha.pages.dev/web?cachebust=hotfix4`.
- Browser review: PASS. A real Web guest session opened Preparation, clicked `Equipar` on `Athame Hematico`, and the panel updated to `Ultima escolha: Instrumento Ritual equipado.` plus `Athame Hematico: Em uso`.
- Handoff: merge to `master` and keep human testing on Android/Windows/Web focused on Preparation loadout changes.
