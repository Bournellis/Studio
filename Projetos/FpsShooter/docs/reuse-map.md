# FpsShooter Reuse Map

- Last updated: `2026-06-09`
- Status: `VIVO`

## Purpose

This document records what `FpsShooter` can reuse from the studio without accidentally importing another project's product identity.

## Approved Reuse

| Source | Use | Boundary |
|---|---|---|
| `Projetos/rpg-isometrico/` | 3D body, arena, simple bot, HUD/feedback and GUT validation references. | Reference and narrow adaptation only; no isometric camera, campaign, loadout or action RPG contract. |
| `Projetos/draxos-mobile/` | Multi-agent workflow, docs index pattern, validation profile thinking and future release discipline. | No Supabase, Cloudflare, mobile-first, backend, account/save or internal alpha machinery. |
| `Projetos/draxos-roguelike-cardgame/` | Lab/report philosophy for future tuning and bot/weapon test matrices. | No cardgame, run, economy, Souls, relics, deck or combat systems. |
| `Projetos/rpg-turnos/` | Clean separation between project docs, implementation tracks, runtime and data. | No RPG exploration, card battle, class or progression systems. |

## Initial Technical References

- `rpg-isometrico/gameplay/combat/combat_body_3d.gd`
- `rpg-isometrico/gameplay/bot/simple_bot_controller.gd`
- `rpg-isometrico/modes/arena/arena_root.gd`
- `rpg-isometrico/tests/unit/test_arena_runtime.gd`
- `rpg-isometrico/autoloads/app_bootstrap.gd`
- `draxos-mobile/tools/validate.gd`
- `draxos-roguelike-cardgame/docs/design-lab.md`
- `draxos-roguelike-cardgame/docs/autorun-lab.md`

## Explicit Non-Reuse

- DraxosMobile online/backend/account/save contracts.
- Draxos Roguelike card/deck/run systems.
- RPG Turnos turn-based battle systems.
- RPG Isometrico campaign/loadout/isometric mode contracts.
- Any promise that this is a lore-canon Draxos product.
