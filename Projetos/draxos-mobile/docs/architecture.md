# DraxosMobile - Architecture

- Status: `VIVO`
- Last updated: `2026-06-14`
- Scope: runtime architecture, authority boundaries and stabilization guardrails.

This document explains how the current DraxosMobile foundation is meant to be
worked on. It does not carry the current package name, release root, preview URL
or version codes. Operational state lives in `implementation/current-status.md`;
package lineage lives in `docs/release-history.md`.

## Product Shape

DraxosMobile is a PVE Arena-first async autobattler with Refugio/Base,
server-authoritative progression, social systems and later PVP. The current
Openworld/Bosque slice is an Internal Alpha mode and launcher/shell integration,
not approval for broad continuous-open-world expansion.

Current hardening work must stabilize the foundation before new expansion:

- no new PVP, economy, weapons, spells, potions, final visuals or broad
  Openworld content without explicit decision;
- no refactor that weakens RLS, idempotency, ledger, auth verification or
  account/save authority;
- no remote mutation or publication from validation commands.

## Stack

| Layer | Technology | Notes |
|---|---|---|
| Client | Godot `4.6.2-stable` / GDScript | UI, input, replay presentation and local non-authoritative cache. |
| Backend | Supabase Auth, Postgres, Edge Functions | Current alpha runtime and server-authoritative mutation layer. |
| Transport | REST through Godot `HTTPRequest` | Client sends intent; server returns authoritative state/logs. |
| Client tests | GUT `9.6.0` plus Godot smoke scripts | Responsive, shell, mode and replay regressions. |
| Server tests | Deno/TypeScript | Edge Function contracts, schema mirrors, labs and remote read-only smokes. |

## Authority Model

The client never owns durable gameplay results. It may preview local UI state,
cache server snapshots and animate battle logs, but durable state is owned by
server functions and Postgres.

| Domain | Authority | Client role |
|---|---|---|
| Account identity | Supabase Auth + `account_profiles` | Hold token and request account state. |
| Save/progression | `game_saves` and server functions | Select active save and display snapshots. |
| Battle/Arena result | Edge Functions + simulator + Postgres | Request duel, animate `battle_log_v1`, never recompute rewards. |
| Economy/ledger | Postgres transactions through Edge Functions | Send intent only. |
| Base production | Server-calculated on reconnect/collect | Display state and pending timers. |
| Social/guild/chat | Account-scoped server functions | Submit messages/actions, display sanitized state. |
| Openworld/Bosque | Local feel + server checkpoint/complete/reward authority | Preview movement and queued ops; save through accepted checkpoints. |
| Labs | Offline/report evidence | Inform tuning decisions; never become runtime authority. |

Non-negotiable invariants:

- `account_profiles` remains account authority.
- `game_saves` remains save/progression authority.
- `players.save_type` remains compatibility only.
- Mutations that can change durable gameplay state require idempotent
  `request_id/request_hash` behavior where the contract says so.
- Economic rewards must pass through ledger/resource transaction paths.
- Service-role access stays inside Edge Functions/server operations, never in
  client/export/portal files.

## Backend Layout And Mirror Policy

`server/` and `supabase/` are intentionally mirrored during the alpha:

```text
server/functions/              authoring mirror for Edge Functions
supabase/functions/            Supabase runtime mirror
server/schema/migrations/      authoring mirror for SQL migrations
supabase/migrations/           Supabase CLI runtime mirror
```

The mirror must remain byte-identical for comparable paths. The desired
hardening direction is:

1. edit the authoring side;
2. sync/generate the runtime mirror deterministically;
3. validate directory equality before any server gate;
4. never hand-edit one side without immediately syncing and proving equality.

`validate_foundation.ps1 -Profile ServerQuick` already compares the mirrors and
checks both Deno function trees. New tooling may add a safer explicit sync step,
but must not change runtime behavior.
Use `tools/sync_backend_mirror.ps1 -Check` to detect drift and `-Apply` to
synchronize `server -> supabase` without changing runtime contracts.

## Edge Function Boundaries

Endpoint groups declare scope before implementation:

| Scope | Examples | Authority |
|---|---|---|
| `save-scoped` | `account`, `battle`, `base`, `build`, `crafting`, `arena/pve`, `competition`, `monetization`, `progression-lab` | Resolve account/save on server and mutate only through contracts. |
| `account-scoped` | `social` | Use account identity and validate save where needed. |
| `release` | `release`, manifest/download endpoints | No gameplay authority; publication still requires explicit user approval. |
| `telemetry` | `telemetry/client-event` | Append-only diagnostic data; no reward/progression mutation. |
| `admin-internal` | internal ops only | Service-role-only and not exposed as player-facing client authority. |

## Client Shell

The Godot boot/runtime shell is the app surface, not a temporary boot script. It
owns route rendering, action dispatch, online state, surface refresh, labs entry
and overlay/modal coordination.

Important shell contracts:

- `SessionStore` stores only non-authoritative snapshots and local cache.
- `SupabaseClient` is the HTTP adapter and never contains secrets.
- Surface presenters render UI and must not mutate durable state directly.
- Flow/action modules send intentions to server functions.
- Overlay shell must preserve layer order, focus, route readiness and real Web
  input behavior for Social, Shop and Arena.
- Responsive and mode visual smokes protect Android portrait and PC browser
  layouts.

Hotspot hardening priority:

1. split overlay layer/focus/modal/readiness responsibilities behind the current
   facade;
2. split large tests by surface when practical;
3. preserve real interaction smokes for every bug class found by human playtest.

## Arena PVE Architecture

Arena PVE is the first approved core. Product direction lives in
`docs/pve-arena-initial-direction.md` and the Arena section of the GDD;
runtime boundaries live in `docs/contracts/` and authored Arena definitions.

Key runtime rules:

- tutorial is one duel;
- first real arena is a three-duel run;
- loadout is locked at attempt start;
- HP resets to full before each duel;
- temporary stat buffs are chosen between victories;
- defeat or abandon ends the attempt according to the server contract;
- `/arena/pve/claim` remains summary/ack and must not mutate economy;
- reward/progression is applied by the authoritative duel/attempt flow.

Labs currently provide technical evidence for Arena S1, but human playtest must
decide whether the loop is clear, paced and satisfying before any broad tuning
or content expansion.

## Openworld/Bosque Architecture

Bosque is an active Internal Alpha slice through the mode platform. It validates
movement feel, collection, local/offline-first preview, launcher integration and
checkpoint/reward boundaries.

Bosque must not silently become a broader Openworld product. Expansion such as
map growth, combat, quests, NPCs, new economy or new reward bridges requires a
separate decision pack and validation plan.

Current persistence principles:

- local movement/collection can feel immediate;
- durable progress, completion, caps, reward and ledger belong to the server;
- checkpoints with ACK are the normal integrated save path;
- pending local operations must be recoverable and visible;
- completion/reward depends on accepted checkpoint state.

Hotspot hardening priority:

1. split session lifecycle from persistence/checkpoint concerns;
2. isolate pending ops and durable progress cache behavior;
3. make stale checkpoint/resume/abandon cases testable;
4. keep the public bridge facade stable while extracting helpers.

## Mode Platform

Official modes are governed by `docs/minigames/mode-catalog.md` and
`docs/contracts/minigame-platform-v1.md`.

| Mode | Current status | Boundary |
|---|---|---|
| `basebuilder` | active | Refugio/Base and permanent progression structures. |
| `autobattler` | active | Arena PVE first core. |
| `openworld` | active in Internal Alpha | Bosque slice only; no broad expansion by default. |
| `towerdefense` | planned disabled | Hidden until decision pack + contracts + rewards. |
| `cardgame` | planned disabled | Hidden; no mechanical inheritance from other Draxos projects. |

No new mode becomes player-facing by adding JSON alone. It needs design
approval, server registry, ruleset, disable/rollback path, tests, telemetry,
reward bridge rules when relevant and human approval.

## Release And Validation Boundaries

Validation profiles are coordinated by `tools/validate_foundation.ps1`.

| Profile | Use |
|---|---|
| `DocsOnly` | Documentation/state/tooling sanity; no publication. |
| `ServerQuick` | Mirrors, Deno checks/tests and backend contract guards. |
| `ClientQuick` | GUT/client, responsive and shell/layout smokes. |
| `ModePlatform` | Mode registry and Bosque/Openworld platform guards. |
| `ReleaseDryRun` | Local release safety planning only. |
| `RemoteReadOnly` | Read-only verification of expected remote artifacts. |

`FullPublish` is disabled in validation. Upload, deploy, manifest mutation,
`supabase db push`, secrets or Cloudflare/Supabase mutation require explicit
approval and the publication scripts with `-ConfirmRemoteMutation`.

## Stabilization Order

1. Fix docs/state governance and make `DocsOnly` reflect the single source of
   operational state.
2. Add deterministic mirror sync/check tooling without changing backend
   behavior.
3. Decompose overlay shell and Openworld bridge hotspots behind compatible
   facades.
4. Update architecture/contracts so agents read the current system rather than
   historical release logs.
5. Run Arena PVE product proof before opening tuning or expansion.

## Backend Exit Strategy

Supabase remains the alpha runtime because it accelerates Auth, Postgres, Edge
Functions, Storage and migrations. The exit strategy is still Backend Proprio +
Postgres if scale or operational needs justify it:

1. freeze HTTP contracts;
2. export schema/data;
3. port domain logic behind the same logical endpoints;
4. preserve account/save IDs, ledger and battle history;
5. validate parity before moving the client `base_url`.

Nakama should only be reconsidered if realtime matchmaking, lobbies, presence or
ready-made social/competitive systems become a central product need.
