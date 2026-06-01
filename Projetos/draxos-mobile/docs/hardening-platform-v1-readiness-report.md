# DraxosMobile - Hardening Platform V1 Readiness Report

- Status: `DRAFT_DOCS_ONLY`
- Date: `2026-06-01`
- Lane: `coord-docs`
- Branch: `codex/draxos-mobile/hardening-coord-docs`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-coord-docs`
- Runtime touched: `no`
- Remote publication: `no`

## Summary

This draft records the coordination/readiness view for a full DraxosMobile
hardening wave around Tracks 1, 2, 16 and 18, with Track 21 kept as the latest
Arena loop package for new agents.

The report does not claim runtime readiness. It defines handoff expectations,
owner lanes, mode boundaries and blockers so implementation lanes can proceed
without reopening historical tracks or mixing remote publication into local
hardening.

## Current Package Reading

| Package | Status for this hardening wave | Use |
|---|---|---|
| Track 1 - Alpha Playtest Hardening | Historical evidence. | Alpha telemetry, offline/error recovery and playtest checklist patterns. |
| Track 2 - Progression Lab | Historical/lab evidence. | Progression Lab, Battle Lab, local-only session guard and playtest evidence flow. |
| Track 16 - Behavior And Potion Crafting | Technical baseline in current alpha. | Potion slot, Po de Osso, crafting, simple spell/potion behavior and lab coverage. |
| Track 18 - PVE Arena Initial | Implemented Arena PVE domain contract. | Arena attempts, steps, progress, buffs, rewards, client shell and labs. |
| Track 21 - Arena Loop Unlock And Friction Pass | Latest Arena loop package for new agents. | Tutorial unlock fix, XP -> level recalculation, direct Arena start and continue-in-Arena summary flow. |

## Lane Readiness Matrix

| Lane | Readiness | Evidence to preserve | Next owner action |
|---|---|---|---|
| `coord-docs` | Ready for handoff after docs validation. | `docs/multi-agent-workflow.md`, DraxosMobile templates, this report and Handoff note. | Keep docs in sync after other lanes finish. |
| `backend-schema` | Planned. | Track 18 API/schema contracts, Track 21 migration/RPC behavior, Track 13 release guardrails. | Confirm no new schema/API work starts without contract update and Deno checks. |
| `session-data` | Planned. | `account_profiles/game_saves`, idempotency v1, replay/history and live-stock potion consumption. | Audit save ownership and idempotency against Arena and modes without using `players.save_type` as new authority. |
| `client-shell` | Planned. | Track 21 direct Arena route, summary continue flow, responsive contract and GUT/client gates. | Harden Entry/Refugio/Arena shell only inside responsive/budget contracts. |
| `mode-scaffolds` | Planned. | Mode Platform V1 registry, active/staged mode states and `/modes` contract. | Keep Basebuilder/Autobattler active, Openworld internal, Towerdefense/Cardgame disabled. |
| `platform-v1` | Planned. | `docs/contracts/minigame-platform-v1.md`, reward bridge, admin/ops and analytics contract. | Review cross-mode boundaries before any mode starts mutating rewards or sessions. |
| `validation-release` | Planned. | Track 13 safe modes, Track 18/21 validation matrices and remote read-only smoke policy. | Define local gates first; no upload/deploy/manifest mutation without approval. |

## Mode Readiness Matrix

| Mode | Current readiness | Hardening focus | Blocked without decision |
|---|---|---|---|
| `basebuilder` | Active foundation surface. | Save/account authority, resource ledger, clear return loop from Arena rewards. | New economy, new buildings, broad tuning. |
| `autobattler` | Active product core through Arena PVE. | Track 21 tutorial -> 3-duel unlock, buffs, potion stock, summary/claim semantics. | PVP, victory prediction, counter-picks, enemy-specific behavior, custom thresholds. |
| `openworld` | Internal alpha mode. | Mode entry isolation and naming consistency. | Expanded openworld content, campaign, rewards beyond approved bridge. |
| `towerdefense` | Staged/disabled. | Disabled affordance and registry clarity. | Any playable tower defense slice or reward. |
| `cardgame` | Staged/disabled. | Disabled affordance and registry clarity. | Any mechanical link to `draxos-roguelike-cardgame`. |

## Required Evidence Per Implementation Lane

Backend/schema:

- contract diff before code;
- mirrored server/supabase function or migration evidence;
- Deno check/test output;
- idempotency and rollback notes;
- explicit statement if remote mutation was not run.

Session/data:

- account/save authority touched or preserved;
- request id/hash behavior;
- replay/history and reward mutation ownership;
- migration/ruleset impact, if any.

Client shell:

- route/surface touched;
- responsive contract impact;
- GUT/client or smoke evidence;
- screenshots only when visual/layout changed.

Mode scaffolds/platform:

- mode registry impact;
- active/staged/disabled state by mode;
- reward bridge/admin/analytics impact;
- `/modes` compatibility and no `/minigames` revival unless explicitly required.

Validation/release:

- local gate chosen and result;
- release Plan/Package result if executed;
- remote read-only smoke result if authorized;
- clear note that Upload/DeployManifest/FullPublish were not run unless approved.

## Blockers And Risks

- Human playtest of the Track 21 tutorial -> 3-duel unlock loop remains the
  current product check before tuning.
- Android APK still uses `debug_fallback` in published alpha artifacts unless a
  release keystore package is selected.
- Broader tuning, new potions, new weapons, new spells, PVP, direct chat,
  moderation, advanced replay controls and economy expansion remain blocked
  until explicit package decisions.
- Portfolio/status docs may record later link/status hotfixes around the
  published alpha. New agent entrypoints for this hardening wave should still
  treat Track 21 as the latest Arena loop package unless Fabio selects a newer
  implementation branch.
- No full runtime, Deno, Godot, Supabase or release validation was executed by
  this coord/docs lane. Its validation is documentation-only.

## Draft Recommendation

Proceed with parallel hardening lanes only after each lane registers a Doing
note from the DraxosMobile template and declares a narrow write scope. Use Track
21 as the current Arena loop package, Track 18 as the Arena contract, Track 16
as technical behavior/potion context and Tracks 1/2 as historical alpha/lab
evidence.

Do not publish remotely from a hardening lane unless Fabio explicitly changes
the task into a release/publication task.
