# Track 06 - Agent Registry

All agents must use dedicated worktrees outside `D:\Estudio`.

| Agent | Track | Worktree | Branch | Status | Handoff |
|---|---|---|---|---|---|
| Codex | T06-A Coordenacao | `D:\Estudio-worktrees\draxos-mobile--codex--t06-coordenacao` | `codex/draxos-mobile/t06-coordenacao` | `INTEGRATED_ON_MASTER` | Base docs/status available for B-H |
| Codex worker | T06-B Feature Rails | `D:\Estudio-worktrees\draxos-mobile--codex--t06-feature-rails` | `codex/draxos-mobile/t06-feature-rails` | `INTEGRATED_ON_MASTER` | Feature contract, checklist, surface validation, fallback and rollback integrated |
| Codex worker | T06-C Runtime Config | `D:\Estudio-worktrees\draxos-mobile--codex--t06-runtime-config` | `codex/draxos-mobile/t06-runtime-config` | `INTEGRATED_ON_MASTER` | Release config endpoint/client/smoke integrated |
| Codex worker | T06-D Perfil/Conta | `D:\Estudio-worktrees\draxos-mobile--codex--t06-profile-account` | `codex/draxos-mobile/t06-profile-account` | `INTEGRATED_IN_T06_I` | Profile/account panel validated; no endpoint/schema/Auth change |
| Codex worker | T06-E Battle History | `D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history` | `codex/draxos-mobile/t06-battle-history` | `INTEGRATED_IN_T06_I` | History/replay endpoints and UI validated |
| Codex worker | T06-F Base Routine | `D:\Estudio-worktrees\draxos-mobile--codex--t06-base-routine` | `codex/draxos-mobile/t06-base-routine` | `INTEGRATED_IN_T06_I` | Base routine panel validated with GUT, validate and foundation smoke |
| Codex worker | T06-G Social QoL | `D:\Estudio-worktrees\draxos-mobile--codex--t06-social-qol` | `codex/draxos-mobile/t06-social-qol` | `INTEGRATED_IN_T06_I` | Social readability improvements validated |
| Codex worker | T06-H Asset Pack 01 | `D:\Estudio-worktrees\draxos-mobile--codex--t06-asset-pack-01` | `codex/draxos-mobile/t06-asset-pack-01` | `INTEGRATED_IN_T06_I` | Safe asset pack validated |
| Codex | T06-I Integracao | `D:\Estudio-worktrees\draxos-mobile--codex--t06-integration` | `codex/draxos-mobile/t06-integration` | `COMPLETE_VALIDATED` | Full validation passed; ready to merge to master |

## Coordination Notes

- Agents are not alone in the codebase; do not revert changes from other agents.
- Use disjoint write sets where possible.
- If a schema change seems required, document the blocker and stop for decision.
- If validation fails, record the failing command and do not mark the track complete.
