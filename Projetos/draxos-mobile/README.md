# DraxosMobile

DraxosMobile is the Godot/Supabase project for Android, PC executable and PC
browser. It is a PVE Arena-first async autobattler with Refugio/Base
management, later PVP, social systems and server-authoritative progression.

## State Pointers

- Current operational stage, package, release root, evidence, version codes,
  risks and next step: `implementation/current-status.md`
- Package history, stable endpoints, download paths and historical previews:
  `docs/release-history.md`
- Portfolio status and allowed work:
  `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`

This README is a project portal. It must not carry package names, release roots,
preview URLs, download URLs, artifact hashes, version codes or current next
steps.

## Current Product Reading

The project is a strong implemented base for refinement, not a final product and
not a content-expansion track.

Arena PVE remains the first approved product core inside `Autobattler`.
Bosque/Openworld remains an integrated Internal Alpha slice for movement,
collection, checkpoint persistence and controlled bridges to existing menus; it
is not approval for broad open-world expansion.

The historical post-login app-shell loop is preserved as context:

`Base -> collect resources -> evolve base -> battle -> receive rewards -> check base again`

The selected first product loop is:

`Refugio -> Arena PVE selection -> start attempt with loadout locked -> duel list -> temporary stat buffs and behavior prep between duels -> rewards -> continue in Arena -> upgrades`

Behavior/potion/crafting is implemented as a technical baseline: whole-number
Ossos, Po de Osso, Fogueira station crafting, simple potions, one potion slot and
simple spell/potion use preferences. Treat it as existing foundation, not as
permission to expand tuning, economy, additional potions or advanced behavior.

Current content, names, spells, weapons, economy values, battle flavor, visual
style and premium systems exist to give substance to the prototype. Treat them
as mock/substance for evaluation, not as final game direction or current tuning
priorities.

## For Agents

Start with:

1. `AGENTS.md`
2. `docs/agent-operating-manual.md`
3. `implementation/current-status.md`
4. `docs/documentation-index.md`
5. `docs/multi-agent-workflow.md`
6. `docs/foundation-hardening-v2-readiness-report.md`
7. `docs/pve-arena-initial-direction.md`
8. `docs/foundation-app-v0-audit.md`
9. `docs/foundation-loop-audit.md`
10. `docs/progression-clarity-v1.md`
11. `docs/first-session-clarity-v1.md`
12. `docs/behavior-potion-crafting-v1.md` when touching Ossos, crafting,
    potions, consumables or behavior.

Do not start from old Track 04/08/10/15/16 notes. They are history or technical
context unless a live doc points to them for a specific detail.

## Current Gate

Before any new feature, numeric tuning, assets-final pass, battle presentation
pass or social expansion:

1. Read `implementation/current-status.md`, `docs/release-history.md`,
   `docs/foundation-hardening-v2-readiness-report.md` and
   `docs/multi-agent-workflow.md`.
2. Treat Foundation Hardening V2 as the preserved multi-mode expansion
   enforcement baseline.
3. Treat Foundation Loop UX Pass 01 as historical app-shell UX baseline.
4. Treat Track 18/20/21 plus Remote Lab Runner as Arena/Autobattler/Lab context.
5. Follow `docs/pve-arena-initial-direction.md` before expanding PVP, social,
   visuals, battle presentation, base builder or content systems.
6. Keep release publishing in `Mode Plan` or `Mode Package` unless the user
   explicitly approves remote mutation.
7. Use the focused human playtest described in `implementation/current-status.md`
   as the operational gate before choosing a new package.

## Safe Validation

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile FullLocal -RequireClean
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_foundation_loop.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
git diff --check
git status --short
```

## Where Things Live

| Need | Read |
|---|---|
| Agent operation | `docs/agent-operating-manual.md` |
| Current state | `implementation/current-status.md` |
| Release history | `docs/release-history.md` |
| Documentation map | `docs/documentation-index.md` |
| Multi-agent hardening workflow | `docs/multi-agent-workflow.md` |
| Hardening readiness report | `docs/foundation-hardening-v2-readiness-report.md` |
| Arena PVE initial direction | `docs/pve-arena-initial-direction.md` |
| Arena PVE implemented contract | `docs/pve-arena-v1.md` |
| Foundation Audit | `docs/foundation-app-v0-audit.md` |
| Foundation Loop Audit | `docs/foundation-loop-audit.md` |
| Visual Direction v1 | `docs/visual-direction-v1.md` |
| Progression Clarity v1 | `docs/progression-clarity-v1.md` |
| First Session Clarity v1 | `docs/first-session-clarity-v1.md` |
| Behavior/potions/crafting | `docs/behavior-potion-crafting-v1.md` |
| Product canon local | `docs/product-vision.md` |
| Implementation GDD | `docs/game-design-document.md` |
| Pending decisions | `docs/design-pending.md` |
| Contracts | `docs/contracts/` |
| Release ops | `docs/release-ops-checklist.md` |
| Manual gate | `docs/track-13-manual-walkthrough-gate.md` |
| Historical concept archive | `../_conceitos/mobile-universe/` |

## Do Not Touch Casually

- `../_conceitos/mobile-universe/`: archive only.
- Remote Supabase/Cloudflare publication: opt-in only.
- `players.save_type` as new account/save authority: blocked.
  `account_profiles/game_saves` are the current foundation authority;
  `players.save_type` is compatibility only.
- Tuning numbers, weapons, spells, Battle Pass, economy and final visual
  identity: blocked unless required by an approved Arena PVE package.
- Secrets: never in client, exports, portal, manifest or docs.
