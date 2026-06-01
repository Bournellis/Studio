# DraxosMobile Foundation Hardening V2 - Worktree Audit

- data: `2026-06-01`
- agente: `Codex`
- pacote: `Foundation Hardening V2 - Expansion Enforcement`
- branch integradora: `codex/draxos-mobile/foundation-hardening-v2`
- worktree integradora: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2`

## Resultado

Worktrees limpas e ja integradas ao `master` foram removidas via `git worktree remove`.

## Worktrees V2 Ativas

| Branch | Worktree |
|---|---|
| `codex/draxos-mobile/foundation-hardening-v2` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2` |
| `codex/draxos-mobile/foundation-hardening-v2-coord-canon-docs` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-coord-canon-docs` |
| `codex/draxos-mobile/foundation-hardening-v2-backend-mode-enforcement` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-backend-mode-enforcement` |
| `codex/draxos-mobile/foundation-hardening-v2-client-session-enforcement` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-client-session-enforcement` |
| `codex/draxos-mobile/foundation-hardening-v2-validation-security-gates` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-validation-security-gates` |
| `codex/draxos-mobile/foundation-hardening-v2-data-labs-mode-decisions` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-data-labs-mode-decisions` |
| `codex/draxos-mobile/foundation-hardening-v2-release-ops-keystore` | `D:\Estudio-worktrees\draxos-mobile--codex--foundation-hardening-v2-release-ops-keystore` |

## Worktrees Antigas Preservadas

| Classificacao | Branch | Motivo |
|---|---|---|
| `handoff-needed` | `codex/draxos-mobile/arena-backend` | Worktree antiga com estado nao limpo; preservar ate revisao/handoff explicito. |
| `handoff-needed` | `codex/draxos-mobile/arena-client-labs` | Worktree antiga com estado nao limpo; preservar ate revisao/handoff explicito. |
| `stale-clean` | `codex/draxos-mobile/pve-arena-direction` | Branch limpa, mas nao aparece como integrada ao `master`; preservar para revisao historica. |
| `stale-clean` | `codex/draxos-mobile/rpgsuave-doc` | Branch limpa, mas nao aparece como integrada ao `master`; preservar para revisao historica. |

## Nota Operacional

Uma tentativa de remocao da worktree `foundation-expansion-readiness` reportou `Permission denied`, mas o checkout nao permaneceu registrado em `git worktree list` apos `git worktree prune`. Se restar diretorio fisico fora do registro Git, tratar como limpeza manual futura, nao como lane ativa.
