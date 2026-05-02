# Candidate Lanes

- Last Updated: `2026-04-23`
- Status: `LANE C ADOPTED FOR F07`

## Purpose

This document lists the content directions that are currently compatible with both shared canon and the active Godot baseline.

It also records when one lane becomes the active implementation-local choice.

## Active Lane

- `Godot Content Candidate C1` adopts `Lane C - Deepen C0 Before Breadth` for `Gate F07 - Campaign Content Expansion`
- `Lane A` and `Lane B` remain future options, but they are not the active content direction for the current campaign-expansion seam

## Lane A - Same-Race Horizontal Expansion

Keep `Heroic` as the only authored race for now and expand breadth inside that race first.

Typical shape:

- add one new Heroic weapon
- author the minimum valid skill set for that weapon
- decide whether potions stay shared or need expansion

Why this lane exists:

- it stays close to the current C0 baseline
- it moves toward the release-horizon idea of `1 race` with a broader loadout surface

What still needs explicit choice:

- which weapon comes next
- whether the new weapon should ship with exactly 4 skills or a larger selection pool
- whether the current potion pair remains sufficient

## Lane B - Second-Race Minimum Slice

Keep `Heroic` intact and add a second race with only the minimum valid package needed to satisfy the canonical loadout contract.

Typical shape:

- add one new race
- add one weapon for that race
- add 4 valid skills for that weapon
- add 2 valid potions or confirm a shared potion rule

Why this lane exists:

- it increases race identity breadth quickly
- it tests the content pipeline against race asymmetry and multi-race frontend behavior

What still needs explicit choice:

- which race territory should be authored first
- whether potion behavior remains race-local or shared for the new race
- whether the project wants breadth across races before breadth within Heroic

## Lane C - Deepen C0 Before Breadth

Keep `Heroic + Martelo Heroico` as the only authored loadout package for now and deepen content expression around it before adding new breadth.

Typical shape:

- improve authored boss or survival variation around C0
- improve encounter vocabulary, unlock framing, or PvE expression without adding a new race or weapon
- keep the current content baseline stable while other production surfaces open

Why this lane exists:

- it preserves the smallest authored content footprint
- it may fit a team that wants campaign or progression framing before broader loadout expansion

What still needs explicit choice:

- whether deeper PvE expression is more valuable than loadout breadth right now
- how long the team wants to hold the one-race one-weapon baseline before widening it

## Next Decision Rule

As long as `Godot Content Candidate C1` remains active, campaign-expansion work should keep deepening the current C0 baseline instead of widening race or weapon breadth.

If a future thread wants to switch to `Lane A` or `Lane B`, active docs must update this file and the candidate note explicitly before that broader content-authoring thread opens.
