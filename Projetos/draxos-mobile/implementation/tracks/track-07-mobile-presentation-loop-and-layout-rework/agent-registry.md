# Track 07 - Agent Registry

| Track | Agent | Branch | Worktree | Status | Handoff |
|---|---|---|---|---|---|
| T07-A Coordenacao | Codex | `codex/draxos-mobile/t07-coordenacao` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-coordenacao` | `IN_PROGRESS` | Track docs/status/portfolio baseline |
| T07-B App Shell/Foundation | Codex worker | `codex/draxos-mobile/t07-app-shell-foundation` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-app-shell-foundation` | `PLANNED` | Route/orientation/back/scroll foundation |
| T07-C Refugio/Home | Codex worker | `codex/draxos-mobile/t07-refugio-home` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-refugio-home` | `PLANNED` | Full-screen home and account panel |
| T07-D App Screens | Codex worker | `codex/draxos-mobile/t07-app-screens` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-app-screens` | `PLANNED` | Base/Social/Competition/Shop app screens |
| T07-E Battle Fullscreen | Codex worker | `codex/draxos-mobile/t07-battle-fullscreen` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-battle-fullscreen` | `PLANNED` | Full-screen battle and summary |
| T07-F PC/Web + Validation | Codex worker | `codex/draxos-mobile/t07-pc-web-validation` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-pc-web-validation` | `PLANNED` | Mobile presentation smoke and compatibility |
| T07-G Integracao | Codex | `codex/draxos-mobile/t07-integration` | `D:\Estudio-worktrees\draxos-mobile--codex--t07-integration` | `PLANNED` | Integrated validated package |

## Coordination Notes

- Workers are not alone in the codebase; do not revert another agent's edits.
- Branches after T07-B should be based on the integrated T07-B baseline.
- T07-C, T07-D and T07-E may run in parallel after T07-B, but should keep write scopes as separate as possible.
- T07-F starts after C/D/E deliver or after their changes are integrated into a validation branch.
- T07-G owns final conflict resolution and status snapshots.
