# Steam Platform Strategy

## 1. Purpose

This document defines the shared platform strategy for Steam-facing release work.

It is engine-neutral and governs:

- release networking expectations
- cloud save behavior
- leaderboard submission seams
- cosmetic ownership confirmation seams

---

## 2. Shared Scope

Steam is the primary release platform for the project.

Steam-facing integrations include:

- optional multiplayer networking for release builds
- lobby/invite flow for co-op or private duel when those surfaces are explicitly opened
- Steam Cloud
- Steam Leaderboards
- cosmetic ownership and purchase confirmation seams

Current online posture:

- Release 1 remains campaign PvE-first and solo-first unless optional co-op proves safe
- co-op may use host authority and does not require dedicated servers
- private duel, if promoted later, is direct-invite and casual/social
- public matchmaking, ranked PvP, and dedicated servers are not current requirements

---

## 3. Boundary Rule

Steam integration belongs to `Online` and `Composition`.

Rules:

- gameplay code must not call Steam APIs directly
- mode logic must emit results through shared contracts
- Steam submission and ownership checks happen at menu or result boundaries, not inside combat logic
- lobby, invite, and transport concerns must stay behind `Online` and be wired by `Composition`

---

## 4. Data Rule

Local persistence remains the base source of truth.

Steam Cloud wraps local saves; it does not replace them.

Rules:

- failed sync must not block local save completion
- gameplay must not block waiting for Steam services

---

## 5. Leaderboard Rule

Leaderboard submission happens only at natural result boundaries.

Rules:

- no partial-run submissions
- no submission logic inside combat ticks
- result presenters or equivalent mode-end seams are the correct integration point
- private duel has no leaderboard requirement in the current plan

---

## 6. Timing Rule

Steam platform work should open only when the active implementation baseline already preserves:

- clean mode-end result seams
- local-first persistence
- stable frontend or return boundaries
- clear separation between gameplay and platform adapters
- an explicit product gate for the online surface being opened

Steam dependencies should stay out of gameplay code until local implementation work explicitly opens the Steam-facing backlog.
