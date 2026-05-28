# DraxosMobile - Documentation Index

- Status: `VIVO`
- Last updated: `2026-05-28`
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
| `implementation/current-status.md` | `VIVO` | Decision snapshot: baseline, active track, risks, next step and validation. |
| `docs/agent-operating-manual.md` | `VIVO` | Detailed agent runbook. |
| `docs/documentation-index.md` | `VIVO` | This classification map. |
| `implementation/tracks/track-15-mobile-ux-overhaul/current-status.md` | `VIVO` | Current Track 15 mobile UX working state. |
| `../../08_Coordenacao_Agentes/Prioridades_Estudio.md` | `VIVO` | Portfolio source of truth. |
| `../../08_Coordenacao_Agentes/Estado_Atual.md` | `VIVO` | Compact studio snapshot. |
| `../README.md` | `VIVO` | Project registry. |

## Product And Design

| Document | Category | Role |
|---|---|---|
| `docs/product-vision.md` | `VIVO` | Local long-term product canon until promoted to shared canon. |
| `docs/product-brief.md` | `VIVO` | Short product/slice summary. |
| `docs/game-design-document.md` | `VIVO` | Authoritative implementation GDD. |
| `docs/design-pending.md` | `VIVO` | Only live register of unresolved design decisions. |
| `docs/character-systems-rework.md` | `VIVO` | Character taxonomy: Instrumentos Rituais, Spells, Doutrinas, Familiares and damage/status sources. |
| `docs/economy/README.md` | `VIVO` | Economy model and calibratable alpha values. |
| `docs/progression-lab/README.md` | `VIVO` | Progression Lab model and review notes. |

## Contracts

| Document | Category | Role |
|---|---|---|
| `docs/contracts/` | `CONTRATO` | API, battle log, schema and content contracts. |
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

## Design Archive

| Document | Category | Role |
|---|---|---|
| `../_conceitos/mobile-universe/` | `ARQUIVO_DESIGN` | Original concept archive promoted to DraxosMobile on `2026-05-18`. |
| `../_conceitos/mobile-universe/gdd.md` | `ARQUIVO_DESIGN` | Historical complete GDD; context only. |
| `../_conceitos/mobile-universe/pendencias.md` | `ARQUIVO_DESIGN` | Historical decision context; not the live pending register. |

## Drift Rules

- A live doc must not tell agents to start from Track 04, Track 08, Track 10 or Track 14 as the current track.
- Historical docs can keep old language when they are clearly historical.
- Product-facing language should use Instrumento Ritual, Doutrina and Familiar.
- Technical field names such as `weapon`, `passive`, `pet`, `WeaponQualityTier`, `PassiveLevelsTotal` and `PetLevel` may remain only where they describe existing schema, telemetry or legacy compatibility.
- New pending design questions must go to `docs/design-pending.md`, not historical track docs.
