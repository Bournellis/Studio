# Track 01 Backlog

This file is the real backlog board for the first active Godot-first workstream.

It organizes bounded implementation candidates on top of the accepted local Arena / Survival / Boss baseline.

## Prioritization Rules

- prefer work that improves daily iteration on top of the accepted baseline
- keep scope bounded enough for a single implementation thread
- preserve the accepted mode-foundation contracts unless a concrete regression requires reopening them
- do not inherit legacy Unity phase names or legacy package assumptions as implicit direction
- keep Steam, campaign, mobile, and broad content expansion deferred unless canon and active docs explicitly open them

## Backlog Board

| ID | Priority | Status | Target Surface | Intended Outcome |
| --- | --- | --- | --- | --- |
| `T01-B01` | Done | Validated | Frontend + loadout UX | Removed validation-era copy, tightened loadout clarity, and made saved-loadout behavior easier to trust in daily use |
| `T01-B02` | Done | Validated | Shared results + return flow | Reframed post-session summaries around match outcomes, improved overlay hierarchy, and made local return cues easier to read and trust |
| `T01-B03` | Done | Validated | Local persistence baseline | Restored saved mode continuity, tightened saved-profile trust, and made stale local saves explicit instead of partially restoring them |
| `T01-B04` | Done | Validated | Arena / Survival / Boss polish | Tightened HUD readability, in-mode pacing cues, and shared shell clarity across the accepted local runtime |
| `T01-B05` | Next | Defined | Godot-first content decisions | The active Godot content-decision surface is now documented; the next step is to choose one explicit content lane from it |
| `T01-D01` | Deferred | Deferred | Steam / campaign / mobile / broad expansion | Remains outside Track 01 by default unless active docs deliberately open it |

## Completed Items

### `T01-B01 Frontend And Loadout UX Tightening`

- Delivered:
  - active frontend copy no longer frames itself as Godot validation
  - local mode summaries no longer talk in `G4` delivery language
  - summary text now shows selected race, weapon, skills, and potions more clearly
  - saved-loadout state now distinguishes between no save, incomplete current selection, saved-match state, and diverged current selection
  - frontend-flow tests now cover the refreshed copy and saved-selection behavior
- Validation:
  - `tools/validate.gd` passed after the implementation pass

### `T01-B02 Shared Results And Return Presentation Tightening`

- Delivered:
  - shared result overlay now reads as a stable post-session surface instead of a validation scaffold
  - result copy in Arena, Survival, and Boss now talks about match outcomes instead of shared-shell implementation details
  - section hierarchy is clearer through left-aligned details, explicit section headings, and a visible next-step cue
  - return flow now points to `Voltar ao menu local`, matching the actual day-to-day Godot loop
  - shared-presentation coverage and active smoke wording were updated to protect the refreshed overlay contract
- Validation:
  - `tools/validate.gd` passed after the implementation pass

### `T01-B03 Local Persistence Baseline Tightening`

- Delivered:
  - local saved profile now carries the mode context used when the loadout was last launched
  - frontend boot and manual restore now preserve the last saved local mode instead of always falling back to `Arena`
  - save-state messaging now names the saved mode when that context exists
  - incompatible saved profiles are now detected up front and kept disabled instead of partially restoring into an unclear state
  - frontend-flow coverage now protects mode continuity and stale-save failure messaging
- Validation:
  - `tools/validate.gd` passed after the implementation pass

### `T01-B04 Mode Polish On Accepted Contracts`

- Delivered:
  - shared `CombatHud` now gives clearer mid-fight reading through better status tone and a stacked recent-event feed
  - `Arena`, `Survival`, and `Boss` shell snapshots now surface more useful mode-specific cues without forking the shared HUD family
  - `Survival` rest windows now read as an explicit interval before the next wave instead of staying in a flatter generic state line
  - `Boss` shell presentation now makes life percentage, rugido readiness, and active tremor or invulnerability easier to scan
  - smoke and automated coverage now protect the refreshed in-mode readability contract
- Validation:
  - `tools/validate.gd` passed after the implementation pass

## Ready Items

There is no additional implementation item marked `Ready` right now.

The next gate is to choose one lane from the defined `T01-B05` content surface before opening the next bounded thread.

## Defined Decision Surface

### `T01-B05 Godot-First Content Decisions`

- Purpose:
  - create the next explicit content-definition surface for Godot
  - decide what content package language belongs in active docs versus canon
- Delivered:
  - `content-surface/` now records the exact Godot content baseline instead of leaving package language implied
  - active docs now define what belongs to canon versus implementation-local content docs
  - candidate content lanes now exist without forcing a premature package choice
  - the next content-authoring thread can be opened deliberately from one chosen lane instead of inherited Unity package language
- Read Next:
  - `content-surface/current-godot-content-baseline.md`
  - `content-surface/content-decision-rules.md`
  - `content-surface/candidate-lanes.md`
  - `thread-candidates/t01-b05-godot-first-content-decisions.md`

## Deferred By Default

### `T01-D01 Later Expansion`

These areas are not part of Track 01 unless active docs explicitly open them:

- Steam-facing services
- campaign implementation
- mobile controls
- broad content expansion
- large-scope roadmap resets
