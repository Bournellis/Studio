# Track 08 - Agent Registry

| Track | Agent | Branch | Worktree | Status | Handoff |
|---|---|---|---|---|---|
| T08-A Coordenacao/Audit | Codex | `codex/draxos-mobile/t08-coordenacao` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-coordenacao` | `COMPLETE` | Track docs, gap report and portfolio baseline |
| T08-B App Shell Lifecycle | Codex worker | `codex/draxos-mobile/t08-app-shell-lifecycle` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-app-shell-lifecycle` | `COMPLETE` | Route/back/orientation contract helper and GUT coverage |
| T08-C Session/Save Boundary | Codex worker | `codex/draxos-mobile/t08-session-save-boundary` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-session-save-boundary` | `PENDING` | Session/save/cache/runtime config invariants |
| T08-D Mobile UI Contract | Codex worker | `codex/draxos-mobile/t08-mobile-ui-contract` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-mobile-ui-contract` | `PENDING` | Touch/scroll/button/layout contract |
| T08-E Battle Mode Contract | Codex worker | `codex/draxos-mobile/t08-battle-mode-contract` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-battle-mode-contract` | `PENDING` | Fullscreen battle mode contract |
| T08-F Service/Asset Contract Checks | Codex worker | `codex/draxos-mobile/t08-service-asset-contracts` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-service-asset-contracts` | `PENDING` | Endpoint/registry/asset contract checks |
| T08-G Validation Harness | Codex | `codex/draxos-mobile/t08-validation-harness` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-validation-harness` | `PENDING` | Foundation hardening smoke |
| T08-H Integracao | Codex | `codex/draxos-mobile/t08-integration` | `D:\Estudio-worktrees\draxos-mobile--codex--t08-integration` | `PENDING` | Integrated validated package |

## Coordination Notes

- Workers are not alone in the codebase; do not revert another agent's edits.
- T08-B, T08-C, T08-D and T08-F can run in parallel after T08-A.
- T08-E starts after T08-B because it depends on the route/orientation contract.
- T08-G starts after B-F have delivered.
- T08-H owns conflict resolution, final validation and status snapshots.
