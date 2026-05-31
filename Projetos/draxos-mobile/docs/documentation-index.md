# DraxosMobile - Documentation Index

- Status: `VIVO`
- Last updated: `2026-05-31`
- Purpose: classify project documents so agents know what to trust, what to update and what to treat as history.

## Categories

| Category | Meaning | Update rule |
|---|---|---|
| `VIVO` | Current operational or product truth. | Keep synchronized with observable state. |
| `CONTRATO` | Stable implementation contract for APIs, schema, content or runtime boundaries. | Update before code that depends on changed behavior. |
| `RUNBOOK` | Procedure/checklist for validation, release, QA or operations. | Update when commands, gates or safety rules change. |
| `HISTORICO` | Past track/status/context retained for traceability. | Do not edit except to fix broken references or mark archival status. |
| `ARQUIVO_DESIGN` | Design archive promoted from concept. | Read-only reference; never overrides live local docs. |

## Live Entrypoints

| Document | Category | Role |
|---|---|---|
| `AGENTS.md` | `VIVO` | Fast operating rules for agents. |
| `README.md` | `VIVO` | Short project portal. |
| `implementation/current-status.md` | `VIVO` | Decision snapshot: baseline, active stage, risks, next step and validation. |
| `docs/agent-operating-manual.md` | `VIVO` | Detailed agent runbook. |
| `docs/documentation-index.md` | `VIVO` | This classification map. |
| `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` | `VIVO` | Portfolio source of truth. |
| `../../08_Coordenacao_Agentes/Estado_Atual.md` | `VIVO` | Compact studio snapshot. |
| `../README.md` | `VIVO` | Project registry. |

## Product And Design

| Document | Category | Role |
|---|---|---|
| `docs/product-vision.md` | `VIVO` | Local long-term product canon until promoted to shared canon. |
| `docs/pve-arena-initial-direction.md` | `VIVO` | Current early-game direction: Arena PVE first, PVP later, no combat cooldown, locked loadout, temporary stat buffs and duel-list scaling. |
| `docs/pve-arena-v1.md` | `VIVO` | Implemented local Track 18 Arena PVE contract for arenas, enemies, temporary buffs, rewards, endpoints, schema and lab modeling. |
| `docs/foundation-app-v0-audit.md` | `HISTORICO` | Closed audit compass: real foundation, current mock, live-product gaps and post-login loop focus preserved as context. |
| `docs/foundation-expansion-readiness.md` | `RUNBOOK` | Active expansion-readiness gate: lanes, ownership, contract-first requirements, account/save, ruleset and admin checks. |
| `docs/foundation-loop-audit.md` | `VIVO` | Executed audit of the historical post-login app-shell loop ergonomics; records Foundation Loop UX Pass 01 as an accepted Internal Alpha UX baseline before Arena PVE became the product loop. |
| `docs/foundation-responsive-layout-contract.md` | `CONTRATO` | Responsive guardrail for Entry Labs, Refugio and Battle safe frames across Android portrait and Web/Desktop viewports. |
| `docs/visual-direction-v1.md` | `VIVO` | Current client visual direction for the Foundation Loop and Social Basico build; defines surface accents, component rules and non-goals. |
| `docs/battle-presentation-v1.md` | `VIVO` | Current Battle Presentation v1 package: client-only readability pass for running battle, summary and current-battle logs. |
| `docs/battle-drama-v1-1.md` | `VIVO` | Follow-up client-only battle drama/readability pass for visible Web difference after Battle Presentation v1. |
| `docs/battle-preparation-complete-v1.md` | `VIVO` | Current Battle Preparation Complete v1 package: real Refugio loadout editor, `POST /build/equip`, enriched build state and published Internal Alpha release snapshot. |
| `docs/behavior-potion-crafting-v1.md` | `VIVO` | Current technical reference for Track 16 systems now present in the alpha baseline: whole-number Ossos, Po de Osso, first potion, crafting, potion slot and simple behavior controls. |
| `docs/progression-clarity-v1.md` | `VIVO` | Published Progression Clarity v1 package: client-only readability for level, power, rewards, next unlocks and next objective. |
| `docs/first-session-clarity-v1.md` | `VIVO` | Published First Session Clarity v1 package: client-only first-session guidance for Refugio, Preparation and battle summary. |
| `docs/battle-preparation-v1.md` | `HISTORICO` | Previous client-first preparation readability package over existing behavior endpoints. |
| `docs/product-brief.md` | `VIVO` | Short product/slice summary. |
| `docs/game-design-document.md` | `VIVO` | Implementation reference and mock/substance context; not the current expansion target. |
| `docs/design-pending.md` | `VIVO` | Only live register of unresolved design decisions. |
| `docs/character-systems-rework.md` | `HISTORICO` | Character taxonomy implemented as current mock/substance; not a priority until Foundation Audit promotes character work. |
| `docs/economy/README.md` | `HISTORICO` | Economy model and calibratable alpha values preserved as context; not a current tuning target. |
| `docs/progression-lab/README.md` | `RUNBOOK` | Progression Lab workflow vivo for review/tuning evidence; reports in dated subdocs can remain historical. |
| `docs/battle-lab/README.md` | `RUNBOOK` | Battle Lab workflow vivo for combat evidence; dated runs are historical evidence. |

## Contracts

| Document | Category | Role |
|---|---|---|
| `docs/contracts/` | `CONTRATO` | API, battle log, schema and content contracts. |
| `docs/contracts/account-save.md` | `CONTRATO` | `account_profiles` + `game_saves` account/save authority and `players.save_type` compatibility boundary. |
| `docs/contracts/ruleset-registry.md` | `CONTRATO` | Ruleset generated-as-authoring-source plus database publication registry contract. |
| `docs/contracts/minigame-integration.md` | `CONTRATO` | Contract-first gate for future minigames. |
| `docs/contracts/admin-ops.md` | `CONTRATO` | Minimum auditable admin/support/ops contract. |
| `docs/contracts/lab-heuristics.md` | `CONTRATO` | Boundary for Battle Lab and Progression Lab local heuristics, Web remote runner, generated evidence and blocked tuning decisions. |
| `docs/architecture.md` | `CONTRATO` | Technical architecture and backend boundaries. |
| `server/schema/` | `CONTRATO` | Server schema mirror. |
| `server/functions/` | `CONTRATO` | Edge Function source mirror. |
| `supabase/migrations/` | `CONTRATO` | Supabase migration mirror. |
| `supabase/functions/` | `CONTRATO` | Supabase function mirror. |
| `modes/boot/surfaces/README.md` | `CONTRATO` | Client presenter/surface boundary. |

## Runbooks

| Document | Category | Role |
|---|---|---|
| `tools/README.md` | `RUNBOOK` | Tool commands and local validation entrypoint. |
| `docs/release-ops-checklist.md` | `RUNBOOK` | Safe release and publication procedure. |
| `docs/track-13-manual-walkthrough-gate.md` | `RUNBOOK` | Required Android/Windows/Web manual gate. |
| `docs/internal-alpha-v0.md` | `RUNBOOK` | Internal Alpha v0 runbook. |
| `docs/internal-alpha-v0-handoff.md` | `RUNBOOK` | Internal Alpha v0 handoff. |
| `docs/playtest-internal-alpha-v0.md` | `RUNBOOK` | Internal alpha checklist. |
| `docs/playtest-alpha.md` | `RUNBOOK` | General alpha playtest checklist. |
| `portal/internal-alpha/README.md` | `RUNBOOK` | Internal alpha portal operations. |

## Track History

| Document | Category | Role |
|---|---|---|
| `implementation/tracks/track-00-first-slice-foundation/` | `HISTORICO` | First slice foundation. |
| `implementation/tracks/track-01-alpha-playtest-hardening/` | `HISTORICO` | Local alpha hardening. |
| `implementation/tracks/track-02-progression-lab/` | `HISTORICO` | Progression Lab tooling. |
| `implementation/tracks/track-03-internal-alpha-v0/` | `HISTORICO` | Internal Alpha v0. |
| `implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/` | `HISTORICO` | Post-handoff and hub modularization. |
| `implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/` | `HISTORICO` | Foundation stabilization and release readiness. |
| `implementation/tracks/track-06-feature-installation-rails-and-first-slices/` | `HISTORICO` | Feature rails and first slices. |
| `implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/` | `HISTORICO` | Mobile presentation loop. |
| `implementation/tracks/track-08-foundation-review-and-hardening/` | `HISTORICO` | Foundation review and hardening. |
| `implementation/tracks/track-09-portrait-entry-refuge-scene-and-visual-loop-rework/` | `HISTORICO` | Portrait entry and Refugio rework. |
| `implementation/tracks/track-10-battle-presentation-rework/` | `HISTORICO` | Battle presentation rework. |
| `implementation/tracks/track-11-product-foundation-consolidation/` | `HISTORICO` | Documentation/coordination consolidation and first boot cut. |
| `implementation/tracks/track-12-boot-decomposition/` | `HISTORICO` | Boot decomposition. |
| `implementation/tracks/track-13-validation-release-safety/` | `HISTORICO` | Validation and release safety baseline. |
| `implementation/tracks/track-14-agent-ops-foundation/` | `HISTORICO` | Agent operating foundation and documentation index baseline. |
| `implementation/tracks/track-15-mobile-ux-overhaul/` | `HISTORICO` | Prior Android portrait UX package; not the active stage. |
| `implementation/tracks/track-16-behavior-crafting/` | `HISTORICO` | Source track for behavior/crafting; use `docs/behavior-potion-crafting-v1.md` for current state. |
| `implementation/tracks/track-17-foundation-expansion-readiness/` | `VIVO` | Delivered foundation package for future parallel expansion, Foundation Closeout, Foundation Final Polish and production readiness. |
| `implementation/tracks/track-18-pve-arena-initial/` | `VIVO` | Active implementation package for Arena PVE initial: contracts, backend, client shell, labs and validation. |

## Design Archive

| Document | Category | Role |
|---|---|---|
| `../_conceitos/mobile-universe/` | `ARQUIVO_DESIGN` | Original concept archive promoted to DraxosMobile on `2026-05-18`. |
| `../_conceitos/mobile-universe/gdd.md` | `ARQUIVO_DESIGN` | Historical complete GDD; context only. |
| `../_conceitos/mobile-universe/pendencias.md` | `ARQUIVO_DESIGN` | Historical decision context; not the live pending register. |

## Drift Rules

- A live doc must not tell agents to start from Track 04, Track 08, Track 10, Track 14, Track 15 or Track 16 as the current stage.
- A live doc must treat `implementation/current-status.md` as the active stage/status source after the user chooses the next package.
- A live doc must treat `docs/pve-arena-initial-direction.md` as the current product direction after Foundation Final Polish: Arena PVE initial first, PVP later.
- A live doc may treat `docs/pve-arena-v1.md` as the current implemented/published contract package for Arena PVE, while values marked `CALIBRAVEL_ALPHA` still require labs and human playthrough. Track 19 Arena Consistency Pass is the latest product baseline, with Lab Web Export Guard as the latest published Internal Alpha hotfix and Remote Lab Runner as the current local implementation follow-up before tuning.
- A live doc must not direct agents to expand balance, weapons, spells, Battle Pass, economy, final visual identity or battle presentation beyond what the Arena PVE initial package explicitly needs.
- Foundation Audit must preserve the post-login loop as app shell, but the first playable product loop is now Refugio -> Arena PVE -> locked loadout -> duel list -> buffs/behavior between duels -> rewards -> upgrades.
- Foundation Expansion Readiness/Foundation Closeout/Foundation Final Polish is now the delivered pre-expansion gate before Arena PVE implementation/tuning; base builder, PVP, expanded social or a real minigame are later packages unless explicitly selected.
- New backend/data/content features must use `account_profiles` + `game_saves`, `foundation_ruleset_v0`/registry, idempotency v1 and explicit contracts.
- Foundation Loop UX Pass 01 was manually accepted on Android/Windows/Web on `2026-05-29` and is a historical app-shell UX baseline. The current product loop is Arena PVE first: Refugio -> Arena PVE -> locked loadout -> duel list -> buffs/behavior between duels -> rewards -> upgrades.
- Visual/layout changes must respect `docs/foundation-responsive-layout-contract.md` and pass `tools/smoke_responsive_layout.gd` before publication.
- Historical docs can keep old language when they are clearly historical.
- Product-facing language should use Instrumento Ritual, Doutrina and Familiar.
- Potion/crafting/behavior systems exist in the current alpha baseline, but new potions, custom thresholds, spell priorities or enemy-specific behavior require the Arena PVE package or another explicit package decision.
- Technical field names such as `weapon`, `passive`, `pet`, `WeaponQualityTier`, `PassiveLevelsTotal` and `PetLevel` may remain only where they describe existing schema, telemetry or legacy compatibility.
- New pending design questions must go to `docs/design-pending.md`, not historical track docs.
