# Track 15 - Mobile UX Overhaul Scope

- Status: `ACTIVE`
- Start date: `2026-05-28`
- Base: `codex/draxos-mobile/agent-ops-foundation`
- Branch: `codex/draxos-mobile/track-15-mobile-ux-overhaul`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--track-15-mobile-ux-overhaul`

## Goal

Transform DraxosMobile from a functional alpha/dev app into a comfortable internal premium Android portrait app. Refugio is the central hub. This track does not change gameplay, tuning, backend, schema, Supabase APIs, economy or authoritative flows.

## Decisions

- Refugio is the post-login hub.
- No bottom navigation; only a small floating Perfil/Ajustes button is allowed.
- Visual direction is dark premium with a light gore edge.
- Copy is direct and functional. Normal flows must not expose technical language.
- Save choice stays on the pre-login screen, directly below the login focus.
- After login/signup/guest, route directly to Refugio.
- Dev tools stay in the pre-login entry screen, collapsed under internal tools.
- Android portrait leads composition; PC/Web are adaptations.
- `assets/referenciaimagens/` can be used as reference. Runtime selections must live under `assets/ux_overhaul/`.

## In Scope

- New UI foundation tokens, sizes, panels, sheets, feedback and touch rules.
- Premium pre-login Entry with fullscreen background image, login CTA first, save selector below login, signup modal, internal tools drawer and separated danger area.
- Refugio hub scene with visual background, contextual CTA, hotspots and small floating Perfil/Ajustes action.
- Base, Loja, Social and Competicao panels integrated into the Refugio mental model.
- Battle visual pass: fullscreen portrait stage, discreet skip, result/reward summary and return CTA.
- Tests for routing, pre-login save choice, dev-only labs, post-login profile boundary, copy hygiene, touch targets, contextual CTA and battle summary.
- Local visual checkpoint screenshots for Entry, Refugio, Battle, Summary, Base and Loja when feasible.

## Out Of Scope

- Gameplay rules, battle tuning or economy changes.
- Supabase schema, SQL, Edge Functions or server simulation changes.
- Account/save migration from `players.save_type` to `account_profiles/game_saves`.
- New onboarding for real users.
- Final production art pass.
- Remote publication.

## Acceptance Criteria

- Entry keeps normal login as the first focus, shows save choice below it and keeps `Continuar` accessible before auth when a local session exists.
- Login/signup/guest route directly to Refugio.
- Labs do not appear in post-login Refugio normal flow.
- Perfil after login does not show login/signup forms.
- Normal flow copy avoids `server-authoritative`, `polling`, `snapshot`, `redeem` and `alpha` as visible labels.
- Primary controls respect mobile touch target rules.
- Refugio contextual CTA priority is result, collect, upgrade, battle.
- Battle summary shows result/reward and a primary return/evolution CTA.
- Track 15 status and documentation agree across project and studio docs.

## Validation Plan

```powershell
git diff --check
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_hardening.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_exports.gd
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { .\tools\validate_foundation.ps1 -ProjectDir . -Profile Client -RequireClean:`$false }"
```
