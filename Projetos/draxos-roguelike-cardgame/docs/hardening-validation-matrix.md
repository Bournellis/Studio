# Hardening Validation Matrix

- Last Updated: `2026-06-09`
- Status: `VIVO`
- Scope: long-term hardening/refactor gates for Draxos Roguelike Cardgame.

## Purpose

This matrix turns the current lab stack into an operational contract. Before a
refactor or content promotion starts, agents must identify the change type and
run the matching gate set. This document does not approve new content by itself.

## Change Types

| Change type | Allowed intent | Required gates |
|---|---|---|
| Player card or reward card | Manual promotion from Design Lab or focused redesign. | Design Lab gate for prototypes, Card Impact V4.2 before/after/compare, Run Lab smoke/quick, `validate.gd`. |
| Enemy card | Manual promotion from Design Lab or focused redesign. | Design Lab gate for prototypes, Card Impact V5 before/after/compare, Battle Lab gate, Run Lab smoke/quick, `validate.gd`. |
| Battle rules, keyword timing, field effects or boss hooks | Internal refactor with preserved semantics. | `validate.gd`, Battle Lab gate, Scenario Fixtures gate, Card Impact V4.2/V5 when card signatures can move. |
| Battle UI or layout | Presenter/refactor/readability work without rule changes. | `validate.gd`, `test_ui_layout.gd`, screenshot capture for desktop-safe viewports when visual layout changes. |
| Run session, save, rewards, relics or Souls shop | Contract hardening or service extraction. | `validate.gd`, `test_run_rewards_shop_save.gd`, Scenario Fixtures gate and Run Lab smoke/quick. |
| Catalog source or generator split | Data organization with identical generated gameplay. | `validate.gd`, `test_data_contract.gd`, catalog loader equivalence and generated resource idempotency check. |
| Lab/reporting tooling | Report/schema/CLI hardening without gameplay changes. | Relevant lab unit tests, sample gate for the affected lab and `validate.gd`. |
| Visual asset release readiness | Asset fallback classification, not gameplay. | `validate.gd`, visual asset contract tests and explicit release-candidate asset review. |

## Design Lab Promotion Contract

Design Lab remains advisory. A candidate can only become official content after:

1. `promotion_manifest.json` validates structurally.
2. Candidate classification is `recommended` or `viable`.
3. `manual_approval_required` stays `true`.
4. Required validations name Design Lab, Card Impact, Run Lab and `validate.gd`.
5. The official catalog change is applied manually and reviewed as a normal diff.
6. Card Impact and Run Lab pass after the official catalog change.

The manifest validator lives in:

```text
tools/lab/design_lab_promotion_manifest_validator.gd
```

## Refactor Guardrails

- Keep public facades stable until a dedicated migration says otherwise.
- Prefer parity tests before extracting from `BattleEngine`, `BattleRoot` or
  `RunSession`.
- Do not split `data/definitions/slice_catalog.json` before catalog loader
  equivalence is covered.
- Treat WARN from Scenario/Battle/Run Lab as human review data, not an automatic
  tuning instruction.
- Full-run feel playtests happen after promoted content is protected, not before.
