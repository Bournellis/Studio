# DraxosMobile — Documentation Index

## Metadata

- status: `living`
- authority: `router`
- last_verified: `2026-07-17`
- review_when: `a live authority, contract or historical route changes`
- supersedes: `history/documentation-index-pre-governance-v2-2026-07-16.md`
- superseded_by: `none`

## Authority map

| Need | Authority |
|---|---|
| portfolio status and allowed work | `../../../08_Coordenacao_Agentes/Prioridades_Estudio.md` |
| local technical state | `../implementation/current-status.md` |
| local workflow | `../08_Coordenacao/README.md` |
| QA commands and gates | `../qa/qa_manifest.json`, `../qa/QA_INDEX.md` |
| validation profile detail | `../qa/validation-matrix.md` |
| package lineage | `release-history.md` |
| product canon | `product-vision.md` |
| Arena PVE direction and contract | `pve-arena-initial-direction.md`, `pve-arena-v1.md` |
| pending product decisions | `design-pending.md` |

Workspace-relative package lineage: `Projetos/draxos-mobile/docs/release-history.md`.

## Live contracts

- Agent/runbook: `agent-operating-manual.md`, `multi-agent-workflow.md`, `hardening-program.md`.
- Product: `product-brief.md`, `game-design-document.md`, `arena-pve-product-proof.md`, `visual-direction-v1.md`.
- Foundation: `foundation-responsive-layout-contract.md`, `foundation-expansion-readiness.md`, `behavior-potion-crafting-v1.md`, `contracts/feature-registry.md`.
- Backend: `contracts/`, `architecture.md`, `backend-own-boundary.md`.
- Modes: `minigames/`, `data/definitions/modes/` and `data/definitions/openworld/`.
- Labs: `progression-lab/README.md`, `battle-lab/README.md`, `dev-lab-workflow.md`.
- Release: `contracts/release-safety.md`, `release-ops-checklist.md`, `internal-alpha-static-hosting.md`, `track-13-manual-walkthrough-gate.md`.

## Historical records

- Closed package reports (`internal-alpha-v0-*`, battle/progression delivery docs) are historical evidence, not competing release authorities.
- `internal-alpha-release-plan.md` and `internal-alpha-remote-setup.md` are closed history; current procedures use `release-ops-checklist.md`.
- `implementation/tracks/` preserves delivery history. In particular, `track-18-pve-arena-initial/` is Arena PVE implementation history and `track-21-arena-loop-unlock-friction/` is preserved loop context.
- The pre-cutover status and full index are preserved in `../implementation/tracks/governance-v2-pre-cutover-status-2026-07-16.md` and `history/documentation-index-pre-governance-v2-2026-07-16.md`.
- `_conceitos/mobile-universe/` is a read-only design archive and never overrides local live contracts.

## Classification rule

Live product/technical contracts may be updated only with their implementation. Runbooks describe repeatable procedure. Historical records may receive link or metadata repair but cannot become current state. New package facts go only to `release-history.md`; new unresolved choices go only to `design-pending.md`.
