# DraxosMobile - Documentation Index

- Status: `VIVO`
- Last updated: `2026-06-09`
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
| `docs/multi-agent-workflow.md` | `VIVO` | Parallel lane/mode workflow, worktree rules, templates and handoff protocol for DraxosMobile hardening work. |
| `docs/hardening-program.md` | `VIVO` | Long-term hardening/refactor guardrails, change matrix and validation profile mapping for the current package. |
| `docs/hardening-platform-v1-readiness-report.md` | `HISTORICO` | Published readiness report for Hardening Platform V1, the previous multi-mode platform baseline. |
| `docs/foundation-hardening-v2-readiness-report.md` | `HISTORICO` | Published readiness report for Foundation Hardening V2, the previous multi-mode expansion enforcement baseline. |
| `docs/backend-own-boundary.md` | `CONTRATO` | Backend Proprio boundary inventory for future Supabase-to-owned-backend planning without runtime refactor. |
| `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` | `VIVO` | Portfolio source of truth. |
| `../../08_Coordenacao_Agentes/Estado_Atual.md` | `VIVO` | Compact studio snapshot. |
| `../README.md` | `VIVO` | Project registry. |

## Product And Design

| Document | Category | Role |
|---|---|---|
| `docs/product-vision.md` | `VIVO` | Local long-term product canon until promoted to shared canon. |
| `docs/pve-arena-initial-direction.md` | `VIVO` | Current early-game direction: Arena PVE first, PVP later, no combat cooldown, locked loadout, temporary stat buffs and duel-list scaling. |
| `docs/pve-arena-v1.md` | `VIVO` | Implemented local Track 18 Arena PVE contract for arenas, enemies, temporary buffs, rewards, endpoints, schema and lab modeling. |
| `docs/arena-pve-season1-loop-v1.md` | `VIVO` | Preserved Arena PVE Season 1 Loop v1 delivery: grouped arena/difficulty selection, S1 progress/reward preview, contextual summary and active buff recovery hardening. |
| `docs/arena-pve-menu-flow-simplification-v1.md` | `VIVO` | Preserved Arena PVE menu-flow simplification package: selection hierarchy, CTA ordering, Preparacao placement and active/buff menu ordering without content/tuning expansion. |
| `data/definitions/pve_arena_difficulties.json` | `CONTRATO` | Track 20 Season 1 Arena tier matrix: arena/difficulty ids, recommended level/power, enemy sequence, reward profile and clear-rate target. |
| `data/definitions/season_1_progression_targets.json` | `CONTRATO` | Track 20 Season 1 XP/milestone target contract; declares `arena_tuning_power_v1` as PVE tuning metadata only. |
| `docs/foundation-app-v0-audit.md` | `HISTORICO` | Closed audit compass: real foundation, current mock, live-product gaps and post-login loop focus preserved as context. |
| `docs/foundation-expansion-readiness.md` | `RUNBOOK` | Active expansion-readiness gate: lanes, ownership, contract-first requirements, account/save, ruleset and admin checks. |
| `docs/foundation-loop-audit.md` | `VIVO` | Executed audit of the historical post-login app-shell loop ergonomics; records Foundation Loop UX Pass 01 as an accepted Internal Alpha UX baseline before Arena PVE became the product loop. |
| `docs/foundation-responsive-layout-contract.md` | `CONTRATO` | Responsive guardrail for Entry Labs, Refugio and Battle safe frames across Android portrait and Web/Desktop viewports. |
| `docs/visual-direction-v1.md` | `VIVO` | Current client visual direction for the Foundation Loop and Social Basico build; defines surface accents, component rules and non-goals. |
| `docs/battle-presentation-v1.md` | `VIVO` | Current Battle Presentation v1 package: client-only readability pass for running battle, summary and current-battle logs. |
| `docs/battle-drama-v1-1.md` | `VIVO` | Follow-up client-only battle drama/readability pass for visible Web difference after Battle Presentation v1. |
| `docs/battle-preparation-complete-v1.md` | `VIVO` | Current Battle Preparation Complete v1 package: real Arena PVE preparation/loadout editor, `POST /build/equip`, enriched build state and published Internal Alpha release snapshot. |
| `docs/behavior-potion-crafting-v1.md` | `VIVO` | Current technical reference for behavior/potion/crafting systems now present in the alpha baseline: whole-number Ossos, Po de Osso, Fogueira station crafting, simple potions, potion slot and behavior controls. |
| `docs/progression-clarity-v1.md` | `VIVO` | Published Progression Clarity v1 package: client-only readability for level, power, rewards, next unlocks and next objective. |
| `docs/first-session-clarity-v1.md` | `VIVO` | Published First Session Clarity v1 package: client-only first-session guidance for Refugio, Arena PVE preparation and battle summary. |
| `docs/minigames/mode-catalog.md` | `VIVO` | Official V1 catalog for Basebuilder, Autobattler, Towerdefense, Cardgame and Openworld. |
| `docs/minigames/basebuilder.md` | `VIVO` | Basebuilder mode doc and descriptor pointer for current Refugio/Base ownership. |
| `docs/minigames/autobattler.md` | `VIVO` | Autobattler mode doc and descriptor pointer for current Arena PVE ownership. |
| `docs/minigames/openworld.md` | `VIVO` | Current Openworld Bosque design/implementation contract, including client-owned active play, checkpoint-first persistence and server-owned reward/completion authority. |
| `docs/minigames/openworld-objectives.md` | `VIVO` | Product-intent guardrail for Bosque Mecanico Basico v2: free relaxing collect/deposit/craft/build minigame, orientation not mandatory objective. |
| `docs/minigames/openworld-decision-pack.md` | `VIVO` | Decision pack preserving Openworld Bosque as the only approved slice and blocking expansion without a package decision. |
| `data/definitions/openworld/forest_ruleset_v1.json` | `CONTRATO` | Active Internal Alpha ruleset definition for Openworld Bosque snapshot/events/resources/recipes. |
| `docs/minigames/towerdefense.md` | `VIVO` | Non-playable planned/disabled Towerdefense mode scaffold hidden from player-facing navigation. |
| `docs/minigames/towerdefense-decision-pack.md` | `VIVO` | Decision pack for future Towerdefense questions; keeps the mode planned/disabled and hidden from player-facing navigation. |
| `docs/minigames/cardgame.md` | `VIVO` | Non-playable planned/disabled Cardgame mode scaffold hidden from player-facing navigation. |
| `docs/minigames/cardgame-decision-pack.md` | `VIVO` | Decision pack for future DraxosMobile Cardgame questions; blocks inheritance from the Steam roguelike cardgame. |
| `docs/minigames/mode-template.md` | `RUNBOOK` | Template for future mode docs and descriptor scaffolds. |
| `data/definitions/modes/` | `CONTRATO` | Declarative mode descriptors and non-playable placeholders for the five official modes. |
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
| `docs/contracts/minigame-integration.md` | `CONTRATO` | Contract-first gate for official modes and future playable integrations. |
| `docs/contracts/mode-integration.md` | `CONTRATO` | Compatibility pointer for Foundation Expansion Readiness gates; canonical content lives in minigame-integration. |
| `docs/contracts/minigame-platform-v1.md` | `CONTRATO` | V1 `/modes` registry/session/progress/admin/analytics/reward bridge contract. |
| `docs/contracts/reward-bridge-v1.md` | `CONTRATO` | Server-authoritative mode reward bridge and audited admin boundary for reward-adjacent operations. |
| `docs/contracts/minigame-platform-v0.md` | `HISTORICO` | Previous `/minigames` Rpgsuave-centered contract; not active in V1. |
| `docs/contracts/admin-ops.md` | `CONTRATO` | Minimum auditable admin/support/ops contract. |
| `docs/contracts/lab-heuristics.md` | `CONTRATO` | Boundary for Battle Lab and Progression Lab local heuristics, Web remote runner, generated evidence and blocked tuning decisions. |
| `docs/architecture.md` | `CONTRATO` | Technical architecture and backend boundaries. |
| `server/schema/` | `CONTRATO` | Server schema mirror. |
| `server/functions/` | `CONTRATO` | Edge Function source mirror. |
| `server/functions/_shared/pve_arena_catalog.ts` | `CONTRATO` | Generated Arena PVE runtime catalog mirror; regenerate from data, do not edit by hand. |
| `supabase/migrations/` | `CONTRATO` | Supabase migration mirror. |
| `supabase/functions/` | `CONTRATO` | Supabase function mirror. |
| `supabase/functions/_shared/pve_arena_catalog.ts` | `CONTRATO` | Generated Supabase Edge catalog mirror; must match the server mirror. |
| `modes/boot/surfaces/README.md` | `CONTRATO` | Client presenter/surface boundary. |

## Runbooks

| Document | Category | Role |
|---|---|---|
| `tools/README.md` | `RUNBOOK` | Tool commands and local validation entrypoint. |
| `tools/check_hardening_contracts.ps1` | `RUNBOOK` | Docs-safe hardening contract checker wired into `DocsOnly`. |
| `docs/release-ops-checklist.md` | `RUNBOOK` | Safe release and publication procedure. |
| `docs/ops/read-only-cli.md` | `RUNBOOK` | Ops CLI runbook for manifest/modes/status/audit/reward/session summaries without remote service role. |
| `docs/ops/latency-baseline.md` | `RUNBOOK` | Read-only request/action/surface latency baseline workflow and artifact format. |
| `docs/track-13-manual-walkthrough-gate.md` | `RUNBOOK` | Required Android/Windows/Web manual gate. |
| `docs/internal-alpha-v0.md` | `RUNBOOK` | Internal Alpha v0 runbook. |
| `docs/internal-alpha-v0-handoff.md` | `RUNBOOK` | Internal Alpha v0 handoff. |
| `docs/playtest-internal-alpha-v0.md` | `RUNBOOK` | Internal alpha checklist. |
| `docs/playtest-alpha.md` | `RUNBOOK` | General alpha playtest checklist. |
| `portal/internal-alpha/README.md` | `RUNBOOK` | Internal alpha portal operations. |
| `../../08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Doing_TEMPLATE.md` | `RUNBOOK` | Doing template for DraxosMobile hardening lanes and mode scopes. |
| `../../08_Coordenacao_Agentes/Templates/DraxosMobile_Hardening_Handoff_TEMPLATE.md` | `RUNBOOK` | Handoff template for DraxosMobile hardening lanes and mode scopes. |

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
| `implementation/tracks/track-17-foundation-expansion-readiness/` | `HISTORICO` | Delivered foundation package for future parallel expansion, Foundation Closeout, Foundation Final Polish and production readiness; Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline. |
| `implementation/tracks/track-18-pve-arena-initial/` | `HISTORICO` | Preserved Arena PVE implementation package; live Arena contract lives in `docs/pve-arena-v1.md`. |
| `implementation/tracks/track-20-season-1-arena-calibration/` | `HISTORICO` | Preserved Season 1 Arena calibration package; current data contracts live in `data/definitions/pve_arena_difficulties.json` and `data/definitions/season_1_progression_targets.json`. |
| `implementation/tracks/track-21-arena-loop-unlock-friction/` | `HISTORICO` | Preserved Arena loop unlock/friction context for Autobattler; not the current platform baseline. |
| `implementation/tracks/track-22-technical-hardening/` | `HISTORICO` | Local technical hardening track for docs compaction, release runner safety, Modes Ops removal, hotspot refactors and backend authority hardening. |

## Design Archive

| Document | Category | Role |
|---|---|---|
| `../_conceitos/mobile-universe/` | `ARQUIVO_DESIGN` | Original concept archive promoted to DraxosMobile on `2026-05-18`. |
| `../_conceitos/mobile-universe/gdd.md` | `ARQUIVO_DESIGN` | Historical complete GDD; context only. |
| `../_conceitos/mobile-universe/pendencias.md` | `ARQUIVO_DESIGN` | Historical decision context; not the live pending register. |

## Drift Rules

- A live doc must not tell agents to start from Track 04, Track 08, Track 10, Track 14, Track 15 or Track 16 as the current stage.
- A live doc must treat `implementation/current-status.md` as the active operational stage/status source.
- A live doc must treat `docs/pve-arena-initial-direction.md` as the current product direction: Arena PVE initial first, PVP later.
- A live doc must distinguish operational publication from product direction: Bosque Diegetic Launcher Foundation v1 is the current remote Internal Alpha package, release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`, preview evidence `https://56b58162.draxos-mobile-internal-alpha.pages.dev`, Portal `https://draxos-mobile-internal-alpha.pages.dev/`, Web `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`, APK/manifest `0.0.16-alpha.0` / version code `16`, minimum supported version code `13`. The next operational step is focused human playtest of this published launcher package on Web/APK. Arena PVE remains the approved early-game direction; Openworld/Bosque remains an integrated Internal Alpha slice, not approval for broad expansion. Bosque Bootstrap Authority v1, Arena PVE Bonus Visual v1, Bosque Node Cooldown ACK v1, Bosque Resume Exit Lifecycle v1, Bosque Feel & Spawn Authority v1, Bosque Persistence Rebase v1, Bosque Session Lifecycle & Durable Structures Hotfix v1, Bosque World Hub Domain Separation v1, Bosque Fogueira Potion Crafting v1, Bosque Durable Bau Mochila v1, Arena PVE Menu Flow Simplification v1, Bosque Offline-First Checkpoint v1, Bosque Sync Responsiveness v1, Arena/Bosque Visible V2, Arena/Bosque Regression Hotfix and Arena PVE Season 1 Loop v1 are previous or preserved packages, not the current publication.
- A live doc may treat `docs/pve-arena-v1.md` as the current implemented/published contract package for Arena PVE, while values marked `CALIBRAVEL_ALPHA` still require labs and human playthrough. Track 21 is preserved Arena PVE/Autobattler context over Track 20 Season 1 Arena Calibration; it must not be described as the current platform baseline.
- Parallel hardening and new mode docs must use Foundation Hardening V2 as the current baseline, Hardening Platform V1 as the previous mode-platform baseline, Track 21 as Arena loop context, Track 18 as Arena contract, Track 16 as technical behavior/potion/crafting context and Tracks 1/2 as historical alpha/lab evidence.
- A live doc must not direct agents to expand balance, weapons, spells, Battle Pass, economy, final visual identity or battle presentation beyond what the Arena PVE initial package explicitly needs.
- Foundation Audit must preserve the post-login loop as app shell, but the first playable product loop is now Refugio -> Arena PVE -> locked loadout -> duel list -> buffs/behavior between duels -> rewards -> upgrades.
- Foundation Expansion Readiness/Foundation Closeout/Foundation Final Polish is now delivered pre-expansion history preserved under the Foundation Hardening V2 baseline; base builder, PVP, expanded social or a real minigame are later packages unless explicitly selected.
- New backend/data/content features must use `account_profiles` + `game_saves`, `foundation_ruleset_v0`/registry, idempotency v1 and explicit contracts.
- Foundation Loop UX Pass 01 was manually accepted on Android/Windows/Web on `2026-05-29` and is a historical app-shell UX baseline. The current product loop is Arena PVE first: Refugio -> Arena PVE selection -> start attempt with loadout locked -> duel list -> buffs/behavior between duels -> rewards -> continue in Arena -> upgrades.
- Visual/layout changes must respect `docs/foundation-responsive-layout-contract.md` and pass `tools/smoke_responsive_layout.gd` before publication.
- Historical docs can keep old language when they are clearly historical.
- Product-facing language should use Instrumento Ritual, Doutrina and Familiar.
- Potion/crafting/behavior systems exist in the current alpha baseline. `pocao_vida`, `pocao_foco` and `pocao_resguardo` are the approved simple potions; any additional potions, custom thresholds, spell priorities or enemy-specific behavior require another explicit package decision.
- Technical field names such as `weapon`, `passive`, `pet`, `WeaponQualityTier`, `PassiveLevelsTotal` and `PetLevel` may remain only where they describe existing schema, telemetry or legacy compatibility.
- New pending design questions must go to `docs/design-pending.md`, not historical track docs.
