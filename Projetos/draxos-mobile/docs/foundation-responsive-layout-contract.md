# DraxosMobile - Foundation Responsive Layout Contract

- Status: `CONTRATO`
- Last updated: `2026-06-05`
- Stage: `BOSQUE_V3_UX_FEEL_PUBLISHED_INTERNAL_ALPHA`

This contract exists because Foundation Loop UX Pass 01 exposed a dangerous visual regression pattern: immersive screens could look acceptable in one viewport while overflowing or being clipped in Android/Web builds. It remains a live guardrail after Foundation Final Polish.

## Current Scope

This contract covers the current foundation loop surfaces:

- Entry/internal tools
- Refugio first screen
- Battle running
- Battle summary
- Battle logs
- Arena selection
- Arena loading/sync shell
- Arena active attempt
- Arena buff choice
- Arena replay
- Arena summary
- Bosque/Openworld fullscreen mode shell

It does not define final art direction, final battle presentation or final navigation style. Those remain later decisions.

## Required Format

- Immersive surfaces must render inside a named safe frame:
  - `RefugeSafeFrame`
  - `BattleSafeFrame`
- Background art may fill the full viewport, but interactive UI must stay inside the safe frame.
- Android portrait viewports must fit at least `360x800` and `390x844`.
- Web/desktop viewports must fit at least `1280x720` and `1920x1080`.
- Wide web/desktop layouts must cap immersive UI width through `DraxosMobileUiContract.IMMERSIVE_SAFE_MAX_WIDTH`.
- Entry must expose `Ferramentas internas`, `Battle Lab` and `Progression Lab` when `draxos_mobile/internal_alpha/dev_tools_enabled=true`.
- Scrollable entry/app-shell content may extend vertically inside scroll containers, but must not overflow horizontally.
- Refugio and Battle fixed immersive controls must not overflow horizontally or vertically.
- Arena app-shell routes must keep body content, panels and CTAs inside the viewport horizontally; scrollable content may extend vertically only inside the shell scroll container.
- Arena replay uses the Battle fullscreen replay shell and therefore must satisfy `BattleFullscreenOverlay`, `BattleSafeFrame`, `BattleRunningStageFrame`, `BattleDuelVisual` and `BattleSkipButton` fit checks.
- Bosque/Openworld must satisfy the fullscreen `mode_shell` contract, with world viewport, HUD, free joystick, action buttons and inventory sheet fitting Android portrait and desktop Web viewports.

## Hard Rules

- Do not size immersive boards from `get_tree().root.size` or physical window size.
- Prefer the parent `Control`/visible viewport rect and `DraxosMobileUiContract.immersive_safe_rect()`.
- Do not place gameplay buttons using anchors outside `0.0..1.0`.
- Do not add a visual pass that changes Refugio/Battle/Arena/Entry/Openworld layout without running the responsive and mode visual smokes.
- Do not hide internal Labs in the Internal Alpha entry flow unless the user explicitly removes them from the tester workflow.

## Validation

Run this guardrail before accepting any visual/layout change:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_modes_visual_layout.gd
```

`validate_foundation.ps1 -Profile Client` runs both smokes.
